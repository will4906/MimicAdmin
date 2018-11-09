package com.willshuhua.dao;

import org.apache.ibatis.annotations.Param;

import java.sql.SQLTransactionRollbackException;

/**
 * 此接口面向带hadm_id的表格，专门用来查询患者的住院信息，如种族，住院类型等
 */
public interface HadmMapper {

    /**
     * 设置不经分组的种族分类。
     * 0: UNKNOWN/NOT SPECIFIED;        1: BLACK/HAITIAN;                  2: BLACK/AFRICAN AMERICAN;       3: ASIAN - ASIAN INDIAN
     * 4: WHITE - RUSSIAN;              5: ASIAN - OTHER;                  6: HISPANIC/LATINO - DOMINICAN;  7: WHITE - OTHER EUROPEAN
     * 8: HISPANIC/LATINO - GUATEMALAN; 9: ASIAN - CHINESE;                10:BLACK/AFRICAN;                11:WHITE
     * 12:HISPANIC/LATINO - HONDURAN;   13:UNABLE TO OBTAIN;               14:HISPANIC OR LATINO;           15:ASIAN - CAMBODIAN
     * 16:MIDDLE EASTERN;               17:HISPANIC/LATINO - PUERTO RICAN; 18:ASIAN;                        19:AMERICAN INDIAN/ALASKA NATIVE
     * 20:PATIENT DECLINED TO ANSWER;   21:ASIAN - VIETNAMESE;             22:HISPANIC/LATINO - SALVADORAN; 23:PORTUGUESE
     * 24:MULTI RACE ETHNICITY;         25:BLACK/CAPE VERDEAN;             26:OTHER;                        27:ASIAN - FILIPINO
     * 28:WHITE - EASTERN EUROPEAN;     29:WHITE - BRAZILIAN;              30:NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER
     * @param projectName 表名
     */
    void addDefaultEthnicity(@Param("project_name")String projectName);

    /**
     * 添加分组的种族种类
     * 1.UNKNOWN/NOT SPECIFIED 2.BLACK 3.ASIAN 4.WHITE 5.HISPANIC/LATINO 6.OTHER
     * @param projectName 表名
     */
    void addEthnicity(@Param("project_name")String projectName);

    /**
     * 添加住院类型
     * @param projectName 表名
     */
    void addAdmissionType(@Param("project_name")String projectName);

    /**
     * 添加是否院内死亡
     * @param projectName 表名
     */
    void addHospitalExpireFlag(@Param("project_name")String projectName);

    /**
     * 添加labevents相关条件下value的平均值
     * @param projectName 表名
     * @param fieldName 需要添加的字段名称
     * @param condition 条件（e.g.item = 1234)
     */
    void addLabeventAverValue(@Param("project_name")String projectName, @Param("field_name")String fieldName, @Param("condition")String condition);

    /**
     * 添加labevents相关条件下value的最大值
     * @param projectName 表名
     * @param fieldName 需要添加的字段名称
     * @param condition 条件（e.g.item = 1234)
     */
    void addLabeventMaxValue(@Param("project_name")String projectName, @Param("field_name")String fieldName, @Param("condition")String condition);

    /**
     * 添加labevents相关条件下value的最小值
     * @param projectName 表名
     * @param fieldName 需要添加的字段名称
     * @param condition 条件（e.g.item = 1234)
     */
    void addLabeventMinValue(@Param("project_name")String projectName, @Param("field_name")String fieldName, @Param("condition")String condition);

    /**
     * 添加elixhauser_ahrq相关字段
     * 需要执行https://github.com/MIT-LCP/mimic-code/blob/master/concepts/comorbidity/elixhauser-ahrq-v37-with-drg.sql
     * @param projectName 表名
     * @param fieldName 字段
     */
    void addElixhauserAhrqValue(@Param("project_name")String projectName, @Param("field_name")String fieldName);

    /**
     * 根据天数添加是否死亡
     * @param projectName 表名
     * @param fieldName 字段
     * @param days 天数
     */
    void addHospitalDeathDays(@Param("project_name")String projectName, @Param("field_name")String fieldName, @Param("days")String days);

    /**
     * 添加存活时间
     * @param projectName
     * @param fieldName
     */
    void addLiveDays(@Param("project_name")String projectName, @Param("field_name")String fieldName);

    /**
     * 根据icd9code为表格添加flag(1 / 0)
     * @param projectName 表名
     * @param fieldName 字段
     * @param condition 条件，如 = icd9code, ILIKE '%icd9code%'等
     */
    void addFlagByIcd9Code(@Param("project_name")String projectName, @Param("field_name")String fieldName, @Param("condition")String condition);

    /**
     * 比较自由地添加一些表格的数据
     * @param projectName
     * @param fieldName
     * @param sourceTable
     * @param sourceField
     */
    void addTargetTableValue(@Param("project_name")String projectName, @Param("field_name")String fieldName, @Param("source_table")String sourceTable, @Param("source_field")String sourceField);

    /**
     * 比较自由地添加一些标志位
     * @param projectName
     * @param fieldName
     * @param sourceTable
     * @param condition
     */
    void addTargetTableFlag(@Param("project_name")String projectName, @Param("field_name")String fieldName, @Param("source_table")String sourceTable, @Param("condition")String condition);

    /**
     * 更加自由地添加一些表格数据
     * @param projectName
     * @param fieldName
     * @param setExpression
     * @param sourceTable
     */
    void addTargetTableCustomValue(@Param("project_name")String projectName, @Param("field_name")String fieldName, @Param("set_expression")String setExpression, @Param("source_table")String sourceTable);

    /**
     * 接近最灵活的添加方式
     * @param projectName
     * @param fieldName
     * @param setExpression
     * @param sourceTable
     * @param condition
     */
    void addTargetTableCustomValueWithCondition(@Param("project_name")String projectName, @Param("field_name")String fieldName, @Param("set_expression")String setExpression, @Param("source_table")String sourceTable, @Param("condition")String condition);

    /**
     * 创建肌酐时间表格
     * @param projectName
     */
    void createCreatinineChart(@Param("project_name")String projectName);

    /**
     * 创建两天的肌酐时间表格
     * @param projectName
     */
    void createCreatinineChart2Day(@Param("project_name")String projectName);

    /**
     * 创建一天的肌酐时间表格
     * @param projectName
     */
    void createCreatinineChart1Day(@Param("project_name")String projectName);
}
