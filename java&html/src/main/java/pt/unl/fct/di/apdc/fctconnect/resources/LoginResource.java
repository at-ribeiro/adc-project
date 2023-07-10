package pt.unl.fct.di.apdc.fctconnect.resources;

import com.google.cloud.datastore.*;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.fctconnect.util.Token.AuthToken;
import pt.unl.fct.di.apdc.fctconnect.util.Login.LoginData;


import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.logging.Logger;
import com.google.gson.Gson;

@Path("/login")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class LoginResource {

    private static final Logger LOG = Logger.getLogger(LoginResource.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");
    private final Gson g = new Gson();

    public LoginResource(){}

    @POST
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response login(LoginData data, @Context HttpServletRequest request, @Context HttpHeaders headers) {

        LOG.fine("Attempt to login user: " + data.getUsername());

        Key userKey = userKeyFactory.newKey(data.getUsername());

        /*
        Key ctrsKey = datastore.newKeyFactory().addAncestors(PathElement.of("User", data.getUsername()))
                                .setKind("UserStats").newKey("Counters");

        Key logKey = datastore.allocateId(datastore.newKeyFactory()
                                            .addAncestors(PathElement.of("User", data.getUsername()))
                                            .setKind("UserLog").newKey());

         */

        Transaction txn = datastore.newTransaction();
        try {
            Entity user = txn.get(userKey);

            LOG.fine("Found user: " + user);

            if (user == null) {
                LOG.warning("Failed login attempt for username: " + data.getUsername());
                return Response.status(Response.Status.NOT_FOUND).build();
            }

            /*
            Entity stats = txn.get(ctrsKey);
            if(stats == null){
                stats = Entity.newBuilder(ctrsKey)
                        .set("user_stats_logins", 0L)
                        .set("user_stats_failed", 0L)
                        .set("user_first_login", Timestamp.now())
                        .set("user_last_login", Timestamp.now())
                        .build();
            }
               */

            String hashedPWD = user.getString("user_pwd");

            if(user.getString("user_state").equals("INACTIVE")) {
            	LOG.warning("Failed login attempt for username: " + data.getUsername());
            	return Response.status(Response.Status.UNAUTHORIZED).build();
            }

            if (hashedPWD.equals(DigestUtils.sha512Hex(data.getPassword()))) {

                /*
                Entity log = Entity.newBuilder(logKey)
                        .set("user_login_ip", request.getRemoteAddr())
                        .set("user_login_host", request.getRemoteHost())
                        .set("user_login_latlon", StringValue.newBuilder(
                                headers.getHeaderString("X-AppEngine-CityLatLong")).setExcludeFromIndexes(true).build())
                        .set("user_login_city", headers.getHeaderString("X-AppEngine-City"))
                        .set("user_login_country", headers.getHeaderString("X-AppEngine-Country"))
                        .set("user_login_time", Timestamp.now())
                        .build();

                Entity ustats = Entity.newBuilder(ctrsKey)
                        .set("user_stats_logins", 1L + stats.getLong("user_stats_logins"))
                        .set("user_stats_failed", 0L)
                        .set("user_first_login", stats.getTimestamp("user_first_login"))
                        .set("user_last_login", Timestamp.now())
                        .build();

                txn.put(log, ustats);
                */

                AuthToken token = new AuthToken(data.getUsername(), user.getString("user_role"));

                Key tokenKey = datastore.newKeyFactory()
                        .setKind("Token")
                        .addAncestor(PathElement.of("User", data.getUsername()))
                        .newKey("token");

                Entity tokenEntity = txn.get(tokenKey);

                if(tokenEntity == null) {

                    tokenEntity = Entity.newBuilder(tokenKey)
                            .set("token_hashed_id", DigestUtils.sha512Hex(token.getTokenID()))
                            .set("token_username", token.getUsername())
                            .set("token_role", token.getRole())
                            .set("token_creation", token.creationData())
                            .set("token_expiration", token.expirationData())
                            .set("token_id", token.getTokenID())
                            .build();

                    txn.add(tokenEntity);
                }
                else if (AuthToken.expired(tokenEntity.getLong("token_expiration"))){

                    tokenEntity = Entity.newBuilder(tokenKey)
                            .set("token_hashed_id", DigestUtils.sha512Hex(token.getTokenID()))
                            .set("token_username", token.getUsername())
                            .set("token_role", token.getRole())
                            .set("token_creation", token.creationData())
                            .set("token_expiration", token.expirationData())
                            .set("token_id", token.getTokenID())
                            .build();

                    txn.update(tokenEntity);

                } else{
                    token.setTokenID(tokenEntity.getString("token_id"));
                    token.setUsername(tokenEntity.getString("token_username"));
                    token.setRole(tokenEntity.getString("token_role"));
                    token.setCreationDate(tokenEntity.getLong("token_creation"));
                    token.setExpirationDate(tokenEntity.getLong("token_expiration"));
                }

                txn.commit();

                LOG.info("User '" + data.getUsername() + "' logged in successfully.");
                return Response.ok(g.toJson(token)).build();

            }else {
                //Incorrect password
                LOG.warning("Wrong password for username: " + data.getUsername());

                /*
                Entity ustats = Entity.newBuilder(ctrsKey)
                        .set("user_stats_logins", stats.getLong("user_stats_logins"))
                        .set("user_stats_failed", 1L + stats.getLong("user_stats_failed"))
                        .set("user_first_login", stats.getTimestamp("user_first_login"))
                        .set("user_last_login", stats.getTimestamp("user_last_login"))
                        .set("user_last_attempt", Timestamp.now())
                        .build();

                txn.put(ustats);
                txn.commit();
                */

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
