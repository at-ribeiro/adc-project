package pt.unl.fct.di.apdc.firstwebapp.util;

public class EventPostData {

    private String creator;
    private String title;
    private String description;
    private long start;
    private long end;
    private String id;

    public EventPostData(){}

    public EventPostData(String creator, String title, String description, long start, long end, String id){
        this.creator = creator;
        this.title = title;
        this.description = description;
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

    public long getStart() {
        return start;
    }

    public long getEnd() {
        return end;
    }


}
