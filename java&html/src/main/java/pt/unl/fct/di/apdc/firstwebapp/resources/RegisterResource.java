package main.java.pt.unl.fct.di.apdc.firstwebapp.resources;


import com.google.cloud.Timestamp;
import com.google.cloud.datastore.*;
import org.apache.commons.codec.digest.DigestUtils;
import main.java.pt.unl.fct.di.apdc.firstwebapp.util.RegisterData;

import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.logging.Logger;
@Path("/register")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class RegisterResource {

    private static final Logger LOG = Logger.getLogger(RegisterResource.class.getName());

    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    @POST
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response register(RegisterData data){
        LOG.fine("Attempt to register user: " + data.getUsername());

        if(!data.validRegistration()){
            return Response.status(Response.Status.BAD_REQUEST).entity("Missing or Wrong parameter.").build();
        }

        Transaction txn = datastore.newTransaction();
        try{
            Key userKey = datastore.newKeyFactory().setKind("User").newKey(data.getUsername());
            Entity user = txn.get(userKey);
            if(user != null){
                txn.rollback();
                return Response.status(Response.Status.CONFLICT).entity("User already exists.").build();
            }else {
                user = Entity.newBuilder(userKey)
                        .set("user_username", data.getUsername())
                        .set("user_fullname", data.getFullname())
                        .set("user_pwd", DigestUtils.sha512Hex(data.getPassword()))
                        .set("user_email", data.getEmail())
                        .set("user_creation_time", Timestamp.now())
                        .set("user_role", data.getRole())
                        .set("user_state", data.getState())
                        .set("user_privacy", data.getPrivacy())
                        .set("user_homephone", "")
                        .set("user_mobilephone", "")
                        .set("user_occupation", "")
                        .set("user_address", "")
                        .set("user_nif", "")
                        .build();
                txn.add(user);
                LOG.info("User registered" + data.getUsername());
                txn.commit();
                return Response.ok(data.getUsername()).header("Access-Control-Allow_Origin", "*").build();
            }
        }finally {
            if(txn.isActive()){
                txn.rollback();
            }
        }
    }
}
