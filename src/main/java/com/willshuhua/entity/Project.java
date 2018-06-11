package com.willshuhua.entity;

import com.willshuhua.dao.*;
import com.willshuhua.util.PythonUtil;
import lombok.Getter;
import lombok.Setter;
import org.apache.ibatis.session.SqlSession;

import java.io.IOException;

public class Project {

    @Getter
    @Setter
    private String projectName = "";

    private SqlSession sqlSession = null;
    private ProjectMapper projectMapper = null;
    private HadmMapper hadmMapper = null;
    private SubjectMapper subjectMapper = null;
    private IcustayMapper icustayMapper = null;
    private SelfMapper selfMapper = null;

    public Project(){}

    public Project(SqlSession sqlSession){
        this.sqlSession = sqlSession;
        this.projectMapper = this.sqlSession.getMapper(ProjectMapper.class);
        this.hadmMapper = this.sqlSession.getMapper(HadmMapper.class);
        this.subjectMapper = this.sqlSession.getMapper(SubjectMapper.class);
        this.icustayMapper = this.sqlSession.getMapper(IcustayMapper.class);
        this.selfMapper = this.sqlSession.getMapper(SelfMapper.class);
    }

    public Project(String projectName, SqlSession sqlSession){
        this(sqlSession);
        this.projectName = projectName;
    }

    public void createProjectByIcd9Code(String condition){
        this.projectMapper.createProjectByIcd9Code(this.projectName, condition);
    }

    public int selectProjectCounts(){
        return this.projectMapper.selectProjectCounts(this.projectName);
    }

    public void addField(String fieldName, String type){
        this.projectMapper.addField(this.projectName, fieldName, type);
    }

    public int deleteInstance(String condition){
        return this.projectMapper.deleteInstance(this.projectName, condition);
    }

