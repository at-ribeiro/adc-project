package pt.unl.fct.di.apdc.firstwebapp.resources;


import com.google.cloud.datastore.*;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.ReportDeleteData;
import pt.unl.fct.di.apdc.firstwebapp.util.ReportGetData;
import pt.unl.fct.di.apdc.firstwebapp.util.ReportPostData;

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
                                 ReportPostData data){

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
                            .newKey("report");

            List<Value<String>> reporters = new ArrayList<>();
            List<Value<String>> reasons = new ArrayList<>();
            List<Value<String>> comments = new ArrayList<>();
            long reportCount = 1;

            if(txn.get(reportKey) != null){
                reporters = new ArrayList<>(txn.get(reportKey).getList("report_reporters"));
                reasons = new ArrayList<>(txn.get(reportKey).getList("report_reasons"));
                comments = new ArrayList<>(txn.get(reportKey).getList("report_comments"));
                reportCount = txn.get(reportKey).getLong("report_count") + 1;
            }

            StringValue reporter = StringValue.newBuilder(username).build();

            if(!reasons.contains(reporter)){
                reporters.add(reporter);
            }

            StringValue reason = StringValue.newBuilder(data.getReason()).build();

            if(!reasons.contains(reason)){
                reasons.add(reason);
            }

            comments.add(StringValue.newBuilder(data.getComment()).build());


            Entity report = Entity.newBuilder(reportKey)
                            .set("report_reporters", reporters)
                            .set("report_post_id", data.getPostId())
                            .set("report_post_creator", data.getPostCreator())
                            .set("report_reasons", ListValue.of(reasons))
                            .set("report_comments", ListValue.of(comments))
                            .set("report_count", reportCount)
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
    @Path("/")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getReports(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username){

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

            Query<Entity> query = Query.newEntityQueryBuilder()
                                    .setKind("Report")
                                    .addOrderBy(StructuredQuery.OrderBy.desc("report_count"))
                                    .build();

            QueryResults<Entity> reports = txn.run(query);

            List<ReportGetData> reportsArray = new ArrayList<>();

            reports.forEachRemaining(report -> {

                List<String> reporters = new ArrayList<>();
                List<String> reasons = new ArrayList<>();
                List<String> comments = new ArrayList<>();

                report.getList("report_reporters").forEach(reporter -> {
                    reporters.add(reporter.get().toString());
                });
                report.getList("report_reasons").forEach(reason -> {
                    reasons.add(reason.get().toString());
                });
                report.getList("report_comments").forEach(comment -> {
                    comments.add(comment.get().toString());
                });


                ReportGetData data = new ReportGetData(
                        reporters,
                        report.getString("report_post_id"),
                        report.getString("report_post_creator"),
                        reasons,
                        comments,
                        report.getLong("report_count"));
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

    @DELETE
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response deleteReport(@HeaderParam("Authorization") String tokenId,
                                 @HeaderParam("User") String username,
                                 ReportDeleteData data) {

        Transaction txn = datastore.newTransaction();

        try {


            Key userKey = userKeyFactory.newKey(username);
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

            for(String id: data.getIds()){
                Key alertKey = datastore.newKeyFactory()
                        .setKind("Report")
                        .addAncestor(PathElement.of("Post", id))
                        .newKey("report");

                if(txn.get(alertKey) == null){
                    LOG.warning("No reports for " + id + " doesn't exist");
                    return Response.status(Response.Status.NOT_FOUND).build();
                }

                txn.delete(alertKey);
            }

            txn.commit();

            return Response.ok().build();

        } catch (Exception e) {
            LOG.warning(e.getMessage());
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }

        }
    }


}
