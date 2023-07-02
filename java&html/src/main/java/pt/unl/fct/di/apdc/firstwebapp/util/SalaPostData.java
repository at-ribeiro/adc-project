package pt.unl.fct.di.apdc.firstwebapp.util;

public class SalaPostData {

    private String name;
    private String building;
    private double lat;
    private double lng;
    private long capacity;

    public SalaPostData(){}

    public SalaPostData(String name, String building, double lat, double lng, long capacity){
        this.name = name;
        this.building = building;
        this.lat = lat;
        this.lng = lng;
        this.capacity = capacity;
    }

    public String getName() {
        return name;
    }

    public String getBuilding() {
        return building;
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
