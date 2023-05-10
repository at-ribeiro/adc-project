package main.java.pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import javax.ws.rs.DELETE;
import javax.ws.rs.Path;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Response;
import java.util.logging.Logger;

@Path("/logout")
public class LogoutResource {

    private static final Logger LOG = Logger.getLogger(LoginResource.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    @DELETE
    @Path("/")
    public Response logout(@QueryParam("username") String username) {

        LOG.fine("Attempting to logout user: " + username);

        Transaction txn = datastore.newTransaction();

        try {

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", username))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token != null) {

                txn.delete(tokenKey);

                return Response.ok().build();

            } else {

                return Response.status(Response.Status.NOT_FOUND).build();

            }

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
