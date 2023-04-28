package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.Timestamp;
import com.google.cloud.datastore.*;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.LoginData;


import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.logging.Logger;
import com.google.gson.Gson;

@Path("/login")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class LoginResource {

    private static final Logger LOG = Logger.getLogger(LoginResource.class.getName());

    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");
    private final Gson g = new Gson();

    public LoginResource(){}

    @POST
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response login(LoginData data) {

        LOG.fine("Attempt to login user: " + data.getUsername());

        Key userKey = userKeyFactory.newKey(data.getUsername());

        Transaction txn = datastore.newTransaction();
        try {
            Entity user = txn.get(userKey);

            LOG.fine("Found user: " + user);

            if (user == null) {
                LOG.warning("Failed login attempt for username: " + data.getUsername());
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            String hashedPWD = user.getString("user_pwd");

            if (hashedPWD.equals(DigestUtils.sha512Hex(data.getPassword()))) {

                //return token

                AuthToken token = new AuthToken(data.getUsername(), user.getString("user_role"));
                LOG.info("User '" + data.getUsername() + "' logged in successfully.");
                return Response.ok(g.toJson(token)).build();

            } else {
                //Incorrect password
                LOG.warning("Wrong password for username: " + data.getUsername());
                return Response.status(Response.Status.FORBIDDEN).build();
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


}
