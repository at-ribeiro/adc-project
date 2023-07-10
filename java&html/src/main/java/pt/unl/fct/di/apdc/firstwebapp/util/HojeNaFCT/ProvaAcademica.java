package pt.unl.fct.di.apdc.firstwebapp.util.HojeNaFCT;

import java.util.List;

public class ProvaAcademica {

    public String course;
    public String title;
    public String type;
    public String dissertation;
    public String hour;
    public String room;
    public String president;
    public List<String> members;

    public ProvaAcademica() {}

    public ProvaAcademica(String course, String title, String type, String dissertation, String hour, String room,
                          String president, List<String> members) {
        this.course = course;
        this.title = title;
        this.type = type;
        this.dissertation = dissertation;
        this.hour = hour;
        this.room = room;
        this.president = president;
        this.members = members;
    }

}
