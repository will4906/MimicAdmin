package com.willshuhua.demo;

import com.willshuhua.entity.Project;
import com.willshuhua.util.SqlSessionFactoryUtil;
import lombok.Getter;
import lombok.Setter;
import org.apache.ibatis.session.SqlSession;

import java.io.IOException;

public class Lv implements IDemo{

    @Getter
    @Setter
    private String projectName;

    public Lv(String projectName) {
        this.projectName = projectName;
    }

    @Override
    public void createProject() throws IOException, InterruptedException {
        SqlSession sqlSession = SqlSessionFactoryUtil.openSqlSession();

        Project project = new Project(this.projectName, sqlSession);
        System.out.println("总实例数为" + project.selectProjectCounts());
//        project.addRelatedData("age");
//        System.out.println("删除年龄小于18岁的人，共" + project.deleteInstance("age < 18") + "个");

//        project.addRelatedData("icu_days");
//        project.addRelatedData("rrt");

        project.addRelatedData("gender");


        try {
            sqlSession.commit();
        } catch (Exception ex) {
            System.out.println(ex.toString());
            sqlSession.rollback();
        } finally {
            sqlSession.close();
        }
    }
}
