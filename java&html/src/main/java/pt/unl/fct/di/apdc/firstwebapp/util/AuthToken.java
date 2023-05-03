package main.java.pt.unl.fct.di.apdc.firstwebapp.util;
import java.util.UUID;

public class AuthToken {
    public static final long EXPIRATION_TIME = 1000*60*60*2; //2h
    private String username;
    private String role;
    private String tokenID;
    private long creationDate;
    private long expirationDate;

    public AuthToken(String username, String role) {
        this.username = username;
        this.role = role;
        this.tokenID = UUID.randomUUID().toString();
        this.creationDate = System.currentTimeMillis();
        this.expirationDate = this.creationDate + AuthToken.EXPIRATION_TIME;
    }

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

    public static boolean expired(long expirationDate){
        return System.currentTimeMillis() > expirationDate;
    }


}