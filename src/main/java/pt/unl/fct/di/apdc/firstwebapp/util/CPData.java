package pt.unl.fct.di.apdc.firstwebapp.util;

public class CPData {

    private String username;
    private long expiration;
    private String newPassword;
    private String oldPassword;
    private String passwordV;

    public CPData(){}

    public CPData(String username, long expiration, String password, String oldPassword, String passwordV){
        this.username = username;
        this.expiration = expiration;
        this.newPassword = password;
        this.oldPassword = oldPassword;
        this.passwordV = passwordV;
    }

    public String getUsername(){
        return username;
    }

    public String getNewPassword() {
        return newPassword;
    }

    public String getOldPassword() {
        return oldPassword;
    }

    public String getPasswordV() {
        return passwordV;
    }

    public boolean valid(){
       return passwordV.equals(oldPassword);
    }

    public long getExpiration() {
        return expiration;
    }
}
