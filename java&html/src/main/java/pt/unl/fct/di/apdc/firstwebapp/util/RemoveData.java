package main.java.pt.unl.fct.di.apdc.firstwebapp.util;

public class RemoveData {
    private String username;
    private String tokenUsername;
    private String role;
    private String tokenId;

    public RemoveData(){}

    public RemoveData(String username, String tokenUsername, String role, String tokenId){
        this.username = username;
        this.tokenUsername = tokenUsername;
        this.role = role;
        this.tokenId = tokenId;
    }

    public String getUsername(){
        return username;
    }

    public String getTokenUsername() {
        return tokenUsername;
    }

    public String getRole() {
        return role;
    }

    public String getTokenId() {
        return tokenId;
    }
}
