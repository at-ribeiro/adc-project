package pt.unl.fct.di.apdc.fctconnect.resources;

import com.google.cloud.datastore.*;
import com.google.cloud.storage.Blob;
import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;
import pt.unl.fct.di.apdc.fctconnect.util.Token.AuthToken;
import org.apache.commons.codec.digest.DigestUtils;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.logging.Logger;

@Path("/remove")
@Consumes(MediaType.APPLICATION_JSON)
public class RemoveResource {

    private static final Logger LOG = Logger.getLogger(RemoveResource.class.getName());

    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");
    private final String bucketName = "fct-connect-estudasses.appspot.com";
    private final Storage storage = StorageOptions.getDefaultInstance().getService();



    @DELETE
    @Path("/{username}")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response remove(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String deleter, @PathParam("username") String username) {
        LOG.fine("Attempt to remove user: " + username);

        Transaction txn = datastore.newTransaction();

        try {
            Key deleterKey = userKeyFactory.newKey(deleter);

            Entity deleterEntity = txn.get(deleterKey);
            if (deleterEntity == null) {
                LOG.warning("User does not exist: " + deleter);
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            if(deleterEntity.getString("user_state").equals("INACTIVE")){
                LOG.warning("User " + deleter + " is inactive");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", deleter))
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

            if (user == null) {
                LOG.warning("User does not exist: " + username);
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            if (validRemove(username, deleter)) {

                Query<Entity> postQuery = Query.newEntityQueryBuilder()
                        .setKind("Post")
                        .setFilter(StructuredQuery.PropertyFilter.hasAncestor(userKey))
                        .build();

                QueryResults<Entity> postResults = txn.run(postQuery);

                while(postResults.hasNext()){
                    Entity post = postResults.next();

                    if (!post.getString("image").equals("")) {

                        BlobId blobId = BlobId.of(bucketName,
                                post.getString("user") + "-" + post.getString("image"));
                        Blob blob = storage.get(blobId);
                        if (blob != null) {
                            storage.delete(blobId);
                        }
                    }

                    txn.delete(post.getKey());
                }

                Query<Entity> commentQuery = Query.newEntityQueryBuilder()
                        .setKind("Comment")
                        .setFilter(StructuredQuery.PropertyFilter.eq("user", username))
                        .build();

                QueryResults<Entity> commentResults = txn.run(commentQuery);

                while(commentResults.hasNext()){
                    Entity comment = commentResults.next();
                    txn.delete(comment.getKey());
                }

                Query<Entity> eventQuery = Query.newEntityQueryBuilder()
                        .setKind("Event")
                        .setFilter(StructuredQuery.PropertyFilter.eq("event_creator", username))
                        .build();

                QueryResults<Entity> eventResults = txn.run(eventQuery);

                while(eventResults.hasNext()){
                    Entity event = eventResults.next();

                    if (!event.getString("event_image").equals("")) {

                        BlobId blobId = BlobId.of(bucketName, event.getString("event_image"));
                        Blob blob = storage.get(blobId);
                        if(blob != null)
                            storage.delete(blobId);
                    }

                    BlobId blobId = BlobId.of(bucketName, event.getString("event_qr"));
                    Blob blob = storage.get(blobId);
                    if(blob != null)
                        storage.delete(blobId);

                    txn.delete(event.getKey());

                }

                Query<Entity> verificiationQuery = Query.newEntityQueryBuilder()
                        .setKind("Verification")
                        .setFilter(StructuredQuery.PropertyFilter.eq("token_user", username))
                        .build();

                QueryResults<Entity> verificationResults = txn.run(verificiationQuery);

                while(verificationResults.hasNext()){
                    Entity verification = verificationResults.next();
                    txn.delete(verification.getKey());
                }

                Query<Entity> activityQuery = Query.newEntityQueryBuilder()
                        .setKind("Activity")
                        .setFilter(StructuredQuery.PropertyFilter.hasAncestor(userKey))
                        .build();

                QueryResults<Entity> activityResults = txn.run(activityQuery);

                while(activityResults.hasNext()){
                    Entity activity = activityResults.next();
                    txn.delete(activity.getKey());
                }

                if(!user.getString("user_profile_pic").equals("")){
                    BlobId blobId = BlobId.of(bucketName, user.getString("user_profile_pic"));
                    Blob blob = storage.get(blobId);
                    if(blob != null)
                        storage.delete(blobId);
                }

                if(!user.getString("user_cover_pic").equals("")){
                    BlobId blobId = BlobId.of(bucketName, user.getString("user_cover_pic"));
                    Blob blob = storage.get(blobId);
                    if(blob != null)
                        storage.delete(blobId);
                }

                txn.delete(userKey, tokenKey);
                txn.commit();
                return Response.ok(user.getString("user_username")).build();

            } else {
                txn.commit();
                LOG.warning("You don't have permissions to delete user: " + username);
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

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

    private boolean validRemove(String username, String deleter) {
        return username.equals(deleter);
    }


}

