package pt.unl.fct.di.apdc.fctconnect.util.HojeNaFCT;

import java.util.List;

public class HojeNaFCTData {

    private int temperature;
    private List<ProvaAcademica> thesis;
    private List<String> links;

    private List<Menu> menus;

    public HojeNaFCTData() {}

    public HojeNaFCTData(int temperature, List<ProvaAcademica> thesis, List<String> links, List<Menu> menus) {
    	this.temperature = temperature;
    	this.thesis = thesis;
    	this.links = links;
    	this.menus = menus;
    }

    public int getTemperature() {
    	return temperature;
    }

    public List<ProvaAcademica> getThesis() {
    	return thesis;
    }

    public List<String> getLinks() {
    	return links;
    }

    public List<Menu> getMenus() {
    	return menus;
    }

}
