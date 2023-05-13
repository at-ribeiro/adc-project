package pt.unl.fct.di.apdc.firstwebapp.util;


public class LoginData {
    private String username;
    private String password;

    public LoginData(){}

    public LoginData(String username, String password){
        this.username = username;
        this.password = password;
    }

    public String getUsername(){
        return username;
    }

    public String getPassword() {
        return password;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
