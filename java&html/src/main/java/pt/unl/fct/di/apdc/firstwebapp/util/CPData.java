package pt.unl.fct.di.apdc.firstwebapp.util;

public class CPData {

    private String newPassword;
    private String oldPassword;
    private String passwordV;

    public CPData(){}

    public CPData(String password, String oldPassword, String passwordV){
        this.newPassword = password;
        this.oldPassword = oldPassword;
        this.passwordV = passwordV;
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
       return passwordV.equals(newPassword);
    }


}
