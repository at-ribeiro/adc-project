package pt.unl.fct.di.apdc.firstwebapp.util;

import java.util.List;

public class NucleoGetData {

    private String name;
    private String type;
    private String email;
    private String subtitle;
    private String description;
    private String foundation;
    private String facebook;
    private String instagram;
    private String website;
    private List<String> members;
    private List<String> events;
    private List<String> admins;
    private String url;

    public NucleoGetData() {}

    public NucleoGetData(String name, String type, String email, String subtitle, String description, String foundation, String facebook,
            String instagram, String website, List<String> members,  List<String> events,List<String> admins, String url) {
    	this.name = name;
    	this.type = type;
    	this.email = email;
    	this.subtitle = subtitle;
    	this.description = description;
    	this.foundation = foundation;
    	this.facebook = facebook;
        this.instagram = instagram;
        this.website = website;
    	this.members = members;
    	this.events = events;
    	this.admins = admins;
        this.url = url;
    }



}
