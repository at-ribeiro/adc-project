package pt.unl.fct.di.apdc.firstwebapp.util;

import com.google.cloud.Timestamp;

import java.util.Date;


public class UserData {

    private String username;
    private String fullname;
    private String email;

    private String role;
    private int nFollowing;
    private int nFollowers;

    public UserData(){}

    public UserData(String username, String fullname, String email, String role, int nFollowing, int nFollowers){
        this.username = username;
        this.fullname = fullname;
        this.email = email;
        this.role = role;
        this.nFollowing = nFollowing;
        this.nFollowers = nFollowers;
    }
}
