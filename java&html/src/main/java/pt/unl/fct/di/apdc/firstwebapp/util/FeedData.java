package pt.unl.fct.di.apdc.firstwebapp.util;

import com.google.cloud.Timestamp;
import com.google.cloud.datastore.Key;
import com.google.cloud.datastore.Value;

import java.util.ArrayList;
import java.util.List;

public class FeedData {

    public String id;
    public String text;
    public String user;
    public String url;
    public String timestamp;
    public List<String> likes;
    public FeedData(){};

    public FeedData(String id, String text, String user, String url, String timestamp, List<String> likes){
        this.id = id;
        this.text = text;
        this.user = user;
        this.url = url;
        this.timestamp = timestamp;
        this.likes = likes;

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
    public String getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }
}
