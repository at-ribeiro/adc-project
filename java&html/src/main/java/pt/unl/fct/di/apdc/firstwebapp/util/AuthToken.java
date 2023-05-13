package pt.unl.fct.di.apdc.firstwebapp.util;
import java.util.UUID;

public class AuthToken {
    public static final long EXPIRATION_TIME = 1000*60*60*2; //2h
    private String username;
    private String role;
    private String tokenID;
    private long creationDate;
    private long expirationDate;


    //for new AuthTokens
    public AuthToken(String username, String role) {
        this.username = username;
        this.role = role;
        this.tokenID = UUID.randomUUID().toString();
        this.creationDate = System.currentTimeMillis();
        this.expirationDate = this.creationDate + AuthToken.EXPIRATION_TIME;
    }

    //for prev established tokens

    public String getUsername(){
        return username;
    }

    public String getRole() {return role;}

    public String getTokenID(){
        return tokenID;
    }

    public Long creationData(){
        return creationDate;
    }

    public Long expirationData(){
        return expirationDate;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public void setTokenID(String tokenID) {
        this.tokenID = tokenID;
    }

    public void setCreationDate(long creationDate) {
        this.creationDate = creationDate;
    }

    public void setExpirationDate(long expirationDate) {
        this.expirationDate = expirationDate;
    }

    public static boolean expired(long expirationDate){
        return System.currentTimeMillis() > expirationDate;
    }


}