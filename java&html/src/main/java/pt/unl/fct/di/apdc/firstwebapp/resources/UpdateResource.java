package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.cloud.storage.*;
import org.glassfish.jersey.media.multipart.FormDataContentDisposition;
import org.glassfish.jersey.media.multipart.FormDataParam;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.UpdateData;
import org.apache.commons.codec.digest.DigestUtils;

import javax.imageio.ImageIO;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.Collections;
import java.util.logging.Logger;

@Path("/update")
public class UpdateResource {

    private static final Logger LOG = Logger.getLogger(LoginResource.class.getName());

    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");

    private final Storage storage = StorageOptions.getDefaultInstance().getService();
    private final String bucketName = "staging.fct-connect-estudasses.appspot.com";

    @PUT
    @Path("/{user}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response userUpdate(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String updaterName, @PathParam("user") String username, UpdateData data) {

        Transaction txn = datastore.newTransaction();

        try {

            Key updaterKey = userKeyFactory.newKey(updaterName);

            Entity updater = txn.get(updaterKey);

            if (updater == null) {
                LOG.warning("User does not exist: " + updaterName);
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            if (updater.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", updaterName))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token == null || !token.getString("token_id").equals(DigestUtils.sha512Hex(tokenId))) {
                LOG.warning("Incorrect token. Please re-login");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            Key userKey = userKeyFactory.newKey(username);
            Entity user = txn.get(userKey);

            if (user == null) {
                LOG.warning("User does not exist: " + username);
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            Entity task = Entity.newBuilder(user)
                    .set("user_username", user.getString("user_username"))
                    .set("user_fullname", data.getFullname())
                    .set("user_pwd", user.getString("user_pwd"))
                    .set("user_email", user.getString("user_email"))
                    .set("user_creation_time", user.getTimestamp("user_creation_time"))
                    .set("user_role", user.getString("user_role"))
                    .set("user_state", user.getString("user_state"))
                    .set("user_privacy", data.getPrivacy())
                    .set("user_phone", StringValue.newBuilder(data.getPhone()).setExcludeFromIndexes(true).build())
                    .set("user_city", data.getCity())
                    .set("user_about_me", StringValue.newBuilder(data.getAbout()).setExcludeFromIndexes(true).build())
                    .set("user_department", data.getDepartment())
                    .set("user_office", StringValue.newBuilder(data.getOffice()).setExcludeFromIndexes(true).build())
                    .set("user_course", data.getCourse())
                    .set("user_year",data.getYear())
                    .set("user_profile_pic", user.getString("user_profile_pic"))
                    .set("user_cover_pic", user.getString("user_cover_pic"))
                    .set("user_purpose", data.getPurpose())
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
