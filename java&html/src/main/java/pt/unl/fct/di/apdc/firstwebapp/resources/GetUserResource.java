package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.gson.Gson;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.UpdateData;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.UserData;

import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.*;

import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Path("/profile")
@Consumes(MediaType.APPLICATION_JSON)
public class GetUserResource {

    private static final Logger LOG = Logger.getLogger(GetUserResource.class.getName());

    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");
    private final Gson g = new Gson();

    @GET
    @Path("/{username}")
    public Response getUser(@PathParam("username")String username, @QueryParam("searcher") String searcher, @HeaderParam("Authorization") String tokenId) {
        LOG.fine("Attempt to get user " + username);

        Transaction txn = datastore.newTransaction();

        try {

            Key searcherKey = userKeyFactory.newKey(searcher);
            Entity searcherEntity = txn.get(searcherKey);
            if(searcherEntity == null){
                LOG.warning("Searcher doesn't exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            if (searcherEntity.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive Searcher.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", searcher))
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
            if (user == null){
                LOG.warning("User doesn't exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            if (user.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Query<Entity> followingQuery = Query.newEntityQueryBuilder()
                    .setKind("Follow")
                    .setFilter(StructuredQuery.PropertyFilter.hasAncestor(userKey))
                    .build();

            QueryResults<Entity> followingResults = txn.run(followingQuery);

            List<Entity> followeesList = new ArrayList<>();
            followingResults.forEachRemaining(followeesList::add);

            int nFollowing = followeesList.size();

            Query<Entity> followersQuery = Query.newEntityQueryBuilder()
                    .setKind("Followed")
                    .setFilter(StructuredQuery.PropertyFilter.hasAncestor(userKey))
                    .build();

            QueryResults<Entity> followersResults = txn.run(followersQuery);

            List<Entity> followerList = new ArrayList<>();
            followersResults.forEachRemaining(followerList::add);

            int nFollowers = followerList.size();

            Query<Entity> postsQuery = Query.newEntityQueryBuilder()
                    .setKind("Post")
                    .setFilter(StructuredQuery.PropertyFilter.hasAncestor(userKey))
                    .build();

            QueryResults<Entity> postResults = txn.run(postsQuery);

            List<Entity> postsList = new ArrayList<>();
            postResults.forEachRemaining(postsList::add);

            int nPosts = postsList.size();


            UserData data;

            String role = user.getString("user_role");

            switch (role) {
                case "STUDENT":
                    //TODO: Adicionar nGroups e nNucleos bem
                    data = new UserData(username, user.getString("user_fullname"), user.getString("user_email"),
                            user.getString("user_role"), user.getString("user_about_me"), user.getString("user_department"),
                            user.getString("user_course"), user.getString("user_year"), user.getString("user_city"), nFollowing, nFollowers, nPosts, 0, 0);
                    break;
                case "PROF":
                    data = new UserData(username, user.getString("user_fullname"), user.getString("user_email"),
                            role, user.getString("user_about_me"), user.getString("user_city"), user.getString("user_department"), nFollowing, nFollowers, nPosts);
                    break;
                case "EXTERNAL":
                    data = new UserData(username, user.getString("user_fullname"), user.getString("user_email"),
                            role, user.getString("user_about_me"), user.getString("user_city"), nFollowing, nFollowers, nPosts, user.getString("user_purpose"));
                    break;
                default:
                    return Response.status(Response.Status.NOT_FOUND).build();
            }

            return Response.ok(g.toJson(data)).build();


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
