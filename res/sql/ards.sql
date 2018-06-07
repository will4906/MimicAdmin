DROP TABLE IF EXISTS ards_info CASCADE;
CREATE TABLE ards_info AS 
SELECT
DISTINCT subject_id, hadm_id
FROM
diagnoses_icd
WHERE 
icd9_code ILIKE '5185%'
OR
icd9_code = '51882';

ALTER TABLE ards_info ADD age numeric;
ALTER TABLE ards_info ADD gender varchar(5);
ALTER TABLE ards_info ADD ethnicity varchar(255); 

UPDATE ards_info 
SET gender = patients.gender 
FROM patients 
WHERE patients.subject_id = ards_info.subject_id;
UPDATE ards_info
SET ethnicity = admissions.ethnicity
FROM admissions
WHERE
admissions.hadm_id = ards_info.hadm_id;
UPDATE ards_info
SET age = ROUND((CAST(EXTRACT(epoch FROM adm.admittime - pat.dob)/(60*60*24*365.242) AS numeric)), 1)
FROM 
admissions adm, patients pat
WHERE adm.subject_id = ards_info.subject_id
AND
pat.subject_id = ards_info.subject_id;

DELETE FROM ards_info WHERE age < 17;
ALTER TABLE ards_info ADD admission_type varchar (50);
UPDATE ards_info SET admission_type = adm.admission_type
FROM admissions adm WHERE ards_info.hadm_id = adm.hadm_id;

DROP TABLE IF EXISTS ards_icu CASCADE;
CREATE TABLE ards_icu AS
SELECT ai.subject_id, ai.hadm_id, icu.icustay_id
FROM
icustays icu, ards_info ai
WHERE
icu.subject_id = ai.subject_id
AND
icu.hadm_id = ai.hadm_id;

-- 调用heightweight.sql生成heightweight
ALTER TABLE ards_icu ADD BMI numeric;

UPDATE ards_icu SET BMI = ROUND(heightweight.weight_first / POWER(heightweight.height_first / 100, 2) , 2)
FROM heightweight
WHERE heightweight.icustay_id = ards_icu.icustay_id;

CREATE TABLE ards_elixhauser_ahrq AS
SELECT
ae.subject_id, 
ae.hadm_id,
ae.congestive_heart_failure,
ae.cardiac_arrhythmias,
ae.valvular_disease,
ae.pulmonary_circulation,
ae.peripheral_vascular, 
ae.hypertension,
ae.paralysis,
ae.other_neurological,
ae.chronic_pulmonary, 
ae.diabetes_uncomplicated,
ae.diabetes_complicated,
ae.hypothyroidism,
ae.renal_failure,
ae.liver_disease,
ae.peptic_ulcer,
ae.aids,
ae.lymphoma,
ae.metastatic_cancer,
ae.solid_tumor,
ae.rheumatoid_arthritis,
ae.coagulopathy,
ae.obesity,
ae.weight_loss,
ae.fluid_electrolyte,
ae.blood_loss_anemia,
ae.deficiency_anemias,
ae.alcohol_abuse,
ae.drug_abuse,
ae.psychoses,
ae.depression
FROM 
elixhauser_ahrq ae, ards_info ai
WHERE
ae.subject_id = ai.subject_id
AND
ae.hadm_id = ai.hadm_id;

ALTER TABLE ards_icu ADD sofa int4;
WITH temp AS(
  SELECT subject_id, hadm_id, max(sofa) FROM sofa GROUP BY subject_id, hadm_id
)
UPDATE ards_icu SET
sofa = sofa.sofa
FROM 
sofa
WHERE 
ards_icu.icustay_id = sofa.icustay_id;

DELETE FROM ards_icu WHERE sofa IS NULL;

-- DELETE FROM ards_icu USING ards_info WHERE ards_icu.hadm_id != ards_info.hadm_id;
ALTER TABLE ards_icu ADD sapsii int4; 

UPDATE ards_icu SET sapsii = sapsii.sapsii FROM sapsii WHERE sapsii.icustay_id = ards_icu.icustay_id;

ALTER TABLE ards_icu ADD respiration int4;
ALTER TABLE ards_icu ADD vent_duration numeric;

UPDATE ards_icu 
SET vent_duration = ventdurations.duration_hours 
FROM ventdurations 
WHERE ventdurations.icustay_id = ards_icu.icustay_id;

WITH vent AS (
  SELECT ventdurations.icustay_id, sum(ventdurations.duration_hours) AS vent_hours FROM ventdurations, ${project_name}
  WHERE ventdurations.icustay_id = ${project_name}.icustay_id
  GROUP BY ventdurations.icustay_id
)
UPDATE ${project_name} SET vent_hours = vent.vent_hours FROM vent WHERE vent.icustay_id = ${project_name};

UPDATE ards_icu SET respiration = null;
UPDATE ards_icu SET pao2fio2 = null;
UPDATE ards_icu
SET
respiration = sofa.respiration
FROM 
sofa
WHERE
sofa.icustay_id = ards_icu.icustay_id;

ALTER TABLE ards_icu ADD pao2fio2 numeric;   --氧合指数
UPDATE ards_icu SET pao2fio2 = bgf.pao2fio2 FROM bloodgasfirstdayarterial bgf WHERE ards_icu.icustay_id = bgf.icustay_id AND bgf.pao2fio2 IS NOT NULL;

ALTER TABLE ards_icu ADD ph numeric;
UPDATE ards_icu SET ph = bgf.ph FROM bloodgasfirstdayarterial bgf WHERE ards_icu.icustay_id = bgf.icustay_id AND bgf.ph IS NOT NULL;

ALTER TABLE ards_icu ADD pco2 numeric;
UPDATE ards_icu SET pco2 = bgf.pco2 FROM bloodgasfirstdayarterial bgf WHERE ards_icu.icustay_id = bgf.icustay_id AND bgf.pco2 IS NOT NULL;

ALTER TABLE ards_icu ADD peep numeric;
UPDATE ards_icu SET peep = bgf.peep FROM bloodgasfirstdayarterial bgf WHERE ards_icu.icustay_id = bgf.icustay_id AND bgf.peep IS NOT NULL;

ALTER TABLE ards_icu ADD tidalvolume numeric;
UPDATE ards_icu SET tidalvolume = bgf.tidalvolume 
FROM bloodgasfirstdayarterial bgf 
WHERE ards_icu.icustay_id = bgf.icustay_id AND bgf.tidalvolume IS NOT NULL;

CREATE TABLE plateau_pressure AS
SELECT * FROM chartevents WHERE itemid = 543;

ALTER TABLE ards_icu ADD plateau_pressure numeric;
-- BEGIN TRANSACTION;
WITH temp AS 
(
  SELECT icustay_id, max(value::numeric) AS value FROM plateau_pressure GROUP BY icustay_id
)
UPDATE ards_icu SET plateau_pressure = temp.value FROM temp WHERE ards_icu.icustay_id = temp.icustay_id;
-- COMMIT;

ALTER TABLE ards_icu ADD heartrate_mean float8;
ALTER TABLE ards_icu ADD resprate_mean float8;

UPDATE ards_whole SET heartrate_mean = v.heartrate_mean 
FROM vitalsfirstday v WHERE ards_whole.icustay_id = v.icustay_id;
UPDATE ards_whole SET resprate_mean = v.resprate_mean 
FROM vitalsfirstday v WHERE ards_whole.icustay_id = v.icustay_id;

