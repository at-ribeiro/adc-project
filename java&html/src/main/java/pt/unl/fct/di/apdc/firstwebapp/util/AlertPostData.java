package pt.unl.fct.di.apdc.firstwebapp.util;

public class AlertPostData {

    private String creator;
    private String location;
    private String description;
    private long timestamp;

    public AlertPostData(){}

    public AlertPostData(String creator, String location, String description, long timestamp){
        this.creator = creator;
        this.location = location;
        this.description = description;
        this.timestamp = timestamp;
    }

    public String getCreator() {
        return creator;
    }

    public String getLocation() {
        return location;
    }

    public String getDescription() {
        return description;
    }

    public long getTimestamp() {
        return timestamp;
    }
}
