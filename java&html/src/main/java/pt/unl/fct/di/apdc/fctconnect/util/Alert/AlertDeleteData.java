package pt.unl.fct.di.apdc.fctconnect.util.Alert;

import java.util.List;

public class AlertDeleteData {

    List<Long> ids;

    public AlertDeleteData(){}

    public AlertDeleteData(List<Long> ids){
        this.ids = ids;
    }
    public List<Long> getIds() {
        return ids;
    }
}