ALTER TABLE ards_icu ADD map float8;
UPDATE ards_whole SET map = aline_vitals.map FROM aline_vitals WHERE aline_vitals.icustay_id = ards_whole.icustay_id;

WITH temp AS (
  SELECT icustay_id, min(value::numeric) AS map FROM map GROUP BY icustay_id
)
UPDATE ards_whole SET map = temp.map FROM temp WHERE temp.icustay_id = ards_whole.icustay_id AND ards_whole.map IS NULL;
UPDATE ards_whole SET map = NULL WHERE map < 0;
--map参照aline_vitals取的是最小值，不对再说


ALTER TABLE ards_icu ADD rrt int2;
UPDATE ards_icu SET rrt = rrt.rrt FROM rrt WHERE rrt.icustay_id = ards_icu.icustay_id;

ALTER TABLE ards_info ADD hosp_espire_flag int2;
UPDATE ards_info SET hosp_espire_flag = admissions.hospital_expire_flag FROM admissions WHERE admissions.hadm_id = ards_info.hadm_id;

ALTER TABLE ards_whole ADD hemoglobin float8;
UPDATE ards_whole SET hemoglobin = blg.hemoglobin
FROM bloodgasfirstdayarterial blg 
WHERE blg.icustay_id = ards_whole.icustay_id
AND 
blg.hemoglobin IS NOT NULL;

ALTER TABLE ards_icu ADD fio2 float8;
UPDATE ards_whole SET fio2 = blg.fio2
FROM bloodgasfirstdayarterial blg 
WHERE blg.icustay_id = ards_whole.icustay_id
AND 
blg.fio2 IS NOT NULL;

ALTER TABLE ards_icu ADD temperature float8;
UPDATE ards_whole SET temperature = blg.temperature 
FROM bloodgasfirstdayarterial blg 
WHERE blg.icustay_id = ards_whole.icustay_id
AND 
blg.temperature IS NOT NULL;

ALTER TABLE ards_icu ADD hematocrit float8;
UPDATE ards_whole SET hematocrit = blg.hematocrit FROM bloodgasfirstdayarterial blg WHERE blg.icustay_id = ards_whole.icustay_id
AND 
blg.hematocrit IS NOT NULL;

-- ALTER TABLE ards_icu ADD wbc_max float8;
-- ALTER TABLE ards_icu ADD wbc_min float8;

-- UPDATE ards_icu SET wbc_max = labsfirstday.wbc_max FROM labsfirstday WHERE labsfirstday.icustay_id = ards_icu.icustay_id AND labsfirstday.wbc_max IS NOT NULL;
-- UPDATE ards_icu SET wbc_min = labsfirstday.wbc_min FROM labsfirstday WHERE labsfirstday.icustay_id = ards_icu.icustay_id AND labsfirstday.wbc_min IS NOT NULL;

ALTER TABLE ards_info ADD wbc_mean float8;
WITH temp AS
(
  SELECT subject_id, hadm_id, avg(valuenum) AS wbc_mean 
  FROM labevents WHERE itemid IN (51300, 51301)
  GROUP BY subject_id, hadm_id
)
UPDATE ards_whole SET wbc_mean = ROUND(CAST(temp.wbc_mean AS numeric),  4) 
FROM temp WHERE temp.hadm_id = ards_whole.hadm_id;

WITH lab AS ( 
  SELECT labevents.subject_id, labevents.hadm_id, avg(labevents.valuenum) AS wbc_mean FROM labevents, hello 
  WHERE itemid IN (51300, 51301) AND labevents.hadm_id = hello.hadm_id GROUP BY labevents.subject_id, labevents.hadm_id 
  ) 
  UPDATE hello SET wbc_mean = ROUND(CAST(lab.wbc_mean AS numeric), 4) FROM lab WHERE lab.hadm_id = hello.hadm_id;

ALTER TABLE ards_info ADD bilirubin_mean float8;
WITH temp AS (
  SELECT subject_id, hadm_id, avg(valuenum) AS bilirubin_mean 
  FROM labevents WHERE itemid IN (50885)
  GROUP BY subject_id, hadm_id
)
UPDATE ards_whole SET bilirubin_mean = ROUND(CAST(temp.bilirubin_mean AS numeric),  4) 
FROM temp WHERE temp.hadm_id = ards_whole.hadm_id;

ALTER TABLE ards_info ADD creatinine_mean float8;
WITH temp AS (
  SELECT subject_id, hadm_id, avg(valuenum) AS creatinine_mean 
  FROM labevents WHERE itemid IN (50912)
  GROUP BY subject_id, hadm_id
)
UPDATE ards_whole SET creatinine_mean = ROUND(CAST(temp.creatinine_mean AS numeric),  4) 
FROM temp WHERE temp.hadm_id = ards_whole.hadm_id;

ALTER TABLE ards_info ADD platelet_mean float8;
WITH temp AS (
  SELECT subject_id, hadm_id, avg(valuenum) AS platelet_mean
  FROM labevents WHERE itemid IN (51265)
  GROUP BY subject_id, hadm_id
)
UPDATE ards_whole SET platelet_mean = ROUND(CAST(temp.platelet_mean AS numeric),  4) 
FROM temp WHERE temp.hadm_id = ards_whole.hadm_id;

ALTER TABLE ards_icu ADD lactate float8;

UPDATE ards_whole SET lactate = bloodgasfirstdayarterial.lactate FROM bloodgasfirstdayarterial 
WHERE bloodgasfirstdayarterial.icustay_id = ards_whole.icustay_id
AND 
bloodgasfirstdayarterial.lactate IS NOT NULL;

ALTER TABLE ards_icu ADD gcs_score int4;
UPDATE ards_icu SET gcs_score = sapsii.gcs_score FROM sapsii WHERE sapsii.icustay_id = ards_icu.icustay_id;

ALTER TABLE ards_icu ADD bilirubin_min float8;
UPDATE ards_whole SET bilirubin_min = labsfirstday.bilirubin_min FROM labsfirstday WHERE labsfirstday.icustay_id = ards_whole.icustay_id;

ALTER TABLE ards_icu ADD bilirubin_max float8;
UPDATE ards_whole SET bilirubin_max = labsfirstday.bilirubin_max FROM labsfirstday WHERE labsfirstday.icustay_id = ards_whole.icustay_id;

ALTER TABLE ards_icu ADD urineoutput float8;
UPDATE ards_whole SET urineoutput = uoayear.urineoutput FROM uoayear WHERE uoayear.icustay_id = ards_whole.icustay_id;

ALTER TABLE ards_icu ADD creatinine_min float8;
UPDATE ards_whole SET creatinine_min = labsfirstday.creatinine_min FROM labsfirstday WHERE labsfirstday.icustay_id = ards_whole.icustay_id;

ALTER TABLE ards_icu ADD creatinine_max float8;
UPDATE ards_whole SET creatinine_max = labsfirstday.creatinine_max FROM labsfirstday WHERE labsfirstday.icustay_id = ards_whole.icustay_id;

ALTER TABLE ards_icu ADD platelet_min float8;
UPDATE ards_whole SET platelet_min = labsfirstday.platelet_min FROM labsfirstday WHERE labsfirstday.icustay_id = ards_whole.icustay_id;

