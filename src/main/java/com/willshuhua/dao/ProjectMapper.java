package com.willshuhua.dao;

import org.apache.ibatis.annotations.Param;

/**
 * 对于表格的一些基础操作，如建表等。
 */
public interface ProjectMapper {

    /**
     * 通过特定的icd9建立表格
     * @param projectName 表名
     * @param condition 条件（icd9的条件）例如icd9_code = '1234'
     */
    void createProjectByIcd9Code(@Param("project_name")String projectName, @Param("condition")String condition);

    /**
     * 查询表格的总实例数
     * @param projectName
     * @return
     */
    int selectProjectCounts(@Param("project_name")String projectName);

    /**
     * 为表格添加字段
     * @param projectName
     * @param field
     * @param type
     */
    void addField(@Param("project_name")String projectName, @Param("field")String field, @Param("type")String type);

    /**
     * 删除表格的行
     * @param projectName 表名
     * @param condition 条件例如age < 18
     */
    int deleteInstance(@Param("project_name")String projectName, @Param("condition")String condition);
}
