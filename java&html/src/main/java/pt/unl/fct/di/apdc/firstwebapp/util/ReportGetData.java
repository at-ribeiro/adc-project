package pt.unl.fct.di.apdc.firstwebapp.util;

import com.google.cloud.datastore.Value;

import java.util.List;

public class ReportGetData {

    public String reportCreator;
    public String postId;
    public String postCreator;
    public List<Value<String>> reportReason;
    public List<Value<String>> reportComment;
    public String reportTimestamp;


    public ReportGetData() {}
    public ReportGetData(String reportCreator, String postId, String postCreator, List<Value<String>> reportReason, List<Value<String>> reportComment, String reportTimestamp) {
        this.reportCreator = reportCreator;
        this.postId = postId;
        this.postCreator = postCreator;
        this.reportReason = reportReason;
        this.reportComment = reportComment;
        this.reportTimestamp = reportTimestamp;
    }
}
