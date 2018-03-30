package com.willshuhua.dao;

import org.apache.ibatis.annotations.Param;

/**
 * 此接口面向带icustay_id的表格，主要查询icu相关参数，如sofa评分等
 */
public interface IcustayMapper {

    /**
     * 添加sofa评分的相关字段，需执行https://github.com/MIT-LCP/mimic-code/blob/master/concepts/severityscores/sofa.sql及关联表格
     * @param projectName 表名
     * @param fieldName 字段名
     */
    void addSofaValue(@Param("project_name")String projectName, @Param("field_name")String fieldName);

    /**
     * 添加sapsii评分的相关字段，需执行https://github.com/MIT-LCP/mimic-code/blob/master/concepts/severityscores/sapsii.sql及关联表格
     * @param projectName 表名
     * @param fieldName 字段名
     */
    void addSapsiiValue(@Param("project_name")String projectName, @Param("field_name")String fieldName);

    /**
     * 添加ventduration的总时长，需执行https://github.com/MIT-LCP/mimic-code/blob/master/concepts/durations/ventilation-durations.sql及关联表格
     * @param projectName 表名
     * @param fieldName 字段名
     */
    void addSumVentDurationHours(@Param("project_name")String projectName, @Param("field_name")String fieldName);

    /**
     * 添加chartevents的最大值
     * @param projectName 表名
     * @param fieldName 字段名
     * @param condition 条件
     */
    void addMaxCharteventValue(@Param("project_name")String projectName, @Param("field_name")String fieldName, @Param("condition")String condition);

    /**
     * 添加chartevents的平均值
     * @param projectName  表名
     * @param fieldName 字段名
     * @param condition 条件
     */
    void addAverCharteventValue(@Param("project_name")String projectName, @Param("field_name")String fieldName, @Param("condition")String condition);

    /**
     * 添加chartevents的最小值
     * @param projectName  表名
     * @param fieldName 字段名
     * @param condition 条件
     */
    void addMinCharteventValue(@Param("project_name")String projectName, @Param("field_name")String fieldName, @Param("condition")String condition);

    /**
     * 直接添加一些自定义表格的字段
     * @param projectName 表名
     * @param source 源表名
     * @param fieldName 字段名称
     */
    void addCustomValue(@Param("project_name")String projectName, @Param("source")String source, @Param("field_name")String fieldName);

    /**
     * 根据条件添加一些自定义表格的字段
     * @param projectName 表名
     * @param source 源表名
     * @param fieldName 字段名称
     * @param condition 条件
     */
    void addCustomConditionValue(@Param("project_name")String projectName, @Param("source")String source, @Param("source_field")String sourceField, @Param("field_name")String fieldName, @Param("condition")String condition);

    /**
     * 添加全部的inputeventcv输入项
     * @param projectName 表名
     * @param fieldName 字段名称
     */
    void addSumInputeventCvInput(@Param("project_name")String projectName, @Param("field_name")String fieldName);

    /**
     * 添加全部的inputeventmv输入项
     * @param projectName 表名
     * @param fieldName 字段名称
     */
    void addSumInputeventMvInput(@Param("project_name")String projectName, @Param("field_name")String fieldName);
    /**
     * 添加inputevents_cv的相关字段
     * @param projectName 表名
     * @param fieldName 字段名称
     * @param condition 条件
     */
    void addSumInputeventCvValue(@Param("project_name")String projectName, @Param("field_name")String fieldName, @Param("condition")String condition);

    /**
     * 添加inputevents_mv的相关字段
     * @param projectName 表名
     * @param fieldName 字段名称
     * @param condition 条件
     */
    void addSumInputeventMvValue(@Param("project_name")String projectName, @Param("field_name")String fieldName, @Param("condition")String condition);

    /**
     * 添加outputevents总输出
     * @param projectName 表名
     */
    void addSumOutputeventOutput(@Param("project_name")String projectName);

    /**
     * 自行定义修改
     * @param projectName
     * @param fieldName
     * @param condition
     */
    void addSelfCustomCondition(@Param("project_name")String projectName, @Param("field_name")String fieldName, @Param("condition")String condition);
}
