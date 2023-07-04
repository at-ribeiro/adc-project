package pt.unl.fct.di.apdc.firstwebapp.util;

import java.util.List;

public class NucleoGetData {

    private String name;
    private String type;
    private String email;
    private String subtitle;
    private String description;
    private String foundation;
    private List<String> links;
    private List<String> members;
    private List<String> events;
    private List<String> admins;

    public NucleoGetData() {}

    public NucleoGetData(String name, String type, String email, String subtitle, String description, String foundation, List<String> links, List<String> members, List<String> events, List<String> admins) {
    	this.name = name;
    	this.type = type;
    	this.email = email;
    	this.subtitle = subtitle;
    	this.description = description;
    	this.foundation = foundation;
    	this.links = links;
    	this.members = members;
    	this.events = events;
    	this.admins = admins;
    }



}
