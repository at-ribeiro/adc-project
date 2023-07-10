package pt.unl.fct.di.apdc.fctconnect.util.Report;

import java.util.List;

public class ReportDeleteData {

    private List<String> ids;

    public ReportDeleteData() {}

    public ReportDeleteData(List<String> ids) {
        this.ids = ids;
    }

    public List<String> getIds() {
        return ids;
    }

}
