package pt.unl.fct.di.apdc.fctconnect.util.Register;

public class RegisterData {


    private String username;

    private String fullname;
    private String password;
    private String passwordV;
    private String email;
    private String state;
    private String privacy;

    public RegisterData(){}

    public RegisterData(String username, String fullname, String password, String passwordV, String email, String role, String state, String privacy){
        this.username = username;
        this.fullname = fullname;
        this.password = password;
        this.passwordV = passwordV;
        this.email = email;
        this.state = state;
        this.privacy = privacy;
    }

    public String getUsername(){
        return username;
    }
    public String getFullname() {
        return fullname;
    }
    public String getPassword() {
        return password;
    }
    public String getPasswordV() {return passwordV;}
    public String getEmail() {return email;}
    public String getState() {return state;}
    public String getPrivacy() {return privacy;}

    public boolean validRegistration() {
        return username != null && password != null && passwordV != null && password.equals(passwordV) && email != null;
    }
}
