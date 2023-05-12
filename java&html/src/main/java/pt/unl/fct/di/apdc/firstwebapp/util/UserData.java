package pt.unl.fct.di.apdc.firstwebapp.util;

import com.google.cloud.Timestamp;

import java.util.Date;


public class UserData {

    private String username;
    private String fullname;
    private String email;
    private String role;
    private String privacy;
    private String state;
    private Date creationTime;

    public UserData(){}

    public UserData(String username, String email, String fullname){
        this.username = username;
        this.email = email;
        this.fullname = fullname;
    }

    public UserData(String username, String fullname, String email, String role, String privacy, String state, Date creationTime){
        this.username = username;
        this.fullname = fullname;
        this.email = email;
        this.role = role;
        this.privacy = privacy;
        this.state = state;
        this.creationTime = creationTime;
    }
}