ALTER TABLE ards_icu ADD platelet_max float8;
UPDATE ards_whole SET platelet_max = labsfirstday.platelet_max FROM labsfirstday WHERE labsfirstday.icustay_id = ards_whole.icustay_id;

UPDATE ards_info SET gender = 0 WHERE gender = 'F';
UPDATE ards_info SET gender = 1 WHERE gender = 'M';


UPDATE ards_info SET ethnicity = 0 WHERE ethnicity = 'UNKNOWN/NOT SPECIFIED';
UPDATE ards_info SET ethnicity = 1 WHERE ethnicity = 'BLACK/HAITIAN';
UPDATE ards_info SET ethnicity = 2 WHERE ethnicity = 'BLACK/AFRICAN AMERICAN';
UPDATE ards_info SET ethnicity = 3 WHERE ethnicity = 'ASIAN - ASIAN INDIAN';
UPDATE ards_info SET ethnicity = 4 WHERE ethnicity = 'WHITE - RUSSIAN';
UPDATE ards_info SET ethnicity = 5 WHERE ethnicity = 'ASIAN - OTHER';
UPDATE ards_info SET ethnicity = 6 WHERE ethnicity = 'HISPANIC/LATINO - DOMINICAN';
UPDATE ards_info SET ethnicity = 7 WHERE ethnicity = 'WHITE - OTHER EUROPEAN';
UPDATE ards_info SET ethnicity = 8 WHERE ethnicity = 'HISPANIC/LATINO - GUATEMALAN';
UPDATE ards_info SET ethnicity = 9 WHERE ethnicity = 'ASIAN - CHINESE';
UPDATE ards_info SET ethnicity = 10 WHERE ethnicity = 'BLACK/AFRICAN';
UPDATE ards_info SET ethnicity = 11 WHERE ethnicity = 'WHITE';
UPDATE ards_info SET ethnicity = 12 WHERE ethnicity = 'HISPANIC/LATINO - HONDURAN';
UPDATE ards_info SET ethnicity = 13 WHERE ethnicity = 'UNABLE TO OBTAIN';
UPDATE ards_info SET ethnicity = 14 WHERE ethnicity = 'HISPANIC OR LATINO';
UPDATE ards_info SET ethnicity = 15 WHERE ethnicity = 'ASIAN - CAMBODIAN';
UPDATE ards_info SET ethnicity = 16 WHERE ethnicity = 'MIDDLE EASTERN';
UPDATE ards_info SET ethnicity = 17 WHERE ethnicity = 'HISPANIC/LATINO - PUERTO RICAN';
UPDATE ards_info SET ethnicity = 18 WHERE ethnicity = 'ASIAN';
UPDATE ards_info SET ethnicity = 19 WHERE ethnicity = 'AMERICAN INDIAN/ALASKA NATIVE';
UPDATE ards_info SET ethnicity = 20 WHERE ethnicity = 'PATIENT DECLINED TO ANSWER';
UPDATE ards_info SET ethnicity = 21 WHERE ethnicity = 'ASIAN - VIETNAMESE';
UPDATE ards_info SET ethnicity = 22 WHERE ethnicity = 'HISPANIC/LATINO - SALVADORAN';
UPDATE ards_info SET ethnicity = 23 WHERE ethnicity = 'PORTUGUESE';
UPDATE ards_info SET ethnicity = 24 WHERE ethnicity = 'MULTI RACE ETHNICITY';
UPDATE ards_info SET ethnicity = 25 WHERE ethnicity = 'BLACK/CAPE VERDEAN';
UPDATE ards_info SET ethnicity = 26 WHERE ethnicity = 'OTHER';
UPDATE ards_info SET ethnicity = 27 WHERE ethnicity = 'ASIAN - FILIPINO';
UPDATE ards_info SET ethnicity = 28 WHERE ethnicity = 'WHITE - EASTERN EUROPEAN';
UPDATE ards_info SET ethnicity = 29 WHERE ethnicity = 'WHITE - BRAZILIAN';
UPDATE ards_info SET ethnicity = 30 WHERE ethnicity = 'NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER';

UPDATE ards_info SET admission_type = 0 WHERE admission_type = 'URGENT';
UPDATE ards_info SET admission_type = 1 WHERE admission_type = 'ELECTIVE';
UPDATE ards_info SET admission_type = 2 WHERE admission_type = 'EMERGENCY';

ALTER TABLE ards_info ADD albumin_mean numeric;
WITH temp AS (
  SELECT subject_id, hadm_id, avg(valuenum) AS albumin_mean 
  FROM labevents WHERE itemid IN (50862)
  GROUP BY subject_id, hadm_id
)
UPDATE ards_info SET albumin_mean = ROUND(CAST(temp.albumin_mean AS numeric),  4) 
FROM temp WHERE temp.hadm_id = ards_info.hadm_id;

ALTER TABLE ards_icu ADD input numeric;
WITH temp AS (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_cv GROUP BY icustay_id
)
UPDATE ards_icu SET input = temp.amount FROM temp WHERE ards_icu.icustay_id = temp.icustay_id;
WITH temp AS (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_mv GROU P BY icustay_id
)
UPDATE ards_icu SET input = temp.amount + input FROM temp WHERE ards_icu.icustay_id = temp.icustay_id;
ALTER TABLE ards_icu ADD red_blood_cell numeric;
WITH temp AS  (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_mv WHERE itemid = 225168 GROUP BY icustay_id
)
UPDATE ards_icu SET red_blood_cell = temp.amount FROM temp WHERE temp.icustay_id = ards_icu.icustay_id;

ALTER TABLE ards_icu ADD PLASMA numeric;
UPDATE ards_icu SET plasma = 0;
WITH temp AS (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_cv WHERE itemid IN (
    30005, 30180, 30103, 44236, 43009, 46530
  )
  GROUP BY icustay_id
)
UPDATE ards_icu SET plasma = temp.amount FROM temp WHERE temp.icustay_id = ards_icu.icustay_id;

WITH temp AS (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_mv WHERE itemid = 220970 GROUP BY icustay_id
)
UPDATE ards_icu SET plasma = plasma + temp.amount FROM temp WHERE temp.icustay_id = ards_icu.icustay_id;

ALTER TABLE ards_icu ADD cryoprecipitate numeric;
UPDATE ards_icu SET cryoprecipitate = 0;
WITH temp AS (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_cv WHERE itemid IN (30007, 45354) GROUP BY icustay_id
)
UPDATE ards_icu SET cryoprecipitate = temp.amount FROM temp WHERE temp.icustay_id = ards_icu.icustay_id;
WITH temp AS (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_mv WHERE itemid IN (225171, 226371) GROUP BY icustay_id
)
UPDATE ards_icu SET cryoprecipitate = temp.amount + cryoprecipitate FROM temp WHERE temp.icustay_id = ards_icu.icustay_id;

ALTER TABLE ards_icu ADD albumin_drup varchar;
UPDATE ards_icu SET 
albumin_drup = prescriptions.dose_val_rx
FROM 
prescriptions
WHERE
prescriptions.icustay_id = ards_icu.icustay_id
AND 
prescriptions.drug ILIKE '%albumin%';

