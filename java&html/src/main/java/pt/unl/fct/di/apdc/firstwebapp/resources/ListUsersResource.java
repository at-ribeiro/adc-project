package main.java.pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.gson.Gson;
import main.java.pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import main.java.pt.unl.fct.di.apdc.firstwebapp.util.ListData;
import main.java.pt.unl.fct.di.apdc.firstwebapp.util.UserData;
import org.apache.commons.codec.digest.DigestUtils;


import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Path("/list")
@Consumes(MediaType.APPLICATION_JSON)
public class ListUsersResource {

    private static final Logger LOG = Logger.getLogger(LoginResource.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");

    private final KeyFactory tokenKeyFactory = datastore.newKeyFactory().setKind("Token");
    private final Gson g = new Gson();
    @POST
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response listUsers(ListData data) {
        LOG.fine("Attempt to list all users");

        Transaction txn = datastore.newTransaction();

        try {
            Key tokenKey = tokenKeyFactory.newKey(DigestUtils.sha512Hex(data.getTokenId()));

            Entity token = txn.get(tokenKey);

            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Key userKey = userKeyFactory.newKey(data.getUsername());
            if(txn.get(userKey).getString("user_state").equals("INACTIVE")){
                LOG.warning("User " + data.getUsername() + " is inactive");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            List<UserData> userList = new ArrayList<>();

            switch (data.getRole()){
                case("USER"):
                    caseUser(userList);
                    break;
                case("GBO"):
                    caseGBO(userList);
                    break;
                case("GS"):
                    caseGS(userList);
                    break;
                case("SU"):
                    caseSU(userList);
                    break;
            }

            txn.commit();

            return Response.ok(g.toJson(userList)).build();


        } catch (Exception e) {
            txn.rollback();
            LOG.severe(e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }

    private void caseUser(List<UserData> userList){
        Query<Entity> query = Query.newEntityQueryBuilder().setKind("User").setFilter(
                StructuredQuery.CompositeFilter.and(
                        StructuredQuery.PropertyFilter.eq("user_role", "USER"),
                        StructuredQuery.PropertyFilter.eq("user_state", "ACTIVE"),
                        StructuredQuery.PropertyFilter.eq("user_privacy", "public")
                )
        ).build();
        QueryResults<Entity> users = datastore.run(query);

        users.forEachRemaining(user ->{
            UserData toAdd = new UserData(user.getString("user_username"), user.getString("user_email"), user.getString("user_fullname"));
            userList.add(toAdd);
        });
    }

    private void caseGBO(List<UserData> userList){
        Query<Entity> query = Query.newEntityQueryBuilder().setKind("User").setFilter(
                StructuredQuery.PropertyFilter.eq("user_role", "USER")
        ).build();
        QueryResults<Entity> users = datastore.run(query);

        users.forEachRemaining(user ->{
            UserData toAdd = new UserData(user.getString("user_username"), user.getString("user_fullname"), user.getString("user_email"),
                    user.getString("user_role"), user.getString("user_privacy"), user.getString("user_state"), user.getTimestamp("user_creation_time").toDate());
            userList.add(toAdd);
        });
    }

    private void caseGS(List<UserData> userList) {
        Query<Entity> query = Query.newEntityQueryBuilder().setKind("User").setFilter(
                        StructuredQuery.PropertyFilter.eq("user_role", "USER")
        ).build();
        QueryResults<Entity> users = datastore.run(query);

        users.forEachRemaining(user ->{
            UserData toAdd = new UserData(user.getString("user_username"), user.getString("user_fullname"), user.getString("user_email"),
                    user.getString("user_role"), user.getString("user_privacy"), user.getString("user_state"), user.getTimestamp("user_creation_time").toDate());
            userList.add(toAdd);
        });

        query = Query.newEntityQueryBuilder().setKind("User").setFilter(
                StructuredQuery.PropertyFilter.eq("user_role", "GBO")
        ).build();

        users = datastore.run(query);

        users.forEachRemaining(user ->{
            UserData toAdd = new UserData(user.getString("user_username"), user.getString("user_fullname"), user.getString("user_email"),
                    user.getString("user_role"), user.getString("user_privacy"), user.getString("user_state"), user.getTimestamp("user_creation_time").toDate());
            userList.add(toAdd);
        });
    }

    private void caseSU(List<UserData> userList) {
        Query<Entity> query = Query.newEntityQueryBuilder().setKind("User").build();
        QueryResults<Entity> users = datastore.run(query);

        users.forEachRemaining(user ->{
            UserData toAdd = new UserData(user.getString("user_username"), user.getString("user_fullname"), user.getString("user_email"),
                    user.getString("user_role"), user.getString("user_privacy"), user.getString("user_state"), user.getTimestamp("user_creation_time").toDate());
            userList.add(toAdd);
        });
    }

}
