package main.java.pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import main.java.pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import org.apache.commons.codec.digest.DigestUtils;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.logging.Logger;

@Path("/follow")
public class FollowResource {
    private static final Logger LOG = Logger.getLogger(LoginResource.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");

    @POST
    @Path("/{follower}/{followee}")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response follow(@PathParam("follower") String follower, @PathParam("followee") String followee, @QueryParam("tokenId") String tokenId){
        LOG.fine("Attempt to follow user " + followee + " with follower: " + follower);

        Transaction txn = datastore.newTransaction();

        try{
            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", follower))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token == null || !token.getString("token_id").equals(DigestUtils.sha512Hex(tokenId))) {
                LOG.warning("Incorrect token. Please re-login");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }
            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
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
}