WITH temp AS (
  SELECT icustay_id, max(valuenum) AS peep FROM chartevents
 WHERE itemid IN (505, 506, 60, 1096, 686, 1227, 5964, 6349, 6350, 6489, 6601, 224700, 220339)
 GROUP BY icustay_id
)
UPDATE ards_icu SET peep = temp.peep FROM temp WHERE temp.icustay_id = ards_icu.icustay_id;

CREATE TABLE ards_code AS 
SELECT 
code_status.subject_id, code_status.hadm_id, code_status.icustay_id, code_status.fullcode_first, 
code_status.cmo_first, code_status.dnr_first, code_status.dni_first,
code_status.dncpr_first, code_status.fullcode_last, code_status.cmo_last, code_status.dnr_last, code_status.dni_last, 
code_status.dncpr_last, code_status.fullcode, 
code_status.cmo, code_status.dnr, code_status.dni, code_status.dncpr, code_status.cmo_ds, 
code_status.timednr_chart, code_status.timecmo_chart, code_status.timecmo_nursingnote
FROM ards_icu, code_status
WHERE ards_icu.icustay_id = code_status.icustay_id;


UPDATE ards_info SET ethnicity = '1' WHERE ethnicity = '0';
UPDATE ards_info SET ethnicity = '2' WHERE ethnicity = '1';
UPDATE ards_info SET ethnicity = '3' WHERE ethnicity = '5';
UPDATE ards_info SET ethnicity = '5' WHERE ethnicity = '6';
UPDATE ards_info SET ethnicity = '4' WHERE ethnicity = '7';
UPDATE ards_info SET ethnicity = '5' WHERE ethnicity = '8';
UPDATE ards_info SET ethnicity = '3' WHERE ethnicity = '9';
UPDATE ards_info SET ethnicity = '2' WHERE ethnicity = '10';
UPDATE ards_info SET ethnicity = '4' WHERE ethnicity = '11';
UPDATE ards_info SET ethnicity = '5' WHERE ethnicity = '12';
UPDATE ards_info SET ethnicity = '1' WHERE ethnicity = '13';
UPDATE ards_info SET ethnicity = '5' WHERE ethnicity = '14';
UPDATE ards_info SET ethnicity = '3' WHERE ethnicity = '15';
UPDATE ards_info SET ethnicity = '6' WHERE ethnicity = '16';
UPDATE ards_info SET ethnicity = '5' WHERE ethnicity = '17';
UPDATE ards_info SET ethnicity = '3' WHERE ethnicity = '18';
UPDATE ards_info SET ethnicity = '6' WHERE ethnicity = '19';
UPDATE ards_info SET ethnicity = '1' WHERE ethnicity = '20';
UPDATE ards_info SET ethnicity = '3' WHERE ethnicity = '21';
UPDATE ards_info SET ethnicity = '5' WHERE ethnicity = '22';
UPDATE ards_info SET ethnicity = '6' WHERE ethnicity = '23';
UPDATE ards_info SET ethnicity = '6' WHERE ethnicity = '24';
UPDATE ards_info SET ethnicity = '2' WHERE ethnicity = '25';
UPDATE ards_info SET ethnicity = '6' WHERE ethnicity = '26';
UPDATE ards_info SET ethnicity = '3' WHERE ethnicity = '27';
UPDATE ards_info SET ethnicity = '4' WHERE ethnicity = '28';
UPDATE ards_info SET ethnicity = '4' WHERE ethnicity = '29';
UPDATE ards_info SET ethnicity = '6' WHERE ethnicity = '30';


Antibiotic 



-- CREATE TABLE ards_icuinfo AS 
WITH temp_info AS (
  SELECT * FROM ards_info
), temp_icuinfo AS (
  SELECT * FROM ards_icu LEFT JOIN temp_info ON ards_icu.hadm_id = temp_info.hadm_id
)
WITH temp_code AS (
  SELECT * FROM ards_code
)
SELECT * FROM temp_infoicu LEFT JOIN temp_code ON temp_infoicu.icustay_id = temp_code.icustay_id;
WITH temp_ali AS (
  SELECT * FROM ards_elixhauser_ahrq
)
SELECT * FROM temp_ic LEFT JOIN temp_ali ON temp_ic.icustay_id = temp_ali.icustay_id;

ALTER TABLE ards_whole ADD hosp_mort_30day INT;
ALTER TABLE ards_whole ADD hosp_mort_1yr INT;

UPDATE ards_whole SET hosp_mort_30day = 1 FROM mortailty my WHERE my.hadm_id::INT = ards_whole.hadm_id AND my.dod < my.admittime + interval '30' day;
UPDATE ards_whole SET hosp_mort_1yr = 1 FROM mortailty my WHERE my.hadm_id::INT = ards_whole.hadm_id AND my.dod < my.admittime + interval '1' year;
UPDATE ards_whole SET hosp_mort_30day = 0 WHERE hosp_mort_30day IS NULL;
UPDATE ards_whole SET hosp_mort_1yr = 0 WHERE hosp_mort_1yr IS NULL;
CREATE TABLE ards_apacheii AS (
  WITH temp_apache AS (
    SELECT 
    sapsii.sapsii, age_score, comorbidity_score, admissiontype_score, 
    CASE admissiontype_score
      WHEN 8 THEN 1
      ELSE 0
    END AS is_scheduledsurgical,
    CASE comorbidity_score
      WHEN 0 THEN 0
      ELSE
        CASE admissiontype_score 
          WHEN 0 THEN 2
          WHEN 6 THEN 5
          WHEN 8 THEN 5
        END
      END AS chronic_score
    FROM sapsii, ards_icu 
    WHERE ards_icu.icustay_id = sapsii.icustay_id
  ), part_lnr AS (
    SELECT 
      temp_apache.*, sapsii + age_score + chronic_score AS apacheii_score
    FROM 
      temp_apache
  )
  SELECT part_lnr.*, -3.517 + apacheii_score * 0.146 + 0.603 * is_scheduledsurgical AS part_inr_score 
  FROM part_lnr
  
);


congestive_heart_failure 删掉

-- CREATE TABLE ards_whole AS (
WITH info_left_part AS (
  SELECT * FROM ards_info
),
code_left_part AS (
  SELECT icustay_id,fullcode_first,cmo_first,dnr_first,dni_first,dncpr_first,fullcode_last,cmo_last,dnr_last,dni_last,dncpr_last,fullcode,cmo,dnr,dni,dncpr,cmo_ds,timednr_chart,timecmo_chart,timecmo_nursingnote FROM ards_code
),
left_part AS (
  SELECT * FROM ards_icu LEFT JOIN code_left_part ON ards_icu.icustay_id = code_left_part.icustay_id
),
ahrq_part AS (
  SELECT hadm_id, congestive_heart_failure , cardiac_arrhythmias , valvular_disease , pulmonary_circulation , peripheral_vascular , hypertension , paralysis , other_neurological , chronic_pulmonary , diabetes_uncomplicated , diabetes_complicated , hypothyroidism , renal_failure , liver_disease , peptic_ulcer , aids , lymphoma , metastatic_cancer , solid_tumor , rheumatoid_arthritis , coagulopathy , obesity , weight_loss , fluid_electrolyte , blood_loss_anemia , deficiency_anemias , alcohol_abuse , drug_abuse , psychoses , depression
  FROM ards_elixhauser_ahrq
)
info_part AS (
  SELECT * FROM ards_info LEFT JOIN ahrq_part ON ahrq_part.hadm_id = ards_info.hadm_id
)
SELECT * FROM left_part LEFT JOIN info_part ON left_part.hadm_id = info_part.hadm_id
-- )
-- SELECT * FROM left_left_part LEFT JOIN ards_elixhauser_ahrq ON left_left_part.hadm_id = ards_elixhauser_ahrq.hadm_id;

