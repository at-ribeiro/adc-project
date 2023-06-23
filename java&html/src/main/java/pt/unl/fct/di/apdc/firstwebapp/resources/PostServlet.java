package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.cloud.datastore.*;
import com.google.cloud.storage.*;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.logging.Logger;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.cloud.storage.Blob;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.FeedData;
import pt.unl.fct.di.apdc.firstwebapp.util.PostData;
import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.io.IOUtils;

import java.awt.Dimension;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import java.io.ByteArrayOutputStream;


@MultipartConfig
public class PostServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(PostServlet.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final Storage storage = StorageOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");
    private final String bucketName = "staging.fct-connect-estudasses.appspot.com";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        Transaction txn = datastore.newTransaction();

        try{

            String jsonPart = IOUtils.toString(request.getPart("post").getInputStream(), StandardCharsets.UTF_8);
            ObjectMapper mapper = new ObjectMapper();

            // Remove outermost quotes if they exist
            if (jsonPart.startsWith("\"") && jsonPart.endsWith("\"")) {
                jsonPart = jsonPart.substring(1, jsonPart.length() - 1);
                // Replace escaped inner quotes
                jsonPart = jsonPart.replace("\\\"", "\"");
            }

            PostData data = mapper.readValue(jsonPart, PostData.class);

            String tokenId = request.getHeader("Authorization");
            String postText = data.getPost();
            String username = data.getUsername();
            long timestamp = System.currentTimeMillis();

            LOG.fine("Attempt to create post for user " + username);

            //verifications

            Key userKey = userKeyFactory.newKey(username);
            Entity user = txn.get(userKey);
            if (user == null){
                LOG.warning("User does not exist.");
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            if (user.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", username))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token == null || !token.getString("token_hashed_id").equals(DigestUtils.sha512Hex(tokenId))) {
                LOG.warning("Incorrect token. Please re-login");
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            String imageName = "";

            if (request.getPart("image") != null) {
                String imageNameJPG = request.getPart("image").getSubmittedFileName();
                imageName = imageNameJPG.substring(0, imageNameJPG.lastIndexOf("."));
                InputStream imageStream = request.getPart("image").getInputStream();

                // Read the original image
                BufferedImage originalImage = ImageIO.read(imageStream);

                int thumbnailWidth;
                int thumbnailHeight;


                //Check image size and set thumbnail size accordingly
                if(originalImage.getWidth() > originalImage.getHeight()){
                    thumbnailWidth = 1350;
                    thumbnailHeight = 1080;
                }else if(originalImage.getWidth() < originalImage.getHeight()){
                    thumbnailWidth = 1080;
                    thumbnailHeight = 1350;
                }else{
                    thumbnailWidth = 1080;
                    thumbnailHeight = 1080;
                }

                // Create a thumbnail image using the original image
                BufferedImage resizedImage = new BufferedImage(thumbnailWidth, thumbnailHeight, BufferedImage.TYPE_INT_RGB);
                resizedImage.getGraphics().drawImage(originalImage.getScaledInstance(thumbnailWidth, thumbnailHeight, java.awt.Image.SCALE_SMOOTH), 0, 0, null);

                // Save the thumbnail image to a byte array
                ByteArrayOutputStream thumbnailOutputStream = new ByteArrayOutputStream();
                ImageIO.write(resizedImage, "jpg", thumbnailOutputStream);
                byte[] thumbnailBytes = thumbnailOutputStream.toByteArray();

                // Upload the thumbnail image to your storage service (similar to the original image)
                BlobId thumbnailBlobId = BlobId.of(bucketName, username + "-" + imageName);
                BlobInfo thumbnailBlobInfo = BlobInfo.newBuilder(thumbnailBlobId)
                        .setAcl(Collections.singletonList(Acl.newBuilder(Acl.User.ofAllUsers(), Acl.Role.READER).build()))
                        .build();
                storage.create(thumbnailBlobInfo, thumbnailBytes);

                // Close the thumbnail output stream
                thumbnailOutputStream.close();
            }

            Key postKey = datastore.newKeyFactory()
                                .setKind("Post")
                                .addAncestor(PathElement.of("User", username))
                                .newKey(username + "-" + timestamp);

            List<Value<Key>> likeList = new ArrayList<>();


            Entity entity = Entity.newBuilder(postKey)
                    .set("id", username + "-" + timestamp)
                    .set("text", StringValue.newBuilder(postText).setExcludeFromIndexes(true).build())
                    .set("user", username)
                    .set("timestamp", timestamp)
                    .set("image", imageName)
                    .set("likes", likeList)
                    .build();

            txn.put(entity);
            txn.commit();

            response.setStatus(HttpServletResponse.SC_OK);

        }catch (Exception e) {
            txn.rollback();
            LOG.severe(e.getMessage());
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response){
        Transaction txn = datastore.newTransaction();

        try{
            String tokenId = request.getHeader("Authorization");
            String searcher = request.getHeader("User");
            String username = request.getPathInfo().substring(1);
            String timestamp = request.getParameter("timestamp");

            LOG.fine("Attempt to get posts from user " + username);

            //verifications

            Key userKey = userKeyFactory.newKey(username);
            Entity user = txn.get(userKey);
            if (user == null){
                LOG.warning("User does not exist.");
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            if (user.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", searcher))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token == null || !token.getString("token_hashed_id").equals(DigestUtils.sha512Hex(tokenId))) {
                LOG.warning("Incorrect token. Please re-login");
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            StructuredQuery.OrderBy descendingOrder = StructuredQuery.OrderBy.desc("timestamp");
            Query<Entity> postQuery = Query.newEntityQueryBuilder()
                    .setKind("Post")
                    .setFilter(
                            StructuredQuery.CompositeFilter.and(
                                    StructuredQuery.PropertyFilter.eq("user", username),
                                    StructuredQuery.PropertyFilter.lt("timestamp", Long.parseLong(timestamp))
                            )
                    )
                    .addOrderBy(descendingOrder)
                    .setLimit(20)
                    .build();

            QueryResults<Entity> postResults = txn.run(postQuery);

            List<FeedData> posts = new ArrayList<>();
            postResults.forEachRemaining(post->{

                        String url = "";

                        if(!post.getString("image").equals("")){

                            BlobId blobId = BlobId.of( bucketName,
                                    post.getString("user") + "-" + post.getString("image"));
                            Blob blob = storage.get(blobId);
                            url = blob.getMediaLink();

                        }

                        List<String> likes = new ArrayList<>();

                        for(Value<?> value : post.getList("likes")){
                            Key likedKey = (Key) value.get();
                            Entity likedEntity = txn.get(likedKey);
                            likes.add(likedEntity.getString("user_username"));
                        }

                        FeedData feedPost = new FeedData(
                                post.getString("id"),
                                post.getString("text"),
                                post.getString("user"),
                                url,
                                post.getString("id").split("-")[1],
                                likes
                        );

                        posts.add(feedPost);

                    }
            );

            if(posts.isEmpty()){
                response.setStatus(HttpServletResponse.SC_PRECONDITION_FAILED);
                return;
            }

            // Convert the list of posts to JSON
            ObjectMapper objectMapper = new ObjectMapper();
            String json = objectMapper.writeValueAsString(posts);

            // Set the response content type and write the JSON string to the output stream
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(json);
            response.setStatus(HttpServletResponse.SC_OK);

        }catch (Exception e) {
            txn.rollback();
            LOG.severe(e.getMessage());
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response){
        Transaction txn = datastore.newTransaction();

        try {
            String tokenId = request.getHeader("Authorization");
            String deleter = request.getHeader("User");
            String username = request.getPathInfo().substring(1);
            String id = request.getParameter("id");

            Key userKey = userKeyFactory.newKey(username);
            Entity user = txn.get(userKey);
            if (user == null){
                LOG.warning("User does not exist.");
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            if (user.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", deleter))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token == null || !token.getString("token_hashed_id").equals(DigestUtils.sha512Hex(tokenId))) {
                LOG.warning("Incorrect token. Please re-login");
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            Key postKey = datastore.newKeyFactory()
                    .setKind("Post")
                    .addAncestor(PathElement.of("User", username))
                    .newKey(id);

            Entity post = txn.get(postKey);

            if(post == null){
                LOG.warning("Post "+ id +" from user " + username + " does not exist");
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            if(!enoughRole(deleter, username)){
                LOG.warning("You don't have permission to delete this post");
                response.setStatus(HttpServletResponse.SC_PRECONDITION_FAILED);
                return;
            }

            String imageName = post.getString("image");

            if(!imageName.equals("")){
                BlobId blobId = BlobId.of(bucketName,  username + "-" + imageName);
                Blob blob = storage.get(blobId);
                blob.delete();
            }

            txn.delete(postKey);
            txn.commit();
            response.setStatus(HttpServletResponse.SC_OK);

        }catch (Exception e) {
            txn.rollback();
            e.printStackTrace();
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }

    private boolean enoughRole(String deleter, String username) {
        //TODO: completar quando backoffice for implementado
        return deleter.equals(username);
    }
}