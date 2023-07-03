package pt.unl.fct.di.apdc.firstwebapp.util;

import java.util.List;

public class RoomGetData {

    private String name;
    private String building;
    private String url;
    private String id;
    private double lat;
    private double lng;
    private long capacity;

    public RoomGetData(){}

    public RoomGetData(String id, String roomName, String roomBuilding, double roomLatitude, double roomLongitude, long roomCapacity) {
        this.id = id;
        this.name = roomName;
        this.building = roomBuilding;
        this.lat = roomLatitude;
        this.lng = roomLongitude;
        this.capacity = roomCapacity;
    }

    public String getName() {
        return name;
    }

    public String getBuilding() {
        return building;
    }

    public String getUrl() {
        return url;
    }

    public String getId() {
        return id;
    }

    public double getLat() {
    	return lat;
    }

    public double getLng() {
    	return lng;
    }

    public long getCapacity() {
        return capacity; 
    }
}