-- DELETE FROM head_whole WHERE age < 18;
SELECT a.attnum,
a.attname AS field,
t.typname AS type,
a.attlen AS length,
a.atttypmod AS lengthvar,
a.attnotnull AS notnull,
b.description AS comment
FROM pg_class c,
pg_attribute a
LEFT OUTER JOIN pg_description b ON a.attrelid=b.objoid AND a.attnum = b.objsubid,
pg_type t
WHERE c.relname = 'ards_elixhauser_ahrq'
and a.attnum > 0
and a.attrelid = c.oid
and a.atttypid = t.oid
ORDER BY a.attnum;

WITH ards_info_with AS (
  SELECT ards_info.subject_id, ards_info.hadm_id, ards_info.age, ards_info.gender, ards_info.ethnicity, ards_info.admission_type, ards_info.hosp_espire_flag, ards_info.wbc_mean, ards_info.bilirubin_mean, ards_info.creatinine_mean, ards_info.platelet_mean, ards_info.albumin_mean
  FROM 
  ards_info
)
,code_with AS (
  SELECT ards_code.subject_id, ards_code.hadm_id, ards_code.icustay_id, ards_code.fullcode_first, ards_code.cmo_first, ards_code.dnr_first, ards_code.dni_first, ards_code.dncpr_first, ards_code.fullcode_last, ards_code.cmo_last, ards_code.dnr_last, ards_code.dni_last, ards_code.dncpr_last, ards_code.fullcode, ards_code.cmo, ards_code.dnr, ards_code.dni, ards_code.dncpr, ards_code.cmo_ds, ards_code.timednr_chart, ards_code.timecmo_chart, ards_code.timecmo_nursingnote
  FROM 
  ards_code
)
,ahrq_with AS (
  SELECT ards_elixhauser_ahrq.subject_id, ards_elixhauser_ahrq.hadm_id, ards_elixhauser_ahrq.congestive_heart_failure, ards_elixhauser_ahrq.cardiac_arrhythmias, ards_elixhauser_ahrq.valvular_disease, ards_elixhauser_ahrq.pulmonary_circulation, ards_elixhauser_ahrq.peripheral_vascular, ards_elixhauser_ahrq.hypertension, ards_elixhauser_ahrq.paralysis, ards_elixhauser_ahrq.other_neurological, ards_elixhauser_ahrq.chronic_pulmonary, ards_elixhauser_ahrq.diabetes_uncomplicated, ards_elixhauser_ahrq.diabetes_complicated, ards_elixhauser_ahrq.hypothyroidism, ards_elixhauser_ahrq.renal_failure, ards_elixhauser_ahrq.liver_disease, ards_elixhauser_ahrq.peptic_ulcer, ards_elixhauser_ahrq.aids, ards_elixhauser_ahrq.lymphoma, ards_elixhauser_ahrq.metastatic_cancer, ards_elixhauser_ahrq.solid_tumor, ards_elixhauser_ahrq.rheumatoid_arthritis, ards_elixhauser_ahrq.coagulopathy, ards_elixhauser_ahrq.obesity, ards_elixhauser_ahrq.weight_loss, ards_elixhauser_ahrq.fluid_electrolyte, ards_elixhauser_ahrq.blood_loss_anemia, ards_elixhauser_ahrq.deficiency_anemias, ards_elixhauser_ahrq.alcohol_abuse, ards_elixhauser_ahrq.drug_abuse, ards_elixhauser_ahrq.psychoses, ards_elixhauser_ahrq.depression, ards_elixhauser_ahrq.hosp_espire_flag
  FROM 
  ards_elixhauser_ahrq
)
,icu_with AS (
  SELECT ards_icu.subject_id, ards_icu.hadm_id, ards_icu.icustay_id, ards_icu.bmi, ards_icu.sofa, ards_icu.sapsii, ards_icu.respiration, ards_icu.vent_duration, ards_icu.pao2fio2, ards_icu.ph, ards_icu.pco2, ards_icu.peep, ards_icu.tidalvolume, ards_icu.plateau_pressure, ards_icu.heartrate_mean, ards_icu.resprate_mean, ards_icu.map, ards_icu.rrt, ards_icu.hemoglobin, ards_icu.fio2, ards_icu.temperature, ards_icu.hematocrit, ards_icu.lactate, ards_icu.gcs_score, ards_icu.bilirubin_min, ards_icu.bilirubin_max, ards_icu.urineoutput, ards_icu.creatinine_min, ards_icu.creatinine_max, ards_icu.platelet_min, ards_icu.platelet_max, ards_icu.input, ards_icu.red_blood_cell, ards_icu.plasma, ards_icu.cryoprecipitate, ards_icu.albumin_drup
  FROM 
  ards_icu
)
CREATE TABLE ards_whole AS (
WITH hadm_id_part AS (
  SELECT ards_info.subject_id, ards_info.hadm_id, ards_info.age, ards_info.gender, ards_info.ethnicity, ards_info.admission_type, ards_info.hosp_espire_flag, ards_info.wbc_mean, ards_info.bilirubin_mean, ards_info.creatinine_mean, ards_info.platelet_mean, ards_info.albumin_mean,
  ards_elixhauser_ahrq.congestive_heart_failure, ards_elixhauser_ahrq.cardiac_arrhythmias, ards_elixhauser_ahrq.valvular_disease, ards_elixhauser_ahrq.pulmonary_circulation, ards_elixhauser_ahrq.peripheral_vascular, ards_elixhauser_ahrq.hypertension, ards_elixhauser_ahrq.paralysis, ards_elixhauser_ahrq.other_neurological, ards_elixhauser_ahrq.chronic_pulmonary, ards_elixhauser_ahrq.diabetes_uncomplicated, ards_elixhauser_ahrq.diabetes_complicated, ards_elixhauser_ahrq.hypothyroidism, ards_elixhauser_ahrq.renal_failure, ards_elixhauser_ahrq.liver_disease, ards_elixhauser_ahrq.peptic_ulcer, ards_elixhauser_ahrq.aids, ards_elixhauser_ahrq.lymphoma, ards_elixhauser_ahrq.metastatic_cancer, ards_elixhauser_ahrq.solid_tumor, ards_elixhauser_ahrq.rheumatoid_arthritis, ards_elixhauser_ahrq.coagulopathy, ards_elixhauser_ahrq.obesity, ards_elixhauser_ahrq.weight_loss, ards_elixhauser_ahrq.fluid_electrolyte, ards_elixhauser_ahrq.blood_loss_anemia, ards_elixhauser_ahrq.deficiency_anemias, ards_elixhauser_ahrq.alcohol_abuse, ards_elixhauser_ahrq.drug_abuse, ards_elixhauser_ahrq.psychoses, ards_elixhauser_ahrq.depression
  FROM
  ards_info LEFT JOIN ards_elixhauser_ahrq ON ards_info.hadm_id = ards_elixhauser_ahrq.hadm_id
), icu_part AS (
  SELECT ards_icu.subject_id, ards_icu.hadm_id, ards_icu.icustay_id, ards_icu.bmi, ards_icu.sofa, ards_icu.sapsii, ards_icu.respiration, ards_icu.vent_duration, ards_icu.pao2fio2, ards_icu.ph, ards_icu.pco2, ards_icu.peep, ards_icu.tidalvolume, ards_icu.plateau_pressure, ards_icu.heartrate_mean, ards_icu.resprate_mean, ards_icu.map, ards_icu.rrt, ards_icu.hemoglobin, ards_icu.fio2, ards_icu.temperature, ards_icu.hematocrit, ards_icu.lactate, ards_icu.gcs_score, ards_icu.bilirubin_min, ards_icu.bilirubin_max, ards_icu.urineoutput, ards_icu.creatinine_min, ards_icu.creatinine_max, ards_icu.platelet_min, ards_icu.platelet_max, ards_icu.input, ards_icu.red_blood_cell, ards_icu.plasma, ards_icu.cryoprecipitate, ards_icu.albumin_drup,
  ards_code.fullcode_first, ards_code.cmo_first, ards_code.dnr_first, ards_code.dni_first, ards_code.dncpr_first, ards_code.fullcode_last, ards_code.cmo_last, ards_code.dnr_last, ards_code.dni_last, ards_code.dncpr_last, ards_code.fullcode, ards_code.cmo, ards_code.dnr, ards_code.dni, ards_code.dncpr, ards_code.cmo_ds, ards_code.timednr_chart, ards_code.timecmo_chart, ards_code.timecmo_nursingnote
  FROM
  ards_icu LEFT JOIN ards_code ON ards_icu.icustay_id = ards_code.icustay_id
)
SELECT 
hadm_id_part.subject_id, hadm_id_part.hadm_id, hadm_id_part.age, hadm_id_part.gender, hadm_id_part.ethnicity, hadm_id_part.admission_type, hadm_id_part.hosp_espire_flag, hadm_id_part.wbc_mean, hadm_id_part.bilirubin_mean, hadm_id_part.creatinine_mean, hadm_id_part.platelet_mean, hadm_id_part.albumin_mean,
  hadm_id_part.congestive_heart_failure, hadm_id_part.cardiac_arrhythmias, hadm_id_part.valvular_disease, hadm_id_part.pulmonary_circulation, hadm_id_part.peripheral_vascular, hadm_id_part.hypertension, hadm_id_part.paralysis, hadm_id_part.other_neurological, hadm_id_part.chronic_pulmonary, hadm_id_part.diabetes_uncomplicated, hadm_id_part.diabetes_complicated, hadm_id_part.hypothyroidism, hadm_id_part.renal_failure, hadm_id_part.liver_disease, hadm_id_part.peptic_ulcer, hadm_id_part.aids, hadm_id_part.lymphoma, hadm_id_part.metastatic_cancer, hadm_id_part.solid_tumor, hadm_id_part.rheumatoid_arthritis, hadm_id_part.coagulopathy, hadm_id_part.obesity, hadm_id_part.weight_loss, hadm_id_part.fluid_electrolyte, hadm_id_part.blood_loss_anemia, hadm_id_part.deficiency_anemias, hadm_id_part.alcohol_abuse, hadm_id_part.drug_abuse, hadm_id_part.psychoses, hadm_id_part.depression,
  icu_part.icustay_id, icu_part.bmi, icu_part.sofa, icu_part.sapsii, icu_part.respiration, icu_part.vent_duration, icu_part.pao2fio2, icu_part.ph, icu_part.pco2, icu_part.peep, icu_part.tidalvolume, icu_part.plateau_pressure, icu_part.heartrate_mean, icu_part.resprate_mean, icu_part.map, icu_part.rrt, icu_part.hemoglobin, icu_part.fio2, icu_part.temperature, icu_part.hematocrit, icu_part.lactate, icu_part.gcs_score, icu_part.bilirubin_min, icu_part.bilirubin_max, icu_part.urineoutput, icu_part.creatinine_min, icu_part.creatinine_max, icu_part.platelet_min, icu_part.platelet_max, icu_part.input, icu_part.red_blood_cell, icu_part.plasma, icu_part.cryoprecipitate, icu_part.albumin_drup,
  icu_part.fullcode_first, icu_part.cmo_first, icu_part.dnr_first, icu_part.dni_first, icu_part.dncpr_first, icu_part.fullcode_last, icu_part.cmo_last, icu_part.dnr_last, icu_part.dni_last, icu_part.dncpr_last, icu_part.fullcode, icu_part.cmo, icu_part.dnr, icu_part.dni, icu_part.dncpr, icu_part.cmo_ds, icu_part.timednr_chart, icu_part.timecmo_chart, icu_part.timecmo_nursingnote
 FROM icu_part LEFT JOIN hadm_id_part ON icu_part.hadm_id = hadm_id_part.hadm_id
);

