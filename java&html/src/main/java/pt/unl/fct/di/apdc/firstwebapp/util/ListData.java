package pt.unl.fct.di.apdc.firstwebapp.util;

public class ListData {
    private String username;
    private String role;
    private String tokenId;
    public ListData(){}

    public ListData(String username, String role, String tokenId){
        this.username = username;
        this.role = role;
        this.tokenId = tokenId;
    }

    public String getUsername(){
        return username;
    }

    public String getRole() {
        return role;
    }

    public String getTokenId() {
        return tokenId;
    }
}
