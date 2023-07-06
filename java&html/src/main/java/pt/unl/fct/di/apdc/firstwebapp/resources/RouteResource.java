package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import org.apache.commons.codec.digest.DigestUtils;
import org.glassfish.jersey.server.monitoring.RequestEvent;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.LocationData;
import pt.unl.fct.di.apdc.firstwebapp.util.RouteData;
import pt.unl.fct.di.apdc.firstwebapp.util.RouteGetData;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.List;
import java.util.Queue;
import java.util.logging.Logger;

@Path("/route")
public class RouteResource {

    private static final Logger LOG = Logger.getLogger(LoginResource.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");

    @POST
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response createRoute(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username, RouteData data){

        Transaction txn = datastore.newTransaction();

        try{

            Key userKey = userKeyFactory.newKey(username);
            Entity user = txn.get(userKey);

            if (user == null) {
                LOG.warning("User does not exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            if (user.getString("user_state").equals("INACTIVE")) {
                LOG.warning("Inactive User.");
                return  Response.status(Response.Status.UNAUTHORIZED).build();
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

            Key routeKey = datastore.newKeyFactory()
                    .setKind("Route")
                    .addAncestor(PathElement.of("User", username))
                    .newKey(data.getCreator() + "-" + data.getName());

            if(txn.get(routeKey) != null){
                LOG.warning("Route already exists.");
                return Response.status(Response.Status.CONFLICT).build();
            }

            List<Value<String>> locations = new ArrayList<>();

            for(String location : data.getLocations()){
                locations.add(StringValue.newBuilder(location).setExcludeFromIndexes(false).build());
            }

            if(locations.isEmpty()){
                LOG.warning("Route has no locations.");
                return Response.status(Response.Status.BAD_REQUEST).build();
            }

            List<Value<String>> participants = new ArrayList<>();

            for(String participant : data.getParticipants()){
                participants.add(StringValue.newBuilder(participant).build());
            }

            if(participants.isEmpty()){
                LOG.warning("Route has no participants.");
                return Response.status(Response.Status.BAD_REQUEST).build();
            }

            List<LongValue> duration = new ArrayList<>();

            for (Integer time : data.getDurations()) {
            	duration.add(LongValue.newBuilder(time).setExcludeFromIndexes(true).build());
            }

            Entity route = Entity.newBuilder(routeKey)
                    .set("route_creator", username)
                    .set("route_name", data.getName())
                    .set("route_locations", ListValue.of(locations))
                    .set("route_participants", ListValue.of(participants))
                    .set("route_durations", ListValue.of(duration))
                    .build();

            txn.add(route);
            txn.commit();

            return Response.ok().build();

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

    @GET
    @Path("/")
    @Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
    public Response getRoutes(@HeaderParam("Authorization") String tokenID, @HeaderParam("User") String username){

        Transaction txn = datastore.newTransaction();

        try{

            Key userKey = userKeyFactory.newKey(username);
            Entity user = txn.get(userKey);

            if (user == null) {
                LOG.warning("User does not exist.");
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

            if (token == null || !token.getString("token_hashed_id").equals(DigestUtils.sha512Hex(tokenID))) {
                LOG.warning("Incorrect token. Please re-login");
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            List<RouteGetData> routes = new ArrayList<>();

            // Perform a query to retrieve routes with the user as a participant
            Query<Entity> query = Query.newEntityQueryBuilder()
                    .setKind("Route")
                    .setFilter(StructuredQuery.PropertyFilter.eq("route_creator", username))
                    .build();

            QueryResults<Entity> results = txn.run(query);

            while (results.hasNext()) {
                Entity route = results.next();

                LOG.warning("DEBUG: route = " + route.getString("route_name"));

                List<LocationData> locations = new ArrayList<>();

                List<StringValue> locationNames = route.getList("route_locations");

                LOG.warning("DEBUG: locations = " + locationNames.toString());

                Query<Entity> query2 = Query.newEntityQueryBuilder()
                        .setKind("Location")
                        .setFilter(StructuredQuery.PropertyFilter.in("name", ListValue.of(locationNames)))
                        .build();

                QueryResults<Entity> results2 = txn.run(query2);

                while (results2.hasNext()) {
                	Entity location = results2.next();
                    if(location.getString("type").equals("EVENT")) {
                        locations.add(new LocationData(location.getString("name"), location.getDouble("latitude"), location.getDouble("longitude")
                                , "EVENT", location.getString("event")));
                    } else {
                        locations.add(new LocationData(location.getString("name"), location.getDouble("latitude"), location.getDouble("longitude")
                                , location.getString("type"), ""));
                    }
                }

                List<String> participants = new ArrayList<>();

                for(Value<?> participant : route.getList("route_participants")){
                    participants.add((String) participant.get());
                }

                List<Integer> durations = new ArrayList<>();

                for (Value<?> duration : route.getList("route_durations")) {
                	durations.add(((Long) duration.get()).intValue());
                }

                routes.add(new RouteGetData(route.getString("route_creator"), route.getString("route_name"),
                                        locations, participants, durations));
            }

            return Response.ok(routes).build();

        }  catch(Exception e){
            LOG.severe(e.getMessage());
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if(txn.isActive()){
                txn.rollback();
            }
        }

    }

    @GET
    @Path("/{route}")
    @Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
    public Response getRoute(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username,
                             @PathParam("route") String routeId){

        Transaction txn = datastore.newTransaction();

        try{
            Key userKey = userKeyFactory.newKey(username);
            Entity user = txn.get(userKey);

            if (user == null) {
                LOG.warning("User does not exist.");
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

            Key routeKey = datastore.newKeyFactory()
                    .setKind("Route")
                    .addAncestor(PathElement.of("User", username))
                    .newKey(routeId);

            Entity route = txn.get(routeKey);

            if(route == null){
                LOG.warning("Route does not exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            if(!route.getString("route_creator").equals(username)){
                LOG.warning("User is not the creator of the route.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            List<LocationData> locations = new ArrayList<>();

            Query<Entity> query = Query.newEntityQueryBuilder()
                    .setKind("Location")
                    .setFilter(StructuredQuery.PropertyFilter.in("name", ListValue.of(route.getList("route_locations"))))
                    .build();

            QueryResults<Entity> results = txn.run(query);

            while(results.hasNext()){
                Entity location = results.next();
                if(location.getString("type").equals("EVENT")) {
                    locations.add(new LocationData(location.getString("name"), location.getDouble("latitude"), location.getDouble("longitude")
                            , "EVENT", location.getString("event")));
                } else {
                    locations.add(new LocationData(location.getString("name"), location.getDouble("latitude"), location.getDouble("longitude")
                            , location.getString("type"), ""));
                }
            }

            List<String> participants = new ArrayList<>();

            for(Value<?> participant : route.getList("route_participants")){
                participants.add((String) participant.get());
            }

            List<Integer> durations = new ArrayList<>();

            for (Value<?> duration : route.getList("route_durations")) {
            	durations.add(((Long) duration.get()).intValue());
            }

            return Response.ok(new RouteGetData(route.getString("route_creator"), route.getString("route_name"),
                    locations, participants, durations)).build();

        }catch(Exception e){
            LOG.severe(e.getMessage());
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if(txn.isActive()){
                txn.rollback();
            }
        }

    }

    @PUT
    @Path("/{route}")
    public Response addParticipant(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username,
                                   @PathParam("route") String routeId, @QueryParam("participant") String participant){

        Transaction txn = datastore.newTransaction();

        try{

            Key userKey = userKeyFactory.newKey(username);
            Entity user = txn.get(userKey);

            if(user == null){
                LOG.warning("User does not exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            if(user.getString("user_state").equals("INACTIVE")){
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

            Key routeKey = datastore.newKeyFactory()
                    .setKind("Route")
                    .addAncestor(PathElement.of("User", username))
                    .newKey(routeId);

            Entity routeEntity = txn.get(routeKey);

            if(routeEntity == null){
                LOG.warning("Route does not exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            if(!routeEntity.getString("route_creator").equals(username)){
                LOG.warning("User is not the creator of the route.");
                return Response.status(Response.Status.PRECONDITION_FAILED).build();
            }

            Key participantKey = userKeyFactory.newKey(participant);

            if(txn.get(participantKey) == null){
                LOG.warning("Participant does not exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            List<Value<String>> participants = routeEntity.getList("route_participants");

            if(participants.contains(StringValue.of(participant))){
                LOG.warning("Participant already exists.");
                return Response.status(Response.Status.CONFLICT).build();
            }

            participants.add(StringValue.of(participant));

            Entity route = Entity.newBuilder(routeEntity)
                    .set("route_creator", routeEntity.getString("route_creator"))
                    .set("route_name", routeEntity.getString("route_name"))
                    .set("route_locations", routeEntity.getList("route_locations"))
                    .set("route_times", routeEntity.getList("route_times"))
                    .set("route_participants", ListValue.of(participants))
                    .set("route_durations", routeEntity.getList("route_durations"))
                    .build();

            txn.update(route);
            txn.commit();

            return Response.ok().build();

        } catch (Exception e) {
            LOG.severe(e.getMessage());
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if(txn.isActive()){
                txn.rollback();
            }
        }

    }

    @DELETE
    @Path("/{route}")
    public Response deleteRoute(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username,
                                @PathParam("route") String routeId){

            Transaction txn = datastore.newTransaction();

            try{

                Key userKey = userKeyFactory.newKey(username);
                Entity user = txn.get(userKey);

                if(user == null){
                    LOG.warning("User does not exist.");
                    return Response.status(Response.Status.NOT_FOUND).build();
                }

                if(user.getString("user_state").equals("INACTIVE")){
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

                Key routeKey = datastore.newKeyFactory()
                        .setKind("Route")
                        .addAncestor(PathElement.of("User", username))
                        .newKey(routeId);

                Entity routeEntity = txn.get(routeKey);

                if(routeEntity == null){
                    LOG.warning("Route does not exist.");
                    return Response.status(Response.Status.NOT_FOUND).build();
                }

                if(!routeEntity.getString("route_creator").equals(username)){
                    LOG.warning("User is not the creator of the route.");
                    return Response.status(Response.Status.PRECONDITION_FAILED).build();
                }

                txn.delete(routeKey);
                txn.commit();

                return Response.ok().build();

            } catch (Exception e) {
                LOG.severe(e.getMessage());
                e.printStackTrace();
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
            } finally {
                if(txn.isActive()){
                    txn.rollback();
                }
            }
    }

}
