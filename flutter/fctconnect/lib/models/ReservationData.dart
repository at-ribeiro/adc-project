class ReservationData {
    final String user;
    final String room;
    final int hour;
    final int day;

    ReservationData({
        required this.user,
        required this.room,
        required this.hour,
        required this.day,
    });

    factory ReservationData.fromJson(Map<String, dynamic> json) {
        return ReservationData(
            user: json["user"],
            room: json["room"],
            hour: json["hour"],
            day: json["day"],
        );
    }
}