    public void addRelatedData(String fieldName) throws IOException, InterruptedException {
        switch (fieldName){
            case "age":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.subjectMapper.addAges(this.projectName);
                break;
            case "gender":
                this.projectMapper.addField(this.projectName, fieldName, "INT2");
                this.subjectMapper.addGenders(this.projectName);
                break;
            case "default ethnicity":
                this.projectMapper.addField(this.projectName, "ethnicity", "INT2");
                this.hadmMapper.addDefaultEthnicity(this.projectName);
                break;
            case "ethnicity":
                this.projectMapper.addField(this.projectName, "ethnicity", "INT2");
                this.hadmMapper.addEthnicity(this.projectName);
                break;
            case "admission_type":
                this.projectMapper.addField(this.projectName, fieldName, "INT2");
                this.hadmMapper.addAdmissionType(this.projectName);
                break;
            case "hospital_expire_flag":
                this.projectMapper.addField(this.projectName, fieldName, "INT2");
                this.hadmMapper.addHospitalExpireFlag(this.projectName);
                break;
//                住院期间白细胞数量平均值
            case "wbc_mean":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventAverValue(this.projectName, fieldName, "itemid IN (51300, 51301)");
                break;
//                住院期间胆红素平均值
            case "bilirubin_mean":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventAverValue(this.projectName, fieldName, "itemid = 50885");
                break;
//                住院期间肌氨酸酐平均值
            case "creatinine_mean":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventAverValue(this.projectName, fieldName, "itemid = 50912");
                break;
            case "creatinine_min":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventMinValue(this.projectName, fieldName, "itemid = 50912");
                break;
            case "creatinine_max":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventMaxValue(this.projectName, fieldName, "itemid = 50912");
                break;
//                住院期间血小板平均值
            case "platelet_mean":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventAverValue(this.projectName, fieldName, "itemid = 51265");
                break;
            case "platelet_min":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventMinValue(this.projectName, fieldName, "itemid = 51265");
                break;
            case "platelet_max":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventMaxValue(this.projectName, fieldName, "itemid = 51265");
                break;
//                白蛋白平均
            case "albumin_mean":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventAverValue(this.projectName, fieldName, "itemid = 50862");
                break;
            case "ph_mean":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventAverValue(this.projectName, fieldName, "itemid = 50820");
                break;
            case "pco2_mean":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventAverValue(this.projectName, fieldName, "itemid = 50818");
                break;
            case "pao2_mean":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventAverValue(this.projectName, fieldName, "itemid = 50821 and valuenum <= 800");
                break;
            case "fio2_mean":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventAverValue(this.projectName, fieldName, "itemid = 50816 and valuenum <= 100 and valuenum >= 20");
                break;
            case "peep_max":
                this.projectMapper.addField(this.projectName, fieldName, "INT");
                this.hadmMapper.addLabeventMaxValue(this.projectName, fieldName, "itemid = 50819");
                break;
            case "tidalvolume_mean":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventAverValue(this.projectName, fieldName, "itemid = 50826");
                break;
            case "hemoglobin_mean":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventAverValue(this.projectName, fieldName, "itemid = 50811");
                break;
            case "temperature_mean":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventAverValue(this.projectName, fieldName, "itemid = 50825");
                break;
            case "temperature_max":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventMaxValue(this.projectName, fieldName, "itemid = 50825");
                break;
            case "hematocrit_mean":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventAverValue(this.projectName, fieldName, "itemid = 50810");
                break;
            case "lactate_mean":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventAverValue(this.projectName, fieldName, "itemid = 50813");
                break;
            case "bilirubin_max":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventMaxValue(this.projectName, fieldName, "itemid = 50885 and valuenum <= 150");
                break;
            case "bilirubin_min":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.hadmMapper.addLabeventMinValue(this.projectName, fieldName, "itemid = 50885 and valuenum <= 150");
                break;
            case "congestive_heart_failure":
            case "cardiac_arrhythmias":
            case "valvular_disease":
            case "pulmonary_circulation":
            case "peripheral_vascular":
            case "hypertension":
            case "paralysis":
            case "other_neurological":
            case "chronic_pulmonary":
            case "diabetes_uncomplicated":
            case "diabetes_complicated":
            case "hypothyroidism":
            case "renal_failure":
            case "liver_disease":
            case "peptic_ulcer":
            case "aids":
            case "lymphoma":
            case "metastatic_cancer":
            case "solid_tumor":
            case "rheumatoid_arthritis":
            case "coagulopathy":
            case "obesity":
            case "weight_loss":
            case "fluid_electrolyte":
            case "blood_loss_anemia":
            case "deficiency_anemias":
            case "alcohol_abuse":
            case "drug_abuse":
            case "psychoses":
            case "depression":
                this.projectMapper.addField(this.projectName, fieldName, "INT4");
                this.hadmMapper.addElixhauserAhrqValue(this.projectName, fieldName);
                break;
            case "sofa":
            case "respiration":
                this.projectMapper.addField(this.projectName, fieldName, "INT4");
                this.icustayMapper.addSofaValue(this.projectName, fieldName);
                break;
            case "sapsii":
                this.projectMapper.addField(this.projectName, fieldName, "INT4");
                this.icustayMapper.addSapsiiValue(this.projectName, fieldName);
                break;
            case "vent_hours":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addSumVentDurationHours(this.projectName, fieldName);
                break;
            case "plateau_pressure_max":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addMaxCharteventValue(this.projectName, fieldName, "itemid = 543");
                break;
            case "plateau_pressure_min":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addMinCharteventValue(this.projectName, fieldName, "itemid = 543");
                break;
            case "heartrate_mean":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addAverCharteventValue(this.projectName, fieldName, "itemid in (211,220045) and valuenum > 0 and valuenum < 300");
                break;
            case "resprate_mean":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addAverCharteventValue(this.projectName, fieldName, "itemid in (615,618,220210,224690) and valuenum > 0 and valuenum < 70");
                break;
            case "map_min":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addMinCharteventValue(this.projectName, fieldName, "itemid in (456,52,6702,443,220052,220181,225312)");
                break;
            case "spo2_mean":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addAverCharteventValue(this.projectName, fieldName, "itemid in (646, 220277) AND valuenum > 0 AND valuenum <= 100");
                break;
            case "map":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addCustomValue(this.projectName, "aline_vitals", fieldName);
                break;
            case "rrt":
                this.projectMapper.addField(this.projectName, fieldName, "INT");
                this.icustayMapper.addCustomValue(this.projectName, "rrt", fieldName);
                break;
            case "gcs_score":
                this.projectMapper.addField(this.projectName, fieldName, "INT");
                this.icustayMapper.addCustomValue(this.projectName, "sapsii", fieldName);
                break;
            case "input":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addSumInputeventCvInput(this.projectName, fieldName);
                this.icustayMapper.addSumInputeventMvInput(this.projectName, fieldName);
                break;
            case "red_blood_cell":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addSumInputeventCvValue(this.projectName, fieldName, "itemid = 225168");
                this.icustayMapper.addSumInputeventMvValue(this.projectName, fieldName, "itemid = 220996");
                this.selfMapper.addSelfCustomCondition(this.projectName, "red_blood_cell", "0 WHERE red_blood_cell IS NULL");
                break;
            case "plasma":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addSumInputeventCvValue(this.projectName, fieldName, "itemid IN (30005, 30180, 30103, 44236, 43009, 46530, 220970)");
                this.icustayMapper.addSumInputeventMvValue(this.projectName, fieldName, "itemid IN (30005, 30180, 30103, 44236, 43009, 46530, 220970)");
                this.selfMapper.addSelfCustomCondition(this.projectName, "plasma", "0 WHERE plasma IS NULL");
                break;
            case "cryoprecipitate":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addSumInputeventCvValue(this.projectName, fieldName, "itemid IN (30007, 45354, 225171, 226371)");
                this.icustayMapper.addSumInputeventMvValue(this.projectName, fieldName, "itemid IN (30007, 45354, 225171, 226371)");
                this.selfMapper.addSelfCustomCondition(this.projectName, "cryoprecipitate", "0 WHERE cryoprecipitate IS NULL");
                break;
            case "albumin_drup":
                this.projectMapper.addField(this.projectName, fieldName, "VARCHAR(255)");
                this.icustayMapper.addCustomConditionValue(this.projectName, "prescriptions", "dose_val_rx", fieldName, "drug ILIKE '%albumin%'");
                break;
            case "mannitol_days":
                this.projectMapper.addField(this.projectName, fieldName, "INT4");
                this.icustayMapper.addCustomConditionSetValue(this.projectName, "prescriptions", "EXTRACT(DAY FROM (prescriptions.enddate - prescriptions.startdate))", fieldName, "prescriptions.drug ILIKE '%mannitol%'");
                break;
            case "mannitol_dosage":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addCustomConditionSetValue(this.projectName, "prescriptions", "prescriptions.dose_val_rx::numeric", fieldName, "prescriptions.drug ILIKE '%mannitol%'");
                break;
            case "mean_airway_press_min":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addMinCharteventValue(this.projectName, fieldName, "itemid IN (444, 1672, 224697)");
                break;
//          下方参数需执行https://github.com/MIT-LCP/mimic-code/blob/master/concepts/code-status.sql
            case "fullcode_first": 
            case "cmo_first":
            case "dnr_first":
            case "dni_first":
            case "dncpr_first":
            case "fullcode_last":
            case "cmo_last":
            case "dnr_last":
            case "dni_last":
            case "dncpr_last":
            case "fullcode":
            case "cmo":
            case "dnr":
            case "dni":
            case "dncpr":
            case "cmo_ds":
                this.projectMapper.addField(this.projectName, fieldName, "INT4");
                this.icustayMapper.addCustomValue(this.projectName, "code_status", fieldName);
                break;
            case "timednr_chart":
            case "timecmo_chart":
            case "timecmo_nursingnote":
                this.projectMapper.addField(this.projectName, fieldName, "timestamp");
                this.icustayMapper.addCustomValue(this.projectName, "code_status", fieldName);
                break;
            case "hosp_mort_30day":
                this.projectMapper.addField(this.projectName, fieldName, "INT2");
                this.hadmMapper.addHospitalDeathDays(this.projectName, fieldName, "'30'");
                break;
            case "hosp_mort_1yr":
                this.projectMapper.addField(this.projectName, fieldName, "INT2");
                this.hadmMapper.addHospitalDeathDays(this.projectName, fieldName, "'365'");
                break;
            case "output":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addSumOutputeventOutput(this.projectName);
                break;
            case "output_input":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.selfMapper.addSelfCustomCondition(this.projectName, fieldName, "output - input");
                break;
            case "pao2fio2":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
//                好像跑python代码有问题，建议直接调用Python文件
//                PythonUtil.doPython("res/python/pao2fio2.py", new String[]{this.projectName});
//                this.icustayMapper.addSelfCustomCondition(this.projectName, fieldName, "output - input");
                break;
//                计算pao2fio2时的fio2
            case "pfio2":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
//                好像跑python代码有问题，建议直接调用Python文件
//                PythonUtil.doPython("res/python/fio2.py", new String[]{this.projectName});
//                this.icustayMapper.addSelfCustomCondition(this.projectName, fieldName, "output - input");
                break;
            case "oxygenation_index":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.selfMapper.addSelfCustomCondition(this.projectName, fieldName, "mean_airway_press_min * pao2fio2");
                break;
            case "aecc_level":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.selfMapper.addSelfCustomCondition(this.projectName, fieldName,
                        "(CASE " +
                                "WHEN oxygenation_index < 300 AND oxygenation_index > 200 THEN 1 " +
                                "WHEN oxygenation_index <= 200 THEN 2 " +
                                "WHEN oxygenation_index >= 300 THEN 0 " +
                                "END )");
                break;
            case "apps":
                this.projectMapper.addField(this.projectName, fieldName, "INT");
                this.selfMapper.addSelfApps(this.projectName);
                break;
            case "spo2fio2":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
//                此处调用python spo2fio2.py project_name
                break;
            case "osi":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.selfMapper.addSelfCustomCondition(this.projectName, fieldName, "mean_airway_press_min * spo2fio2");
                break;
            case "bmi":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addCustomConditionSetValue(this.projectName, "heightweight", "ROUND(heightweight.weight_first / POWER(heightweight.height_first / 100, 2) , 2)", fieldName, "1=1");
                break;
            case "transfusion":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.selfMapper.addSelfCustomCondition(this.projectName, "red_blood_cell", "0 WHERE red_blood_cell IS NULL");
                this.selfMapper.addSelfCustomCondition(this.projectName, "plasma", "0 WHERE plasma IS NULL");
                this.selfMapper.addSelfCustomCondition(this.projectName, "cryoprecipitate", "0 WHERE cryoprecipitate IS NULL");
                this.selfMapper.addSelfCustomCondition(this.projectName, fieldName, "red_blood_cell + plasma + cryoprecipitate");
                break;
            case "icu_days":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.selfMapper.addSelfCustomCondition(this.projectName, fieldName, "EXTRACT(DAY FROM icustays.outtime - icustays.intime) FROM icustays WHERE icustays.icustay_id = " + this.projectName + ".icustay_id;");
                break;
            case "icp":
                this.projectMapper.addField(this.projectName, fieldName, "INT2");
                this.hadmMapper.addFlagByIcd9Code(this.projectName, fieldName, "d_icd_diagnoses.icd9_code ILIKE '584%'");
                break;
            default:
                System.out.println("暂未支持：" + fieldName);
                break;
        }
    }

    public void addSpo2Fio2(){

    }
}
