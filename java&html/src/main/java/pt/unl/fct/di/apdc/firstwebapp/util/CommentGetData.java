package pt.unl.fct.di.apdc.firstwebapp.util;

public class CommentGetData {

    private String user;
    private String text;
    private long timestamp;

    public CommentGetData(){}

    public CommentGetData(String user, String text, long timestamp){
        this.user = user;
        this.text = text;
        this.timestamp = timestamp;
    }

}
