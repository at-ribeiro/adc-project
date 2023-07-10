package pt.unl.fct.di.apdc.fctconnect.resources;

import com.google.cloud.datastore.*;
import pt.unl.fct.di.apdc.fctconnect.util.Token.AuthToken;
import org.apache.commons.codec.digest.DigestUtils;

import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import java.util.logging.Logger;

@Path("/follow")
public class FollowResource {
    private static final Logger LOG = Logger.getLogger(FollowResource.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");

    @POST
    @Path("/{follower}/{followee}")
    public Response follow(@PathParam("follower") String follower, @PathParam("followee") String followee, @HeaderParam("Authorization") String tokenId){
        LOG.fine("Attempt to follow user " + followee + " with follower: " + follower);

        Transaction txn = datastore.newTransaction();

        try{
            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", follower))
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

            Key followerKey = userKeyFactory.newKey(follower);
            Entity followerEntity = txn.get(followerKey);
            if (followerEntity.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Key followeeKey = userKeyFactory.newKey(followee);
            Entity followeeEntity = txn.get(followeeKey);
            if (followeeEntity == null){
                LOG.warning("Followee does not exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            //TODO: VERIFCAR CASOS EM QUE O FOLLOWEE É PRIVADO

            Key followKey = datastore.newKeyFactory()
                            .setKind("Follow")
                            .addAncestor(PathElement.of("User", follower))
                            .newKey(followee);

            Entity followEntity = Entity.newBuilder(followKey)
                                    .set("followee", followee)
                                    .build();

            Key followedKey = datastore.newKeyFactory()
                              .setKind("Followed")
                              .addAncestor(PathElement.of("User", followee))
                              .newKey(follower);

            Entity followedEntity = Entity.newBuilder(followedKey)
                                    .set("follower", follower)
                                    .build();

            txn.put(followEntity, followedEntity);
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

    @DELETE
    @Path("/{follower}/{followee}")
    public Response unfollow(@PathParam("follower") String follower, @PathParam("followee") String followee, @HeaderParam("Authorization") String tokenId){
        LOG.fine("Attempt to unfollow user " + followee + " with follower: " + follower);

        Transaction txn = datastore.newTransaction();

        try{
            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", follower))
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

            Key followerKey = userKeyFactory.newKey(follower);
            Entity followerEntity = txn.get(followerKey);
            if (followerEntity == null){
                LOG.warning("Follower does not exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            if (followerEntity.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Key followeeKey = userKeyFactory.newKey(followee);
            Entity followeeEntity = txn.get(followeeKey);
            if (followeeEntity == null){
                LOG.warning("Followee does not exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            Key followKey = datastore.newKeyFactory()
                    .setKind("Follow")
                    .addAncestor(PathElement.of("User", follower))
                    .newKey(followee);

            Entity followEntity = txn.get(followKey);

            if(followEntity == null){
                LOG.warning( follower + " doesn't follow " + followee);
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            Key followedKey = datastore.newKeyFactory()
                    .setKind("Followed")
                    .addAncestor(PathElement.of("User", followee))
                    .newKey(follower);

            Entity followedEntity = txn.get(followedKey);

            if(followedEntity == null){
                LOG.warning(followee + " not followed by " + follower);
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            txn.delete(followKey, followedKey);
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
    @Path("/{follower}/{followee}")
    public Response followExists(@PathParam("follower") String follower, @PathParam("followee") String followee, @HeaderParam("Authorization") String tokenId){
        LOG.fine("Attempt to unfollow user " + followee + " with follower: " + follower);

        Transaction txn = datastore.newTransaction();

        try{
            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", follower))
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

            Key followerKey = userKeyFactory.newKey(follower);
            Entity followerEntity = txn.get(followerKey);
            if (followerEntity == null){
                LOG.warning("Follower does not exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            if (followerEntity.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Key followeeKey = userKeyFactory.newKey(followee);
            Entity followeeEntity = txn.get(followeeKey);
            if (followeeEntity == null){
                LOG.warning("Followee does not exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            Key followKey = datastore.newKeyFactory()
                    .setKind("Follow")
                    .addAncestor(PathElement.of("User", follower))
                    .newKey(followee);

            Entity followEntity = txn.get(followKey);

            if(followEntity == null){
                LOG.warning( follower + " doesn't follow " + followee);
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            Key followedKey = datastore.newKeyFactory()
                    .setKind("Followed")
                    .addAncestor(PathElement.of("User", followee))
                    .newKey(follower);

            Entity followedEntity = txn.get(followedKey);

            if(followedEntity == null){
                LOG.warning(followee + " not followed by " + follower);
                return Response.status(Response.Status.NOT_FOUND).build();
            }

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
}
