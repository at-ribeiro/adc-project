package main.java.pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.gson.Gson;
import main.java.pt.unl.fct.di.apdc.firstwebapp.util.UserData;

import javax.ws.rs.*;

import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Path("/search")
@Produces(MediaType.APPLICATION_JSON)
public class SearchUserResource {

    private static final Logger LOG = Logger.getLogger(LoginResource.class.getName());

    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");
    private final Gson g = new Gson();

    @GET
    @Path("/")
    public Response getUser(@QueryParam("name") String username, @QueryParam("user") String searchName) {

        Transaction txn = datastore.newTransaction();

        try {

            Key userKey = userKeyFactory.newKey(username);
            Entity user = txn.get(userKey);

            if (user == null) {
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            /**
             if (user.getString("user_state").equals("INACTIVE")){
             return Response.status(Response.Status.UNAUTHORIZED).build();
             }
             */

            // Build query to get users that match searchName
            Query<Entity> query = Query.newEntityQueryBuilder().setKind("User").setFilter(
                            StructuredQuery.CompositeFilter.and(
                                    StructuredQuery.PropertyFilter.eq("user_role", "USER")
                            )
                    ).setLimit(3)
                    .build();
            // Execute query and get results
            QueryResults<Entity> queryResults = datastore.run(query);
            List<UserData> users = new ArrayList<>();
            while (queryResults.hasNext()) {
                Entity entity = queryResults.next();
                if(entity.getString("user_fullname").contains(searchName) && users.size() < 3){
                    UserData toAdd = new UserData(entity.getString("user_username"), entity.getString("user_fullname"), entity.getString("user_email"));
                    users.add(toAdd);

                }
            }
            LOG.info("ola");
            LOG.info(searchName);

            return Response.ok(g.toJson(users)).build();


        } catch (Exception e) {
            txn.rollback();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }
}
