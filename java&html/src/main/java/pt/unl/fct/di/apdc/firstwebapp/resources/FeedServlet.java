package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.cloud.datastore.*;
import com.google.cloud.storage.Blob;
import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;
import org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.FeedData;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Logger;

public class FeedServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(FeedServlet.class.getName());
    private final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();
    private final Storage storage = StorageOptions.getDefaultInstance().getService();
    private final KeyFactory userKeyFactory = datastore.newKeyFactory().setKind("User");
    private final String bucketName = "staging.fct-connect-2023.appspot.com";

    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response){
        Transaction txn = datastore.newTransaction();

        try{
            String tokenId = request.getHeader("Authorization");
            String username = request.getPathInfo().substring(1);
            String timestamp = request.getParameter("timestamp");

            LOG.fine("Attempt get feed for user " + username);

            //verifications

            Key userKey = userKeyFactory.newKey(username);
            Entity user = txn.get(userKey);
            if (user == null){
                LOG.warning("User does not exist.");
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            if (user.getString("user_state").equals("INACTIVE")){
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


            // Retrieve the user's followees
            Query<Entity> followingQuery = Query.newEntityQueryBuilder()
                    .setKind("Follow")
                    .setFilter(StructuredQuery.PropertyFilter.hasAncestor(userKey))
                    .build();
            QueryResults<Entity> followingResults = datastore.run(followingQuery);
            Set<String> followeesKeys = new HashSet<>();
            followingResults.forEachRemaining(followees->{
              String toAdd = txn.get(followees.getKey()).getString("followee");
              followeesKeys.add(toAdd);
            });

            LOG.info("followees: " + followeesKeys.toString());

            List<FeedData> posts = new ArrayList<>();

            StructuredQuery.OrderBy descendingTimestamp = StructuredQuery.OrderBy.desc("timestamp");

            Query<Entity> postQuery = Query.newEntityQueryBuilder()
                    .setKind("Post")
                    .setFilter(
                            StructuredQuery.PropertyFilter.lt("timestamp", timestamp)
                    )
                    .addOrderBy(descendingTimestamp)
                    .build();

            QueryResults<Entity> postResults = datastore.run(postQuery);

            postResults.forEachRemaining(post-> {
                        LOG.info("DEBUG!!!!!!!!!: " + post.getString("id"));

                            if (followeesKeys.contains(txn.get(post.getKey()).getString("user"))) {
                                //paginacao
                                if(posts.size() < 20) {
                                    String url = "";

                                    if (!post.getString("image").equals("")) {

                                        BlobId blobId = BlobId.of(bucketName,
                                                post.getString("user") + "-" + post.getString("image"));
                                        Blob blob = storage.get(blobId);
                                        url = blob.getMediaLink();
                                    }

                                    FeedData feedPost = new FeedData(
                                            post.getString("id"),
                                            post.getString("text"),
                                            post.getString("user"),
                                            url,
                                            post.getString("id").split("-")[1]
                                    );

                                    posts.add(feedPost);
                                }

                            }

                    }
                    );


            if(posts.isEmpty()){
                LOG.info("posts: " + posts.toString());
                response.setStatus(HttpServletResponse.SC_PRECONDITION_FAILED);
                return;
            }

            // Convert the list of posts to JSON
            ObjectMapper objectMapper = new ObjectMapper();
            String json = objectMapper.writeValueAsString(posts);

            // Set the response content type and write the JSON string to the output stream
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(json);
            response.setStatus(HttpServletResponse.SC_OK);

        }catch (Exception e) {
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
