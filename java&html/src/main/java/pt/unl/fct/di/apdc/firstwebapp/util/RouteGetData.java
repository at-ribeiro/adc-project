package pt.unl.fct.di.apdc.firstwebapp.util;


import java.util.List;

public class RouteGetData {

    private String creator;
    private String name;
    private List<LocationData> locations;
    private List<String> participants;
    private List<Integer> durations;

    public RouteGetData() {

    }

    public RouteGetData(String creator, String name, List<LocationData> locations, List<String> participants, List<Integer> durations) {
        this.creator = creator;
        this.name = name;
        this.locations = locations;
        this.participants = participants;
        this.durations = durations;
    }

    public String getCreator() {
        return creator;
    }

    public String getName() {
        return name;
    }

    public List<LocationData> getLocations() {
        return locations;
    }

    public List<String> getParticipants() {
        return participants;
    }

    public List<Integer> getDurations() {
        return durations;
    }

}
