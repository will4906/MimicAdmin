package com.willshuhua;

import com.willshuhua.dao.ProjectMapper;
import com.willshuhua.demo.ARDS;
import com.willshuhua.entity.Project;
import com.willshuhua.util.SqlSessionFactoryUtil;
import org.apache.ibatis.session.SqlSession;

import java.io.IOException;

public class Main {

    public static void main(String[] args) throws IOException {
        ARDS ards = new ARDS("hello");
        ards.createProject();
    }
}
