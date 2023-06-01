package pt.unl.fct.di.apdc.firstwebapp.util;

public class AlertPostData {

    private String creator;
    private String title;
    private String location;
    private String description;
    private long timestamp;

    public AlertPostData(String creator, String title, String location, String description, long timestamp){
        this.creator = creator;
        this.title = title;
        this.location = location;
        this.description = description;
        this.timestamp = timestamp;
    }

    public String getCreator() {
        return creator;
    }
    public String getTitle() {
        return title;
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