ALTER TABLE ards_whole ADD oi numeric;
UPDATE ards_whole SET oi = NULL;
UPDATE ards_whole SET oi = (pao2fio2 * mean_airway_press) WHERE mean_airway_press IS NOT NULL AND pao2fio2 IS NOT NULL;


ALTER TABLE ards_whole ADD spo2 numeric;
UPDATE ards_whole SET spo2=bloodgasfirstdayarterial.spo2 FROM bloodgasfirstdayarterial WHERE bloodgasfirstdayarterial.hadm_id = ards_whole.hadm_id;

ALTER TABLE ards_whole ADD fio2_chartevents numeric;
UPDATE ards_whole SET fio2_chartevents = bloodgasfirstdayarterial.fio2_chartevents FROM bloodgasfirstdayarterial WHERE bloodgasfirstdayarterial.hadm_id = ards_whole.hadm_id;

ALTER TABLE ards_whole ADD osi numeric;
UPDATE ards_whole SET osi = 100*spo2*map/(coalesce(FIO2, fio2_chartevents));

ALTER TABLE ards_whole ADD spo2_d_fio2 numeric;
UPDATE ards_whole SET spo2_d_fio2 = spo2/fio2;

ALTER TABLE ards_whole ADD pao2 numeric;
UPDATE ards_whole SET pao2 = bloodgasfirstdayarterial.po2 FROM bloodgasfirstdayarterial WHERE bloodgasfirstdayarterial.hadm_id = ards_whole.hadm_id;

ALTER TABLE ards_whole ADD po2_d_fio2 NUMERIC;
UPDATE ards_whole SET po2_d_fio2 = pao2/fio2;

ALTER TABLE ards_whole ADD aecc_level NUMERIC;
UPDATE ards_whole SET aecc_level = 1 WHERE oi < 300;
UPDATE ards_whole SET aecc_level = 2 WHERE oi < 200;
UPDATE ards_whole SET aecc_level = 0 WHERE oi > 300;

