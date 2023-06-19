package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.cloud.storage.*;
import com.google.cloud.storage.Blob;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;

import javax.imageio.ImageIO;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.core.Response;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.Collections;
import java.util.logging.Logger;

public class CoverPicServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(ProfilePicServlet.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final Storage storage = StorageOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");
    private final String bucketName = "staging.fct-connect-estudasses.appspot.com";

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response){

        Transaction txn = datastore.newTransaction();

        try{

            String tokenId = request.getHeader("Authorization");
            String updater = request.getHeader("User");
            String username = request.getPathInfo().substring(1);


            Key updaterKey = userKeyFactory.newKey(updater);

            Entity updaterEntity = txn.get(updaterKey);

            if (updaterEntity == null) {
                LOG.warning("User does not exist: " + updater);
                response.setStatus(Response.Status.NOT_FOUND.getStatusCode());
                return;
            }
            if (updaterEntity.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                response.setStatus(Response.Status.UNAUTHORIZED.getStatusCode());
                return;
            }

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", updater))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token == null || !token.getString("token_id").equals(DigestUtils.sha512Hex(tokenId))) {
                LOG.warning("Incorrect token. Please re-login");
                response.setStatus(Response.Status.UNAUTHORIZED.getStatusCode());
                return;
            }
            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                response.setStatus(Response.Status.UNAUTHORIZED.getStatusCode());
                return;
            }

            Key userKey = userKeyFactory.newKey(username);
            Entity user = txn.get(userKey);

            if (user == null) {
                LOG.warning("User does not exist: " + username);
                response.setStatus(Response.Status.NOT_FOUND.getStatusCode());
                return;
            }

            if ( request.getPart("image") == null) {
                LOG.warning("No profile picture sent.");
                response.setStatus(Response.Status.BAD_REQUEST.getStatusCode());
                return;
            }

            String imageNameFull = request.getPart("image").getSubmittedFileName();
            String imageName = imageNameFull.substring(0, imageNameFull.lastIndexOf('.'));
            InputStream imageStream = request.getPart("image").getInputStream();


            BufferedImage originalImage = ImageIO.read(imageStream);

            int thumbnailWidth =  820;
            int thumbnailHeight = 312;

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

            Entity task = Entity.newBuilder(user)
                    .set("user_username", user.getString("user_username"))
                    .set("user_fullname", user.getString("user_fullname"))
                    .set("user_pwd", user.getString("user_pwd"))
                    .set("user_email", user.getString("user_email"))
                    .set("user_creation_time", user.getTimestamp("user_creation_time"))
                    .set("user_role", user.getString("user_role"))
                    .set("user_state", user.getString("user_state"))
                    .set("user_privacy", user.getString("user_privacy"))
                    .set("user_phone", user.getString("user_phone"))
                    .set("user_city", user.getString("user_city"))
                    .set("user_about_me", user.getString("user_about_me"))
                    .set("user_department", user.getString("user_department"))
                    .set("user_office", user.getString("user_office"))
                    .set("user_course", user.getString("user_course"))
                    .set("user_year", user.getString("user_year"))
                    .set("user_profile_pic", user.getString("user_profile_pic"))
                    .set("user_cover_pic", StringValue.newBuilder(imageName).setExcludeFromIndexes(true).build())
                    .set("user_purpose", user.getString("user_purpose"))
                    .build();

            txn.update(task);
            txn.commit();

            response.setStatus(Response.Status.OK.getStatusCode());

        }catch (Exception e){
            txn.rollback();
            LOG.severe(e.getMessage());
            response.setStatus(Response.Status.INTERNAL_SERVER_ERROR.getStatusCode());
        }finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }

    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response){

        try{
            String username = request.getPathInfo().substring(1);

            Key userKey = userKeyFactory.newKey(username);
            Entity user = datastore.get(userKey);

            if (user == null) {
                LOG.warning("User does not exist: " + username);
                response.setStatus(Response.Status.NOT_FOUND.getStatusCode());
                return;
            }

            String imageName = user.getString("user_profile_pic");
            BlobId blobId;

            if(imageName.equals(""))
                blobId = BlobId.of(bucketName, "foto-fct.jpg");
            else
                blobId = BlobId.of(bucketName, username + "-" + imageName);

            Blob blob = storage.get(blobId);

            if (blob == null) {
                LOG.warning("User does not have a profile picture.");
                response.setStatus(Response.Status.NOT_FOUND.getStatusCode());
                return;
            }

            String url = blob.getMediaLink();

            response.setContentType("text/html");
            response.getOutputStream().write(url.getBytes());
            response.setStatus(Response.Status.OK.getStatusCode());

        }catch (Exception e){
            LOG.severe(e.getMessage());
            response.setStatus(Response.Status.INTERNAL_SERVER_ERROR.getStatusCode());
        }

    }

}
