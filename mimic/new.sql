-- 通过icustay记录创建表格
DROP TABLE IF EXISTS lv_creat CASCADE;
CREATE TABLE lv_creat AS (
    SELECT DISTINCT subject_id, hadm_id, icustay_id FROM icustays
    
);
-- 添加入院第一个肌酐值
ALTER TABLE lv_creat ADD creatinine_first NUMERIC;
WITH temp AS (
    SELECT hadm_id, MIN(charttime) AS charttime
		FROM labevents WHERE itemid = 50912
		GROUP BY hadm_id
), temp2 AS (
SELECT labevents.subject_id, labevents.hadm_id, labevents.valuenum AS creatinine_first FROM labevents, temp
WHERE labevents.hadm_id = temp.hadm_id AND 
labevents.charttime = temp.charttime AND itemid = 50912
)
UPDATE lv_creat SET creatinine_first = temp2.creatinine_first
FROM temp2 WHERE temp2.hadm_id = lv_creat.hadm_id;

-- 调用MimicAdmin添加年龄和删除年龄小于18的实例
ALTER TABLE lv_creat ADD age NUMERIC;
UPDATE lv_creat
SET age = ROUND((CAST(EXTRACT(EPOCH FROM adm.admittime - pat.dob) / (60 * 60 * 24 * 365.242) AS NUMERIC)), 1)
FROM
admissions adm, patients pat
WHERE adm.subject_id = lv_creat.subject_id
AND
pat.subject_id = lv_creat.subject_id;

-- 删除第一个肌酐值为空的实例
DELETE FROM lv_creat WHERE creatinine_first IS NULL;
-- 删除第一个肌酐值大于1.5mg/dl的实例
DELETE FROM lv_creat WHERE creatinine_first > 1.5;

-- 调用MimicAdmin添加icu_days(进入Icu时间，单位天)
UPDATE lv_creat 
SET icu_days = EXTRACT(DAY FROM icustays.outtime - icustays.intime) FROM icustays WHERE icustays.icustay_id = " + this.projectName + ".icustay_id;;

-- 删除icu入院时间小于一天的人数
DELETE FROM lv_creat WHERE icu_days < 1;

-- 获取ckd的所有icd9_code
WITH temp AS (
SELECT * FROM d_icd_diagnoses WHERE short_title ILIKE '%chronic kidney disease%'
OR long_title ILIKE '%chronic kidney disease%' OR short_title ILIKE '%CKD%'
OR long_title ILIKE '%CKD%'
), 
-- 获取icd9_code诊断为ckd的病人
temp2 AS (
SELECT diagnoses_icd.* FROM diagnoses_icd 
WHERE 
diagnoses_icd.icd9_code IN (SELECT "temp".icd9_code FROM "temp")
)
-- 删除有ckd的icd9_code的病人
DELETE FROM lv_creat USING temp2 WHERE lv_creat.hadm_id = temp2.hadm_id;

-- 获取kidney transplant的所有icd9_code
WITH temp AS (
SELECT * FROM d_icd_diagnoses WHERE short_title ILIKE '%kidney transplant%'
OR long_title ILIKE '%kidney transplant%'
), 
-- 获取icd9_code诊断为kidney transplant的病人
temp2 AS (
SELECT diagnoses_icd.* FROM diagnoses_icd 
WHERE 
diagnoses_icd.icd9_code IN (SELECT "temp".icd9_code FROM "temp")
)
-- 删除有kidney transplant的icd9_code的病人
DELETE FROM lv_creat USING temp2 WHERE lv_creat.hadm_id = temp2.hadm_id;

-- 调用MimicAdmin添加rrt
-- 删除rrt标记为1的病人
DELETE FROM lv_