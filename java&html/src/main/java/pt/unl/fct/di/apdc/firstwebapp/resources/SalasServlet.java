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

public class SalasServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(SalasServlet.class.getName());
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

            LOG.fine("Attempt get salas");

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

            StructuredQuery.OrderBy descendingTimestamp = StructuredQuery.OrderBy.desc("sala_title");

            Query<Entity> salasQuery = Query.newEntityQueryBuilder()
                    .setKind("Sala")
                    .addOrderBy(descendingTimestamp)
                    .build();

            QueryResults<Entity> salaResults = txn.run(salasQuery);

            List<SalaGetData> salaList = new ArrayList<>();

            salaResults.forEachRemaining(sala -> {
                String url = "";
                //String qrCodeUrl;

                if (!sala.getString("sala_image").equals("")) {

                    BlobId blobId = BlobId.of(bucketName, sala.getString("sala_image"));
                    Blob blob = storage.get(blobId);
                    url = blob.getMediaLink();

                }

                // qr code for salas ?
                
                /** 
                BlobId blobId = BlobId.of(bucketName, event.getString("event_qr"));
                Blob blob = storage.get(blobId);
                qrCodeUrl = blob.getMediaLink();
                */

                List<Integer> participants = new ArrayList<>();

                for(Value<?> value : sala.getList("sala_participants")){
                    Key userKey = (Key) value.get();
                    Entity entity = txn.get(userKey);
                    //participants.add(entity.getString("user_username"));
                }

                if(participants.isEmpty()){
                    //participants.add("");
                }

                SalaGetData salaInstance = new SalaGetData(
                        sala.getString("sala_name"),
                        sala.getString("sala_building"),
                        url,
                        sala.getString("id"),
                        participants,
                        sala.getDouble("sala_latitude"),
                        sala.getDouble("sala_longitude"),
                        sala.getLong("sala_capacity"));

                salaList.add(salaInstance);
            });

            if (salaList.isEmpty()) {
                LOG.info("no salas found");
                response.setStatus(HttpServletResponse.SC_PRECONDITION_FAILED);
                return;
            }

            // Convert the list of posts to JSON
            ObjectMapper objectMapper = new ObjectMapper();
            String json = objectMapper.writeValueAsString(salaList);

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

            String jsonPart = IOUtils.toString(request.getPart("sala").getInputStream(), StandardCharsets.UTF_8);
            ObjectMapper mapper = new ObjectMapper();

            if (jsonPart.startsWith("\"") && jsonPart.endsWith("\"")) {
                jsonPart = jsonPart.substring(1, jsonPart.length() - 1);
                // Replace escaped inner quotes
                jsonPart = jsonPart.replace("\\\"", "\"");
            }

            SalaPostData data = mapper.readValue(jsonPart, SalaPostData.class);

            String tokenId = request.getHeader("Authorization");
            String name = data.getName();
            String building = data.getBuilding();
            String uniqueSalaId = (name + System.currentTimeMillis()).replace(' ', '-');

            LOG.fine("Attempt to create sala with user " + creator);

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
                imageName = request.getPart("image").getSubmittedFileName();
                InputStream imageStream = request.getPart("image").getInputStream();

                String contentType = request.getPart("image").getContentType();

                imageName = request.getPart("image").getSubmittedFileName();
                BlobId blobId = BlobId.of(bucketName, name + "-" + imageName);

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
                BlobId thumbnailBlobId = BlobId.of(bucketName, uniqueSalaId + "-" + imageName);

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

            byte[] qrCode = this.generateQRCode("www.fct-connect-estudasses.oa.r.appspot.com/qrcode/"+uniqueSalaId, 500, 500);

            BlobId blobId = BlobId.of(bucketName, uniqueSalaId + "-qrCode.png");

            if (storage.get(blobId) != null) {
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    return;
            }

            BlobInfo blobInfo = BlobInfo.newBuilder(blobId).setAcl(Collections.singletonList(
                        Acl.newBuilder(Acl.User.ofAllUsers(), Acl.Role.READER).build())).build();

            storage.create(blobInfo, qrCode);

            List<Value<String>> participants = new ArrayList<>();

            Key salaKey = datastore.newKeyFactory()
                    .setKind("Sala")
                    .newKey(uniqueSalaId);

            Entity entity = Entity.newBuilder(salaKey)
                    .set("id", uniqueSalaId)
                    .set("sala_name", name)
                    .set("sala_creator", creator)
                    .set("sala_building", StringValue.newBuilder(building).setExcludeFromIndexes(true).build())
                    .set("sala_image", StringValue.newBuilder(uniqueSalaId + "-" + imageName).setExcludeFromIndexes(true).build())
                    //.set("sala_qr", StringValue.newBuilder(uniqueSalaId + "-qrCode.png").setExcludeFromIndexes(true).build())
                    .set("sala_participants", ListValue.of(participants))
                    .set("sala_latitude", DoubleValue.newBuilder(data.getLat()).setExcludeFromIndexes(true).build())
                    .set("sala_longitude", DoubleValue.newBuilder(data.getLng()).setExcludeFromIndexes(true).build())
                    .set("sala_capacity", data.getCapacity())
                    .build();

            txn.add(entity);
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
