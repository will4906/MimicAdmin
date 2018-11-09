package com.willshuhua.demo;

import com.willshuhua.entity.Project;
import com.willshuhua.util.SqlSessionFactoryUtil;
import lombok.Getter;
import lombok.Setter;
import org.apache.ibatis.session.SqlSession;

public class ARDS {

    @Getter
    @Setter
    private String projectName;

    public ARDS(String projectName){
        this.projectName = projectName;
    }

    public void createProject(){
        SqlSession sqlSession = SqlSessionFactoryUtil.openSqlSession();

        Project project = new Project(this.projectName, sqlSession);

//        project.createProjectByIcd9Code("icd9_code ILIKE '5185%' OR icd9_code = '51882'");
        System.out.println("总实例数为" + project.selectProjectCounts());
        try {
//            project.addRelatedData("age");
            System.out.println("删除年龄小于18岁的人，共" + project.deleteInstance("age < 18") + "个");
//            project.addRelatedData("gender");
//            project.addRelatedData("ethnicity");
//            project.addRelatedData("admission_type");
//            project.addRelatedData("hospital_expire_flag");
//            project.addRelatedData("wbc_mean");
//            project.addRelatedData("bilirubin_mean");
//            project.addRelatedData("creatinine_mean");
//            project.addRelatedData("platelet_mean");
//            project.addRelatedData("albumin_mean");
//            String[] elixhauserAhrqs = new String[]{"congestive_heart_failure", "cardiac_arrhythmias", "valvular_disease",
//                    "pulmonary_circulation", "peripheral_vascular", "hypertension", "paralysis",
//                    "other_neurological", "chronic_pulmonary", "diabetes_uncomplicated", "diabetes_complicated",
//                    "hypothyroidism", "renal_failure", "liver_disease", "peptic_ulcer", "aids", "lymphoma",
//                    "metastatic_cancer", "solid_tumor", "rheumatoid_arthritis", "coagulopathy", "obesity",
//                    "weight_loss", "fluid_electrolyte", "blood_loss_anemia", "deficiency_anemias",
//                    "alcohol_abuse", "drug_abuse", "psychoses", "depression"
//            };
//            for (String e : elixhauserAhrqs){
//                project.addRelatedData(e);
//            }
//            project.addRelatedData("sofa");
//            project.addRelatedData("respiration");
//            project.addRelatedData("sapsii");
//            project.addRelatedData("ph_mean");
//            project.addRelatedData("vent_hours");
//            project.addRelatedData("pco2_mean");
//            project.addRelatedData("pao2_mean");
//            project.addRelatedData("fio2_mean");
//            project.addRelatedData("peep_max");
//            project.addRelatedData("plateau_pressure_max");
//            project.addRelatedData("plateau_pressure_min");
//            project.addRelatedData("tidalvolume_mean");
//            project.addRelatedData("heartrate_mean");
//            project.addRelatedData("resprate_mean");
//            project.addRelatedData("map_min");
//            project.addRelatedData("spo2_mean");
//            project.addRelatedData("rrt");
//            project.addRelatedData("hemoglobin_mean");
//            project.addRelatedData("temperature_max");
//            project.addRelatedData("hematocrit_mean");
//            project.addRelatedData("lactate_mean");
//            project.addRelatedData("gcs_score");
//            project.addRelatedData("bilirubin_max");
//            project.addRelatedData("bilirubin_min");
//            project.addRelatedData("creatinine_min");
//            project.addRelatedData("creatinine_max");
//            project.addRelatedData("platelet_min");
//            project.addRelatedData("platelet_max");
//            project.addRelatedData("input");
//            project.addRelatedData("red_blood_cell");
//            project.addRelatedData("plasma");
//            project.addRelatedData("cryoprecipitate");
//            project.addRelatedData("albumin_drup");
//            project.addRelatedData("mean_airway_press_min");
//            String[] codeStatus = new String[]{"fullcode_first", "cmo_first", "dnr_first", "dni_first", "dncpr_first",
//            "fullcode_last", "cmo_last", "dnr_last", "dni_last", "dncpr_last", "fullcode", "cmo", "dnr", "dni", "dncpr",
//            "cmo_ds", "timednr_chart", "timecmo_chart", "timecmo_nursingnote"};
//            for (String cs : codeStatus){
//                project.addRelatedData(cs);
//            }
//            project.addRelatedData("hosp_mort_30day");
//            project.addRelatedData("hosp_mort_1yr");
//            project.addRelatedData("output");
//            project.addRelatedData("output_input");
//            project.addRelatedData("pao2fio2");
//            project.addRelatedData("oxygenation_index");
//            project.addRelatedData("aecc_level");
//            project.addRelatedData("pfio2");
//            project.addRelatedData("apps");
//            project.addRelatedData("spo2fio2");
//            project.addRelatedData("osi");
//            project.addRelatedData("bmi");
            System.out.println("删除mean_airway_press为空的人，共" + project.deleteInstance("mean_airway_press_min IS NULL") + "个");
            System.out.println("删除apps为空的人，共" + project.deleteInstance("apps IS NULL") + "个");
//            project.addRelatedData("transfusion");
//            project.addRelatedData("icu_duration");
            sqlSession.commit();
        } catch (Exception ex) {
            System.out.println(ex.toString());
            sqlSession.rollback();
        } finally {
            sqlSession.close();
        }

/**
 * 总实例数3260
 * 删除年龄小于18的8个
 *
 */
    }
}
