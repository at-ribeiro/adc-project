package pt.unl.fct.di.apdc.fctconnect.util.Feed;

import java.util.List;

public class FeedData {

    public String id;
    public String text;
    public String user;
    public String url;
    public String timestamp;
    public List<String> likes;
    public String profilePic;
    public FeedData(){};

    public FeedData(String id, String text, String user, String url, String timestamp, List<String> likes, String profilePic){
        this.id = id;
        this.text = text;
        this.user = user;
        this.url = url;
        this.timestamp = timestamp;
        this.likes = likes;
        this.profilePic = profilePic;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getText() {
        return text;
    }

    public String getUser(){
        return user;
    }

    public String getUrl() {
        return url;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public List<String> getLikes() {
        return likes;
    }

    public String getProfilePic() {
        return profilePic;
    }

    public String setText(){
        return text;
    }

    public String setUser(){
        return user;
    }

    public String getBlobName() {
        return url;
    }

    public void setUrl(String blobName) {
        this.url = blobName;
    }
    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }
}
