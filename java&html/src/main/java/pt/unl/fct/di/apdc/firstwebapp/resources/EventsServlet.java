package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.cloud.datastore.*;
import com.google.cloud.storage.*;
import com.google.cloud.storage.Blob;
import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.io.IOUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.EventPostData;
import pt.unl.fct.di.apdc.firstwebapp.util.NewsPostData;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.logging.Logger;

public class EventsServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(EventsServlet.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final Storage storage = StorageOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");
    private final String bucketName = "staging.fct-connect-2023.appspot.com";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {

        Transaction txn = datastore.newTransaction();

        try{

        }catch (Exception e) {
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
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        Transaction txn = datastore.newTransaction();

        try{

            String jsonPart = IOUtils.toString(request.getPart("event").getInputStream(), StandardCharsets.UTF_8);
            ObjectMapper mapper = new ObjectMapper();

            if (jsonPart.startsWith("\"") && jsonPart.endsWith("\"")) {
                jsonPart = jsonPart.substring(1, jsonPart.length() - 1);
                // Replace escaped inner quotes
                jsonPart = jsonPart.replace("\\\"", "\"");
            }

            EventPostData data = mapper.readValue(jsonPart, EventPostData.class);

            String tokenId = request.getHeader("Authorization");
            String username = request.getParameter("username");
            String title = data.getTitle();
            String creator = data.getCreator();
            String description = data.getDescription();
            long start = data.getStart();
            long end = data.getEnd();

            LOG.fine("Attempt to create event with user " + username);

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

            InputStream imageStream = null;

            if (request.getPart("image") != null) {
                imageStream = request.getPart("image").getInputStream();
            }

            String imageName = "";

            if (imageStream != null) {

                imageName = request.getPart("image").getSubmittedFileName();
                BlobId blobId = BlobId.of(bucketName,  title + "-" + imageName);

                if(storage.get(blobId)==null){
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    return;
                }

                BlobInfo blobInfo = BlobInfo.newBuilder(blobId).setAcl(Collections.singletonList(
                        Acl.newBuilder(Acl.User.ofAllUsers(), Acl.Role.READER).build())).build();

                byte[] imageBytes = IOUtils.toByteArray(imageStream);

                storage.create(blobInfo, imageBytes);
            }

            Key eventKey = datastore.newKeyFactory()
                    .setKind("Event")
                    .newKey(title);

            Entity entity = Entity.newBuilder(eventKey)
                    .set("event_title", title)
                    .set("event_creator", creator)
                    .set("event_description", StringValue.newBuilder(description).setExcludeFromIndexes(true).build())
                    .set("event_start", start)
                    .set("event_end", end)
                    .set("event_image", title + "-" + imageName)
                    .build();

            txn.put(entity);
            txn.commit();

            response.setStatus(HttpServletResponse.SC_OK);

        }catch (Exception e) {
            txn.rollback();
            LOG.severe(e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }
}
