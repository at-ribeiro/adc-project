package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.cloud.datastore.*;
import com.google.cloud.storage.*;
import com.google.cloud.storage.Blob;
import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.io.IOUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.*;

import javax.servlet.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.*;
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
    private final Storage storage = StorageOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");
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
                    .addOrderBy(descendingTimestamp)
                    .build();

            QueryResults<Entity> eventResults = txn.run(eventsQuery);

            List<EventGetData> eventList = new ArrayList<>();

            eventResults.forEachRemaining(event -> {
                String url = "";
                String qrCodeUrl = "";

                if (!event.getString("event_image").equals("")) {

                    BlobId blobId = BlobId.of(bucketName, event.getString("event_image"));
                    Blob blob = storage.get(blobId);
                    url = blob.getMediaLink();

                }

                BlobId blobId = BlobId.of(bucketName, event.getString("event_qr"));
                Blob blob = storage.get(blobId);
                qrCodeUrl = blob.getMediaLink();

                // TODO: Check with frontend
                EventGetData newsInstance = new EventGetData(
                        event.getString("event_creator"),
                        event.getString("event_title"),
                        event.getString("event_description"),
                        url,
                        event.getLong("event_start"),
                        event.getLong("event_end"),
                        event.getString("id"),
                        qrCodeUrl);

                eventList.add(newsInstance);
            });

            if (eventList.isEmpty()) {
                LOG.info("events: " + eventList);
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
            String uniqueEventId = title + System.currentTimeMillis();

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

            InputStream imageStream = null;

            if (request.getPart("image") != null) {
                imageStream = request.getPart("image").getInputStream();
            }

            String imageName = "";

            if (imageStream != null) {

                imageName = request.getPart("image").getSubmittedFileName();
                BlobId blobId = BlobId.of(bucketName, title + "-" + imageName);

                if (storage.get(blobId) != null) {
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    return;
                }

                BlobInfo blobInfo = BlobInfo.newBuilder(blobId).setAcl(Collections.singletonList(
                        Acl.newBuilder(Acl.User.ofAllUsers(), Acl.Role.READER).build())).build();

                byte[] imageBytes = IOUtils.toByteArray(imageStream);

                storage.create(blobInfo, imageBytes);
            }

            // QR CODE image creation

            byte[] qrCode = this.generateQRCode("www.fct-connect-estudasses.oa.r.appspot.com/qrcode/"+uniqueEventId, 500, 500);

            BlobId blobId = BlobId.of(bucketName, uniqueEventId + "-qrCode.png");

            if (storage.get(blobId) != null) {
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    return;
            }

            BlobInfo blobInfo = BlobInfo.newBuilder(blobId).setAcl(Collections.singletonList(
                        Acl.newBuilder(Acl.User.ofAllUsers(), Acl.Role.READER).build())).build();

            storage.create(blobInfo, qrCode);

            // end of qr code

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
                    .set("event_image", StringValue.newBuilder(title + "-" + imageName).setExcludeFromIndexes(true).build())
                    .set("event_qr", uniqueEventId + "-qrCode.png")
                    .build();

            txn.put(entity);
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
}
