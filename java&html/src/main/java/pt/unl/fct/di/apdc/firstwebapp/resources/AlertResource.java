package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.AlertDeleteData;
import pt.unl.fct.di.apdc.firstwebapp.util.AlertGetData;
import pt.unl.fct.di.apdc.firstwebapp.util.AlertPostData;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Path("/alert")
public class AlertResource {

    private static final Logger LOG = Logger.getLogger(AlertResource.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");

    @POST
    @Path("/{creator}")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response createAlert(@HeaderParam("Authorization") String tokenId, @PathParam("creator") String username, AlertPostData data){

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

            Key alertKey = datastore.newKeyFactory()
                    .setKind("Alert")
                    .newKey(data.getTimestamp());

            if(txn.get(alertKey) != null){
                LOG.warning("Alert already exists! Please try again");
                return Response.status(Response.Status.CONFLICT).build();
            }

            Entity alert = Entity.newBuilder(alertKey)
                    .set("alert_creator", data.getCreator())
                    .set("alert_location", data.getLocation())
                    .set("alert_description", StringValue.newBuilder(data.getDescription()).setExcludeFromIndexes(true).build())
                    .set("alert_timestamp", data.getTimestamp())
                    .build();

            txn.put(alert);
            txn.commit();

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

    @GET
    @Path("/")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getAlerts(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username){

        Transaction txn = datastore.newTransaction();

        try {

            Key userKey = userKeyFactory.newKey(username);
            Entity userEntity = txn.get(userKey);
            if (userEntity == null) {
                LOG.warning("User doesn't exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            if (userEntity.getString("user_state").equals("INACTIVE")) {
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

            StructuredQuery.OrderBy ascTimestamp = StructuredQuery.OrderBy.asc("alert_timestamp");

            Query<Entity> alertQuery = Query.newEntityQueryBuilder()
                    .setKind("Alert")
                    .addOrderBy(ascTimestamp)
                    .build();

            QueryResults<Entity> alertResults = txn.run(alertQuery);

            List<AlertGetData> toSend = new ArrayList<>();

            alertResults.forEachRemaining(alert -> {
                toSend.add(new AlertGetData(
                        alert.getString("alert_creator"),
                        alert.getString("alert_location"),
                        alert.getString("alert_description"),
                        alert.getLong("alert_timestamp")
                ));

            });

            if(toSend.isEmpty()){
                return Response.status(Response.Status.PRECONDITION_FAILED).build();
            }

            return Response.ok(toSend).build();

        }catch (Exception e) {
            txn.rollback();
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }

    @DELETE
    @Path("/")
    public Response deleteAlert(@HeaderParam("Authorization") String tokenId,
                                @HeaderParam("User") String username,
                                AlertDeleteData data){

        Transaction txn = datastore.newTransaction();

        try{

            Key userKey = userKeyFactory.newKey(username);
            Entity userEntity = txn.get(userKey);
            if (userEntity == null) {
                LOG.warning("User doesn't exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            if (userEntity.getString("user_state").equals("INACTIVE")) {
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

            for(Long alert: data.getIds()){
                Key alertKey = datastore.newKeyFactory()
                        .setKind("Alert")
                        .newKey(alert);

                if(txn.get(alertKey) == null){
                    LOG.warning("Alert " + alert + " doesn't exist");
                    return Response.status(Response.Status.NOT_FOUND).build();
                }

                txn.delete(alertKey);
            }

            txn.commit();
            return Response.ok().build();

        }catch (Exception e) {
            txn.rollback();
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }

    }


}
