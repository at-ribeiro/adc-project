package pt.unl.fct.di.apdc.firstwebapp.util;

import java.util.List;

public class NucleoPostData {

    private String admin;
    private String name;
    private String type;
    private String email;
    private String subtitle;
    private String description;
    private String foundation;
    private List<String> links;

    public NucleoPostData() {}

    public NucleoPostData(String admin, String name, String type, String email, String subtitle, String description, String foundation, List<String> links) {
        this.admin = admin;
        this.name = name;
        this.type = type;
    	this.email = email;
    	this.subtitle = subtitle;
    	this.description = description;
    	this.foundation = foundation;
    	this.links = links;
    }

    public String getAdmin() {
    	return admin;
    }
    public String getName() {
    	return name;
    }
    public String getType() {
    	return type;
    }
    public String getEmail() {
    	return email;
    }

    public String getSubtitle() {
    	return subtitle;
    }

    public String getDescription() {
    	return description;
    }

    public String getFoundation() {
    	return foundation;
    }

    public List<String> getLinks() {
    	return links;
    }

}
