package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.CPData;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.logging.Logger;

@Path("/changepwd")
@Consumes(MediaType.APPLICATION_JSON)
public class ChangePwdResource {

    private static final Logger LOG = Logger.getLogger(LoginResource.class.getName());

    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");

    @PUT
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response updatePwd(CPData data) {
        LOG.fine("Attempt to update user: " + data.getUsername());

        Key userKey = userKeyFactory.newKey(data.getUsername());

        Transaction txn = datastore.newTransaction();
        try {
            Entity user = txn.get(userKey);

            String newPassword = data.getNewPassword();

            if(newPassword == null || !data.valid()){
                LOG.info("newPass: " + newPassword);
                return Response.status(Response.Status.BAD_REQUEST).build();
            }

            AuthToken token = new AuthToken("", "");
            if (token.expired(data.getExpiration())) {
                LOG.warning("Your token has expired. Please re-login.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            if (user.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            String hashedPWD = (String) user.getString("user_pwd");

            if (hashedPWD.equals(DigestUtils.sha512Hex(data.getOldPassword()))) {

                Entity task = Entity.newBuilder(user)
                        .set("user_username", user.getString("user_username"))
                        .set("user_fullname", user.getString("user_fullname"))
                        .set("user_pwd", DigestUtils.sha512Hex(data.getNewPassword()))
                        .set("user_email", user.getString("user_email"))
                        .set("user_creation_time", user.getTimestamp("user_creation_time"))
                        .set("user_role", user.getString("user_role"))
                        .set("user_state", user.getString("user_state"))
                        .set("user_privacy", user.getString("user_privacy"))
                        .set("user_homephone", user.getString("user_homephone"))
                        .set("user_mobilephone", user.getString("user_mobilephone"))
                        .set("user_occupation", user.getString("user_occupation"))
                        .set("user_address", user.getString("user_address"))
                        .set("user_nif", user.getString("user_nif"))
                        .build();;

                txn.update(task);

                txn.commit();
                return Response.ok().build();
            }else{
                LOG.warning("Wrong Password");
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
