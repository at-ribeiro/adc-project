package pt.unl.fct.di.apdc.firstwebapp.util;

public class ListData {
    private String username;
    private String role;
    private long expirationDate;
    public ListData(){}

    public ListData(String username, String role, long expirationDate){
        this.username = username;
        this.role = role;
        this.expirationDate = expirationDate;
    }

    public String getUsername(){
        return username;
    }
    public String getRole() {
        return role;
    }
    public long getExpirationDate() {
        return expirationDate;
    }

}
