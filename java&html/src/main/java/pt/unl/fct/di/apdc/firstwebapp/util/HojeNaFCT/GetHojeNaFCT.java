package pt.unl.fct.di.apdc.firstwebapp.util.HojeNaFCT;

import java.util.List;

public class GetHojeNaFCT {

    private long temperature;
    private List<ProvaAcademica> thesis;
    private List<Menu> menus;
    private List<String> links;
    private List<EventInHoje> events;


    public GetHojeNaFCT(long temperature, List<ProvaAcademica> thesis, List<Menu> menus, List<String> links, List<EventInHoje> events) {
        this.temperature = temperature;
        this.thesis = thesis;
        this.menus = menus;
        this.links = links;
        this.events = events;
    }



}
