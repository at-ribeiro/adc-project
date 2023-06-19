package pt.unl.fct.di.apdc.firstwebapp.util;

public class UpdateData {

    private String username;
    private String fullname;
    private String email;
    private String phone;
    private String about_me;
    private String department;
    private String office;
    private String course;
    private String year;
    private String city;
    private String purpose;
    private String privacy;

    public UpdateData(){}

    public UpdateData(String username, String fullname, String email, String phone, String about_me, String department,
                      String office,String course, String year, String city, String purpose, String privacy){
        this.username = username;
        this.fullname = fullname;
        this.email = email;
        this.phone = phone;
        this.about_me = about_me;
        this.department = department;
        this.office = office;
        this.course = course;
        this.year = year;
        this.city = city;
        this.purpose = purpose;
        this.privacy = privacy;
    }

    public String getPhone() {
        return phone;
    }

    public String getCity() {
        return city;
    }

    public String getAbout() {
        return about_me;
    }

    public String getDepartment() {
        return department;
    }

    public String getCourse() {
        return course;
    }

    public String getYear() {
        return year;
    }

    public String getPurpose() {
        return purpose;
    }

    public String getFullname() {
        return fullname;
    }

    public String getOffice() {
        return office;
    }

    public String getPrivacy() {
        return privacy;
    }
}
