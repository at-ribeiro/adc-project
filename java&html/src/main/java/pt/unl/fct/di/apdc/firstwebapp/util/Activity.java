package pt.unl.fct.di.apdc.firstwebapp.util;

import java.time.LocalDateTime;

public class Activity {

    private String activityName;
    private long from;
    private long to;
    private String background;
    private String creationTime;

    public Activity() {}

    public Activity(String activityName, long from, long to, String background, String creationTime) {
    	this.activityName = activityName;
    	this.from = from;
    	this.to = to;
    	this.background = background;
    	this.creationTime = creationTime;
    }

    public String getActivityName() {
    	return activityName;
    }

    public long getFrom() {
    	return from;
    }

    public long getTo() {
    	return to;
    }

    public String getBackground() {
    	return background;
    }

    public String  getCreationTime() {
    	return creationTime;
    }



}