DROP TABLE ards_pao2 IF EXISTS;
CREATE TABLE ards_pao2 AS (
SELECT labevents.hadm_id, labevents.charttime, min(labevents."value") AS pao2 FROM labevents,ards_whole WHERE itemid = 50821 AND labevents.hadm_id = ards_whole.hadm_id
GROUP BY labevents.hadm_id, labevents.charttime
);
DROP TABLE ards_fio2 IF EXISTS;
CREATE TABLE ards_fio2 AS (
  SELECT labevents.hadm_id, labevents.charttime, max(labevents."value") AS fio2 FROM labevents,ards_whole WHERE itemid = 50816 AND labevents.hadm_id = ards_whole.hadm_id
GROUP BY labevents.hadm_id, labevents.charttime
);

CREATE TABLE stg_fio2 as
(
  select SUBJECT_ID, HADM_ID, ICUSTAY_ID, CHARTTIME
    -- pre-process the FiO2s to ensure they are between 21-100%
    , max(
        case
          when itemid = 223835
            then case
              when valuenum > 0 and valuenum <= 1
                then valuenum * 100
              -- improperly input data - looks like O2 flow in litres
              when valuenum > 1 and valuenum < 21
                then null
              when valuenum >= 21 and valuenum <= 100
                then valuenum
              else null end -- unphysiological
        when itemid in (3420, 3422)
        -- all these values are well formatted
            then valuenum
        when itemid = 190 and valuenum > 0.20 and valuenum < 1
        -- well formatted but not in %
            then valuenum * 100
      else null end
    ) as fio2_chartevents
  from CHARTEVENTS
  where ITEMID in
  (
    3420 -- FiO2
  , 190 -- FiO2 set
  , 223835 -- Inspired O2 Fraction (FiO2)
  , 3422 -- FiO2 [measured]
  )
  -- exclude rows marked as error
  and error IS DISTINCT FROM 1
  group by SUBJECT_ID, HADM_ID, ICUSTAY_ID, CHARTTIME
);

CREATE TABLE ards_pao2fio2 AS (
  SELECT labevents.hadm_id, labevents.itemid, labevents.charttime, labevents."value" 
FROM labevents,ards_whole 
WHERE itemid IN (50821, 50816) AND labevents.hadm_id = ards_whole.hadm_id
)


ALTER TABLE ards_whole ADD platelet_min_all_days float8;
WITH temp AS (
  SELECT subject_id, hadm_id, min(valuenum) AS platelet_min_all_days
  FROM labevents WHERE itemid IN (51265)
  GROUP BY subject_id, hadm_id
)
UPDATE ards_whole SET platelet_min_all_days = ROUND(CAST(temp.platelet_min_all_days AS numeric),  4) 
FROM temp WHERE temp.hadm_id = ards_whole.hadm_id;

ALTER TABLE ards_whole ADD platelet_max_all_days float8;
WITH temp AS (
  SELECT subject_id, hadm_id, min(valuenum) AS platelet_max_all_days
  FROM labevents WHERE itemid IN (51265)
  GROUP BY subject_id, hadm_id
)
UPDATE ards_whole SET platelet_max_all_days = ROUND(CAST(temp.platelet_max_all_days AS numeric),  4) 
FROM temp WHERE temp.hadm_id = ards_whole.hadm_id;


UPDATE ards_whole SET PEEP = NULL;


ALTER TABLE ards_whole ADD mean_airway_press numeric;
WITH hello AS (
  SELECT chartevents.hadm_id, "min"("value") AS value FROM chartevents, ards_whole WHERE itemid IN (444, 1672, 224697)
AND
ards_whole.hadm_id = chartevents.hadm_id
GROUP BY chartevents.hadm_id
)
UPDATE ards_whole SET mean_airway_press = hello.value::numeric FROM hello WHERE hello.hadm_id = ards_whole.hadm_id;

DROP TABLE IF EXISTS ards_spo2fio2 CASCADE;
CREATE TABLE ards_spo2fio2 AS (
  select CHARTEVENTS.HADM_ID, CHARTTIME
    -- max here is just used to group SpO2 by charttime
    , max(case when valuenum <= 0 or valuenum > 100 then null else valuenum end) as SpO2
  from CHARTEVENTS, ards_whole
  -- o2 sat
  where ITEMID in
  (
    646 -- SpO2
  , 220277 -- O2 saturation pulseoxymetry
  )
  AND 
  ards_whole.hadm_id = chartevents.hadm_id
  group by chartevents.HADM_ID, CHARTTIME
);

ALTER TABLE ards_whole ADD spo2fio2 NUMERIC;

UPDATE ards_whole SET spo2 = NULL;
WITH hello AS (
  SELECT hadm_id, round(avg(spo2)::numeric, 0) AS spo2 FROM ards_spo2fio2 GROUP BY hadm_id
)
UPDATE ards_whole SET spo2 = hello.spo2 FROM hello WHERE hello.hadm_id = ards_whole.hadm_id;


UPDATE ards_whole SET spo2fio2 = NULL;
UPDATE ards_whole SET spo2fio2 = spo2/(coalesce(FIO2, fio2_chartevents));
UPDATE ards_whole SET osi = NULL;
UPDATE ards_whole SET osi = (spo2fio2 * mean_airway_press) WHERE mean_airway_press IS NOT NULL AND spo2fio2 IS NOT NULL;

UPDATE ards_whole SET spo2 = NULL;
UPDATE ards_whole SET spo2=bloodgasfirstdayarterial.spo2 FROM bloodgasfirstdayarterial WHERE bloodgasfirstdayarterial.hadm_id = ards_whole.hadm_id;

-- 加个output-input的变量
-- 删掉vent_duration为空的实例
-- spo2fio2改为时间滑动窗为48hr的min(spo2) / max(fio2)
-- 重新计算osi
-- 重新计算aecc_level
-- 补体重，重新计算bmi
-- 合并fio2和fio2_chartevents

DELETE FROM ards_whole WHERE vent_duration IS NULL;

ALTER TABLE ards_whole ADD out_in_diff NUMERIC;
-- 没有output
UPDATE ards_whole SET out_in_diff = output - input;

UPDATE ards_whole SET fio2 = fio2_chartevents WHERE fio2 IS NULL;

CREATE TABLE ards_spo2 AS (
  SELECT chartevents.* FROM ards_whole, chartevents WHERE ards_whole.hadm_id = chartevents.hadm_id AND itemid IN (646,220277)
);


DROP TABLE IF EXISTS ards_fio2 CASCADE;
CREATE TABLE ards_fio2 AS (
  SELECT labevents.subject_id, labevents.hadm_id, labevents.charttime, labevents.value as fio2 
  FROM labevents, ards_whole
  WHERE itemid = 50816 AND labevents.hadm_id = ards_whole.hadm_id
);

INSERT INTO ards_fio2 SELECT chartevents.subject_id, chartevents.hadm_id, chartevents.charttime,
case
          when itemid = 223835
            then case
              when valuenum > 0 and valuenum <= 1
                then valuenum * 100
              -- improperly input data - looks like O2 flow in litres
              when valuenum > 1 and valuenum < 21
                then null
              when valuenum >= 21 and valuenum <= 100
                then valuenum
              else null end -- unphysiological
        when itemid in (3420, 3422)
        -- all these values are well formatted
            then valuenum
        when itemid = 190 and valuenum > 0.20 and valuenum < 1
        -- well formatted but not in %
            then valuenum * 100
      else null end 
			AS fio2
