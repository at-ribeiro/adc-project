package pt.unl.fct.di.apdc.firstwebapp.util;

public class EventGetData {

    private String creator;
    private String title;
    private String description;

    private String url;
    private String start;
    private String end;

    public EventGetData(){}

    public EventGetData(String creator, String title, String description, String url, String start, String end){
        this.creator = creator;
        this.title = title;
        this.description = description;
        this.url = url;
        this.start = start;
        this.end = end;
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

    public String getStart() {
        return start;
    }

    public String getEnd() {
        return end;
    }

}
