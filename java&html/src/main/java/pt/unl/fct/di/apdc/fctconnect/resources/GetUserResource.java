package pt.unl.fct.di.apdc.fctconnect.resources;

import com.google.cloud.datastore.*;
import com.google.cloud.storage.Blob;
import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;
import com.google.gson.Gson;
import pt.unl.fct.di.apdc.fctconnect.util.Token.AuthToken;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.fctconnect.util.Profile.UserData;

import javax.ws.rs.*;

import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Path("/")
@Consumes(MediaType.APPLICATION_JSON)
public class GetUserResource {

    private static final Logger LOG = Logger.getLogger(GetUserResource.class.getName());

    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");

    private final Storage storage = StorageOptions.getDefaultInstance().getService();
    private final String bucketName = "staging.fct-connect-estudasses.appspot.com";
    private final Gson g = new Gson();

    @GET
    @Path("/profile/{username}")
    @Produces(MediaType.APPLICATION_JSON)
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

            String profilePicUrl = "";
            String coverPicUrl = "";

            if(!user.getString("user_profile_pic").equals("")) {
                BlobId blobId = BlobId.of(bucketName, user.getString("user_profile_pic"));
                Blob blob = storage.get(blobId);
                profilePicUrl = blob.getMediaLink();
            }
            if(!user.getString("user_cover_pic").equals("")) {
                BlobId blobId = BlobId.of(bucketName, user.getString("user_cover_pic"));
                Blob blob = storage.get(blobId);
                coverPicUrl = blob.getMediaLink();
            }

            UserData data;

            String role = user.getString("user_role");

            switch (role) {
                case "ALUNO":
                    //TODO: Adicionar nGroups e nNucleos bem
                    data = new UserData(username, user.getString("user_fullname"), user.getString("user_email"), user.getString("user_phone"),
                            role, user.getString("user_privacy"), user.getString("user_about_me"), user.getString("user_department"), user.getString("user_course"),
                            user.getString("user_year"), user.getString("user_city"), nFollowing, nFollowers, nPosts, 0, 0, profilePicUrl, coverPicUrl);
                    break;
                case "PROFESSOR":
                    data = new UserData(username, user.getString("user_fullname"), user.getString("user_email"), user.getString("user_phone"),
                            role, user.getString("user_privacy"), user.getString("user_about_me"), user.getString("user_department"), user.getString("user_office"),
                            user.getString("user_city"), nFollowing, nFollowers, nPosts, profilePicUrl, coverPicUrl);
                    break;
                case "EXTERNO":
                    data = new UserData(username, user.getString("user_fullname"), user.getString("user_email"), user.getString("user_phone"),
                            role, user.getString("user_privacy"), user.getString("user_about_me"), user.getString("user_city"), nFollowing, nFollowers, nPosts,
                            user.getString("user_purpose"), profilePicUrl, coverPicUrl);
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

    @GET
    @Path("/hasEvent/{username}")
    public Response interestedInEvent(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username,
                                      @PathParam("username") String usernamePath, @QueryParam("event") String event) {

        Transaction txn = datastore.newTransaction();

        try{

            Key userKey = userKeyFactory.newKey(usernamePath);
            Entity user = txn.get(userKey);

            if(user == null){
                LOG.warning("User doesn't exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
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

            Key searchedUserKey = userKeyFactory.newKey(usernamePath);
            Entity searchedUser = txn.get(searchedUserKey);

            if(searchedUser == null){
                LOG.warning("User doesn't exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            Key eventKey = datastore.newKeyFactory()
                    .setKind("Event")
                    .newKey(event);

            Entity eventEntity = txn.get(eventKey);

            if(eventEntity == null){
                LOG.warning("Event doesn't exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            List<StringValue> eventList = searchedUser.getList("user_events");

            if(eventList.contains(StringValue.newBuilder(event).build())){
                return Response.status(Response.Status.ACCEPTED).build();
            }
            else{
                return Response.status(Response.Status.NOT_ACCEPTABLE).build();
            }

        }catch (Exception e){
            txn.rollback();
            LOG.severe(e.getMessage());
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }finally {
            if(txn.isActive()){
                txn.rollback();
            }
        }

    }
}
