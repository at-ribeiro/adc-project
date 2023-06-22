package pt.unl.fct.di.apdc.firstwebapp.util;

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
