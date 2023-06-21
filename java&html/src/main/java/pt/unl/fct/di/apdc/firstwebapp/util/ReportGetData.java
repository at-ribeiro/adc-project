package pt.unl.fct.di.apdc.firstwebapp.util;

import com.google.cloud.datastore.Value;

import java.util.List;

public class ReportGetData {

    public List<String> reporters;
    public String postId;
    public String postCreator;
    public List<String> reportReason;
    public List<String> reportComment;
    public long count;


    public ReportGetData() {}

    public ReportGetData(List<String> reporters, String postId, String postCreator, List<String> reportReason, List<String> reportComment, long count){
        this.reporters = reporters;
        this.postId = postId;
        this.postCreator = postCreator;
        this.reportReason = reportReason;
        this.reportComment = reportComment;
        this.count = count;
    }
}
