package pt.unl.fct.di.apdc.firstwebapp.util;

public class UserData {

    private String username;
    private String fullname;
    private String email;
    private String phone;
    private String role;
    private String about_me;
    private String department;
    private String course;
    private String year;
    private String city;
    private int nFollowing;
    private int nFollowers;
    private int nPosts;
    private int nGroups;
    private int nNucleos;

    private String purpose;

    public UserData(){}

    public UserData(String username, String fullname, String email, String phone, String role, String about_me, String department,
                    String course, String year, String city, int nFollowing, int nFollowers, int nPosts, int nGroups, int nNucleos){
        this.username = username;
        this.fullname = fullname;
        this.email = email;
        this.phone = phone;
        this.role = role;
        this.about_me = about_me;
        this.department = department;
        this.course = course;
        this.year = year;
        this.city = city;
        this.nFollowing = nFollowing;
        this.nFollowers = nFollowers;
        this.nPosts = nPosts;
        this.nGroups = nGroups;
        this.nNucleos = nNucleos;
    }

    public UserData(String username, String fullname, String email, String phone, String role, String about_me, String department, String city,
                    int nFollowing, int nFollowers, int nPosts){
        this.username = username;
        this.fullname = fullname;
        this.email = email;
        this.phone = phone;
        this.role = role;
        this.about_me = about_me;
        this.department = department;
        this.city = city;
        this.nFollowing = nFollowing;
        this.nFollowers = nFollowers;
        this.nPosts = nPosts;
    }

    public UserData(String username, String fullname, String email, String phone, String role, String about_me, String city,
                    int nFollwing, int nFollowers, int nPosts, String purpose){
        this.username = username;
        this.fullname = fullname;
        this.email = email;
        this.phone = phone;
        this.role = role;
        this.about_me = about_me;
        this.city = city;
        this.nFollowing = nFollwing;
        this.nFollowers = nFollowers;
        this.nPosts = nPosts;
        this.purpose = purpose;
    }

}
