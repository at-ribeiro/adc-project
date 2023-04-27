package pt.unl.fct.di.apdc.firstwebapp.util;

public class RemoveData {
    private String username;
    private String tokenUsername;
    private String role;
    private long expirationDate;

    public RemoveData(){}

    public RemoveData(String username, String tokenUsername, String role, long expirationDate){
        this.username = username;
        this.tokenUsername = tokenUsername;
        this.role = role;
        this.expirationDate = expirationDate;
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

    public long getExpirationDate() {return expirationDate;}
}
