package pt.unl.fct.di.apdc.fctconnect.resources;

import com.google.cloud.datastore.*;
import org.apache.commons.codec.digest.DigestUtils;

import javax.ws.rs.DELETE;
import javax.ws.rs.HeaderParam;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.core.Response;
import java.util.logging.Logger;

@Path("/logout/{username}")
public class LogoutResource {

    private static final Logger LOG = Logger.getLogger(LogoutResource.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    @DELETE
    @Path("/")
    public Response logout(@HeaderParam("Authorization") String tokenId, @PathParam("username") String username) {

        LOG.fine("Attempting to logout user: " + username);

        Transaction txn = datastore.newTransaction();

        try {

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", username))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token != null) {
                if(!token.getString("token_hashed_id").equals(DigestUtils.sha512Hex(tokenId))){
                    LOG.warning("Token id doesn't belong to user");
                    return Response.status(Response.Status.UNAUTHORIZED).build();
                }

                txn.delete(tokenKey);
                txn.commit();

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
