package pt.unl.fct.di.apdc.firstwebapp.util;

public class UpdateData {

    private String username;
    private String tokenUser;
    private String tokenRole;
    private String tokenId;
    private String fullname;
    private String email;
    private String privacy;
    private String homephone;
    private String mobilephone;
    private String occupation;
    private String address;
    private String nif;
    private String role;
    private String state;

    public UpdateData(){}

    public UpdateData(String username, String tokenUser, String tokenRole, String tokenId, String fullname, String email, String privacy, String homephone,
                      String mobilephone, String occupation, String address, String nif, String role, String state){
        this.username = username;
        this.tokenUser = tokenUser;
        this.tokenRole = tokenRole;
        this.tokenId = tokenId;
        this.fullname = fullname;
        this.email = email;
        this.privacy = privacy;
        this.homephone = homephone;
        this.mobilephone = mobilephone;
        this.occupation = occupation;
        this.address = address;
        this.nif = nif;
        this.role = role;
        this.state = state;
    }

    public String getUsername(){
        return username;
    }
    public String getEmail() {return email;}
    public void setUsername(String username) {
        this.username = username;
    }

    public String getTokenRole() {
        return tokenRole;
    }

    public String getPrivacy() {
        return privacy;
    }

    public String getHomephone() {
        return homephone;
    }

    public String getMobilephone() {
        return mobilephone;
    }

    public String getOccupation() {
        return occupation;
    }

    public String getAddress() {
        return address;
    }

    public String getNif() {
        return nif;
    }

    public String getRole() {
        return role;
    }

    public String getState() {
        return state;
    }

    public String getFullname() {
        return fullname;
    }

    public String getTokenUser() {
        return tokenUser;
    }

    public String getTokenId() {
        return tokenId;
    }
}
