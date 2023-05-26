package pt.unl.fct.di.apdc.firstwebapp.resources;


import com.google.cloud.datastore.*;
import com.google.gson.Gson;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.CommentGetData;
import pt.unl.fct.di.apdc.firstwebapp.util.CommentPostData;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Path("/comment/")
public class CommentResource {

    private static final Logger LOG = Logger.getLogger(LoginResource.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");
    private final Gson g = new Gson();


    @POST
    @Path("/{creator}/{post}")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response addComment(@HeaderParam("Authorization") String tokenId, @PathParam("creator") String creator,
                               @PathParam("post") String postId, CommentPostData data) {

        LOG.fine("Attempt to comment on post: " + postId);

        Transaction txn = datastore.newTransaction();

        try {

            Key postKey = datastore.newKeyFactory()
                    .setKind("Post")
                    .addAncestor(PathElement.of("User", creator))
                    .newKey(postId);

            Entity post = txn.get(postKey);

            if(post == null){
                LOG.warning("Post does not exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            Key userKey = userKeyFactory.newKey(data.getUser());
            Entity userEntity = txn.get(userKey);
            if(userEntity == null){
                LOG.warning("User doesn't exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            if (userEntity.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }


            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", data.getUser()))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token == null || !token.getString("token_hashed_id").equals(DigestUtils.sha512Hex(tokenId))) {
                LOG.warning("Incorrect token. Please re-login");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }
            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Key commentKey = datastore.newKeyFactory()
                    .setKind("Comment")
                    .addAncestor(PathElement.of("User", creator))
                    .addAncestor(PathElement.of("Post", postId))
                    .newKey(data.getTimestamp());

            LOG.warning("DEBUG COMENTÁRIOOOS keyPost = " + commentKey);

            Entity comment = Entity.newBuilder(commentKey)
                    .set("user", data.getUser())
                    .set("text", StringValue.newBuilder(data.getText()).setExcludeFromIndexes(true).build())
                    .set("timestamp", data.getTimestamp())
                    .build();

            txn.put(comment);
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
    @Path("/{creator}/{post}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response addComment(@HeaderParam("Authorization") String tokenId, @PathParam("creator") String creator,
                               @QueryParam("searcher") String searcher, @PathParam("post") String postId) {

        LOG.fine("Attempt to comment on post: " + postId);

        Transaction txn = datastore.newTransaction();

        try {

            Key creatorKey = userKeyFactory.newKey(creator);
            Entity creatorEntity = txn.get(creatorKey);
            if (creatorEntity == null) {
                LOG.warning("Creator doesn't exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            Key postKey = datastore.newKeyFactory()
                    .setKind("Post")
                    .addAncestor(PathElement.of("User", creator))
                    .newKey(postId);

            Entity post = txn.get(postKey);

            if (post == null) {
                LOG.warning("Post does not exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            Key userKey = userKeyFactory.newKey(searcher);
            Entity userEntity = txn.get(userKey);
            if (userEntity == null) {
                LOG.warning("User doesn't exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            if (userEntity.getString("user_state").equals("INACTIVE")) {
                LOG.warning("Inactive User.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }


            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", searcher))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token == null || !token.getString("token_hashed_id").equals(DigestUtils.sha512Hex(tokenId))) {
                LOG.warning("Incorrect token. Please re-login");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }
            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            StructuredQuery.OrderBy descendingTimestamp = StructuredQuery.OrderBy.desc("timestamp");

            Query<Entity> commentQuery = Query.newEntityQueryBuilder()
                                        .setKind("Comment")
                                        .setFilter(StructuredQuery.PropertyFilter.hasAncestor(postKey))
                                        .addOrderBy(descendingTimestamp)
                                        .build();


            LOG.warning("DEBUG DO COMENTÁRIOOOOOOOOO key = " + postKey);

            QueryResults<Entity> commentResults = datastore.run(commentQuery);

            List<CommentGetData> toSend = new ArrayList<>();

            commentResults.forEachRemaining(comment -> {
                LOG.warning("DEBUG DO COMENTÁRIOOOOOOOOO comment = " + comment);

                toSend.add(new CommentGetData(
                        comment.getString("user"),
                        comment.getString("text"),
                        comment.getLong("timestamp")
                ));

            });


            return Response.ok(g.toJson(toSend)).build();

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