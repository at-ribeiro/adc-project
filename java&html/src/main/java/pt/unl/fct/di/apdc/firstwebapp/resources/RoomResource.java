package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.ReservationData;
import pt.unl.fct.di.apdc.firstwebapp.util.RoomGetData;
import pt.unl.fct.di.apdc.firstwebapp.util.RoomPostData;

import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Path("/rooms")
public class RoomResource {

    private static final Logger LOG = Logger.getLogger(RoomResource.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");

    @POST
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response createRoom(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username, RoomPostData data) {

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

            // TODO:Check user's role

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

            String uniqueRoomId = (data.getName() + "-" + data.getBuilding()).toLowerCase();

            Key roomKey = datastore.newKeyFactory()
                    .setKind("Room")
                    .newKey(uniqueRoomId);

            if(txn.get(roomKey) != null){
                LOG.warning("Room already exists.");
                return Response.status(Response.Status.CONFLICT).build();
            }


            Entity entity = Entity.newBuilder(roomKey)
                    .set("id", uniqueRoomId)
                    .set("room_name", data.getName())
                    .set("room_building", StringValue.newBuilder(data.getBuilding()).setExcludeFromIndexes(true).build())
                    .set("room_latitude", DoubleValue.newBuilder(data.getLat()).setExcludeFromIndexes(true).build())
                    .set("room_longitude", DoubleValue.newBuilder(data.getLng()).setExcludeFromIndexes(true).build())
                    .set("room_capacity", data.getCapacity())
                    .build();

            txn.add(entity);
            txn.commit();
            return Response.ok().build();

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
    @Path("/{roomId}")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response makeReservation(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username,
                                    @PathParam("roomId") String roomId, ReservationData data) {

        Transaction txn = datastore.newTransaction();

        try{

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

            Key roomKey = datastore.newKeyFactory()
                    .setKind("Room")
                    .newKey(roomId);

            Entity room = txn.get(roomKey);

            if(room == null){
                LOG.warning("Room does not exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            Key reservationKey = datastore.newKeyFactory()
                    .setKind("Reservation")
                    .addAncestor(PathElement.of("Room", roomId))
                    .newKey(data.getUser()+"-"+data.getDay()+"-"+data.getHour());

            if(txn.get(reservationKey) != null) {
                LOG.warning("Reservation already exists.");
                return Response.status(Response.Status.CONFLICT).build();
            }

            Query<Entity> query = Query.newEntityQueryBuilder()
                    .setKind("Reservation")
                    .setFilter(StructuredQuery.CompositeFilter.and(
                            StructuredQuery.PropertyFilter.eq("reservation_room", roomId),
                            StructuredQuery.PropertyFilter.eq("reservation_day", data.getDay()),
                            StructuredQuery.PropertyFilter.eq("reservation_hour", data.getHour())
                    ))
                    .build();

            QueryResults<Entity> results = txn.run(query);

            List<Entity> reservations = new ArrayList<>();

            while(results.hasNext())
                reservations.add(results.next());

            if(room.getLong("room_capacity") <=  reservations.size()){
                LOG.warning("Room is full.");
                return Response.status(Response.Status.PRECONDITION_FAILED).build();
            }

            Entity entity = Entity.newBuilder(reservationKey)
                    .set("reservation_id", data.getUser()+"-"+data.getDay()+"-"+data.getHour())
                    .set("reservation_user", data.getUser())
                    .set("reservation_room", roomId)
                    .set("reservation_day", data.getDay())
                    .set("reservation_hour", data.getHour())
                    .build();

            txn.add(entity);
            txn.commit();

            return Response.ok().build();

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

    @GET
    @Path("/")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getRooms(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username,
                             @QueryParam("building") String building) {

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

            Query<Entity> query = Query.newEntityQueryBuilder()
                    .setKind("Room")
                    .setFilter(StructuredQuery.PropertyFilter.eq("room_building", building))
                    .build();

            QueryResults<Entity> results = txn.run(query);

            List<RoomGetData> rooms = new ArrayList<>();

            while (results.hasNext()) {
                Entity entity = results.next();
                rooms.add(new RoomGetData(entity.getString("id"), entity.getString("room_name"), entity.getString("room_building"),
                        entity.getDouble("room_latitude"), entity.getDouble("room_longitude"), entity.getLong("room_capacity")));
            }

            return Response.ok(rooms).build();

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

    @GET
    @Path("/{roomId}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getRoom(@HeaderParam("Authorization") String tokenId, @HeaderParam("User") String username,
                            @PathParam("roomId") String roomId) {

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

            Key roomKey = datastore.newKeyFactory()
                            .setKind("Room")
                            .newKey(roomId);

            Entity room = txn.get(roomKey);

            if (room == null) {
                LOG.warning("Room does not exist.");
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            Query<Entity> query = Query.newEntityQueryBuilder()
                    .setKind("Reservation")
                    .setFilter(StructuredQuery.PropertyFilter.eq("reservation_room", roomId))
                    .build();
            
            QueryResults<Entity> results = txn.run(query);

            List<ReservationData> reservations = new ArrayList<>();

            while(results.hasNext()) {
                Entity entity = results.next();
                reservations.add(new ReservationData(entity.getString("reservation_user"),
                        entity.getString("reservation_room"), entity.getLong("reservation_day"), entity.getLong("reservation_hour")));
            }

            return Response.ok(results).build();

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
