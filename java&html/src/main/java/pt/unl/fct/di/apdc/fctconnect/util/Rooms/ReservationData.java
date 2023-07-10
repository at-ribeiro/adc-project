package pt.unl.fct.di.apdc.fctconnect.util.Rooms;

public class ReservationData {

    String user;
    String room;
    long hour;
    long day;

    public ReservationData() {}

    public ReservationData(String user, String room, long day, long hour) {
    	this.user = user;
    	this.room = room;
    	this.day = day;
        this.hour = hour;
    }

    public String getUser() {
    	return user;
    }

    public String getRoom() {
    	return room;
    }

    public long getDay() {
    	return day;
    }

    public long getHour() {
    	return hour;
    }


}
