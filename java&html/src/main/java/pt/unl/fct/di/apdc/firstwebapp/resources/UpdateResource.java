package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.UpdateData;
import org.apache.commons.codec.digest.DigestUtils;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.logging.Logger;

@Path("/update")
public class UpdateResource {

    private static final Logger LOG = Logger.getLogger(LoginResource.class.getName());

    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");

    @PUT
    @Path("/admin")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response adminUpdate(UpdateData data) {
        LOG.fine("Attempt to update user: " + data.getUsername());

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
                    .addAncestor(PathElement.of("User", data.getUsername()))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token == null || !token.getString("token_id").equals(DigestUtils.sha512Hex(data.getTokenId()))) {
                LOG.warning("Incorrect token. Please re-login");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Key updaterKey = userKeyFactory.newKey(data.getTokenUser());
            Entity updater = txn.get(updaterKey);
            if (updater.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Entity tokenUser = txn.get(userKeyFactory.newKey(data.getTokenUser()));

            if (!data.getTokenRole().equals(tokenUser.getString("user_role"))){
                LOG.warning("Token role does not correspond current user role");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            String fullname = data.getFullname();
            if(fullname.equals(""))
                fullname = user.getString("user_fullname");

            String mail = data.getEmail();
            if(mail.equals(""))
                mail = user.getString("user_email");

            String privacy = data.getPrivacy();
            if(privacy.equals(""))
                privacy = user.getString("user_privacy");

            String homephone = data.getHomephone();
            if(homephone.equals(""))
                homephone = user.getString("user_homephone");

            String mobilephone = data.getMobilephone();
            if(mobilephone.equals(""))
                mobilephone = user.getString("user_mobilephone");

            String occupation = data.getOccupation();
            if(occupation.equals(""))
                occupation = user.getString("user_occupation");

            String address = data.getAddress();
            if(address.equals(""))
                address = user.getString("user_address");

            String nif = data.getNif();
            if(nif.equals(""))
                nif = user.getString("user_nif");

            String role = data.getRole();
            if(role.equals(""))
                role = user.getString("user_role");

            String state = data.getState();
            if(state.equals(""))
                state = user.getString("user_state");

            boolean rolePermission = false;
            boolean statePermission = false; //true when permission to change other aspects is true

            if(data.getTokenRole().equals("SU")) {
                rolePermission = true;
                statePermission = true;
            }
            if(data.getTokenRole().equals("GS") && (data.getRole().equals("USER")) && (role.equals("GBO") || role.equals("USER"))){
                rolePermission = true;
            }
            if(data.getTokenRole().equals("GS") && (data.getRole().equals("USER") || data.getRole().equals("GA") || data.getRole().equals("GBO"))){
                statePermission = true;
            }
            if(data.getTokenRole().equals("GA") && (data.getRole().equals("GBO") || data.getRole().equals("USER"))){
                statePermission = true;
            }
            if(data.getTokenRole().equals("GBO") && (data.getRole().equals("USER"))){
                statePermission = true;
            }

            if(statePermission){
                if(rolePermission || role.equals(user.getString("user_role"))){
                    Entity task = Entity.newBuilder(user)
                            .set("user_username", user.getString("user_username"))
                            .set("user_fullname", fullname)
                            .set("user_pwd", user.getString("user_pwd"))
                            .set("user_email", mail)
                            .set("user_creation_time", user.getTimestamp("user_creation_time"))
                            .set("user_role", role)
                            .set("user_state", state)
                            .set("user_privacy", privacy)
                            .set("user_homephone", homephone)
                            .set("user_mobilephone", mobilephone)
                            .set("user_occupation", occupation)
                            .set("user_address", address)
                            .set("user_nif", nif)
                            .build();

                    txn.update(task);

                    txn.commit();
                    return Response.ok().build();
                }else{
                    return Response.status(Response.Status.FORBIDDEN).build();
                }
            }else{
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

    @PUT
    @Path("/user")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response userUpdate(UpdateData data) {
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
                    .addAncestor(PathElement.of("User", data.getUsername()))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token == null || !token.getString("token_id").equals(DigestUtils.sha512Hex(data.getTokenId()))) {
                LOG.warning("Incorrect token. Please re-login");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Key updaterKey = userKeyFactory.newKey(data.getTokenUser());
            Entity updater = txn.get(updaterKey);
            if (updater.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Entity tokenUser = txn.get(userKeyFactory.newKey(data.getTokenUser()));

            if (!data.getTokenRole().equals(tokenUser.getString("user_role"))){
                LOG.warning("Token role does not correspond current user role");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            String fullname = data.getFullname();
            if (fullname.equals(""))
                fullname = user.getString("user_fullname");

            String mail = data.getEmail();
            if (mail.equals(""))
                mail = user.getString("user_email");

            String privacy = data.getPrivacy();
            if (privacy.equals(""))
                privacy = user.getString("user_privacy");

            String homephone = data.getHomephone();
            if (homephone.equals(""))
                homephone = user.getString("user_homephone");

            String mobilephone = data.getMobilephone();
            if (mobilephone.equals(""))
                mobilephone = user.getString("user_mobilephone");

            String occupation = data.getOccupation();
            if (occupation.equals(""))
                occupation = user.getString("user_occupation");

            String address = data.getAddress();
            if (address.equals(""))
                address = user.getString("user_address");

            String nif = data.getNif();
            if (nif.equals(""))
                nif = user.getString("user_nif");

            Entity task = Entity.newBuilder(user)
                    .set("user_username", user.getString("user_username"))
                    .set("user_fullname", fullname)
                    .set("user_pwd", user.getString("user_pwd"))
                    .set("user_email", mail)
                    .set("user_creation_time", user.getTimestamp("user_creation_time"))
                    .set("user_role", user.getString("user_role"))
                    .set("user_state", user.getString("user_state"))
                    .set("user_privacy", privacy)
                    .set("user_homephone", homephone)
                    .set("user_mobilephone", mobilephone)
                    .set("user_occupation", occupation)
                    .set("user_address", address)
                    .set("user_nif", nif)
                    .build();;

            txn.update(task);

            txn.commit();

            return Response.ok().build();
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
