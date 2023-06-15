package pt.unl.fct.di.apdc.firstwebapp.resources;


import com.google.cloud.datastore.*;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.ReportData;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Path("/report")
public class ReportResource {


    private static final Logger LOG = Logger.getLogger(ActivityResource.class.getName());

    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");


    @POST
    @Path("/{postId}")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response createReport(@HeaderParam("Authorization") String tokenId,
                                 @HeaderParam("User") String username,
                                 @PathParam("postId") String postId,
                                 ReportData data){

        Transaction txn = datastore.newTransaction();

        try{

            Key userKey = userKeyFactory.newKey(username);
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
                    .addAncestor(PathElement.of("User", username))
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

            Key postKey = datastore.newKeyFactory()
                            .setKind("Post")
                            .addAncestor(PathElement.of("User", data.getPostCreator()))
                            .newKey(data.getPostId());

            Entity post = txn.get(postKey);

            if(post == null){
                LOG.warning("Post doesn't exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            Key reportKey = datastore.newKeyFactory()
                            .setKind("Report")
                            .addAncestor(PathElement.of("Post", data.getPostId()))
                            .newKey(data.getTimestamp());

            Entity report = Entity.newBuilder(reportKey)
                            .set("report_creator", username)
                            .set("report_post_creator", data.getPostCreator())
                            .set("report_reason", data.getReason())
                            .set("report_comment", data.getComment())
                            .set("report_timestamp", data.getTimestamp())
                            .build();

            txn.put(report);
            txn.commit();

            return Response.ok().build();

        }catch (Exception e){
            LOG.warning(e.getMessage());
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }finally {
            if(txn.isActive()) {
                txn.rollback();
            }
        }
    }

    @GET
    @Path("/{postId}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getReports(@HeaderParam("Authorization") String tokenId,
                               @HeaderParam("User") String username,
                               @PathParam("postId") String postId){

        Transaction txn = datastore.newTransaction();

        try{

            Key userKey = userKeyFactory.newKey(username);
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
                    .addAncestor(PathElement.of("User", username))
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

            Key postKey = datastore.newKeyFactory()
                            .setKind("Post")
                            .addAncestor(PathElement.of("User", username))
                            .newKey(postId);

            Query<Entity> query = Query.newEntityQueryBuilder()
                                    .setKind("Report")
                                    .setFilter(StructuredQuery.PropertyFilter.hasAncestor(postKey))
                                    .build();

            QueryResults<Entity> reports = txn.run(query);

            List<ReportData> reportsArray = new ArrayList<>();

            reports.forEachRemaining(report -> {
                ReportData data = new ReportData(report.getString("report_creator"),
                                                 postId,
                                                 report.getString("report_post_creator"),
                                                 report.getString("report_reason"),
                                                 report.getString("report_comment"),
                                                 report.getString("report_timestamp"));
                reportsArray.add(data);
            });

            return Response.ok(reportsArray).build();

        }catch (Exception e){
            LOG.warning(e.getMessage());
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }finally {
            if(txn.isActive()) {
                txn.rollback();
            }
        }
    }



}
