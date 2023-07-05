package pt.unl.fct.di.apdc.firstwebapp.util;

public class VerificationToken {

    private int code;
    private String username;

    public VerificationToken(){}

    public VerificationToken(int code, String username){
        this.code = code;
        this.username = username;
    }

}
