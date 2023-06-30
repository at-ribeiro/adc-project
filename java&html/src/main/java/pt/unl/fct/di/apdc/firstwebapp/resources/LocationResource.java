package pt.unl.fct.di.apdc.firstwebapp.resources;


import com.google.cloud.datastore.*;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.LocationData;

import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Path("/location")
public class LocationResource {

    private static final Logger LOG = Logger.getLogger(LocationResource.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");

    @GET
    @Path("/")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getLocations(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username, @QueryParam("type") String type){

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

            List<LocationData> locations = new ArrayList<>();

            if(type.equals("EVENT")){
                List<Value<String>> events = user.getList("user_events");

                if(events.isEmpty()){
                    LOG.warning("User has no events.");
                    return Response.status(Response.Status.PRECONDITION_FAILED).build();
                }


                Query<Entity> queryEvents = Query.newEntityQueryBuilder()
                        .setKind("Location")
                        .setFilter(StructuredQuery.PropertyFilter.in("event", ListValue.of(events)))
                        .build();

                QueryResults<Entity> resultsEvents = txn.run(queryEvents);

                while (resultsEvents.hasNext()) {
                    Entity location = resultsEvents.next();
                    locations.add(new LocationData(location.getString("name"), location.getDouble("latitude"), location.getDouble("longitude"), location.getString("type"), location.getString("event")));
                }

            }

            else{
                Query<Entity> query = Query.newEntityQueryBuilder()
                        .setKind("Location")
                        .setFilter(StructuredQuery.PropertyFilter.eq("type", type))
                        .build();

                QueryResults<Entity> results = txn.run(query);

                while (results.hasNext()) {
                    Entity location = results.next();
                    locations.add(new LocationData(location.getString("name"), location.getDouble("latitude"), location.getDouble("longitude"), location.getString("type"), ""));
                }
            }


            txn.commit();

            return Response.ok(locations).build();

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
