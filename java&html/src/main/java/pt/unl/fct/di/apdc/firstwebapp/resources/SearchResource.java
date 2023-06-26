package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.cloud.storage.Blob;
import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;
import com.google.gson.Gson;
import pt.unl.fct.di.apdc.firstwebapp.util.SearchUserData;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Path("/search")
public class SearchResource {

    private static final Logger LOG = Logger.getLogger(LoginResource.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    private final Storage storage = StorageOptions.getDefaultInstance().getService();
    private final String bucketName = "staging.fct-connect-estudasses.appspot.com";
    private final Gson g = new Gson();

    @GET
    @Path("/user")
    @Produces(MediaType.APPLICATION_JSON)
    public Response searchUser(@QueryParam("query") String query){

        Transaction txn = datastore.newTransaction();

        try{

            String lowerBound = query;
            String upperBound = query + "\ufffd"; // Next possible Unicode character

            // Query to find users with usernames greater than or equal to the search input
            Query<Entity> queryGreaterThanOrEqual = Query.newEntityQueryBuilder()
                    .setKind("User")
                    .setFilter(StructuredQuery.PropertyFilter.ge("user_username", lowerBound))
                    .setLimit(5)
                    .build();

            // Query to find users with usernames less than the upper bound
            Query<Entity> queryLessThan = Query.newEntityQueryBuilder()
                    .setKind("User")
                    .setFilter(StructuredQuery.PropertyFilter.lt("user_username", upperBound))
                    .setLimit(5)
                    .build();

            QueryResults<Entity> greaterThanOrEqualResults = txn.run(queryGreaterThanOrEqual);
            QueryResults<Entity> lessThanResults = txn.run(queryLessThan);

            List<SearchUserData> matchedUsers = new ArrayList<>();
            while (greaterThanOrEqualResults.hasNext() && lessThanResults.hasNext() && matchedUsers.size()<=5) {
                Entity user1 = greaterThanOrEqualResults.next();
                Entity user2 = lessThanResults.next();

                String imageName1 = user1.getString("user_profile_pic");
                String imageName2 = user2.getString("user_profile_pic");

                BlobId blobId;

                if(imageName1 == null || imageName1.equals(""))
                    blobId = BlobId.of(bucketName, "default_profile.jpg");
                else
                    blobId = BlobId.of(bucketName, imageName1);

                Blob blob = storage.get(blobId);

                String profilePic1 = blob.getMediaLink();

                if(imageName2 == null || imageName2.equals(""))
                    blobId = BlobId.of(bucketName, "default_profile.jpg");
                else
                    blobId = BlobId.of(bucketName, imageName2);

                blob = storage.get(blobId);

                String profilePic2 = blob.getMediaLink();

                SearchUserData data1 = new SearchUserData(user1.getString("user_username"),
                        user1.getString("user_fullname"), profilePic1);

                SearchUserData data2 = new SearchUserData(user2.getString("user_username"),
                        user2.getString("user_fullname"), profilePic2);

                // If the username matches in both queries, add it to the result list
                if (user1.getString("user_username").startsWith(query) && !matchedUsers.contains(data1)) {
                    matchedUsers.add(data1);
                }
                if(user2.getString("user_username").startsWith(query) && !matchedUsers.contains(data2)){
                    matchedUsers.add(data2);
                }
            }

            return Response.ok(matchedUsers).build();

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
