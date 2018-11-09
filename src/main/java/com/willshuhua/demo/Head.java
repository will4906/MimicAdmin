package com.willshuhua.demo;

import com.willshuhua.entity.Project;
import com.willshuhua.util.SqlSessionFactoryUtil;
import lombok.Getter;
import lombok.Setter;
import org.apache.ibatis.session.SqlSession;

import javax.rmi.PortableRemoteObject;
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
//        project.createProjectByIcd9Code(
//                "icd9_code ILIKE '800%' OR icd9_code ILIKE '801%' OR icd9_code ILIKE '803%'" +
//                        " OR icd9_code ILIKE '804%' OR icd9_code ILIKE '850%' OR icd9_code ILIKE '851%'" +
//                        " OR icd9_code ILIKE '852%' OR icd9_code ILIKE '853%' OR icd9_code ILIKE '854%'" +
//                        " OR icd9_code = '95901'"
//        );
        System.out.println("总实例数为" + project.selectProjectCounts());    // 总数为2862
//        project.addRelatedData("age");
//        System.out.println("删除年龄小于18岁的人，共" + project.deleteInstance("age < 18") + "个");   // 删掉61个
//        System.out.println("没有尿量评级的人，共" + project.deleteInstance("stage_kdigo_7day_admin_uo IS NULL") + "个");   // 删掉61个
//        System.out.println("没有肌酐评级的人，共" + project.deleteInstance("stage_kdigo_creat_by_min IS NULL") + "个");   // 删掉61个
//        SELECT * FROM d_icd_diagnoses WHERE icd9_code BETWEEN '63000' AND '67999' 怀孕的人的查询代码
//        project.addRelatedData("pregnancy");
//        System.out.println("删除怀孕的人，共" + project.deleteInstance("pregnancy = 1"));
//        project.addRelatedData("gender");
//        project.addRelatedData("ethnicity");
//        project.addRelatedData("admission_type");
//        project.addRelatedData("hospital_expire_flag");
//        project.addRelatedData("sofa");
//        project.addRelatedData("sapsii");
//        project.addRelatedData("gcs_score");
//        project.addRelatedData("rrt");
//        project.addRelatedData("icp");
//        project.addRelatedData("vent_hours");
//        project.addRelatedData("icu_days");
//        project.addRelatedData("mannitol_days");
//        project.addRelatedData("mannitol_dosage");
//        project.addRelatedData("albumin_drup");
//        project.addRelatedData("bmi");
//        project.addRelatedData("base_excess_max");
//        下面两项shock_at_ed_le_60依赖于diasbp_min
        project.addRelatedData("diasbp_min");
        project.addRelatedData("shock_at_ed_le_60");
//        project.addRelatedData("intravenous_contrast_medium_flag");
//        project.addRelatedData("aminoglysosides_flag");
//        project.addRelatedData("vancomycin_flag");
//        project.addRelatedData("polymyxin_b_flag");
//        project.addRelatedData("arb_acei_flag");
//        project.addRelatedData("input");
//        project.addRelatedData("red_blood_cell");
//        project.addRelatedData("plasma");
//        project.addRelatedData("cryoprecipitate");
//        project.addRelatedData("transfusion");
//        String[] codeStatus = new String[]{"fullcode_first", "cmo_first", "dnr_first", "dni_first", "dncpr_first",
//                "fullcode_last", "cmo_last", "dnr_last", "dni_last", "dncpr_last", "fullcode", "cmo", "dnr", "dni", "dncpr",
//                "cmo_ds", "timednr_chart", "timecmo_chart", "timecmo_nursingnote"};
//        for (String cs : codeStatus){
//            project.addRelatedData(cs);
//        }
//        project.addRelatedData("elixhauser_sid30");
//        project.addRelatedData("esrd");
//        project.addRelatedData("hosp_mort_30day");
//        project.addRelatedData("hosp_mort_1yr");
//        project.addRelatedData("hosp_days");
//        project.addRelatedData("hypertension");
//        project.addRelatedData("chronic_pulmonary");
//        project.addRelatedData("live_days");
//        project.addRelatedData("sepsis");
//        project.addRelatedData("anisocoria");
//        project.addRelatedData("creatinine_max");
//        project.addRelatedData("depression");
//        project.addRelatedData("craniotomy");
//        project.addRelatedData("heart_failure");
//        project.addRelatedData("cardiac_arrhythmias");
//        project.addRelatedData("valvular_disease");
//        project.addRelatedData("diabetes_uncomplicated");
//        project.addRelatedData("diabetes_complicated");
//        project.addRelatedData("liver_disease");
//        project.addRelatedData("immunocompromised");
//        project.addRelatedData("malignancy");
//        project.addRelatedData("bun_admin");
//        project.addRelatedData("albumin_admin");
//        project.addRelatedData("coronary_artery_flag");
//        project.addRelatedData("hemoglobin_min");
//        project.addRelatedData("antiplate_flag");
//        project.addRelatedData("anticoaguation_flag");
//        project.addRelatedData("chart_creatinine");
//        project.addRelatedData("kdigo_creat_stage");
//        project.addRelatedData("anxiety");
//        project.addRelatedData("chart_creatinine");
//        project.addRelatedData("stage_kdigo_creat_admin");
//        project.addRelatedData("chart_creatinine_2day");
//        project.addRelatedData("chart_creatinine_1day");
//        project.addRelatedData("admit_days");
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
