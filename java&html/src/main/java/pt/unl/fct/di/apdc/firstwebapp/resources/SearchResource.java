package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.gson.Gson;
import pt.unl.fct.di.apdc.firstwebapp.util.SearchUserData;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Logger;
@Path("/search")
public class SearchResource {

    private static final Logger LOG = Logger.getLogger(LoginResource.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final Gson g = new Gson();

    @GET
    @Path("/user")
    @Produces()
    public Response searchUser(@QueryParam("query") String query){

        Transaction txn = datastore.newTransaction();

        try{

            String lowerBound = query;
            String upperBound = query + "\ufffd"; // Next possible Unicode character

            // Query to find users with usernames greater than or equal to the search input
            Query<Entity> queryGreaterThanOrEqual = Query.newEntityQueryBuilder()
                    .setKind("User")
                    .setFilter(StructuredQuery.PropertyFilter.ge("user_username", lowerBound))
                    .build();

            // Query to find users with usernames less than the upper bound
            Query<Entity> queryLessThan = Query.newEntityQueryBuilder()
                    .setKind("User")
                    .setFilter(StructuredQuery.PropertyFilter.lt("user_username", upperBound))
                    .build();

            QueryResults<Entity> greaterThanOrEqualResults = datastore.run(queryGreaterThanOrEqual);
            QueryResults<Entity> lessThanResults = datastore.run(queryLessThan);

            List<SearchUserData> matchedUsers = new ArrayList<>();
            while (greaterThanOrEqualResults.hasNext() && lessThanResults.hasNext() && matchedUsers.size()<=5) {
                Entity user1 = greaterThanOrEqualResults.next();
                Entity user2 = lessThanResults.next();

                SearchUserData data1 = new SearchUserData(user1.getString("user_username"),
                        user1.getString("user_fullname"));

                SearchUserData data2 = new SearchUserData(user2.getString("user_username"),
                        user2.getString("user_fullname"));

                // If the username matches in both queries, add it to the result list
                if (user1.getString("user_username").startsWith(query)) {
                    matchedUsers.add(data1);
                }
                if(user2.getString("user_username").startsWith(query) && !data1.equals(data2)){
                    matchedUsers.add(data2);
                }
            }
            return Response.ok(g.toJson(matchedUsers)).build();
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
