package pt.unl.fct.di.apdc.fctconnect.resources;


import com.google.cloud.datastore.*;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.fctconnect.util.Activity.Activity;
import pt.unl.fct.di.apdc.fctconnect.util.Token.AuthToken;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Path("/activity")
public class ActivityResource {


    private static final Logger LOG = Logger.getLogger(ActivityResource.class.getName());

    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");

    @POST
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response createActivity(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username, Activity data){

        Transaction txn = datastore.newTransaction();

        try{

            Key userKey = userKeyFactory.newKey(username);
            Entity userEntity = txn.get(userKey);
            if(userEntity == null){
                LOG.warning("User doesn't exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            if (userEntity.getString("user_state").equals("INACTIVE")){
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

            Key activityKey = datastore.newKeyFactory()
                    .setKind("Activity")
                    .addAncestor(PathElement.of("User", username))
                    .newKey(data.getCreationTime());

            Entity activity = txn.get(activityKey);

            if(activity != null){
                LOG.warning("Activity already exists.");
                return Response.status(Response.Status.CONFLICT).build();
            }

            if(data.getActivityName().length()>300){
                LOG.warning("Activity name too long.");
                return Response.status(Response.Status.PRECONDITION_FAILED).build();
            }

            activity = Entity.newBuilder(activityKey)
                    .set("activity_creation_time", data.getCreationTime())
                    .set("activity_name", data.getActivityName())
                    .set("activity_from", data.getFrom())
                    .set("activity_to", data.getTo())
                    .set("activity_colour", data.getBackground())
                    .build();

            txn.put(activity);
            txn.commit();

            return Response.ok().build();

        }catch (Exception e){
            LOG.warning(e.getMessage());
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }finally {
            if(txn.isActive()) {
                txn.rollback();
            }
        }

    }

    @GET
    @Path("/")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getActivities(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username){
        Transaction txn = datastore.newTransaction();

        try{

            Key userKey = userKeyFactory.newKey(username);
            Entity userEntity = txn.get(userKey);
            if(userEntity == null){
                LOG.warning("User doesn't exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            if(userEntity.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", username))
                    .newKey("token");
            Entity token = txn.get(tokenKey);
            if(token == null || !token.getString("token_hashed_id").equals(DigestUtils.sha512Hex(tokenId))){
                LOG.warning("Incorrect token. Please re-login");
                return Response.status(Response.Status.FORBIDDEN).build();
            }
            if(AuthToken.expired(token.getLong("token_expiration"))){
                LOG.warning("Your token has expired. Please re-login.");
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            Query<Entity> query = Query.newEntityQueryBuilder()
                    .setKind("Activity")
                    .setFilter(StructuredQuery.PropertyFilter.hasAncestor(userKey))
                    .build();

            QueryResults<Entity> activities = txn.run(query);

            List<Activity> activityList = new ArrayList<>();

            activities.forEachRemaining(activity -> {
                activityList.add(new Activity(
                        activity.getString("activity_name"),
                        activity.getLong("activity_from"),
                        activity.getLong("activity_to"),
                        activity.getString("activity_colour"),
                        activity.getString("activity_creation_time")
                        ));

            });

            return Response.ok(activityList).build();

        }catch(Exception e) {
            LOG.warning(e.getMessage());
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }finally {
            if(txn.isActive()) {
                txn.rollback();
            }
        }
    }


    @DELETE
    @Path("/{activity_creation_time}")
    public Response deleteActivity(@HeaderParam("Authorization") String tokenId,
                                   @HeaderParam("User") String username,
                                   @PathParam("activity_creation_time") String activity_creation_time){

        Transaction txn = datastore.newTransaction();

        try{

            Key userKey = userKeyFactory.newKey(username);
            Entity userEntity = txn.get(userKey);
            if(userEntity == null){
                LOG.warning("User doesn't exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            if(userEntity.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", username))
                    .newKey("token");
            Entity token = txn.get(tokenKey);
            if(token == null || !token.getString("token_hashed_id").equals(DigestUtils.sha512Hex(tokenId))){
                LOG.warning("Incorrect token. Please re-login");
                return Response.status(Response.Status.FORBIDDEN).build();
            }
            if(AuthToken.expired(token.getLong("token_expiration"))){
                LOG.warning("Your token has expired. Please re-login.");
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            Key activityKey = datastore.newKeyFactory()
                    .setKind("Activity")
                    .addAncestor(PathElement.of("User", username))
                    .newKey(activity_creation_time);

            Entity activity = txn.get(activityKey);

            if(activity == null){
                LOG.warning("Activity doesn't exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            
            txn.delete(activityKey);
            txn.commit();

            return Response.ok().build();

        }catch(Exception e) {
            LOG.warning(e.getMessage());
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }finally {
            if(txn.isActive()) {
                txn.rollback();
            }
        }
    }

    @PUT
    @Path("/{activity_creation_time}")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response updateActivity(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username, @PathParam("activity_creation_time") String activity_creation_time, Activity data){
        Transaction txn = datastore.newTransaction();

        try{

            Key userKey = userKeyFactory.newKey(username);
            Entity userEntity = txn.get(userKey);
            if(userEntity == null){
                LOG.warning("User doesn't exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            if(userEntity.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", username))
                    .newKey("token");
            Entity token = txn.get(tokenKey);
            if(token == null || !token.getString("token_hashed_id").equals(DigestUtils.sha512Hex(tokenId))){
                LOG.warning("Incorrect token. Please re-login");
                return Response.status(Response.Status.FORBIDDEN).build();
            }
            if(AuthToken.expired(token.getLong("token_expiration"))){
                LOG.warning("Your token has expired. Please re-login.");
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            Key activityKey = datastore.newKeyFactory()
                    .setKind("Activity")
                    .addAncestor(PathElement.of("User", username))
                    .newKey(activity_creation_time);

            Entity activity = txn.get(activityKey);

            if(activity == null){
                LOG.warning("Activity doesn't exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            activity = Entity.newBuilder(activityKey)
                    .set("activity_creation_time", activity_creation_time)
                    .set("activity_name", data.getActivityName())
                    .set("activity_from", data.getFrom())
                    .set("activity_to", data.getTo())
                    .set("activity_colour", data.getBackground())
                    .build();

            txn.put(activity);
            txn.commit();

            return Response.ok().build();

        }catch(Exception e) {
            LOG.warning(e.getMessage());
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }finally {
            if(txn.isActive()) {
                txn.rollback();
            }
        }
    }

}
