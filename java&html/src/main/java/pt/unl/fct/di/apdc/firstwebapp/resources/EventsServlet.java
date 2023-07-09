package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.cloud.datastore.*;
import com.google.cloud.storage.*;
import com.google.cloud.storage.Blob;
import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.io.IOUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.*;

import javax.imageio.ImageIO;
import javax.servlet.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.*;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.logging.Logger;

// qr code imports
import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import java.io.ByteArrayOutputStream;

@MultipartConfig

public class EventsServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(EventsServlet.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");

    private final Storage storage = StorageOptions.getDefaultInstance().getService();
    private final String bucketName = "staging.fct-connect-estudasses.appspot.com";

    public byte[] generateQRCode(String data, int width, int height) throws IOException, WriterException {
        QRCodeWriter qrCodeWriter = new QRCodeWriter();
        BitMatrix bitMatrix = qrCodeWriter.encode(data, BarcodeFormat.QR_CODE, width, height);
        byte[] png;
        try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
            MatrixToImageWriter.writeToStream(bitMatrix, "PNG", baos);
            png = baos.toByteArray();
        }
        return png;
    }


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {

        Transaction txn = datastore.newTransaction();

        try {

            String tokenId = request.getHeader("Authorization");
            String username = request.getPathInfo().substring(1);
            String cursor = request.getParameter("cursor");

            LOG.fine("Attempt get events");

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", username))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token == null || !token.getString("token_hashed_id").equals(DigestUtils.sha512Hex(tokenId))) {
                LOG.warning("Incorrect token. Please re-login");
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            StructuredQuery.OrderBy descendingTimestamp = StructuredQuery.OrderBy.desc("event_start");

            Query<Entity> eventsQuery = Query.newEntityQueryBuilder()
                    .setKind("Event")
                    .setFilter(StructuredQuery.PropertyFilter.lt("event_start", cursor))
                    .addOrderBy(descendingTimestamp)
                    .setLimit(10)
                    .build();

            QueryResults<Entity> eventResults = txn.run(eventsQuery);

            List<EventGetData> eventList = new ArrayList<>();

            eventResults.forEachRemaining(event -> {
                String url = "";
                String qrCodeUrl;

                if (!event.getString("event_image").equals("")) {

                    BlobId blobId = BlobId.of(bucketName, event.getString("event_image"));
                    Blob blob = storage.get(blobId);
                    url = blob.getMediaLink();

                }

                BlobId blobId = BlobId.of(bucketName, event.getString("event_qr"));
                Blob blob = storage.get(blobId);
                qrCodeUrl = blob.getMediaLink();

                List<String> participants = new ArrayList<>();

                for(Value<?> value : event.getList("event_participants")){
                    Key userKey = (Key) value.get();
                    Entity entity = txn.get(userKey);
                    participants.add(entity.getString("user_username"));
                }

                if(participants.isEmpty()){
                    participants.add("");
                }

                EventGetData eventInstance = new EventGetData(
                        event.getString("event_creator"),
                        event.getString("event_title"),
                        event.getString("event_description"),
                        url,
                        event.getLong("event_start"),
                        event.getLong("event_end"),
                        event.getString("id"),
                        qrCodeUrl,
                        participants,
                        event.getDouble("event_latitude"),
                        event.getDouble("event_longitude"));

                eventList.add(eventInstance);
            });

            if (eventList.isEmpty()) {
                LOG.info("no events found");
                response.setStatus(HttpServletResponse.SC_PRECONDITION_FAILED);
                return;
            }

            // Convert the list of posts to JSON
            ObjectMapper objectMapper = new ObjectMapper();
            String json = objectMapper.writeValueAsString(eventList);

            // Set the response content type and write the JSON string to the output stream
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(json);
            response.setStatus(HttpServletResponse.SC_OK);

        } catch (Exception e) {
            txn.rollback();
            LOG.severe(e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        Transaction txn = datastore.newTransaction();

        try {

            String creator = request.getPathInfo().substring(1);

            String jsonPart = IOUtils.toString(request.getPart("event").getInputStream(), StandardCharsets.UTF_8);
            ObjectMapper mapper = new ObjectMapper();

            if (jsonPart.startsWith("\"") && jsonPart.endsWith("\"")) {
                jsonPart = jsonPart.substring(1, jsonPart.length() - 1);
                // Replace escaped inner quotes
                jsonPart = jsonPart.replace("\\\"", "\"");
            }

            EventPostData data = mapper.readValue(jsonPart, EventPostData.class);

            String tokenId = request.getHeader("Authorization");
            String title = data.getTitle();
            String description = data.getDescription();
            long start = data.getStart();
            long end = data.getEnd();
            String uniqueEventId = (title + System.currentTimeMillis()).replace(' ', '-');

            LOG.fine("Attempt to create event with user " + creator);

            // verifications
            Key userKey = userKeyFactory.newKey(creator);
            Entity user = txn.get(userKey);
            if (user == null) {
                LOG.warning("User does not exist.");
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            if (user.getString("user_state").equals("INACTIVE")) {
                LOG.warning("Inactive User.");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }

            // TODO:Check user's role

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", creator))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token == null || !token.getString("token_hashed_id").equals(DigestUtils.sha512Hex(tokenId))) {
                LOG.warning("Incorrect token. Please re-login");
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            String imageName = "";

            if (request.getPart("image") != null) {
                InputStream imageStream = request.getPart("image").getInputStream();

                String contentType = request.getPart("image").getContentType();

                imageName = request.getPart("image").getSubmittedFileName();
                BlobId blobId = BlobId.of(bucketName, title + "-" + imageName);

                if (storage.get(blobId) != null) {
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    return;
                }

                BufferedImage originalImage = ImageIO.read(imageStream);

                int thumbnailWidth;
                int thumbnailHeight;


                //Check image size and set thumbnail size accordingly
                if (originalImage.getWidth() > originalImage.getHeight()) {
                    thumbnailWidth = 1350;
                    thumbnailHeight = 1080;
                } else if (originalImage.getWidth() < originalImage.getHeight()) {
                    thumbnailWidth = 1080;
                    thumbnailHeight = 1350;
                } else {
                    thumbnailWidth = 1080;
                    thumbnailHeight = 1080;
                }

                // Create a thumbnail image using the original image
                BufferedImage resizedImage = new BufferedImage(thumbnailWidth, thumbnailHeight, BufferedImage.TYPE_INT_RGB);
                resizedImage.getGraphics().drawImage(originalImage.getScaledInstance(thumbnailWidth, thumbnailHeight, java.awt.Image.SCALE_SMOOTH), 0, 0, null);

                // Save the thumbnail image to a byte array
                ByteArrayOutputStream thumbnailOutputStream = new ByteArrayOutputStream();
                ImageIO.write(resizedImage, contentType.substring(contentType.lastIndexOf('/') +1), thumbnailOutputStream);
                byte[] thumbnailBytes = thumbnailOutputStream.toByteArray();


                // Upload the thumbnail image to your storage service (similar to the original image)
                BlobId thumbnailBlobId = BlobId.of(bucketName, uniqueEventId + "-" + imageName);

                if(storage.get(thumbnailBlobId)!=null){
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    return;
                }

                BlobInfo thumbnailBlobInfo = BlobInfo.newBuilder(thumbnailBlobId)
                        .setAcl(Collections.singletonList(Acl.newBuilder(Acl.User.ofAllUsers(), Acl.Role.READER).build()))
                        .build();

                storage.create(thumbnailBlobInfo, thumbnailBytes);

                // Close the thumbnail output stream
                thumbnailOutputStream.close();

            }

            byte[] qrCode = this.generateQRCode("www.fct-connect-estudasses.oa.r.appspot.com/qrcode/"+uniqueEventId, 500, 500);

            BlobId blobId = BlobId.of(bucketName, uniqueEventId + "-qrCode.png");

            if (storage.get(blobId) != null) {
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    return;
            }

            BlobInfo blobInfo = BlobInfo.newBuilder(blobId).setAcl(Collections.singletonList(
                        Acl.newBuilder(Acl.User.ofAllUsers(), Acl.Role.READER).build())).build();

            storage.create(blobInfo, qrCode);

            List<Value<String>> participants = new ArrayList<>();

            Key eventKey = datastore.newKeyFactory()
                    .setKind("Event")
                    .newKey(uniqueEventId);

            Entity entity = Entity.newBuilder(eventKey)
                    .set("id", uniqueEventId)
                    .set("event_title", title)
                    .set("event_creator", creator)
                    .set("event_description", StringValue.newBuilder(description).setExcludeFromIndexes(true).build())
                    .set("event_start", start)
                    .set("event_end", end)
                    .set("event_image", StringValue.newBuilder(uniqueEventId + "-" + imageName).setExcludeFromIndexes(true).build())
                    .set("event_qr", StringValue.newBuilder(uniqueEventId + "-qrCode.png").setExcludeFromIndexes(true).build())
                    .set("event_participants", ListValue.of(participants))
                    .set("event_latitude", DoubleValue.newBuilder(data.getLat()).setExcludeFromIndexes(true).build())
                    .set("event_longitude", DoubleValue.newBuilder(data.getLng()).setExcludeFromIndexes(true).build())
                    .build();

            txn.add(entity);

            Key locationKey = datastore.newKeyFactory()
                            .setKind("Location")
                            .newKey(uniqueEventId);

            Entity locationEntity = Entity.newBuilder(locationKey)
                                    .set("latitude", data.getLat())
                                    .set("longitude", data.getLng())
                                    .set("name", uniqueEventId)
                                    .set("type", "EVENT")
                                    .set("event", uniqueEventId)
                                    .build();

            txn.put(locationEntity);

            long currentTime = System.currentTimeMillis();

            Key activityKey = datastore.newKeyFactory()
                    .setKind("Activity")
                    .addAncestor(PathElement.of("User", creator))
                    .newKey(currentTime);

            Entity activityEntity = Entity.newBuilder(activityKey)
                    .set("activity_creation_time", LongValue.of(currentTime).toBuilder().setExcludeFromIndexes(true).build())
                    .set("activity_name", title)
                    .set("activity_from", LongValue.of(start).toBuilder().setExcludeFromIndexes(true).build())
                    .set("activity_to", LongValue.of(end).toBuilder().setExcludeFromIndexes(true).build())
                    .set("activity_colour", "FF9800")
                    .build();

            txn.add(activityEntity);

            txn.commit();

            response.setStatus(HttpServletResponse.SC_OK);

        } catch (Exception e) {
            txn.rollback();
            LOG.severe(e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }

    @Override
    public void doPut(HttpServletRequest request, HttpServletResponse response){

        Transaction txn = datastore.newTransaction();

        try{
            String tokenId = request.getHeader("Authorization");
            String pathInfo = request.getPathInfo(); // Assuming request is an instance of HttpServletRequest
            String[] pathParams = pathInfo.substring(1).split("/");
            String username = pathParams[0];

            String eventId = null;

            if (pathParams.length >= 2) {
                eventId = pathParams[1];
            }

            if(eventId ==null){
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            LOG.fine("Attempt add event to user: " + username);

            Key userKey = userKeyFactory.newKey(username);
            Entity user = txn.get(userKey);
            if (user == null) {
                LOG.warning("User does not exist.");
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            if (user.getString("user_state").equals("INACTIVE")) {
                LOG.warning("Inactive User.");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", username))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token == null || !token.getString("token_hashed_id").equals(DigestUtils.sha512Hex(tokenId))) {
                LOG.warning("Incorrect token. Please re-login");
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                return;
            }


            Key eventKey = datastore.newKeyFactory()
                    .setKind("Event")
                    .newKey(eventId);

            Entity event = txn.get(eventKey);

            if(event == null){
                LOG.warning("Event does not exist");
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            List<Value<?>> eventValues = new ArrayList<>(user.getList("user_events"));
            List<String> events = new ArrayList<>();

            for(Value<?> value : eventValues){
                events.add(value.get().toString());
            }

            if(events.contains(eventId)){

                eventValues.remove(StringValue.of(eventId));

                Entity updatedUser = Entity.newBuilder(user)
                        .set("user_events", ListValue.of(eventValues))
                        .build();

                txn.put(updatedUser);

                Query<Entity> activityQuery = Query.newEntityQueryBuilder()
                        .setKind("Activity")
                        .setFilter(StructuredQuery.CompositeFilter.and(
                                StructuredQuery.PropertyFilter.hasAncestor(userKey),
                                StructuredQuery.PropertyFilter.eq("activity_name", event.getString("event_title"))
                        ))
                        .build();

                QueryResults<Entity> activityResults = datastore.run(activityQuery);

                if(activityResults.hasNext()){
                    Entity activity = activityResults.next();
                    txn.delete(activity.getKey());
                }

                txn.commit();

                response.setStatus(HttpServletResponse.SC_OK);
                return;

            }

            eventValues.add(StringValue.of(eventId));

            Entity updatedUser = Entity.newBuilder(user)
                    .set("user_events", ListValue.of(eventValues))
                    .build();

            txn.put(updatedUser);

            String currentTime = String.valueOf(System.currentTimeMillis());

            Key activityKey = datastore.newKeyFactory()
                    .setKind("Activity")
                    .addAncestor(PathElement.of("User", username))
                    .newKey(currentTime);

            Entity activityEntity = Entity.newBuilder(activityKey)
                    .set("activity_creation_time", StringValue.of(currentTime).toBuilder().setExcludeFromIndexes(true).build())
                    .set("activity_name", event.getString("event_title"))
                    .set("activity_from", LongValue.of(event.getLong("event_start")).toBuilder().setExcludeFromIndexes(true).build())
                    .set("activity_to", LongValue.of(event.getLong("event_end")).toBuilder().setExcludeFromIndexes(true).build())
                    .set("activity_colour", "FF9800")
                    .build();

            txn.add(activityEntity);
            txn.commit();
            response.setStatus(HttpServletResponse.SC_OK);

        }catch (Exception e) {
            txn.rollback();
            LOG.severe(e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }


    }


}
