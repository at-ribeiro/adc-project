package pt.unl.fct.di.apdc.firstwebapp.util;

public class NewsPostData {

    private String title;
    private String text;

    public NewsPostData() {
    }

    public NewsPostData(String title, String text, String username) {
        this.title = title;
        this.text = text;
    }

    public String getTitle() {
        return title;
    }

    public String getText() {
        return text;
    }

}
