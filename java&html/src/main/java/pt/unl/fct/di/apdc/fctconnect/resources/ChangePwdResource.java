package pt.unl.fct.di.apdc.fctconnect.resources;

import com.google.cloud.datastore.*;
import com.sendgrid.*;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.fctconnect.util.Token.AuthToken;
import pt.unl.fct.di.apdc.fctconnect.util.ChangePwd.CPData;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.Random;
import java.util.logging.Logger;

@Path("/")
@Consumes(MediaType.APPLICATION_JSON)
public class ChangePwdResource {

    private static final Logger LOG = Logger.getLogger(ChangePwdResource.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");

    @PUT
    @Path("/changepwd")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response updatePwd(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username, CPData data) {
        LOG.fine("Attempt to update user: " + username);

        Transaction txn = datastore.newTransaction();
        try {
            Key userKey = userKeyFactory.newKey(username);

            Entity user = txn.get(userKey);

            String newPassword = data.getNewPassword();

            if(newPassword == null || !data.valid()){
                LOG.info("newPass: " + newPassword);
                return Response.status(Response.Status.BAD_REQUEST).build();
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

            if (user.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            String hashedPWD = user.getString("user_pwd");

            if (hashedPWD.equals(DigestUtils.sha512Hex(data.getOldPassword()))) {

                Entity task = Entity.newBuilder(user)
                        .set("user_username", user.getString("user_username"))
                        .set("user_fullname", user.getString("user_fullname"))
                        .set("user_pwd", DigestUtils.sha512Hex((data.getNewPassword())))
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
                        .set("user_cover_pic", user.getString("user_cover_pic"))
                        .set("user_purpose", user.getString("user_purpose"))
                        .set("user_events", user.getList("user_events"))
                        .build();;

                txn.update(task);

                txn.commit();
                return Response.ok().build();
            }else{
                LOG.warning("Wrong Password");
                return Response.status(Response.Status.BAD_REQUEST).build();
            }

        }catch (Exception e) {
            txn.rollback();
            LOG.severe(e.getMessage());
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }


    @POST
    @Path("/forgotpwd")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response forgotPwdEmail(@QueryParam("username") String username, @QueryParam("email") String email){

        Transaction txn = datastore.newTransaction();

        try{

            if(email == null && username == null){
                LOG.warning("Missing parameters.");
                return Response.status(Response.Status.BAD_REQUEST).build();
            }

            if(email == null) {
                Key userKey = userKeyFactory.newKey(username);

                Entity user = txn.get(userKey);

                if (user == null) {
                    LOG.warning("User does not exist.");
                    return Response.status(Response.Status.NOT_FOUND).build();
                }

                email = user.getString("user_email");

            }
            else{

                Query<Entity> query = Query.newEntityQueryBuilder()
                        .setKind("User")
                        .setFilter(StructuredQuery.PropertyFilter.eq("user_email", email))
                        .build();


                QueryResults<Entity> results = datastore.run(query);

                if(!results.hasNext()){
                    LOG.warning("Email not associated with any user.");
                    return Response.status(Response.Status.NOT_FOUND).build();
                }

               username = results.next().getString("user_username");

            }

            Key pwdKey = datastore.newKeyFactory()
                    .setKind("ChangePwd")
                    .addAncestor(PathElement.of("User", username))
                    .newKey("pwd");

            Random rand = new Random();

            int code = rand.nextInt(900000) + 100000;

            Entity token = Entity.newBuilder(pwdKey)
                    .set("token_code", DigestUtils.sha512Hex(String.valueOf(code)))
                    .build();

            txn.add(token);

            Email from = new Email("fctconnect2023@gmail.com");
            String subject = "noreply - Activate your account!";
            Email to = new Email(email);


            Content content = new Content("text/plain", "Thank you for registering!\n " +
                    "Para alterar a sua password, por favor, utilize o seguinte código: " + code );
            Mail mail = new Mail(from, subject, to, content);

            //TODO: Substituir key por variavel de ambiente
            SendGrid sg = new SendGrid("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");
            Request request = new Request();

            request.setMethod(Method.POST);
            request.setEndpoint("mail/send");
            request.setBody(mail.build());
            com.sendgrid.Response response = sg.api(request);
            LOG.info("Verification email (" + email + ") result: " + response.getStatusCode());

            txn.commit();
            return Response.ok().build();


        } catch (Exception e) {
            txn.rollback();
            LOG.severe(e.getMessage());
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }

    }

    @PUT
    @Path("/forgotpwd")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response forgotPwd(@HeaderParam("Authorization") String tokenId, @QueryParam("username") String username,
                              @QueryParam("email") String email, @QueryParam("code") String code,
                              @QueryParam("newpwd") String newpwd){

        Transaction txn = datastore.newTransaction();

        try{

            if(email == null && username == null || code == null || newpwd == null){
                LOG.warning("Missing parameters.");
                return Response.status(Response.Status.BAD_REQUEST).build();
            }

            if(username == null){


                    Query<Entity> query = Query.newEntityQueryBuilder()
                            .setKind("User")
                            .setFilter(StructuredQuery.PropertyFilter.eq("user_email", email))
                            .build();

                    QueryResults<Entity> results = datastore.run(query);

                    if(!results.hasNext()){
                        LOG.warning("Email not associated with any user.");
                        return Response.status(Response.Status.NOT_FOUND).build();
                    }

                    username = results.next().getString("user_username");
            }

            Key userKey = userKeyFactory.newKey(username);

            Entity user = txn.get(userKey);

            if (user == null) {
                LOG.warning("User does not exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            Key pwdKey = datastore.newKeyFactory()
                    .setKind("ChangePwd")
                    .addAncestor(PathElement.of("User", username))
                    .newKey("pwd");

            Entity token = txn.get(pwdKey);

            if(token == null){
                LOG.warning("Token does not exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            if(!token.getString("token_code").equals(DigestUtils.sha512Hex(code))){
                LOG.warning("Wrong code.");
                return Response.status(Response.Status.BAD_REQUEST).build();
            }


            Entity task = Entity.newBuilder(user)
                    .set("user_pwd", StringValue.newBuilder(newpwd).setExcludeFromIndexes(true).build())
                    .build();;

            txn.update(task);
            txn.commit();

            return Response.ok().build();

        } catch (Exception e) {
            txn.rollback();
            LOG.severe(e.getMessage());
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }
}

