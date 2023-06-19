package pt.unl.fct.di.apdc.firstwebapp.resources;


import com.google.api.client.http.HttpRequestInitializer;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.services.gmail.GmailScopes;
import com.google.auth.http.HttpCredentialsAdapter;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.Timestamp;
import com.google.cloud.datastore.*;
import com.sendgrid.*;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.RegisterData;
import pt.unl.fct.di.apdc.firstwebapp.util.VerificationToken;

import java.io.IOException;
import java.util.*;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.logging.Logger;


@Path("/register")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class RegisterResource {

    private static final Logger LOG = Logger.getLogger(RegisterResource.class.getName());
    private static final String API_MAIL = "fctconnect2023@gmail.com";
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    @POST
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response register(RegisterData data){
        LOG.fine("Attempt to register user: " + data.getUsername());

        if(!data.validRegistration()){
            return Response.status(Response.Status.BAD_REQUEST).entity("Missing or Wrong parameter.").build();
        }

        Transaction txn = datastore.newTransaction();
        try{
            Key userKey = datastore.newKeyFactory().setKind("User").newKey(data.getUsername());
            Entity user = txn.get(userKey);

            if(user != null){
                txn.rollback();
                return Response.status(Response.Status.CONFLICT).entity("User already exists.").build();
            }

            Query<Entity> query = Query.newEntityQueryBuilder().setKind("User").setFilter(
                    StructuredQuery.PropertyFilter.eq("user_email", data.getEmail())
            ).build();
            QueryResults<Entity> users = txn.run(query);

            List<Entity> userList = new ArrayList<>();

            users.forEachRemaining(userQ ->{
                userList.add(userQ);
            });

            if(!userList.isEmpty()){
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
                    .set("user_privacy", "PUBLIC")
                    .set("user_phone", StringValue.newBuilder("").setExcludeFromIndexes(true).build())
                    .set("user_city", "")
                    .set("user_about_me", StringValue.newBuilder("").setExcludeFromIndexes(true).build())
                    .set("user_department", "")
                    .set("user_office", StringValue.newBuilder("").setExcludeFromIndexes(true).build())
                    .set("user_course", "")
                    .set("user_year", "")
                    .set("user_profile_pic", StringValue.newBuilder("").setExcludeFromIndexes(true).build())
                    .set("user_cover_pic", StringValue.newBuilder("").setExcludeFromIndexes(true).build())
                    .set("external_purpose","")
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


            sendEmailVerification(tokenId, data.getUsername(), data.getEmail());

            return Response.ok(tokenData).header("Access-Control-Allow_Origin", "*").build();

        }finally {
            if(txn.isActive()){
                txn.rollback();
            }
        }
    }

    private void sendSendGridEmail(String email, String link){
        Email from = new Email("fctconnect2023@gmail.com");
        String subject = "noreply - Activate your account!";
        Email to = new Email(email);
        Content content = new Content("text/plain", "Thank you for registering!\n " +
                                                                "To activate your account please click the following link: " + link );
        Mail mail = new Mail(from, subject, to, content);

        //TODO: Remover key e subs por ?
        SendGrid sg = new SendGrid("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");
        Request request = new Request();
        try {
            request.setMethod(Method.POST);
            request.setEndpoint("mail/send");
            request.setBody(mail.build());
            com.sendgrid.Response response = sg.api(request);
            LOG.info(String.valueOf("Verification email ("+ email +") result: " + response.getStatusCode()));
        } catch (IOException ex) {
            LOG.warning(ex.getMessage());
        }
    }

    public void sendEmailVerification(String tokenId, String username, String email) {

        String link = "https://fct-connect-estudasses.oa.r.appspot.com/rest/register/verification/" + username +"?token=" + tokenId;

        try{
            sendSendGridEmail(email, link);
        } catch (Exception e) {
            LOG.warning("Google API Error: " + e.getMessage());
            throw new RuntimeException(e);
        }

    }

    @GET
    @Path("/verification/{username}")
    public Response verify(@PathParam("username") String username, @QueryParam("token") String tokenId){

        Transaction txn = datastore.newTransaction();

        try{

            Key userKey = datastore.newKeyFactory().setKind("User").newKey(username);
            Entity user = txn.get(userKey);

            if(user == null){
                txn.rollback();
                return Response.status(Response.Status.NOT_FOUND).entity("User doesn't exist.").build();
            }

            Key verKey = datastore.newKeyFactory()
                    .setKind("Verification")
                    .addAncestor(PathElement.of("User", username))
                    .newKey(DigestUtils.sha512Hex(tokenId));

            Entity verToken = txn.get(verKey);

            if(verToken == null){
                LOG.warning("Token doesn't exist");
                Response.status(Response.Status.FORBIDDEN);
            }

            user =  Entity.newBuilder(userKey)
                    .set("user_username", user.getString("user_username"))
                    .set("user_fullname", user.getString("user_fullname"))
                    .set("user_pwd", user.getString("user_pwd"))
                    .set("user_email", user.getString("user_email"))
                    .set("user_creation_time", user.getTimestamp("user_creation_time"))
                    .set("user_role", user.getString("user_role"))
                    .set("user_state", "ACTIVE")
                    .set("user_privacy", user.getString("user_privacy"))
                    .set("user_phone", user.getString("user_phone"))
                    .set("user_city", user.getString("user_city"))
                    .set("user_about_me", user.getString("user_about_me"))
                    .set("user_department", user.getString("user_department"))
                    .set("user_office", StringValue.newBuilder("").setExcludeFromIndexes(true).build())
                    .set("user_course", user.getString("user_course"))
                    .set("user_year", user.getString("user_year"))
                    .set("user_profile_pic", user.getString("user_profile_pic"))
                    .set("user_cover_pic", user.getString("user_cover_pic"))
                    .set("user_purpose", user.getString("user_purpose"))


                    .build();

            txn.put(user);
            txn.commit();

            LOG.fine(username + " successfully activated!");

            return Response.ok().build();

        }catch (Exception e) {
            txn.rollback();
            LOG.severe(e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }


}
