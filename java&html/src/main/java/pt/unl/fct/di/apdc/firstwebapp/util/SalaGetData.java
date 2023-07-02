package pt.unl.fct.di.apdc.firstwebapp.util;

import java.util.List;

public class SalaGetData {

    private String name;
    private String building;
    private String url;
    private String id;
    //private String qrCodeUrl;
    private List<Integer> lotation;
    private double lat;
    private double lng;
    private long capacity;

    public SalaGetData(){}

    public SalaGetData(String name, String building, String url, String id,
                        List<Integer> lotation, double lat, double lng, long capacity) {
        this.name = name;
        this.building = building;
        this.url = url;
        this.id = id;
        this.lotation = lotation;
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

    public String getUrl() {
        return url;
    }

    public String getId() {
        return id;
    }

    public List<Integer> getLotation(){
        return lotation;
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