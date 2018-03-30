package com.willshuhua.dao;

import org.apache.ibatis.annotations.Param;

public interface SelfMapper {

    /**
     * 自行定义修改
     * @param projectName
     * @param fieldName
     * @param condition
     */
    void addSelfCustomCondition(@Param("project_name")String projectName, @Param("field_name")String fieldName, @Param("condition")String condition);

    /**
     * 添加apps变量
     * @param projectName
     */
    void addSelfApps(@Param("project_name")String projectName);
}
