
package pt.unl.fct.di.apdc.firstwebapp.resources;


import com.google.api.client.auth.oauth2.Credential;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleClientSecrets;
import com.google.api.client.http.HttpRequestInitializer;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.services.gmail.GmailScopes;
import com.google.auth.http.HttpCredentialsAdapter;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.Timestamp;
import com.google.cloud.datastore.*;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.RegisterData;
import pt.unl.fct.di.apdc.firstwebapp.util.VerificationToken;

import com.google.api.client.extensions.java6.auth.oauth2.AuthorizationCodeInstalledApp;
import com.google.api.client.extensions.jetty.auth.oauth2.LocalServerReceiver;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.googleapis.json.GoogleJsonError;
import com.google.api.client.googleapis.json.GoogleJsonResponseException;
import com.google.api.client.util.store.FileDataStoreFactory;
import com.google.api.services.gmail.Gmail;
import com.google.api.services.gmail.model.Message;
import org.apache.commons.codec.binary.Base64;

import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.file.Paths;
import java.util.*;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.logging.Logger;

import static com.google.api.services.gmail.GmailScopes.GMAIL_SEND;
import static javax.mail.Message.RecipientType.TO;

@Path("/register")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class RegisterResource {

    private static final Logger LOG = Logger.getLogger(RegisterResource.class.getName());
    private static final String PATH_TO_JSON = "C:/Users/geekg/Desktop/ADC/FCT CONNECT/adc-project/java&html/src/main/java/pt/unl/fct/di/apdc/firstwebapp/resources/client_secret.json";

    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    private final String TEST_EMAIL = "fctconnect2023@gmail.com";

    @POST
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response register(RegisterData data) {
        LOG.fine("Attempt to register user: " + data.getUsername());

        if (!data.validRegistration()) {
            return Response.status(Response.Status.BAD_REQUEST).entity("Missing or Wrong parameter.").build();
        }

        Transaction txn = datastore.newTransaction();
        try {
            Key userKey = datastore.newKeyFactory().setKind("User").newKey(data.getUsername());
            Entity user = txn.get(userKey);

            if (user != null) {
                txn.rollback();
                return Response.status(Response.Status.CONFLICT).entity("User already exists.").build();
            }

            Query<Entity> query = Query.newEntityQueryBuilder().setKind("User").setFilter(
                    StructuredQuery.PropertyFilter.eq("user_email", data.getEmail())
            ).build();
            QueryResults<Entity> users = datastore.run(query);

            List<Entity> userList = new ArrayList<>();

            users.forEachRemaining(userQ -> {
                userList.add(userQ);
            });

            if (!userList.isEmpty()) {
                txn.rollback();
                return Response.status(Response.Status.CONFLICT).entity("Email already in use.").build();
            }

            user = Entity.newBuilder(userKey)
                    .set("user_username", data.getUsername())
                    .set("user_fullname", data.getFullname())
                    .set("user_pwd", DigestUtils.sha512Hex(data.getPassword()))
                    .set("user_email", data.getEmail())
                    .set("user_creation_time", Timestamp.now())
                    .set("user_role", data.getRole())
                    .set("user_state", "INACTIVE")
                    .set("user_privacy", data.getPrivacy())
                    .set("user_homephone", "")
                    .set("user_mobilephone", "")
                    .set("user_occupation", "")
                    .set("user_address", "")
                    .set("user_nif", "")
                    .build();

            txn.add(user);

            LOG.info("User registered" + data.getUsername());

            String tokenId = UUID.randomUUID().toString();
            VerificationToken tokenData = new VerificationToken(tokenId, data.getUsername());

            Key verKey = datastore.newKeyFactory()
                    .setKind("Verification")
                    .addAncestor(PathElement.of("User", data.getUsername()))
                    .newKey(DigestUtils.sha512Hex(tokenId));

            Entity token = Entity.newBuilder(verKey)
                    .set("token_id", DigestUtils.sha512Hex(tokenId))
                    .set("token_user", data.getUsername())
                    .build();

            txn.add(token);
            txn.commit();


            sendEmailVerification(tokenId, data.getUsername());

            return Response.ok(tokenData).header("Access-Control-Allow_Origin", "*").build();

        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }

    private static Credential getCredentials(final NetHttpTransport httpTransport, GsonFactory jsonFactory)
            throws IOException {

        InputStreamReader inputStream = new InputStreamReader(RegisterResource.class.getResourceAsStream("/client_secret.json"));

        System.out.println(inputStream.toString());

        GoogleClientSecrets clientSecrets = GoogleClientSecrets.load(jsonFactory, inputStream);

        GoogleAuthorizationCodeFlow flow = new GoogleAuthorizationCodeFlow.Builder(
                httpTransport, jsonFactory, clientSecrets, Set.of(GMAIL_SEND))
                .setDataStoreFactory(new FileDataStoreFactory(Paths.get("tokens").toFile()))
                .setAccessType("offline")
        public static Message sendEmail (String fromEmailAddress,
                String toEmailAddress)
            throws MessagingException, IOException {
        /* Load pre-authorized user credentials from the environment.
           TODO(developer) - See https://developers.google.com/identity for
            guides on implementing OAuth2 for your application.*/
            GoogleCredentials credentials = GoogleCredentials.getApplicationDefault()
                    .createScoped(GmailScopes.GMAIL_SEND);
            HttpRequestInitializer requestInitializer = new HttpCredentialsAdapter(credentials);

            // Create the gmail API client
            Gmail service = new Gmail.Builder(new NetHttpTransport(),
                    GsonFactory.getDefaultInstance(),
                    requestInitializer)
                    .setApplicationName("Gmail samples")
                    .build();

            LocalServerReceiver receiver = new LocalServerReceiver.Builder().setPort(8888).build();
            return new AuthorizationCodeInstalledApp(flow, receiver).authorize("user");
        }
        // Create the email content
        String messageSubject = "noreply - Verify your FCT Connect email";
        String bodyText = "lorem ipsum.";

        public void sendMail (String subject, String message) throws Exception {
            // Encode as MIME message
            Properties props = new Properties();
            Session session = Session.getDefaultInstance(props, null);
            MimeMessage email = new MimeMessage(session);
            email.setFrom(new InternetAddress(TEST_EMAIL));
            email.addRecipient(TO, new InternetAddress(TEST_EMAIL));
            email.setSubject(subject);
            email.setText(message);
            email.setFrom(new InternetAddress(fromEmailAddress));
            email.addRecipient(javax.mail.Message.RecipientType.TO,
                    new InternetAddress(toEmailAddress));
            email.setSubject(messageSubject);
            email.setText(bodyText);

            // Encode and wrap the MIME message into a gmail message
            ByteArrayOutputStream buffer = new ByteArrayOutputStream();
            email.writeTo(buffer);
            byte[] rawMessageBytes = buffer.toByteArray();
            String encodedEmail = Base64.encodeBase64URLSafeString(rawMessageBytes);
            Message msg = new Message();
            msg.setRaw(encodedEmail);
            Message message = new Message();
            message.setRaw(encodedEmail);

            try {
                NetHttpTransport httpTransport = GoogleNetHttpTransport.newTrustedTransport();
                GsonFactory jsonFactory = GsonFactory.getDefaultInstance();
                Gmail service = new Gmail.Builder(httpTransport, jsonFactory, getCredentials(httpTransport, jsonFactory))
                        .setApplicationName("Test Mailer")
                        .build();
                msg = service.users().messages().send("me", msg).execute();
                LOG.fine("Verification message id: " + msg.getId());
                LOG.fine("Message: " + msg.toPrettyString());
                // Create send message
                message = service.users().messages().send("me", message).execute();
                System.out.println("Message id: " + message.getId());
                System.out.println(message.toPrettyString());
                return message;
            } catch (GoogleJsonResponseException e) {
                GoogleJsonError error = e.getDetails();
                if (error.getCode() == 403) {
                    System.err.println("Unable to send message: " + e.getDetails());
                } else {
                    throw e;
                }
            }
            return null;
        }
    }

    public void sendEmailVerification(String tokenId, String username) {

        String link = "https://fct-connect-estudasses.oa.r.appspot.com/rest/register/verification/" + username + "?token=" + tokenId;

        try {
            sendMail("noreply - Verify your FCT Connect email",
                    "Thank you for registering! Please verify your account by clicking on the following link: \n" +
                            link);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

    }

    @GET
    @Path("/verification/{username}")
    public Response verify(@PathParam("username") String username, @QueryParam("token") String tokenId) {

        Transaction txn = datastore.newTransaction();

        try {

            Key userKey = datastore.newKeyFactory().setKind("User").newKey(username);
            Entity user = txn.get(userKey);

            if (user == null) {
                txn.rollback();
                return Response.status(Response.Status.NOT_FOUND).entity("User doesn't exist.").build();
            }

            Key verKey = datastore.newKeyFactory()
                    .setKind("Verification")
                    .addAncestor(PathElement.of("User", username))
                    .newKey(DigestUtils.sha512Hex(tokenId));

            Entity verToken = txn.get(verKey);

            if (verToken == null) {
                LOG.warning("Token doesn't exist");
                Response.status(Response.Status.FORBIDDEN);
            }

            user = Entity.newBuilder(userKey)
                    .set("user_username", user.getString("user_username"))
                    .set("user_fullname", user.getString("user_fullname"))
                    .set("user_pwd", user.getString("user_pwd"))
                    .set("user_email", user.getString("user_email"))
                    .set("user_creation_time", user.getTimestamp("user_creation_time"))
                    .set("user_role", user.getString("user_role"))
                    .set("user_state", "ACTIVE")
                    .set("user_privacy", user.getString("user_privacy"))
                    .set("user_homephone", user.getString("user_homephone"))
                    .set("user_mobilephone", user.getString("user_mobilephone"))
                    .set("user_occupation", user.getString("user_occupation"))
                    .set("user_address", user.getString("user_address"))
                    .set("user_nif", user.getString("user_nif"))
                    .build();

            txn.put(user);
            txn.commit();

            return Response.ok().build();

        } catch (Exception e) {
            txn.rollback();
            LOG.severe(e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }

    public static void main(String[] args) throws Exception {
        new RegisterResource().sendEmailVerification("12345", "username");
    }


}
