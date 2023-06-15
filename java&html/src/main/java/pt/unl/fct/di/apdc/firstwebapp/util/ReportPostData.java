package pt.unl.fct.di.apdc.firstwebapp.util;

public class ReportPostData {

    private String creator;
    private String postId;
    private String postCreator;
    private String reason;
    private String comment;
    private String timestamp;

    public ReportPostData() {}

    public ReportPostData(String creator, String postId, String postCreator, String reason, String comment, String timestamp){
        this.creator = creator;
        this.postId = postId;
        this.postCreator = postCreator;
        this.reason = reason;
        this.comment = comment;
        this.timestamp = timestamp;
    }

    public String getCreator() {
        return creator;
    }

    public String getPostId() {
        return postId;
    }

    public String getPostCreator() {
        return postCreator;
    }

    public String getReason() {
        return reason;
    }

    public String getComment() {
        return comment;
    }

    public String getTimestamp() {
        return timestamp;
    }



}
