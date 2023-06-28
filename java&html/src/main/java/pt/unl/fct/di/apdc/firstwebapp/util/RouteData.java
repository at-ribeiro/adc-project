package pt.unl.fct.di.apdc.firstwebapp.util;


import java.util.List;

public class RouteData {

    private String creator;
    private String name;
    private List<String> locations;
    private List<String> participants;

    public RouteData() {

    }

    public RouteData(String creator, String name, List<String> locations, List<String> participants) {
        this.creator = creator;
        this.name = name;
        this.locations = locations;
        this.participants = participants;
    }

    public String getCreator() {
        return creator;
    }

    public String getName() {
        return name;
    }

    public List<String> getLocations() {
        return locations;
    }

    public List<String> getParticipants() {
        return participants;
    }

}
