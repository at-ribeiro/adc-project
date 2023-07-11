package pt.unl.fct.di.apdc.fctconnect.util.Event;

import java.util.List;

public class EventGetData {

    private String creator;
    private String title;
    private String description;
    private String url;
    private long start;
    private long end;
    private String id;
    private String qrCodeUrl;
    private List<String> participants;
    private double lat;
    private double lng;

    public EventGetData(){}

    public EventGetData(String creator, String title, String description, String url, long start, long end, String id,
                        String qrCodeUrl, List<String> participants, double lat, double lng) {
        this.creator = creator;
        this.title = title;
        this.description = description;
        this.url = url;
        this.start = start;
        this.end = end;
        this.id = id;
        this.qrCodeUrl = qrCodeUrl;
        this.participants = participants;
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

    public String getUrl() {
        return url;
    }

    public long getStart() {
        return start;
    }

    public long getEnd() {
        return end;
    }
    public String getId() {
        return id;
    } 

    public String getQrCodeUrl(){
        return qrCodeUrl;
    }

    public List<String> getParticipants(){
        return participants;
    }

    public double getLat() {
    	return lat;
    }

    public double getLng() {
    	return lng;
    }

}
