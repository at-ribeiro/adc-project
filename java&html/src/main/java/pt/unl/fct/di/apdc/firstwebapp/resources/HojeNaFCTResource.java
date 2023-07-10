package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.cloud.storage.Blob;
import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.HojeNaFCT.*;

import javax.mail.*;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.logging.Logger;

import javax.mail.internet.MimeMessage;

@Path("/hojenafct")
public class HojeNaFCTResource {

    private static final Logger LOG = Logger.getLogger(HojeNaFCTResource.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");
    private final Storage storage = StorageOptions.getDefaultInstance().getService();
    private final String bucketName = "staging.fct-connect-estudasses.appspot.com";

    @POST
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response createHojeNaFCT(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username,
                                    HojeNaFCTData data) {

        Transaction txn = datastore.newTransaction();

        try {

            Key userKey = userKeyFactory.newKey(username);
            Entity user = txn.get(userKey);

            if (user == null) {
                LOG.warning("User does not exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            if (user.getString("user_state").equals("INACTIVE")) {
                LOG.warning("Inactive User.");
                return  Response.status(Response.Status.UNAUTHORIZED).build();
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

            Date today = Calendar.getInstance().getTime();

            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            String formattedDate = dateFormat.format(today);

            Key hojeNaFCTKey = datastore.newKeyFactory()
                    .setKind("HojeNaFCT")
                    .newKey(formattedDate);

            List<ProvaAcademica> thesis = data.getThesis();

            for(ProvaAcademica prova : thesis){

                Key provaKey = datastore.newKeyFactory()
                        .setKind("ProvaAcademica")
                        .addAncestor(PathElement.of("HojeNaFCT", formattedDate))
                        .newKey(prova.title);

                List<String> members = prova.members;

                if(members == null)
                	return Response.status(Response.Status.BAD_REQUEST).build();

                List<StringValue> membersValue = null;

                for (String member : members) {
                	membersValue.add(StringValue.newBuilder(member).build());
                }

                Entity provaEntity = Entity.newBuilder(provaKey)
                        .set("title", prova.title)
                        .set("course", prova.course)
                        .set("type", prova.type)
                        .set("dissertation", prova.dissertation)
                        .set("hour", prova.hour)
                        .set("room", prova.room)
                        .set("president", prova.president)
                        .set("members", membersValue)
                        .build();

                txn.put(provaEntity);
            }

            List<Menu> menus = data.getMenus();

            if(menus == null)
            	return Response.status(Response.Status.BAD_REQUEST).build();

            for(Menu menu : menus){

                Key menuKey = datastore.newKeyFactory()
                        .setKind("Menu")
                        .addAncestor(PathElement.of("HojeNaFCT", formattedDate))
                        .newKey(menu.restaurant);

                Entity menuEntity = Entity.newBuilder(menuKey)
                        .set("restaurant", menu.restaurant)
                        .set("building", menu.building)
                        .set("menu", menu.menu)
                        .build();

                txn.put(menuEntity);

            }

            Calendar calendar = Calendar.getInstance();

            calendar.set(Calendar.HOUR_OF_DAY, 23);
            calendar.set(Calendar.MINUTE, 59);
            calendar.set(Calendar.SECOND, 59);
            calendar.set(Calendar.MILLISECOND, 999);

            long endOfDayTimestamp = calendar.getTimeInMillis();

            calendar.set(Calendar.HOUR_OF_DAY, 0);
            calendar.set(Calendar.MINUTE, 0);
            calendar.set(Calendar.SECOND, 0);
            calendar.set(Calendar.MILLISECOND , 0);

            long startOfDayTimestamp = calendar.getTimeInMillis();

            Query<Entity> query = Query.newEntityQueryBuilder()
                    .setKind("Event")
                    .setFilter(
                            StructuredQuery.CompositeFilter.and(
                            StructuredQuery.PropertyFilter.lt("event_end", endOfDayTimestamp),
                            StructuredQuery.PropertyFilter.gt("event_start", startOfDayTimestamp))
                    )
                    .build();

            QueryResults<Entity> results = datastore.run(query);

            List<StringValue> events = new ArrayList<>();

            while(results.hasNext()) {
                Entity event = results.next();

                events.add(StringValue.newBuilder(event.getString("id")).setExcludeFromIndexes(true).build());

            }

            List<StringValue> linksValue = new ArrayList<>();
            List<String> links = data.getLinks();

            if(links != null) {
            	for(String link : links) {
            		linksValue.add(StringValue.newBuilder(link).setExcludeFromIndexes(true).build());
            	}
            }

            Entity hojeNaFCT = Entity.newBuilder(hojeNaFCTKey)
                    .set("temperature", LongValue.newBuilder(data.getTemperature()).setExcludeFromIndexes(true).build())
                    .set("links", linksValue)
                    .set("events", events)
                    .build();

            txn.put(hojeNaFCT);
            txn.commit();

            return Response.ok().build();

        } catch (Exception e) {
            txn.rollback();
            LOG.severe(e.getMessage());
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }

    @GET
    @Path("/")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getHojeNaFct(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username) {

        Transaction txn = datastore.newTransaction();

        try {

            Key userKey = userKeyFactory.newKey(username);
            Entity user = txn.get(userKey);

            if (user == null) {
                LOG.warning("User does not exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            if (user.getString("user_state").equals("INACTIVE")) {
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

            Date today = Calendar.getInstance().getTime();

            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            String formattedDate = dateFormat.format(today);

            Key hojeNaFCTKey = datastore.newKeyFactory()
                    .setKind("HojeNaFCT")
                    .newKey(formattedDate);

            Entity hojeNaFCT = txn.get(hojeNaFCTKey);

            if (hojeNaFCT == null) {
                LOG.warning("Hoje na FCT para o dia de hoje ainda por fazer.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            List<ProvaAcademica> thesis = new ArrayList<>();
            List<Menu> menus = new ArrayList<>();
            List<String> links = new ArrayList<>();
            List<EventInHoje> events = new ArrayList<>();

            Query<Entity> query = Query.newEntityQueryBuilder()
                    .setKind("ProvaAcademica")
                    .setFilter(StructuredQuery.PropertyFilter.hasAncestor(hojeNaFCTKey))
                    .build();

            QueryResults<Entity> results = datastore.run(query);

            while (results.hasNext()) {
                Entity prova = results.next();

                List<String> members = new ArrayList<>();

                for (Value<?> member : prova.getList("members")) {
                    members.add((String) member.get());
                }

                thesis.add(new ProvaAcademica(prova.getString("title"), prova.getString("course"), prova.getString("type"),
                        prova.getString("dissertation"), prova.getString("hour"), prova.getString("room"),
                        prova.getString("president"), members));
            }

            query = Query.newEntityQueryBuilder()
                    .setKind("Menu")
                    .setFilter(StructuredQuery.PropertyFilter.hasAncestor(hojeNaFCTKey))
                    .build();

            results = datastore.run(query);

            while (results.hasNext()) {
                Entity menu = results.next();

                menus.add(new Menu(menu.getString("restaurant"), menu.getString("building"), menu.getString("menu")));
            }

            for (Value<?> link : hojeNaFCT.getList("links")) {
                links.add((String) link.get());
            }

            List<StringValue> eventsValues = hojeNaFCT.getList("events");

            for (StringValue eventValue : eventsValues) {

                Key eventKey = datastore.newKeyFactory()
                        .setKind("Event")
                        .newKey(eventValue.get());

                Entity event = txn.get(eventKey);

                String url = "";
                if (!event.getString("event_image").equals("")) {

                    BlobId blobId = BlobId.of(bucketName, event.getString("event_image"));
                    Blob blob = storage.get(blobId);
                    url = blob.getMediaLink();
                }

                events.add(new EventInHoje(event.getString("event_creator"), event.getString("event_title"),
                        event.getString("event_description"), url, event.getLong("start"), event.getLong("end"),
                        event.getString("id")));

            }

            GetHojeNaFCT getHojeNaFCT = new GetHojeNaFCT(hojeNaFCT.getLong("temperature"), thesis, menus, links, events);

            return Response.ok(getHojeNaFCT).build();

        } catch (Exception e) {
            txn.rollback();
            LOG.severe(e.getMessage());
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if (txn.isActive()) {
                txn.rollback();
            }
        }
    }

}
