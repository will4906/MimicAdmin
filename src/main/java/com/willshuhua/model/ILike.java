package com.willshuhua.model;


import lombok.Getter;
import lombok.Setter;

public class ILike extends ParmBase{

    @Getter
    @Setter
    private String main = "";

    public ILike(String main){
        StringBuilder stringBuilder = new StringBuilder("%");
        this.main = stringBuilder.append(main).append("%").toString();
    }

    @Override
    public String toString() {
        return main;
    }
}
