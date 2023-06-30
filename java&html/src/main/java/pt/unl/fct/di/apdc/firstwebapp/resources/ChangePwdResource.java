package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.CPData;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.logging.Logger;

@Path("/")
@Consumes(MediaType.APPLICATION_JSON)
public class ChangePwdResource {

    private static final Logger LOG = Logger.getLogger(LoginResource.class.getName());
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

    @PUT
    @Path("/forgotpwd")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response forgotPwd(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username, CPData data){

        Transaction txn = datastore.newTransaction();

        try{

            Key userKey = userKeyFactory.newKey(username);

            Entity user = txn.get(userKey);

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

            Entity task = Entity.newBuilder(user)
                    .set("user_username", user.getString("user_username"))
                    .set("user_fullname", user.getString("user_fullname"))
                    .set("user_pwd", data.getNewPassword())
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

