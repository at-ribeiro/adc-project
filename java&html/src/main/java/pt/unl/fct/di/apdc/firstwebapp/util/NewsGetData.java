package pt.unl.fct.di.apdc.firstwebapp.util;

public class NewsGetData {

    private String title;
    private String text;
    private String url;
    private String timestamp;

    public NewsGetData() {
    }

    public NewsGetData(String title, String text, String url, String timestamp) {
        this.title = title;
        this.text = text;
        this.url = url;
        this.timestamp = timestamp;
    }

    public String getTitle() {
        return title;
    }

    public String getText() {
        return text;
    }

    public String getUrl() {
        return url;
    }

    public String getTimestamp() {
        return timestamp;
    }
}
