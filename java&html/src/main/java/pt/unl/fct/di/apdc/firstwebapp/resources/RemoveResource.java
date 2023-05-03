package main.java.pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import main.java.pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import main.java.pt.unl.fct.di.apdc.firstwebapp.util.RemoveData;
import org.apache.commons.codec.digest.DigestUtils;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.logging.Logger;

@Path("/remove")
@Consumes(MediaType.APPLICATION_JSON)
public class RemoveResource {

    private static final Logger LOG = Logger.getLogger(LoginResource.class.getName());

    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");
    private final KeyFactory tokenKeyFactory = datastore.newKeyFactory().setKind("Token");


    @DELETE
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response remove(RemoveData data) {
        LOG.fine("Attempt to remove user: " + data.getUsername());

        Key userKey = userKeyFactory.newKey(data.getUsername());

        Transaction txn = datastore.newTransaction();
        try {
            Entity user = txn.get(userKey);
            if (user == null) {
                LOG.warning("User does not exist: " + data.getUsername());
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", data.getTokenUsername()))
                    .newKey(DigestUtils.sha512Hex(data.getTokenId()));

            Entity token = txn.get(tokenKey);

            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Key removerKey = userKeyFactory.newKey(data.getTokenUsername());
            if(txn.get(removerKey).getString("user_state").equals("INACTIVE")){
                LOG.warning("User " + data.getTokenUsername() + " is inactive");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            if (validRemove(data, user)) {
                txn.delete(userKey);
                txn.commit();
                return Response.ok(user.getString("user_username")).build();

            } else {
                txn.commit();
                LOG.warning("You don't have permissions to delete user: " + data.getUsername());
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

    private boolean validRemove(RemoveData data, Entity user){

        String userRole = user.getString("user_role");
        String tokenRole = data.getRole();

        if(user.getString("user_username").equals(data.getTokenUsername()))
            return true;
        if(tokenRole.equals("SU"))
            return true;
        if(tokenRole.equals("GS") && ( userRole.equals("USER") || userRole.equals("GBO") ||  userRole.equals("GA")))
            return true;
        if(tokenRole.equals("GBO") && userRole.equals("USER"))
            return true;
        if(tokenRole.equals("GA") && (userRole.equals("USER") ||  userRole.equals("GBO")))
            return true;

        return false;

    }
}
