package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.cloud.storage.Blob;
import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.EventGetData;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Path("/qrcode")
public class QRCodeResource {
    private static final Logger LOG = Logger.getLogger(QRCodeResource.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");
    private final Storage storage = StorageOptions.getDefaultInstance().getService();
    private final String bucketName = "staging.fct-connect-estudasses.appspot.com";


    @GET
    @Path("/{eventId}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response enterEvent(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username, @PathParam("eventId") String eventId){

        Transaction txn = datastore.newTransaction();

        try{

            Key userKey = userKeyFactory.newKey(username);
            Entity user = txn.get(userKey);
            if (user == null) {
                LOG.warning("User does not exist: " + username);
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            if(user.getString("user_state").equals("INACTIVE")){
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
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                return Response.status(Response.Status.FORBIDDEN).build();
            }

            Key eventKey = datastore.newKeyFactory()
                    .setKind("Event")
                    .newKey(eventId);

            Entity event = txn.get(eventKey);

            if(event == null){
                LOG.warning("Event does not exist: " + eventId);
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            String url = "";
            String qrCodeUrl;

            if (!event.getString("event_image").equals("")) {

                BlobId blobId = BlobId.of(bucketName, event.getString("event_image"));
                com.google.cloud.storage.Blob blob = storage.get(blobId);
                url = blob.getMediaLink();

            }

            BlobId blobId = BlobId.of(bucketName, event.getString("event_qr"));
            Blob blob = storage.get(blobId);
            qrCodeUrl = blob.getMediaLink();

            List<Value<String>> eventList = user.getList("user_events");

            eventList.add(StringValue.of(eventId));

            Entity task = Entity.newBuilder(userKey)
                    .set("user_username", user.getString("user_username"))
                    .set("user_fullname", user.getString("user_fullname"))
                    .set("user_pwd", user.getString("user_pwd"))
                    .set("user_email", user.getString("user_email"))
                    .set("user_creation_time", user.getTimestamp("user_creation_time"))
                    .set("user_role", user.getString("user_role"))
                    .set("user_state", user.getString("user_state"))
                    .set("user_privacy", user.getString("user_privacy"))
                    .set("user_phone", user.getString("user_phone"))
                    .set("user_city",user.getString("user_city"))
                    .set("user_about_me",user.getString("user_about_me"))
                    .set("user_department", user.getString("user_department"))
                    .set("user_office", user.getString("user_office"))
                    .set("user_course", user.getString("user_course"))
                    .set("user_year", user.getString("user_year"))
                    .set("user_profile_pic", user.getString("user_profile_pic"))
                    .set("user_cover_pic", user.getString("user_cover_pic"))
                    .set("user_purpose", user.getString("user_purpose"))
                    .set("user_events", ListValue.of(eventList))
                    .build();;

            txn.update(task);

            List<Value<Key>> eventParticipants = event.getList("event_participants");

            eventParticipants.add(KeyValue.of(userKey));

            task = Entity.newBuilder(eventKey)
                    .set("id", event.getString("id"))
                    .set("event_title", event.getString("id"))
                    .set("event_creator", event.getString("id"))
                    .set("event_description", event.getString("id"))
                    .set("event_start", event.getString("id"))
                    .set("event_end", event.getString("id"))
                    .set("event_image", event.getString("id"))
                    .set("event_qr", event.getString("id"))
                    .set("event_participants", ListValue.of(eventParticipants))
                    .build();

            txn.update(task);

            List<String> participants = new ArrayList<>();

            for(Value<?> value : event.getList("event_participants")){
                Key key = (Key) value.get();
                Entity entity = txn.get(key);
                participants.add(entity.getString("user_username"));
            }

            EventGetData eventData = new EventGetData(event.getString("event_creator"),
                    event.getString("event_title"),
                    event.getString("event_description"),
                    url,
                    event.getLong("event_start"),
                    event.getLong("event_end"),
                    event.getString("id"),
                    qrCodeUrl,
                    participants);

            txn.commit();
            return Response.ok(eventData).build();

        }catch (Exception e) {
            LOG.info("Failed to get event: " + e.getMessage());
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }

}
