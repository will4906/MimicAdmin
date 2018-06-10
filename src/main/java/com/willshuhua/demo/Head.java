package com.willshuhua.demo;

import com.willshuhua.entity.Project;
import com.willshuhua.util.SqlSessionFactoryUtil;
import lombok.Getter;
import lombok.Setter;
import org.apache.ibatis.session.SqlSession;

import java.io.IOException;

public class Head implements IDemo{

    @Getter
    @Setter
    private String projectName;

    public Head(String projectName) {
        this.projectName = projectName;
    }

    public void createProject() throws IOException, InterruptedException {
        SqlSession sqlSession = SqlSessionFactoryUtil.openSqlSession();
        Project project = new Project(this.projectName, sqlSession);
//        初始构建使用res/result/head_injury_icd9.csv中的Icd9构建，此份文件为人工筛选。本工程导入时命名为brain
//        project.createProjectByIcd9Code("icd9_code IN (SELECT icd9_code FROM brain)");
//        project.addRelatedData("sofa");
//        project.addRelatedData("sapsii");
//        project.addRelatedData("gcs_score");
//        project.addRelatedData("rrt");
//        project.addRelatedData("icp");
//        project.addRelatedData("vent_hours");
//        project.addRelatedData("icu_days");
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