FROM chartevents, ards_whole  where ITEMID in
  (
    3420 -- FiO2
  , 190 -- FiO2 set
  , 223835 -- Inspired O2 Fraction (FiO2)
  , 3422 -- FiO2 [measured]
  ) AND chartevents.icustay_id = ards_whole.icustay_id; 

  UPDATE ards_whole SET spo2fio2 = NULL;
  DELETE FROM ards_spo2fio2 WHERE value = 0;
  WITH temp AS (
    SELECT hadm_id, MIN(value) AS value FROM ards_spo2fio2 GROUP BY hadm_id
  )
  UPDATE ards_whole SET spo2fio2 = temp.value FROM temp WHERE temp.hadm_id = ards_whole.hadm_id;
  UPDATE ards_whole SET spo2fio2 = spo2fio2 * 100;

UPDATE ards_whole SET plateau_pressure = NULL;
WITH temp AS (
  SELECT chartevents.icustay_id, MAX(chartevents.valuenum::NUMERIC) AS value FROM chartevents, ards_whole WHERE itemid = 543
  AND ards_whole.hadm_id = chartevents.hadm_id
GROUP BY chartevents.icustay_id
)
UPDATE ards_whole SET plateau_pressure = temp.value FROM temp WHERE temp.icustay_id = ards_whole.icustay_id;

ALTER TABLE ards_whole ADD apps INT;
WITH hello AS (
SELECT 
hadm_id,
CASE 
WHEN age < 47 THEN 1
WHEN age >= 47 AND age <= 66 THEN 2
WHEN age > 66 THEN 3
END AS age_score,

CASE 
WHEN pao2fio2 > 158 THEN 1
WHEN pao2fio2 <=158 AND pao2fio2 >= 105 THEN 2
WHEN pao2fio2 < 105 THEN 3
END AS p_score,

CASE 
WHEN plateau_pressure < 27 THEN 1
WHEN plateau_pressure >= 27 AND plateau_pressure <= 30 THEN 2
WHEN plateau_pressure > 30 THEN 3
END AS pp_score
FROM 
ards_whole
)
UPDATE ards_whole SET apps = (hello.age_score + hello.p_score + hello.pp_score)
FROM
hello
WHERE ards_whole.hadm_id = hello.hadm_id
AND 
peep >= 10 AND pfio2 >= 50;

UPDATE ards_whole SET apps = NULL WHERE peep < 10;
ALTER TABLE ards_whole ADD pfio2 numeric;
UPDATE ards_whole SET apps = NULL WHERE pfio2 < 50;

DELETE FROM ards_whole2 WHERE fullcode_first = 0;
DELETE FROM ards_whole2 WHERE dnr_first = 1;
DELETE FROM ards_whole2 WHERE cmo_last = 1;
DELETE FROM ards_whole2 WHERE dnr_last = 1;
DELETE FROM ards_whole2 WHERE dni_last = 1;
DELETE FROM ards_whole2 WHERE dnr = 1;
DELETE FROM ards_whole2 WHERE dni = 1;
DELETE FROM ards_whole2 WHERE cmo_ds = 1;
-- 500                                        保留

DELETE FROM ards_whole2 WHERE vent_duration IS NULL;    --1012 找到有平均气道压就行
DELETE FROM ards_whole WHERE age < 18;   -- 6   删除

DELETE FROM ards_whole USING icustays WHERE ards_whole.icustay_id = icustays.icustay_id
AND 
icustays.outtime - icustays.intime < interval '24'HOUR;  -- 46

DELETE FROM ards_whole WHERE apps IS NULL;  - 1147


ALTER TABLE hello ADD elixhauser_sid30 int4;
UPDATE hello SET elixhauser_sid30 = elixhauser_ahrq_score.elixhauser_sid30
FROM elixhauser_ahrq_score
WHERE elixhauser_ahrq_score.hadm_id = hello.hadm_id;

UPDATE hello SET red_blood_cell = 0 WHERE red_blood_cell IS NULL;
UPDATE hello SET plasma = 0 WHERE plasma IS NULL;
UPDATE hello SET cryoprecipitate = 0 WHERE cryoprecipitate IS NULL;

ALTER TABLE hello ADD transfusion numeric;
UPDATE hello SET transfusion = red_blood_cell + plasma + cryoprecipitate;

ALTER TABLE ards_whole ADD hemoglobin_min numeric;
UPDATE ards_whole SET hemoglobin_min = NULL;
WITH gg AS (
SELECT ch.subject_id, ch.hadm_id, min(charttime) as charttime FROM chartevents as ch, head_whole WHERE 
itemid IN (814, 220228) 
AND 
ch.hadm_id = head_whole.hadm_id
GROUP BY
ch.subject_id, ch.hadm_id
)
, gg2 AS (
  SELECT chartevents.hadm_id, MIN(valuenum) AS valuenum FROM chartevents, gg 
  WHERE gg.hadm_id = chartevents.hadm_id 
  AND chartevents.charttime = gg.charttime
  AND chartevents.itemid IN (814, 220228) GROUP BY chartevents.hadm_id
)
UPDATE ards_whole SET hemoglobin_min = gg2.valuenum FROM gg2 WHERE ards_whole.hadm_id = gg2.hadm_id;

UPDATE ards_whole SET hemoglobin_min = NULL;
WITH temphello AS (
  SELECT chartevents.hadm_id, MIN(chartevents.valuenum) AS valuenum FROM ards_whole, chartevents
  WHERE chartevents.itemid IN (220228, 814) AND ards_whole.hadm_id = chartevents.hadm_id
  GROUP BY chartevents.hadm_id
)
UPDATE ards_whole SET hemoglobin_min = temphello.valuenum FROM temphello WHERE ards_whole.hadm_id = temphello.hadm_id;


UPDATE ards_whole SET red_blood_cell = null;
WITH cv AS (
  SELECT icv.icustay_id, sum(icv.amount) AS amount FROM inputevents_cv AS icv, ards_whole
  WHERE itemid IN (225168, 220996) AND icv.icustay_id = ards_whole.icustay_id GROUP BY icv.icustay_id
)
UPDATE ards_whole SET red_blood_cell = cv.amount FROM cv WHERE cv.icustay_id = ards_whole.icustay_id;
UPDATE ards_whole SET red_blood_cell = 0 WHERE red_blood_cell IS NULL;

WITH mv AS  (
  SELECT imv.icustay_id, sum(imv.amount) AS amount FROM inputevents_mv AS imv, ards_whole
  WHERE itemid IN (225168, 220996) AND imv.icustay_id = ards_whole.icustay_id GROUP BY imv.icustay_id
)
UPDATE ards_whole SET red_blood_cell = mv.amount + red_blood_cell FROM mv WHERE mv.icustay_id = ards_whole.icustay_id;


ALTER TABLE ards_whole ADD transfusion numeric;
UPDATE ards_whole SET transfusion = red_blood_cell + plasma + cryoprecipitate;

ALTER TABLE hello ADD vent_duration numeric;
UPDATE hello 
SET vent_duration = ventdurations.duration_hours 
FROM ventdurations 
WHERE ventdurations.icustay_id = hello.icustay_id;

ALTER TABLE hello ADD icu_duration int4;
UPDATE hello SET icu_duration = EXTRACT(DAY FROM icustays.outtime - icustays.intime) 
FROM icustays WHERE icustays.icustay_id = hello.icustay_id;