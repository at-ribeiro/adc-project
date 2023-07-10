package pt.unl.fct.di.apdc.firstwebapp.util.HojeNaFCT;

public class EventInHoje {

    private String creator;
    private String title;
    private String description;
    private String url;
    private long start;
    private long end;
    private String id;

    public EventInHoje(){}

    public EventInHoje(String creator, String title, String description, String url, long start, long end, String id) {
        this.creator = creator;
        this.title = title;
        this.description = description;
        this.url = url;
        this.start = start;
        this.end = end;
        this.id = id;
    }


}
