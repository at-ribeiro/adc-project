package pt.unl.fct.di.apdc.fctconnect.util.Route;


import java.util.List;

public class RouteData {

    private String creator;
    private String name;
    private List<String> locations;
    private List<String> participants;
    private List<Integer> durations;

    public RouteData() {

    }

    public RouteData(String creator, String name, List<String> locations, List<String> participants, List<Integer> durations) {
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

    public List<String> getLocations() {
        return locations;
    }

    public List<String> getParticipants() {
        return participants;
    }

    public List<Integer> getDurations() {
        return durations;
    }

}
