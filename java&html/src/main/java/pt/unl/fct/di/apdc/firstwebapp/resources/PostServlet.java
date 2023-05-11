package main.java.pt.unl.fct.di.apdc.firstwebapp.resources;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.cloud.Timestamp;
import com.google.cloud.datastore.*;
import com.google.cloud.storage.*;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Collections;
import java.util.Map;
import java.util.logging.Logger;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import main.java.pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import main.java.pt.unl.fct.di.apdc.firstwebapp.util.PostData;
import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.io.IOUtils;

@MultipartConfig
public class PostServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(LoginResource.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final Storage storage = StorageOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");
    private final String bucketName = "staging.fct-connect-2023.appspot.com";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        Transaction txn = datastore.newTransaction();

        try{

            String jsonPart = IOUtils.toString(request.getPart("post").getInputStream(), StandardCharsets.UTF_8);
            ObjectMapper mapper = new ObjectMapper();
            PostData data = mapper.readValue(jsonPart, PostData.class);

            String tokenId = request.getHeader("Authorization");
            String postText = data.getPost();
            String username = data.getUsername();
            Timestamp timestamp = Timestamp.now();

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
                BlobId blobId = BlobId.of(bucketName, imageName + username);

                BlobInfo blobInfo = BlobInfo.newBuilder(blobId).setAcl(Collections.singletonList(
                                                Acl.newBuilder(Acl.User.ofAllUsers(), Acl.Role.READER).build())).build();

                byte[] imageBytes = IOUtils.toByteArray(imageStream);

                storage.create(blobInfo, imageBytes);
            }

            Key postKey = datastore.newKeyFactory()
                                .setKind("Post")
                                .addAncestor(PathElement.of("User", username))
                                .newKey(username + "-" + timestamp);

            Entity entity = Entity.newBuilder(postKey)
                    .set("text", postText)
                    .set("user", username)
                    .set("timestamp", timestamp)
                    .set("image", imageName)
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
            String username = request.getParameter("username");
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