package main.java.pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.gson.Gson;
import main.java.pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import main.java.pt.unl.fct.di.apdc.firstwebapp.util.UpdateData;
import org.apache.commons.codec.digest.DigestUtils;

import javax.ws.rs.Consumes;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.logging.Logger;

@Path("/get")
@Consumes(MediaType.APPLICATION_JSON)
public class GetUserResource {

    private static final Logger LOG = Logger.getLogger(LoginResource.class.getName());

    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");

    private final KeyFactory tokenKeyFactory = datastore.newKeyFactory().setKind("Token");

    private final Gson g = new Gson();

    @GET
    @Path("/")
    public Response getUser(@QueryParam("username")String username,@QueryParam("tUser") String tUser,@QueryParam("role")String role, @QueryParam("tokenId")String tokenId) {
        LOG.fine("Attempt to get user " + username);

        Transaction txn = datastore.newTransaction();

        try {

            Key tokenKey = tokenKeyFactory.newKey(DigestUtils.sha512Hex(tokenId));

            Entity token = txn.get(tokenKey);

            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Key userKey = userKeyFactory.newKey(tUser);
            Entity user = txn.get(userKey);
            if (user.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            userKey = userKeyFactory.newKey(username);
            user = txn.get(userKey);
            if (user == null){
                LOG.warning("User doesn't exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            if(!(role.equals("SU") || username.equals(tUser))){
                LOG.warning("Wrong Role");
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            UpdateData data = new UpdateData(username, "", "",  user.getString("user_fullname"), user.getString("user_email"),
                    user.getString("user_privacy"), user.getString("user_homephone"), user.getString("user_mobilephone"), user.getString("user_occupation"),
                    user.getString("user_address"), user.getString("user_nif"), user.getString("user_role"), user.getString("user_state"));

            return Response.ok(g.toJson(data)).build();


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
}
