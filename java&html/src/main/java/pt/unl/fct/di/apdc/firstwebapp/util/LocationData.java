package pt.unl.fct.di.apdc.firstwebapp.util;

public class LocationData {

    private String name;
    private double latitude;
    private double longitude;
    private String type;
    private String event;

    public LocationData() {

    }

    public LocationData(String name, double latitude, double longitude, String type, String event) {
        this.name = name;
        this.latitude = latitude;
        this.longitude = longitude;
        this.type = type;
        this.event = event;
    }

    public String getName() {
        return name;
    }

    public double getLatitude() {
        return latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public String getType() {
        return type;
    }

    public String getEvent() {
        return event;
    }


}
