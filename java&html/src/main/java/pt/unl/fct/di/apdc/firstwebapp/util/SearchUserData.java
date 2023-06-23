package pt.unl.fct.di.apdc.firstwebapp.util;

public class SearchUserData {

    private String username;

    private String fullname;

    public SearchUserData(){}

    public SearchUserData(String username, String fullname){
        this.username = username;
        this.fullname = fullname;
    }

    @Override
    public boolean equals(Object obj) {
        SearchUserData other = (SearchUserData) obj;
        return this.username.equals(other.getUsername()) && this.fullname.equals(other.getFullname());
    }
    public String getFullname() {
        return fullname;
    }

    public String getUsername() {
        return username;
    }

}
