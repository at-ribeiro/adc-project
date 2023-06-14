package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.cloud.datastore.*;
import com.google.cloud.storage.*;
import com.google.cloud.storage.Blob;
import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.io.IOUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.NewsGetData;
import pt.unl.fct.di.apdc.firstwebapp.util.NewsPostData;

import javax.servlet.http.*;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.logging.Logger;

public class NewsServlet extends HttpServlet {
    private static final Logger LOG = Logger.getLogger(NewsServlet.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final Storage storage = StorageOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");
    private final String bucketName = "staging.fct-connect-estudasses.appspot.com";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        Transaction txn = datastore.newTransaction();

        try {
            String tokenId = request.getHeader("Authorization");
            String username = request.getParameter("username");

            LOG.fine("Attempt get news");

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

            StructuredQuery.OrderBy descendingTimestamp = StructuredQuery.OrderBy.desc("timestamp");

            Query<Entity> newsQuery = Query.newEntityQueryBuilder()
                    .setKind("News")
                    .addOrderBy(descendingTimestamp)
                    .build();

            QueryResults<Entity> newsResults = txn.run(newsQuery);

            List<NewsGetData> newsList = new ArrayList<>();


            newsResults.forEachRemaining(news -> {
                String url = "";

                if (!news.getString("img").equals("")) {

                    BlobId blobId = BlobId.of(bucketName, news.getString("img"));
                    Blob blob = storage.get(blobId);
                    url = blob.getMediaLink();
                }

                NewsGetData newsInstance = new NewsGetData(
                        news.getString("title"),
                        news.getString("text"),
                        url,
                        Long.toString(news.getLong("timestamp"))
                );

                newsList.add(newsInstance);
            } );

            if(newsList.isEmpty()){
                LOG.info("news: " + newsList.toString());
                response.setStatus(HttpServletResponse.SC_PRECONDITION_FAILED);
                return;
            }

            // Convert the list of posts to JSON
            ObjectMapper objectMapper = new ObjectMapper();
            String json = objectMapper.writeValueAsString(newsList);

            // Set the response content type and write the JSON string to the output stream
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(json);
            response.setStatus(HttpServletResponse.SC_OK);

        } catch (Exception e) {
            txn.rollback();
            LOG.severe(e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }

        @Override
        protected void doPost (HttpServletRequest request, HttpServletResponse response) {

            Transaction txn = datastore.newTransaction();

            try{

                String jsonPart = IOUtils.toString(request.getPart("news").getInputStream(), StandardCharsets.UTF_8);
                ObjectMapper mapper = new ObjectMapper();

                // Remove outermost quotes if they exist
                if (jsonPart.startsWith("\"") && jsonPart.endsWith("\"")) {
                    jsonPart = jsonPart.substring(1, jsonPart.length() - 1);
                    // Replace escaped inner quotes
                    jsonPart = jsonPart.replace("\\\"", "\"");
                }

                NewsPostData data = mapper.readValue(jsonPart, NewsPostData.class);

                String tokenId = request.getHeader("Authorization");
                String username = request.getParameter("username");
                String newsTitle = data.getTitle();
                String newsText = data.getText();
                long timestamp = System.currentTimeMillis();

                LOG.fine("Attempt to create news from user " + username);

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

                //TODO:Check user's role

                Key tokenKey = datastore.newKeyFactory()
                        .setKind("Token")
                        .addAncestor(PathElement.of("User", username))
                        .newKey("token");

                Entity token = txn.get(tokenKey);

                if (token == null || !token.getString("token_id").equals(DigestUtils.sha512Hex(tokenId))) {
                    LOG.warning("Incorrect token. Please re-login");
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                if (AuthToken.expired(token.getLong("token_expiration"))) {
                    LOG.warning("Your token has expired. Please re-login.");
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }

                //actual start

                InputStream imageStream = null;

                if (request.getPart("image") != null) {
                    imageStream = request.getPart("image").getInputStream();
                }

                String imageName = "";

                if (imageStream != null) {

                    imageName = request.getPart("image").getSubmittedFileName();
                    BlobId blobId = BlobId.of(bucketName,  timestamp + "-" + imageName);

                    if(storage.get(blobId)==null){
                        response.setStatus(HttpServletResponse.SC_CONFLICT);
                        return;
                    }

                    BlobInfo blobInfo = BlobInfo.newBuilder(blobId).setAcl(Collections.singletonList(
                            Acl.newBuilder(Acl.User.ofAllUsers(), Acl.Role.READER).build())).build();

                    byte[] imageBytes = IOUtils.toByteArray(imageStream);


                    storage.create(blobInfo, imageBytes);
                }

                Key newsKey = datastore.newKeyFactory()
                        .setKind("News")
                        .newKey(timestamp);

                Entity entity = Entity.newBuilder(newsKey)
                        .set("title", newsTitle)
                        .set("text", StringValue.newBuilder(newsText).setExcludeFromIndexes(true).build())
                        .set("timestamp", timestamp)
                        .set("image", timestamp + "-" + imageName)
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
}
