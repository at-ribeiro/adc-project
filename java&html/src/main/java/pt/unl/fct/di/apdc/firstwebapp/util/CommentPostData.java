package pt.unl.fct.di.apdc.firstwebapp.util;

public class CommentPostData {

    private String user;
    private String text;
    private long timestamp;

    public CommentPostData(){}

    public CommentPostData(String user, String text, long timestamp){
        this.user = user;
        this.text = text;
        this.timestamp = timestamp;
    }

    public String getUser() {
        return user;
    }

    public String getText() {
        return text;
    }

    public long getTimestamp() {
        return timestamp;
    }
}
