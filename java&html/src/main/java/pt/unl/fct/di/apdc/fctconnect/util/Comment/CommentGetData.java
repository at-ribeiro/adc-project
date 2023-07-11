package pt.unl.fct.di.apdc.fctconnect.util.Comment;

public class CommentGetData {

    private String user;
    private String text;
    private long timestamp;
    private String profilePic;

    public CommentGetData(){}

    public CommentGetData(String user, String text, long timestamp, String profilePic) {
        this.user = user;
        this.text = text;
        this.timestamp = timestamp;
        this.profilePic = profilePic;
    }

}
