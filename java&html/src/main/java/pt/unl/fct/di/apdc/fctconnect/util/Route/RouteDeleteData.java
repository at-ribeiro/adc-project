package pt.unl.fct.di.apdc.fctconnect.util.Route;

import java.util.List;

public class RouteDeleteData {

    private List<String> routes;

    public RouteDeleteData() {}

    public RouteDeleteData(List<String> routes) {
        this.routes = routes;
    }

    public List<String> getRoutes() {
        return routes;
    }

}
