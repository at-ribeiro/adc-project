package pt.unl.fct.di.apdc.fctconnect.util.Post;

public class PostData {

    public String post;
    public String username;
    public PostData(){};

    public PostData(String post, String username){
        this.post = post;
        this.username = username;
    }

    public String getPost() {
        return post;
    }

    public String getUsername(){
        return username;
    }

    public String setPost(){
        return post;
    }

    public String setUsername(){
        return username;
    }
}
