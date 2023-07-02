package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.cloud.datastore.*;
import com.google.cloud.storage.*;
import com.google.gson.Gson;
import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.io.IOUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.NucleoGetData;
import pt.unl.fct.di.apdc.firstwebapp.util.NucleoPostData;

import javax.imageio.ImageIO;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.core.Response;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.logging.Logger;

public class NucleosServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(EventsServlet.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final Storage storage = StorageOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");
    private final String bucketName = "staging.fct-connect-estudasses.appspot.com";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response){

        Transaction txn = datastore.newTransaction();

        try {

            String tokenId = request.getHeader("Authorization");
            String username = request.getHeader("User");

            Key updaterKey = userKeyFactory.newKey(username);

            Entity updaterEntity = txn.get(updaterKey);

            if (updaterEntity == null) {
                LOG.warning("User does not exist: " + username);
                response.setStatus(Response.Status.NOT_FOUND.getStatusCode());
                return;
            }
            if (updaterEntity.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                response.setStatus(Response.Status.UNAUTHORIZED.getStatusCode());
                return;
            }

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", username))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token == null || !token.getString("token_hashed_id").equals(DigestUtils.sha512Hex(tokenId))) {
                LOG.warning("Incorrect token. Please re-login");
                response.setStatus(Response.Status.FORBIDDEN.getStatusCode());
                return;
            }
            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                response.setStatus(Response.Status.FORBIDDEN.getStatusCode());
                return;
            }

            if ( request.getPart("image") == null) {
                LOG.warning("No profile picture sent.");
                response.setStatus(Response.Status.BAD_REQUEST.getStatusCode());
                return;
            }

            String jsonPart = IOUtils.toString(request.getPart("nucleo").getInputStream(), StandardCharsets.UTF_8);
            ObjectMapper mapper = new ObjectMapper();

            if (jsonPart.startsWith("\"") && jsonPart.endsWith("\"")) {
                jsonPart = jsonPart.substring(1, jsonPart.length() - 1);
                // Replace escaped inner quotes
                jsonPart = jsonPart.replace("\\\"", "\"");
            }

            NucleoPostData data = mapper.readValue(jsonPart, NucleoPostData.class);

            String admin = data.getAdmin();
            String name = data.getName();
            String type = data.getType();
            String email = data.getEmail();
            String subtitle = data.getSubtitle();
            String description = data.getDescription();
            String foundation = data.getFoundation();
            List<String> links = data.getLinks();

            Key adminKey = userKeyFactory.newKey(admin);
            if(txn.get(adminKey) == null){
                LOG.warning("Admin does not exist: " + admin);
                response.setStatus(Response.Status.NOT_FOUND.getStatusCode());
                return;
            }

            if (request.getPart("image") != null) {
                InputStream imageStream = request.getPart("image").getInputStream();

                String contentType = request.getPart("image").getContentType();

                String imageName = request.getPart("image").getSubmittedFileName();
                BlobId blobId = BlobId.of(bucketName, name + "-" + imageName);

                if (storage.get(blobId) != null) {
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    return;
                }

                BufferedImage originalImage = ImageIO.read(imageStream);

                int thumbnailWidth = 180;
                int thumbnailHeight = 180;

                // Create a thumbnail image using the original image
                BufferedImage resizedImage = new BufferedImage(thumbnailWidth, thumbnailHeight, BufferedImage.TYPE_INT_RGB);
                resizedImage.getGraphics().drawImage(originalImage.getScaledInstance(thumbnailWidth, thumbnailHeight, java.awt.Image.SCALE_SMOOTH), 0, 0, null);

                // Save the thumbnail image to a byte array
                ByteArrayOutputStream thumbnailOutputStream = new ByteArrayOutputStream();
                ImageIO.write(resizedImage, contentType.substring(contentType.lastIndexOf('/') +1), thumbnailOutputStream);
                byte[] thumbnailBytes = thumbnailOutputStream.toByteArray();


                // Upload the thumbnail image to your storage service (similar to the original image)
                BlobId thumbnailBlobId = BlobId.of(bucketName, name + "-" + imageName);

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

            List<Value<String>> linksValue = new ArrayList<>();

            if (links != null && !links.isEmpty()) {
                for (String link : links) {
                   linksValue.add(StringValue.newBuilder(link).build());
                }
            }

            List<Value<String>> admins = new ArrayList<>();
            admins.add(StringValue.newBuilder(admin).build());

            List<Value<String>> listOfStrings = new ArrayList<>();

            Key nucleoKey = datastore.newKeyFactory()
                    .setKind("Nucleo")
                    .newKey(name);

            Entity nucleo = Entity.newBuilder(nucleoKey)
                    .set("nucleo_name", name)
                    .set("nucleo_type", type)
                    .set("nucleo_email", StringValue.newBuilder(email).setExcludeFromIndexes(true).build())
                    .set("nucleo_subtitle", StringValue.newBuilder(subtitle).setExcludeFromIndexes(true).build())
                    .set("nucleo_description", StringValue.newBuilder(description).setExcludeFromIndexes(true).build())
                    .set("nucleo_foundation", StringValue.newBuilder(foundation).setExcludeFromIndexes(true).build())
                    .set("nucleo_links", ListValue.of(linksValue).excludeFromIndexes())
                    .set("nucleo_members", ListValue.of(listOfStrings))
                    .set("nucleo_admins", ListValue.of(admins))
                    .set("nucleo_events", ListValue.of(listOfStrings))
                    .build();

            txn.add(nucleo);
            txn.commit();

            response.setStatus(Response.Status.OK.getStatusCode());

        }catch (Exception e){
            LOG.severe(e.getMessage());
            e.printStackTrace();
            response.setStatus(Response.Status.INTERNAL_SERVER_ERROR.getStatusCode());
        }finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response){
        Transaction txn = datastore.newTransaction();

        try {

            String tokenId = request.getHeader("Authorization");
            String username = request.getHeader("User");


            Key userKey = datastore.newKeyFactory()
                    .setKind("User")
                    .newKey(username);

            Entity user = txn.get(userKey);

            if (user == null) {
                LOG.warning("User does not exist: " + username);
                response.setStatus(Response.Status.NOT_FOUND.getStatusCode());
                return;
            }
            if (user.getString("user_state").equals("INACTIVE")){
                LOG.warning("Inactive User.");
                response.setStatus(Response.Status.UNAUTHORIZED.getStatusCode());
                return;
            }

            Key tokenKey = datastore.newKeyFactory()
                    .setKind("Token")
                    .addAncestor(PathElement.of("User", username))
                    .newKey("token");

            Entity token = txn.get(tokenKey);

            if (token == null || !token.getString("token_hashed_id").equals(DigestUtils.sha512Hex(tokenId))) {
                LOG.warning("Incorrect token. Please re-login");
                response.setStatus(Response.Status.FORBIDDEN.getStatusCode());
                return;
            }
            if (AuthToken.expired(token.getLong("token_expiration"))) {
                LOG.warning("Your token has expired. Please re-login.");
                response.setStatus(Response.Status.FORBIDDEN.getStatusCode());
                return;
            }

            if(request.getParameter("nucleo_name")==null){
                getAllNucleos(request,response,txn);
            }

            else{
                getNucleo(request,response,txn);
            }


        }catch (Exception e){
            LOG.severe(e.getMessage());
            e.printStackTrace();
            response.setStatus(Response.Status.INTERNAL_SERVER_ERROR.getStatusCode());
        }finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }

    }

    private void getNucleo(HttpServletRequest request, HttpServletResponse response, Transaction txn) throws IOException {

        String nucleoName = request.getParameter("nucleo_name");

        Key nucleoKey = datastore.newKeyFactory()
                .setKind("Nucleo")
                .newKey(nucleoName);

        Entity entity = txn.get(nucleoKey);

        if(entity==null){
            LOG.warning("Nucleo does not exist: " + nucleoName);
            response.setStatus(Response.Status.NOT_FOUND.getStatusCode());
            return;
        }

        String name = entity.getKey().getName();
        String subtitle = entity.getString("nucleo_subtitle");
        String description = entity.getString("nucleo_description");
        String foundation = entity.getString("nucleo_foundation");
        String email = entity.getString("nucleo_email");
        String typeNucleo = entity.getString("nucleo_type");
        List<String> links = new ArrayList<>();
        List<String> members = new ArrayList<>();
        List<String> admins = new ArrayList<>();
        List<String> events = new ArrayList<>();

        if (entity.getList("nucleo_links") != null) {
            for (Value<?> link : entity.getList("nucleo_links")) {
                links.add((String) link.get());
            }
        }

        if (entity.getList("nucleo_members") != null) {
            for (Value<?> member : entity.getList("nucleo_members")) {
                members.add((String) member.get());
            }
        }

        if (entity.getList("nucleo_admins") != null) {
            for (Value<?> admin : entity.getList("nucleo_admins")) {
                admins.add((String) admin.get());
            }
        }

        if (entity.getList("nucleo_events") != null) {
            for (Value<?> event : entity.getList("nucleo_events")) {
                events.add((String) event.get());
            }
        }

        NucleoGetData nucleo = new NucleoGetData(name, subtitle, description, foundation, email, typeNucleo, links, members, admins, events);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(new Gson().toJson(nucleo));
        response.setStatus(Response.Status.OK.getStatusCode());
    }

    private void getAllNucleos(HttpServletRequest request, HttpServletResponse response, Transaction txn) throws IOException {

        String type = request.getParameter("type");

        Query<Entity> query = Query.newEntityQueryBuilder()
                                .setKind("Nucleo")
                                .setFilter(StructuredQuery.PropertyFilter.eq("nucleo_type", type))
                                .build();

        QueryResults<Entity> results = txn.run(query);

        List<NucleoGetData> nucleos = new ArrayList<>();

        while (results.hasNext()) {
            Entity entity = results.next();

            String name = entity.getKey().getName();
            String subtitle = entity.getString("nucleo_subtitle");
            String description = entity.getString("nucleo_description");
            String foundation = entity.getString("nucleo_foundation");
            String email = entity.getString("nucleo_email");
            String typeNucleo = entity.getString("nucleo_type");
            List<String> links = new ArrayList<>();
            List<String> members = new ArrayList<>();
            List<String> admins = new ArrayList<>();
            List<String> events = new ArrayList<>();

            if (entity.getList("nucleo_links") != null) {
                for (Value<?> link : entity.getList("nucleo_links")) {
                    links.add((String) link.get());
                }
            }

            if (entity.getList("nucleo_members") != null) {
                for (Value<?> member : entity.getList("nucleo_members")) {
                    members.add((String) member.get());
                }
            }

            if (entity.getList("nucleo_admins") != null) {
                for (Value<?> admin : entity.getList("nucleo_admins")) {
                    admins.add((String) admin.get());
                }
            }

            if (entity.getList("nucleo_events") != null) {
                for (Value<?> event : entity.getList("nucleo_events")) {
                    events.add((String) event.get());
                }
            }

            nucleos.add(new NucleoGetData(name, subtitle, description, foundation, email, typeNucleo, links, members, admins, events));
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(new Gson().toJson(nucleos));
        response.setStatus(Response.Status.OK.getStatusCode());
    }


}
