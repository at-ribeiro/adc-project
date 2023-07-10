package pt.unl.fct.di.apdc.fctconnect.resources;

import com.google.cloud.datastore.*;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;

import javax.ws.rs.Consumes;
import javax.ws.rs.HeaderParam;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.messaging.Notification;
import com.google.firebase.messaging.TopicManagementResponse;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.fctconnect.servlets.EventsServlet;
import pt.unl.fct.di.apdc.fctconnect.util.Token.AuthToken;
import pt.unl.fct.di.apdc.fctconnect.util.Notification.NotificationData;

import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;
import java.util.List;
import java.util.logging.Logger;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;



@Path("/notification")
public class NotificationResource {


    private static final Logger LOG = Logger.getLogger(EventsServlet.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");

    @POST
    @Path("/anomaly")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response anomalyNotification(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username,
                                        NotificationData data) {

        Transaction txn = datastore.newTransaction();

        try{

            Key userKey = userKeyFactory.newKey(username);

            Entity user = txn.get(userKey);

            if (user == null) {
                LOG.warning("User doesn't exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            if (user.getString("user_state").equals("INACTIVE")) {
                LOG.warning("Inactive User.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", username))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token == null || !token.getString("token_hashed_id").equals(DigestUtils.sha512Hex(tokenId))) {
                LOG.warning("Incorrect token. Please re-login");
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            if(!(user.getString("user_role").equals("SECRETARIA") || user.getString("user_role").equals("SA"))){
                LOG.warning("User does not have sufficient role");
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            if(data.getTitle() == null || data.getMessage() == null ||
               data.getTitle().equals("") || data.getMessage().equals("")){
                LOG.warning("Missing data");
                return Response.status(Response.Status.BAD_REQUEST).build();
            }

            if(FirebaseApp.getApps().isEmpty()) {

                URL url = new URL("https://storage.googleapis.com/staging.fct-connect-estudasses.appspot.com/firebase.json");
                URLConnection connection = url.openConnection();
                InputStream serviceAccount = connection.getInputStream();

                FirebaseOptions options = new FirebaseOptions.Builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                        .build();

                FirebaseApp.initializeApp(options);
            }

            Message message = Message.builder()
                    .setNotification(Notification.builder().setTitle(data.getTitle()).setBody(data.getMessage()).build())
                    .setTopic("all_users")
                    .build();

            String response = FirebaseMessaging.getInstance().send(message);

            if(response.equals("")){
                LOG.severe("Error sending notification");
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
            }

            return Response.ok().build();

        } catch (Exception e) {
            LOG.warning(e.getMessage());
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }finally {
            if(txn.isActive()){
                txn.rollback();
            }
        }
    }

    @POST
    @Path("/msgToken")
    public Response registerToken(@HeaderParam("Token") String tokenId){

        try{

            List<String> registrationTokens = List.of(tokenId);

            if(FirebaseApp.getApps().isEmpty()) {

                URL url = new URL("https://storage.googleapis.com/staging.fct-connect-estudasses.appspot.com/firebase.json");
                URLConnection connection = url.openConnection();
                InputStream serviceAccount = connection.getInputStream();

                FirebaseOptions options = new FirebaseOptions.Builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                        .build();

                FirebaseApp.initializeApp(options);
            }

            TopicManagementResponse response = FirebaseMessaging.getInstance().subscribeToTopic(
                    registrationTokens, "all_users");

            if(response.getSuccessCount() == 0){
                LOG.severe("Error subscribing to topic");
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
            }

            return Response.ok().build();

        }catch (Exception e){
            LOG.warning(e.getMessage());
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }

    }

}