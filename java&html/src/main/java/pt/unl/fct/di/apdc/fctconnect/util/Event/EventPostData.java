package pt.unl.fct.di.apdc.fctconnect.util.Event;

public class EventPostData {

    private String creator;
    private String title;
    private String description;
    private long start;
    private long end;
    private double lat;
    private double lng;

    public EventPostData(){}

    public EventPostData(String creator, String title, String description, long start, long end, double lat, double lng){
        this.creator = creator;
        this.title = title;
        this.description = description;
        this.start = start;
        this.end = end;
        this.lat = lat;
        this.lng = lng;
    }

    public String getCreator() {
        return creator;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public long getStart() {
        return start;
    }

    public long getEnd() {
        return end;
    }

    public double getLat() {
    	return lat;
    }

    public double getLng() {
    	return lng;
    }


}
