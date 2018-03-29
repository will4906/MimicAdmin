package com.willshuhua.entity;

import com.willshuhua.dao.HadmMapper;
import com.willshuhua.dao.IcustayMapper;
import com.willshuhua.dao.ProjectMapper;
import com.willshuhua.dao.SubjectMapper;
import lombok.Getter;
import lombok.Setter;
import org.apache.ibatis.session.SqlSession;

public class Project {

    @Getter
    @Setter
    private String projectName = "";

    private SqlSession sqlSession = null;
    private ProjectMapper projectMapper = null;
    private HadmMapper hadmMapper = null;
    private SubjectMapper subjectMapper = null;
    private IcustayMapper icustayMapper = null;

    public Project(){}

    public Project(SqlSession sqlSession){
        this.sqlSession = sqlSession;
        this.projectMapper = this.sqlSession.getMapper(ProjectMapper.class);
        this.hadmMapper = this.sqlSession.getMapper(HadmMapper.class);
        this.subjectMapper = this.sqlSession.getMapper(SubjectMapper.class);
        this.icustayMapper = this.sqlSession.getMapper(IcustayMapper.class);
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

    public void addRelatedData(String fieldName){
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
            case "input":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addSumInputeventCvInput(this.projectName, fieldName);
                this.icustayMapper.addSumInputeventMvInput(this.projectName, fieldName);
                break;
            case "red_blood_cell":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addSumInputeventCvValue(this.projectName, fieldName, "itemid = 225168");
                this.icustayMapper.addSumInputeventMvValue(this.projectName, fieldName, "itemid = 225168");
                break;
            case "plasma":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addSumInputeventCvValue(this.projectName, fieldName, "itemid IN (30005, 30180, 30103, 44236, 43009, 46530, 220970)");
                this.icustayMapper.addSumInputeventMvValue(this.projectName, fieldName, "itemid IN (30005, 30180, 30103, 44236, 43009, 46530, 220970)");
                break;
            case "cryoprecipitate":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addSumInputeventCvValue(this.projectName, fieldName, "itemid IN (30007, 45354, 225171, 226371)");
                this.icustayMapper.addSumInputeventMvValue(this.projectName, fieldName, "itemid IN (30007, 45354, 225171, 226371)");
                break;
            case "albumin_drup":
                this.projectMapper.addField(this.projectName, fieldName, "VARCHAR(255)");
                this.icustayMapper.addCustomConditionValue(this.projectName, "prescriptions", "dose_val_rx", fieldName, "drug ILIKE '%albumin%'");
                break;
            case "mean_airway_press_min":
                this.projectMapper.addField(this.projectName, fieldName, "NUMERIC");
                this.icustayMapper.addMinCharteventValue(this.projectName, fieldName, "itemid IN (444, 1672, 224697)");
                break;
            default:
                break;
        }
    }
}
