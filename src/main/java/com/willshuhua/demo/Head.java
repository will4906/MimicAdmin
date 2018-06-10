package com.willshuhua.demo;

import com.willshuhua.entity.Project;
import com.willshuhua.util.SqlSessionFactoryUtil;
import lombok.Getter;
import lombok.Setter;
import org.apache.ibatis.session.SqlSession;

public class Head implements IDemo{

    @Getter
    @Setter
    private String projectName;

    public Head(String projectName) {
        this.projectName = projectName;
    }

    public void createProject() {
        SqlSession sqlSession = SqlSessionFactoryUtil.openSqlSession();
        Project project = new Project(this.projectName, sqlSession);
//        初始构建使用res/result/head_injury_icd9.csv中的Icd9构建，此份文件为人工筛选

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
