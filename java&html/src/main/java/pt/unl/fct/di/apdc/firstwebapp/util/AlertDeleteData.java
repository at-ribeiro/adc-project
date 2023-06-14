package pt.unl.fct.di.apdc.firstwebapp.util;

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
