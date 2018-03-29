package com.willshuhua.dao;

import org.apache.ibatis.annotations.Param;

/**
 * 此接口面向带subject_id的表格，专门用来查询患者的基础信息，如年龄，性别等
 */
public interface SubjectMapper {

    /**
     * 添加年龄
     * @param projectName 表名
     */
    void addAges(@Param("project_name")String projectName);

    /**
     * 添加性别,gender：性别，0：female, 1: male
     * @param projectName 表名
     */
    void addGenders(@Param("project_name")String projectName);
}
