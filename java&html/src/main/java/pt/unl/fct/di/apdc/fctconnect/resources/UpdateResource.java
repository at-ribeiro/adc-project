package pt.unl.fct.di.apdc.fctconnect.resources;

import com.google.cloud.datastore.*;
import pt.unl.fct.di.apdc.fctconnect.util.Token.AuthToken;
import pt.unl.fct.di.apdc.fctconnect.util.Profile.UpdateData;
import org.apache.commons.codec.digest.DigestUtils;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.logging.Logger;

@Path("/update")
public class UpdateResource {

    private static final Logger LOG = Logger.getLogger(UpdateResource.class.getName());

    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");


    @PUT
    @Path("/{user}")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response userUpdate(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String updaterName, @PathParam("user") String username, UpdateData data) {

        Transaction txn = datastore.newTransaction();

        try {

            Key updaterKey = userKeyFactory.newKey(updaterName);

            Entity updater = txn.get(updaterKey);

            if (updater == null) {
                LOG.warning("User does not exist: " + updaterName);
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            if (updater.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", updaterName))
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

            Key userKey = userKeyFactory.newKey(username);
            Entity user = txn.get(userKey);

            if (user == null) {
                LOG.warning("User does not exist: " + username);
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            if(data.getAbout_me().length() > 300 || data.getCity().length()>300 || data.getDepartment().length()>300 || data.getOffice().length()>300
                    || data.getPurpose().length()>300 || data.getPhone().length()>300 || data.getFullname().length()>300 || data.getCourse().length()>300
                    || data.getYear().length()>300){
                LOG.warning("Invalid input.");
                return Response.status(Response.Status.PRECONDITION_FAILED).build();
            }


            Entity task = Entity.newBuilder(userKey)
                    .set("user_username", user.getString("user_username"))
                    .set("user_fullname", data.getFullname())
                    .set("user_pwd", user.getString("user_pwd"))
                    .set("user_email", user.getString("user_email"))
                    .set("user_creation_time", user.getTimestamp("user_creation_time"))
                    .set("user_role", user.getString("user_role"))
                    .set("user_state", user.getString("user_state"))
                    .set("user_privacy", data.getPrivacy())
                    .set("user_phone", StringValue.newBuilder(data.getPhone()).setExcludeFromIndexes(true).build())
                    .set("user_city", data.getCity())
                    .set("user_about_me", StringValue.newBuilder(data.getAbout_me()).setExcludeFromIndexes(true).build())
                    .set("user_department", data.getDepartment())
                    .set("user_office", StringValue.newBuilder(data.getOffice()).setExcludeFromIndexes(true).build())
                    .set("user_course", data.getCourse())
                    .set("user_year",data.getYear())
                    .set("user_profile_pic", user.getString("user_profile_pic"))
                    .set("user_cover_pic", user.getString("user_cover_pic"))
                    .set("user_purpose", data.getPurpose())
                    .set("user_events", user.getList("user_events"))
                    .set("user_posts", user.getLong("user_posts"))
                    .build();;

            txn.update(task);

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

    @PUT
    @Path("/activate/{user}")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response changeUserState(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username,
                                    @PathParam("user") String userToChange){

        Transaction txn = datastore.newTransaction();

        try{

            Key userKey = userKeyFactory.newKey(username);

            Entity user = txn.get(userKey);

            if (user == null){
                LOG.warning("User does not exist: " + username);
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            if (!(user.getString("user_role").equals("SECRETARIA") || user.getString("user_role").equals("SA"))){
                LOG.warning("User does not have permission to change user state.");
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", username))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token == null || !token.getString("token_hashed_id").equals(DigestUtils.sha512Hex(tokenId))){
                LOG.warning("Incorrect token. Please re-login");
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            if (AuthToken.expired(token.getLong("token_expiration"))){
                LOG.warning("Your token has expired. Please re-login.");
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            Key userToChangeKey = userKeyFactory.newKey(userToChange);

            Entity userToChangeEntity = txn.get(userToChangeKey);

            if (userToChangeEntity == null){
                LOG.warning("User does not exist: " + userToChange);
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            if (userToChangeEntity.getString("user_state").equals("ACTIVE")){
                LOG.warning("User is already active.");
                return Response.status(Response.Status.BAD_REQUEST).build();
            }

            Entity task = Entity.newBuilder(userToChangeKey)
                    .set("user_username", userToChangeEntity.getString("user_username"))
                    .set("user_fullname", userToChangeEntity.getString("user_fullname"))
                    .set("user_pwd", userToChangeEntity.getString("user_pwd"))
                    .set("user_email", userToChangeEntity.getString("user_email"))
                    .set("user_creation_time", userToChangeEntity.getTimestamp("user_creation_time"))
                    .set("user_role", userToChangeEntity.getString("user_role"))
                    .set("user_state", userToChangeEntity.getString("user_state"))
                    .set("user_privacy", userToChangeEntity.getString("user_privacy"))
                    .set("user_phone", userToChangeEntity.getString("user_phone"))
                    .set("user_city", userToChangeEntity.getString("user_city"))
                    .set("user_about_me", userToChangeEntity.getString("user_about_me"))
                    .set("user_department", userToChangeEntity.getString("user_department"))
                    .set("user_office", userToChangeEntity.getString("user_office"))
                    .set("user_course", userToChangeEntity.getString("user_course"))
                    .set("user_year", userToChangeEntity.getString("user_year"))
                    .set("user_profile_pic", userToChangeEntity.getString("user_profile_pic"))
                    .set("user_cover_pic", userToChangeEntity.getString("user_cover_pic"))
                    .set("user_purpose", userToChangeEntity.getString("user_purpose"))
                    .set("user_events", userToChangeEntity.getList("user_events"))
                    .set("user_posts", userToChangeEntity.getLong("user_posts"))
                    .build();

            txn.update(task);

            txn.commit();

            return Response.ok().build();

        } catch (Exception e){
            txn.rollback();
            LOG.severe(e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if (txn.isActive()){
                txn.rollback();
            }
        }
    }


    @PUT
    @Path("/deactivate/{user}")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response deactivateUser(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username,
                                   @PathParam("user") String userToChange){

        Transaction txn = datastore.newTransaction();

        try{

            Key userKey = userKeyFactory.newKey(username);

            Entity user = txn.get(userKey);

            if (user == null){
                LOG.warning("User does not exist: " + username);
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            if (!(user.getString("user_role").equals("SECRETARIA") || user.getString("user_role").equals("SA"))){
                LOG.warning("User does not have permission to change user state.");
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", username))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token == null || !token.getString("token_hashed_id").equals(DigestUtils.sha512Hex(tokenId))){
                LOG.warning("Incorrect token. Please re-login");
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            if (AuthToken.expired(token.getLong("token_expiration"))){
                LOG.warning("Your token has expired. Please re-login.");
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            Key userToChangeKey = userKeyFactory.newKey(userToChange);

            Entity userToChangeEntity = txn.get(userToChangeKey);

            if (userToChangeEntity == null){
                LOG.warning("User does not exist: " + userToChange);
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            if (userToChangeEntity.getString("user_state").equals("INACTIVE")){
                LOG.warning("User is already inactive.");
                return Response.status(Response.Status.BAD_REQUEST).build();
            }

            Entity task = Entity.newBuilder(userToChangeKey)
                    .set("user_username", userToChangeEntity.getString("user_username"))
                    .set("user_fullname", userToChangeEntity.getString("user_fullname"))
                    .set("user_pwd", userToChangeEntity.getString("user_pwd"))
                    .set("user_email", userToChangeEntity.getString("user_email"))
                    .set("user_creation_time", userToChangeEntity.getTimestamp("user_creation_time"))
                    .set("user_role", userToChangeEntity.getString("user_role"))
                    .set("user_state", "INACTIVE")
                    .set("user_privacy", userToChangeEntity.getString("user_privacy"))
                    .set("user_phone", userToChangeEntity.getString("user_phone"))
                    .set("user_city", userToChangeEntity.getString("user_city"))
                    .set("user_about_me", userToChangeEntity.getString("user_about_me"))
                    .set("user_department", userToChangeEntity.getString("user_department"))
                    .set("user_office", userToChangeEntity.getString("user_office"))
                    .set("user_course", userToChangeEntity.getString("user_course"))
                    .set("user_year", userToChangeEntity.getString("user_year"))
                    .set("user_profile_pic", userToChangeEntity.getString("user_profile_pic"))
                    .set("user_cover_pic", userToChangeEntity.getString("user_cover_pic"))
                    .set("user_purpose", userToChangeEntity.getString("user_purpose"))
                    .set("user_events", userToChangeEntity.getList("user_events"))
                    .set("user_posts", userToChangeEntity.getLong("user_posts"))
                    .build();

            txn.update(task);

            txn.commit();

            return Response.ok().build();

        }catch (Exception e){
            txn.rollback();
            LOG.severe(e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }

    @GET
    @Path("/state/{user}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getState(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username,
                             @PathParam("user") String userToChange){

        Transaction txn = datastore.newTransaction();

        try{

            Key userKey = userKeyFactory.newKey(username);

            Entity user = txn.get(userKey);

            if (user == null){
                LOG.warning("User does not exist: " + username);
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            if (!(user.getString("user_role").equals("SECRETARIA") || user.getString("user_role").equals("SA"))){
                LOG.warning("User does not have permission to change user state.");
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", username))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token == null || !token.getString("token_hashed_id").equals(DigestUtils.sha512Hex(tokenId))){
                LOG.warning("Incorrect token. Please re-login");
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            if (AuthToken.expired(token.getLong("token_expiration"))){
                LOG.warning("Your token has expired. Please re-login.");
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            Key userToChangeKey = userKeyFactory.newKey(userToChange);

            Entity userToChangeEntity = txn.get(userToChangeKey);

            if(userToChangeEntity == null){
                LOG.warning("User does not exist: " + userToChange);
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            if(userToChangeEntity.getString("user_state").equals("INACTIVE")){
                return Response.status(Response.Status.NOT_ACCEPTABLE).build();
            } else {
                return Response.status(Response.Status.ACCEPTED).build();
            }

        } catch (Exception e){
            txn.rollback();
            LOG.severe(e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if (txn.isActive()){
                txn.rollback();
            }
        }

    }
}
