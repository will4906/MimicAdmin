

DROP TABLE IF EXISTS head_injury CASCADE;
CREATE TABLE head_injury AS
SELECT di.subject_id, di.hadm_id, di.seq_num, di.icd9_code
FROM
diagnoses_icd di, head_icd9 hi
WHERE
di.icd9_code = hi.icd9_code;

DROP TABLE IF EXISTS head_info CASCADE;
CREATE TABLE head_info AS
SELECT DISTINCT
subject_id, hadm_id
FROM
head_injury;

DROP TABLE IF EXISTS head_icu CASCADE;
CREATE TABLE head_icu AS
SELECT head_info.subject_id, head_info.hadm_id, icustays.icustay_id
FROM
head_info, icustays
WHERE
head_info.hadm_id = icustays.hadm_id;

ALTER TABLE head_icu ADD sofa int4;
UPDATE head_icu SET sofa = sofa.sofa FROM sofa WHERE head_icu.icustay_id = sofa.icustay_id;

ALTER TABLE head_icu ADD sapsii int4;
UPDATE head_icu SET sapsii = sapsii.sapsii FROM sapsii WHERE head_icu.icustay_id = sapsii.icustay_id;

ALTER TABLE head_info ADD age numeric;
ALTER TABLE head_info ADD gender varchar(5);
ALTER TABLE head_info ADD ethnicity varchar(255); 

UPDATE head_info 
SET gender = patients.gender 
FROM patients 
WHERE patients.subject_id = head_info.subject_id;
UPDATE head_info
SET ethnicity = admissions.ethnicity
FROM admissions
WHERE
admissions.hadm_id = head_info.hadm_id;
UPDATE head_info
SET age = ROUND((CAST(EXTRACT(epoch FROM adm.admittime - pat.dob)/(60*60*24*365.242) AS numeric)), 1)
FROM 
admissions adm, patients pat
WHERE adm.subject_id = head_info.subject_id
AND
pat.subject_id = head_info.subject_id;

ALTER TABLE head_icu ADD gcs_score int4;
UPDATE head_icu SET gcs_score = sapsii.gcs_score FROM sapsii WHERE sapsii.icustay_id = head_icu.icustay_id;

ALTER TABLE head_info ADD aki int2;
UPDATE head_info SET aki = 1 FROM aki WHERE head_info.hadm_id = aki.hadm_id;
UPDATE head_info SET aki = 0 WHERE aki IS NULL;

ALTER TABLE head_icu ADD rrt int2;
UPDATE head_icu SET rrt = rrt.rrt FROM rrt WHERE rrt.icustay_id = head_icu.icustay_id;

ALTER TABLE head_icu ADD vent_duration numeric;

UPDATE head_icu 
SET vent_duration = ventdurations.duration_hours 
FROM ventdurations 
WHERE ventdurations.icustay_id = head_icu.icustay_id;

ALTER TABLE head_info ADD hosp_duration int4;
UPDATE head_info SET hosp_duration = EXTRACT(DAY FROM admissions.dischtime - admissions.admittime) 
FROM admissions WHERE admissions.hadm_id = head_info.hadm_id;

ALTER TABLE head_icu ADD icu_duration int4;
UPDATE head_icu SET icu_duration = EXTRACT(DAY FROM icustays.outtime - icustays.intime) 
FROM icustays WHERE icustays.icustay_id = head_icu.icustay_id;

ALTER TABLE head_info ADD hypertension int2;
UPDATE head_info SET hypertension = elixhauser_ahrq.hypertension FROM elixhauser_ahrq WHERE head_info.hadm_id = elixhauser_ahrq.hadm_id;

ALTER TABLE head_info ADD chronic_pulmonary int2;
UPDATE head_info SET chronic_pulmonary = elixhauser_ahrq.chronic_pulmonary FROM elixhauser_ahrq WHERE head_info.hadm_id = elixhauser_ahrq.hadm_id;

ALTER TABLE head_icu ADD mannitol_duration int4;
UPDATE head_icu SET mannitol_duration = NULL;
UPDATE head_icu SET mannitol_duration = EXTRACT(DAY FROM (prescriptions.enddate - prescriptions.startdate)) FROM prescriptions WHERE head_icu.icustay_id = prescriptions.icustay_id 
AND 
prescriptions.drug ILIKE '%mannitol%';

ALTER TABLE head_info ADD creatinine_mean float8;
WITH temp AS (
  SELECT subject_id, hadm_id, avg(valuenum) AS creatinine_mean 
  FROM labevents WHERE itemid IN (50912)
  GROUP BY subject_id, hadm_id
)
UPDATE head_info SET creatinine_mean = ROUND(CAST(temp.creatinine_mean AS numeric),  4) 
FROM temp WHERE temp.hadm_id = head_info.hadm_id;

ALTER TABLE head_info ADD live_time numeric;
UPDATE head_info SET live_time = NULL;
UPDATE head_info
SET
live_time = ROUND((CAST(EXTRACT(epoch FROM patients.dod - adm.admittime)/(60*60*24) AS numeric)), 1)
FROM
patients, admissions adm
WHERE
patients.subject_id = head_info.subject_id
AND
adm.subject_id = head_info.subject_id
AND
patients.dod IS NOT NULL;
UPDATE head_info SET live_time = 0 WHERE live_time < 0;

ALTER TABLE head_info ADD sepsis int2;
UPDATE head_info SET sepsis = angus_sepsis.angus FROM angus_sepsis WHERE angus_sepsis.hadm_id = head_info.hadm_id;

ALTER TABLE head_info ADD bun_mean numeric;
WITH temp AS (
  SELECT subject_id, hadm_id, avg(valuenum) AS bun_mean 
  FROM labevents WHERE itemid IN (51006)
  GROUP BY subject_id, hadm_id
)
UPDATE head_info SET bun_mean = ROUND(CAST(temp.bun_mean AS numeric),  4) 
FROM temp WHERE temp.hadm_id = head_info.hadm_id;

ALTER TABLE head_info ADD albumin_mean numeric;
WITH temp AS (
  SELECT subject_id, hadm_id, avg(valuenum) AS albumin_mean 
  FROM labevents WHERE itemid IN (50862)
  GROUP BY subject_id, hadm_id
)
UPDATE head_info SET albumin_mean = ROUND(CAST(temp.albumin_mean AS numeric),  4) 
FROM temp WHERE temp.hadm_id = head_info.hadm_id;

ALTER TABLE head_icu ADD mannitoldosage numeric;
UPDATE head_icu SET 
mannitoldosage = prescriptions.dose_val_rx::numeric
FROM 
prescriptions
WHERE
prescriptions.icustay_id = head_icu.icustay_id
AND 
prescriptions.drug ILIKE '%mannitol%';

ALTER TABLE head_icu ADD anticoaguation int2;
WITH temp AS (
  SELECT DISTINCT icustay_id, itemid FROM chartevents WHERE itemid = 228004
)
UPDATE head_icu SET anticoaguation = 1 FROM temp WHERE temp.icustay_id = head_icu.icustay_id;

WITH temp AS (
  SELECT DISTINCT icustay_id, itemid FROM chartevents WHERE itemid = 224145
)
UPDATE head_icu SET anticoaguation = 3 FROM temp WHERE temp.icustay_id = head_icu.icustay_id AND head_icu.anticoaguation = 1;

UPDATE head_icu SET anticoaguation = 0 WHERE anticoaguation IS NULL;

ALTER TABLE head_info ADD anisocoria int2;
WITH temp AS(
  SELECT * FROM noteevents WHERE "text" ILIKE '%Anisocoria%'
)
UPDATE head_info SET anisocoria = 1 FROM temp WHERE temp.hadm_id = head_info.hadm_id;









ALTER TABLE head_icu ADD input numeric;
WITH temp AS (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_cv GROUP BY icustay_id
)
UPDATE head_icu SET input = temp.amount FROM temp WHERE head_icu.icustay_id = temp.icustay_id;
WITH temp AS (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_mv GROUP BY icustay_id
)
UPDATE head_icu SET input = temp.amount + input FROM temp WHERE head_icu.icustay_id = temp.icustay_id;
ALTER TABLE head_icu ADD red_blood_cell numeric;
WITH temp AS  (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_mv WHERE itemid = 225168 GROUP BY icustay_id
)
UPDATE head_icu SET red_blood_cell = temp.amount FROM temp WHERE temp.icustay_id = head_icu.icustay_id;

ALTER TABLE head_icu ADD PLASMA numeric;
UPDATE head_icu SET plasma = 0;
WITH temp AS (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_cv WHERE itemid IN (
    30005, 30180, 30103, 44236, 43009, 46530
  )
  GROUP BY icustay_id
)
UPDATE head_icu SET plasma = temp.amount FROM temp WHERE temp.icustay_id = head_icu.icustay_id;

WITH temp AS (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_mv WHERE itemid = 220970 GROUP BY icustay_id
)
UPDATE head_icu SET plasma = plasma + temp.amount FROM temp WHERE temp.icustay_id = head_icu.icustay_id;

ALTER TABLE head_icu ADD cryoprecipitate numeric;
UPDATE head_icu SET cryoprecipitate = 0;
WITH temp AS (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_cv WHERE itemid IN (30007, 45354) GROUP BY icustay_id
)
UPDATE head_icu SET cryoprecipitate = temp.amount FROM temp WHERE temp.icustay_id = head_icu.icustay_id;
WITH temp AS (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_mv WHERE itemid IN (225171, 226371) GROUP BY icustay_id
)
UPDATE head_icu SET cryoprecipitate = temp.amount + cryoprecipitate FROM temp WHERE temp.icustay_id = head_icu.icustay_id;

ALTER TABLE head_icu ADD albumin_drup numeric;
UPDATE head_icu SET 
albumin_drup = prescriptions.dose_val_rx::numeric
FROM 
prescriptions
WHERE
prescriptions.icustay_id = head_icu.icustay_id
AND 
prescriptions.drug ILIKE '%albumin%';
update head_all set albumin_drup = 0 where albumin_drup is null;









































CREATE TABLE icp AS
SELECT * FROM diagnoses_icd WHERE icd9_code ILIKE '584%';

ALTER TABLE head_info ADD aki int4;
UPDATE head_info hi
SET 
aki = 1
FROM
icp
WHERE
hi.subject_id = icp.subject_id
AND
hi.hadm_id = icp.hadm_id;

ALTER TABLE head_info ADD rrt int4;
UPDATE head_info hi
SET 
rrt = 1
FROM
rrt
WHERE
hi.subject_id = rrt.subject_id
AND
hi.hadm_id = rrt.hadm_id
AND
rrt.rrt = 1;

WITH temp AS
(
SELECT * 
FROM diagnoses_icd
WHERE icd9_code = 'V4511' OR icd9_code = 'V560' OR icd9_code = 'V561'
UNION 
SELECT *
FROM procedures_icd
WHERE icd9_code = '3995'
)
UPDATE head_info
SET 
rrt = 1
FROM
temp
WHERE 
head_info.hadm_id = temp.hadm_id;

ALTER TABLE head_info ADD anti_freezing int4;
--0:没有
--1:Heparin Dose
--2:Citrate
ALTER TABLE head_info ADD hospital_expire_flag int2;

UPDATE head_info hi
SET
hospital_expire_flag = adm.hospital_expire_flag
FROM
admissions adm
WHERE
adm.subject_id = hi.subject_id
AND
adm.hadm_id = hi.hadm_id;

ALTER TABLE head_info ADD hosp_mort_30day int2;
ALTER TABLE head_info ADD hosp_mort_1yr int2;

DROP TABLE IF EXISTS mortailty CASCADE;
CREATE TABLE mortailty AS
SELECT adm.hadm_id, admittime, dischtime, adm.deathtime, pat.dod
-- integer which is 1 for the first hospital admission
, ROW_NUMBER() OVER (PARTITION BY hadm_id ORDER BY admittime) AS FirstAdmission
FROM admissions adm
INNER JOIN patients pat
ON adm.subject_id = pat.subject_id
-- filter out organ donor accounts
WHERE lower(diagnosis) NOT LIKE '%organ donor%'
-- at least 15 years old
AND extract(YEAR FROM admittime) - extract(YEAR FROM dob) > 15
-- filter that removes hospital admissions with no corresponding ICU data
AND HAS_CHARTEVENTS_DATA = 1;

UPDATE
head_info
SET
hosp_mort_30day = 1
FROM
mortailty my
WHERE
my.hadm_id = head_info.hadm_id
AND
my.dod < my.admittime + interval '30' day;

UPDATE
head_info
SET
hosp_mort_1yr = 1
FROM
mortailty my
WHERE
my.hadm_id = head_info.hadm_id
AND
my.dod < my.admittime + interval '1' year;

UPDATE head_info SET hosp_mort_30day = 0 WHERE hosp_mort_30day IS NULL;
UPDATE head_info SET hosp_mort_1yr = 0 WHERE hosp_mort_1yr IS NULL;

ALTER TABLE head_info ADD deathage numeric;
UPDATE head_info SET deathage = NULL;
UPDATE head_info
SET
deathage = ROUND((CAST(EXTRACT(epoch FROM patients.dod - adm.admittime)/(60*60*24*365.242) AS numeric)), 1)
FROM
patients, admissions adm
WHERE
patients.subject_id = head_info.subject_id
AND
adm.subject_id = head_info.subject_id
AND
patients.dod IS NOT NULL;

ALTER TABLE head_info ADD esrd int2;
WITH endstage AS(
SELECT * 
FROM d_icd_diagnoses 
WHERE short_title ILIKE '%End stage renal disease%' 
OR long_title ILIKE '%End stage renal disease%'
), temp AS (
	SELECT diagnoses_icd.subject_id, diagnoses_icd.hadm_id
	FROM endstage, diagnoses_icd
	WHERE 
	diagnoses_icd.icd9_code = endstage.icd9_code
)
UPDATE head_info 
SET esrd = 1 FROM temp
WHERE head_info.subject_id = temp.subject_id AND head_info.hadm_id = temp.hadm_id;
UPDATE head_info SET esrd = 0 WHERE esrd IS NULL;

wITH temp AS
(
    SELECT 
    subject_id, hadm_id, 
    CASE itemid WHEN 224145 THEN 1 ELSE 0 AS h, 
    CASE itemid WHEN 228004 THEN 1 ELSE 0 AS c
    FROM
    chartevents
)
UPDATE head_info
SET
anti_freezing = 
CASE 

DROP TABLE IF EXISTS dis_head_info CASCADE;
CREATE TABLE dis_head_info AS
SELECT DISTINCT 
subject_id, hadm_id, aki, rrt, anti_freezing, hospital_expire_flag, hosp_mort_30day, hosp_mort_1yr, deathtime
FROM
head_info;

CREATE TABLE temp_hc AS
SELECT DISTINCT
subject_id, hadm_id, 
(CASE itemid WHEN 224145 THEN 1 ELSE 0 END) AS h, 
(CASE itemid WHEN 228004 THEN 1 ELSE 0 END) AS c
FROM
chartevents_14;

CREATE TABLE dis_hc AS
SELECT
DISTINCT subject_id, hadm_id, h, c
FROM
temp_hc;

UPDATE dis_head_info dhi
SET
anti_freezing = 1
FROM
dis_hc dh
WHERE
dhi.subject_id = dh.subject_id
AND
dhi.hadm_id = dh.hadm_id
AND
dh.h = 1;

UPDATE dis_head_info dhi
SET
anti_freezing = 2
FROM
dis_hc dh
WHERE
dhi.subject_id = dh.subject_id
AND
dhi.hadm_id = dh.hadm_id
AND
dh.c = 1;

CREATE TABLE repeat_hc_detail AS
WITH temp AS 
(
	SELECT DISTINCT subject_id, hadm_id, "max"(h) AS h, "max"(c) AS c FROM dis_hc GROUP BY subject_id, hadm_id
),
temp2 AS(
    SELECT * FROM temp WHERE h = 1 AND c = 1
)
SELECT 
ch.subject_id, ch.hadm_id, ch.icustay_id, ch.itemid, ch.charttime, ch.value, ch.valuenum
FROM
chartevents_14 ch, temp2
WHERE
ch.subject_id = temp2.subject_id
AND
ch.hadm_id = temp2.hadm_id;


UPDATE head_info SET rrt = 1 WHERE rrt = 2;
UPDATE head_info SET esrd = 0 WHERE esrd IS NULL;

ALTER TABLE head_info ADD elixhauser_sid30 int4;
UPDATE head_info SET elixhauser_sid30 = elixhauser_ahrq_score.elixhauser_sid30
FROM elixhauser_ahrq_score
WHERE elixhauser_ahrq_score.hadm_id = head_info.hadm_id;

ALTER TABLE head_info ADD sofa int4;
WITH temp AS(
  SELECT subject_id, hadm_id, max(sofa) FROM sofa GROUP BY subject_id, hadm_id
)
UPDATE head_info SET
sofa = sofa.sofa
FROM 
sofa
WHERE 
head_info.hadm_id = sofa.hadm_id;

DELETE FROM head_info WHERE sofa IS NULL;

BEGIN TRANSACTION;
ALTER TABLE head_info ADD sapsii int4;
WITH temp AS (
  SELECT subject_id, hadm_id, MAX(sapsii) FROM sapsii GROUP BY subject_id, hadm_id
)
UPDATE head_info SET
sapsii = sapsii.sapsii
FROM
sapsii
WHERE
head_info.hadm_id = sapsii.hadm_id;
COMMIT;

--ICP
DROP TABLE IF EXISTS icp CASCADE;
CREATE TABLE icp AS
SELECT 
DISTINCT
subject_id,
hadm_id,
icustay_id
FROM chartevents
WHERE 
chartevents.itemid
IN
(
    226,
    5856,
    227989,
    220765
);
ALTER TABLE head_icu ADD icp int4;
UPDATE head_icu SET icp = 1 FROM icp WHERE head_icu.icustay_id = icp.icustay_id;
UPDATE head_icu SET icp = 0 WHERE icp IS NULL;

UPDATE head_info SET esrd = 1 
FROM noteevents 
WHERE noteevents.text ILIKE '%end-stage renal disease%' 
AND noteevents.hadm_id = head_info.hadm_id;


ALTER TABLE head_info ADD creatinine_max float8;
WITH temp AS (
  SELECT subject_id, hadm_id, max(valuenum) AS creatinine_max 
  FROM labevents WHERE itemid IN (50912)
  GROUP BY subject_id, hadm_id
)
UPDATE head_info SET creatinine_max = ROUND(CAST(temp.creatinine_max AS numeric),  4) 
FROM temp WHERE temp.hadm_id = head_info.hadm_id;


ALTER TABLE head_info ADD aki_level int2;
UPDATE head_info SET aki_level = 1 WHERE creatinine_max >= 0.3 
AND 
creatinine_max < 0.6;
UPDATE head_info SET aki_level = 2 WHERE creatinine_max >= 0.6
AND 
creatinine_max < 0.9;
UPDATE head_info SET aki_level = 3 FROM rrt 
WHERE creatinine_max >= 0.9
OR
(
rrt.rrt = 1
AND 
rrt.hadm_id = head_info.hadm_id
);



CREATE TABLE head_info_note AS 
SELECT noteevents.* FROM noteevents,head_info WHERE noteevents.category ILIKE 'DISCHARGE SUMMARY' AND noteevents.hadm_id = head_info.hadm_id;

ALTER TABLE head_info ADD depression int2;
UPDATE head_info SET depression = 1 
WHERE hadm_id IN 
(178713,175017,145214,129866,123154,167997,199645,145379,195660,185187,175791,167483,
121714,168286,132199,145528,163734,119344,168578,130193,181254,109661,174043,105661,
131281,183691,110908,123493,159186,105279,110776,186846,120070,187890,123308,116331,
188644,107109,133412,192806,172228,136981,174028,184976,184301,185272,102833,179398,
147716,114132,146315,112688,107855,145046,132878,142414,164932,103812,127379,126381,
136560,191196,143380,144058,112798,155333,136803,156214,154426,127129,199362,165126,
111223,142382,111928,135887,149621,118793,119224,100934,102074,194632,163158,165339,
133839,129240,148523,140303,131245,197190,161550,136917,129392,181637,137937,102695,
104676,100663,181982,126877,162229,177863,177863,173131,174089,107336,120801,113883,
144845,183500,163799,146238,161505,171643,195791,188398,185052,125961,158284,131696,
186402,185163,179359,111444,111577,199125,126393,197409,122769,189482,136107,151469,
114013,175857,156062,101443,145046,109584,191263,126338,170407,190264,194565,142417,
142417,160140,160140,112595,193641,147501,139394,127971,147935,137885,135880,105667,
185875,135684,164537,187570,153362,163930,189134,106469,149180,185258,173886,139932,
143112,188891,185461,173670,122161,125236,173950,109610,104981,175475,104694,185831,
108148,115601,164053,152659,152409,115241,164729,128497,105772,101435,102168,137889,
107947,136796,136552,140774,130109,192826,110157,123812,164396,154728,166597,171982,
169388,161390,170409,150105,157128,154728,154728,154728,154104,195027,155889,184262,
185620,153932,188673,118251,151096,198652,194253,180679,140324,170519,154470);
UPDATE head_info SET depression = 0 WHERE depression IS NULL;


ALTER TABLE head_info ADD aspirin int2;
UPDATE head_info SET aspirin = 1 WHERE hadm_id IN 
(
167457,169415,162857,197160,195660,141595,115417,152263,162277,118931,108480,106887,
125761,117182,111702,112744,117307,151110,107505,109626,108041,191754,111538,183126,
190177,150502,194018,193777,175341,154426,118998,112254,117825,121712,124140,106044,
195317,153312,181637,171409,129378,138340,100663,129252,166368,129193,120333,121832,
142581,103063,132587,183500,128599,146450,145231,169485,191777,163513,107226,184953,
189482,106437,145774,138810,138508,196780,199813,112311,114013,130887,193482,125107,
176076,142417,160140,160140,112595,122695,155541,122284,159773,139394,162834,128604,
127971,161251,136813,139762,105667,164537,143339,106469,124427,108874,154574,154574,
188891,158991,116890,171936,134119,199976,162365,105535,148717,142824,160195,119225,
107585,107585,112150,146757,182123,179404,189431,189431,193806,164729,157148,173044,
196933,102168,144647,116509,155346,130109,158200,155719,141579,199598,121234,185663,
185663,166959,161390,182768,133127,163720,115613,114953,103432,103005,139076,108340,
151096,133167,161680,158830
);
UPDATE head_info SET aspirin = 0 WHERE aspirin IS NULL;

ALTER TABLE head_info ADD coumadin int2;
UPDATE head_info SET coumadin = 1 WHERE hadm_id IN (
  147742,140545,117645,181254,194723,119761,165829,188294,146928,123598,155855,152241,
179994,135453,144976,127971,118106,131893,113214,187570,120605,158991,135978,136576,
116523,164729,181829,135136,174751,172169,189439,125940,140992,125616,102265,125524,
121125,142414,130083,133839,168495,172355,196423,107226,118419,124896,120953,176069,
128604,190856,172231,159100,133127,166101
);
UPDATE head_info SET coumadin = 0 WHERE coumadin IS NULL;

ALTER TABLE head_info ADD anxiety int2;
UPDATE head_info SET anxiety = 1 WHERE hadm_id IN (
  109421,175017,110651,121714,135534,132199,158706,120081,174043,110908,123493,136183,
107109,192806,125921,185272,177444,121125,155506,142414,109516,179494,179494,127379,
157480,150557,135200,153453,158179,109445,127129,199362,135887,149621,124140,119224,
102074,146928,147897,194632,127703,119987,140303,171300,174089,143522,107336,120801,
192635,165777,188398,158284,131696,125227,105990,111577,199125,189482,186818,156277,
129448,142417,142417,123745,112595,187570,166740,147072,122161,110754,164053,152659,
184889,105525,178134,138600,153893,177791,192826,141579,161390,170409,143972,155889,
184262,185620,161919,188673,110756,194253,171444,180679
);
UPDATE head_info SET anxiety = 0 WHERE anxiety IS NULL;


ALTER TABLE head_icu ADD bmi numeric;

UPDATE head_icu SET bmi = ROUND(heightweight.weight_first / (heightweight.height_first*heightweight.height_first/10000) , 2)
FROM heightweight
WHERE heightweight.icustay_id = head_icu.icustay_id
AND
heightweight.height_first != 0;
---------------------------------------并表代码---------------------------------------------
CREATE TABLE head_whole AS (
  WITH info_left_part AS (
  SELECT * FROM head_info
  ),
  code_left_part AS (
    SELECT icustay_id,fullcode_first,cmo_first,dnr_first,dni_first,dncpr_first,fullcode_last,cmo_last,dnr_last,dni_last,dncpr_last,fullcode,cmo,dnr,dni,dncpr,cmo_ds,timednr_chart,timecmo_chart,timecmo_nursingnote FROM head_code
  ),
  left_part AS (
    SELECT * FROM head_icu LEFT JOIN code_left_part ON head_icu.icustay_id = code_left_part.icustay_id
  )
  SELECT * FROM left_part LEFT JOIN info_left_part ON left_part.hadm_id = info_left_part.hadm_id
);
DELETE FROM head_whole WHERE age < 18;
-------------------------------------------------------------------------------------------
ALTER TABLE head_icu ADD aki_7day int2;
UPDATE head_icu SET aki_7day = kdigo_stages_7day.aki_7day FROM kdigo_stages_7day 
WHERE head_icu.icustay_id = kdigo_stages_7day.icustay_id;

ALTER TABLE head_icu ADD aki_stage_7day int2;
UPDATE head_icu SET aki_stage_7day = kdigo_stages_7day.aki_stage_7day 
FROM kdigo_stages_7day WHERE head_icu.icustay_id = kdigo_stages_7day.icustay_id; 

ALTER TABLE head_icu ADD aki_stage_creat_7day int2;
UPDATE head_icu SET aki_stage_creat_7day = kdigo_stages_7day.aki_stage_7day_creat 
FROM kdigo_stages_7day WHERE head_icu.icustay_id = kdigo_stages_7day.icustay_id; 

ALTER TABLE head_icu ADD aki_48hr int2;
UPDATE head_icu SET aki_48hr = kdigo_stages_48hr.aki_48hr FROM kdigo_stages_48hr 
WHERE head_icu.icustay_id = kdigo_stages_48hr.icustay_id;

ALTER TABLE head_icu ADD aki_stage_48hr int2;
UPDATE head_icu SET aki_stage_48hr = kdigo_stages_48hr.aki_stage_48hr 
FROM kdigo_stages_48hr WHERE head_icu.icustay_id = kdigo_stages_48hr.icustay_id; 

ALTER TABLE head_icu ADD aki_stage_creat_48hr int2;
UPDATE head_icu SET aki_stage_creat_48hr = kdigo_stages_48hr.aki_stage_48hr_creat 
FROM kdigo_stages_48hr WHERE head_icu.icustay_id = kdigo_stages_48hr.icustay_id; 

-- 创建身高表格
DROP TABLE IF EXISTS all_height CASCADE;
CREATE TABLE all_height AS (
  SELECT DISTINCT icustay_id FROM icustays
);
ALTER TABLE all_height ADD height_first numeric;
UPDATE all_height SET height_first = heightfirstday.height FROM heightfirstday 
WHERE all_height.icustay_id = heightfirstday.icustay_id AND heightfirstday.height IS NOT NULL;
UPDATE all_height SET height_first = heightweight.height_first FROM heightweight
WHERE all_height.icustay_id = heightweight.icustay_id AND heightweight.height_first IS NOT NULL;
ALTER TABLE all_height ADD weight_first numeric;
UPDATE all_height SET weight_first = heightweight.weight_first FROM heightweight WHERE all_height.icustay_id = heightweight.icustay_id;

CREATE TABLE head_code AS 
SELECT 
code_status.subject_id, code_status.hadm_id, code_status.icustay_id, code_status.fullcode_first, 
code_status.cmo_first, code_status.dnr_first, code_status.dni_first,
code_status.dncpr_first, code_status.fullcode_last, code_status.cmo_last, code_status.dnr_last, code_status.dni_last, 
code_status.dncpr_last, code_status.fullcode, 
code_status.cmo, code_status.dnr, code_status.dni, code_status.dncpr, code_status.cmo_ds, 
code_status.timednr_chart, code_status.timecmo_chart, code_status.timecmo_nursingnote
FROM head_icu, code_status
WHERE head_icu.icustay_id = code_status.icustay_id;

13728	225103	Intravenous  / IV access prior to admission	Intravenous  / IV access prior to admission	metavision	chartevents	Adm History/FHPA		Checkbox	

-- 2017年12月3号讨论记录
Base execess: 在bloodgasfirstday里面有个字段
Shock at ED(n, %): 在vitalsfirstday 里面的diasbp_min 小于60就是1
Penetrating injury 
intravenous contrast medium 在prescriptions drug字段中查询 meglumine, iohexol(没有), iopromide(没有), iopamidol(没有)
aminoglysosides:
 在prescriptions drug字段中查询Amikacin, Tobramycin Sulfate, Tobramycin, tobramycin, Streptomycin Sulfate, Gentamicin, Gentamicin , Gentamicin Sulfate, 
vancomycin:   Vancomycin , Vancomycin, Vancomycin HCl
polymyxin B:  Polymyxin B Sulfate
ARB/ACE-I: 
  ARB:    ILIKE '%losartan%', ILIKE '%valsartan%', ILIKE '%irbesartan%', ILIKE '%candesartan%', 
  ACE-I:  ILIKE '%captopril%', ILIKE '%enalapril%', ILIKE '%ramipril%', ILIKE '%benazepril%', ILIKE '%fosinopril%'
Transfusion: 
  red_blood_cell + PLASMA + cryoprecipitate

最最后删掉小于18岁
删掉入院24小时死亡的病人
跑一遍elixhauser-ahrq-v37-no-drg-all-icd.sql 删掉代码里标注了排除的参量的病人。
删掉

-- 以下内容来自2017年12月3号讨论记录
1.Base execess只有332条记录
ALTER TABLE head_icu ADD baseexcess numeric;
UPDATE head_icu SET baseexcess = bloodgasfirstday.baseexcess FROM bloodgasfirstday WHERE head_icu.icustay_id = bloodgasfirstday.icustay_id;
2. Shock at ED(n, %) 有2698条记录？这么多？
ALTER TABLE head_icu ADD shock_at_ed INT;
UPDATE head_icu SET shock_at_ed = 1 FROM vitalsfirstday WHERE head_icu.icustay_id = vitalsfirstday.icustay_id AND vitalsfirstday.diasbp_min < 60;
UPDATE head_whole SET shock_at_ed = 0 WHERE shock_at_ed IS NULL;
3. Penetrating injury 
-- ALTER TABLE （没解决，先放着）
4. intravenous contrast medium
ALTER TABLE head_icu ADD icm INT;
WITH hello AS (
SELECT prescriptions.* FROM prescriptions,head_icu WHERE drug ILIKE '%meglumine%' AND prescriptions.icustay_id = head_icu.icustay_id
)
UPDATE head_icu SET icm = 1 FROM hello WHERE hello.icustay_id = head_icu.icustay_id;
UPDATE head_icu SET icm = 0 WHERE icm IS NULL;
5. aminoglysosides
ALTER TABLE head_icu ADD aminoglysosides INT;
WITH hello AS (
  SELECT prescriptions.* FROM prescriptions,head_icu 
  WHERE 
  (
    drug = 'Tobramycin Sulfate'
    OR 
    drug = 'Tobramycin'
    OR
    drug = 'tobramycin'
    OR
    drug = 'Streptomycin Sulfate'
    OR
    drug = 'Gentamicin'
    OR
    drug = 'Gentamicin '
    OR 
    drug = 'Gentamicin Sulfate'
    OR
    drug = 'Amikacin' 
  )
  AND 
  prescriptions.icustay_id = head_icu.icustay_id
)
UPDATE head_icu SET aminoglysosides = 1 FROM hello WHERE hello.icustay_id = head_icu.icustay_id;
UPDATE head_icu SET aminoglysosides = 0 WHERE aminoglysosides IS NULL;
6. vancomycin
ALTER TABLE head_icu ADD vancomycin INT;
WITH hello AS (
  SELECT prescriptions.* FROM prescriptions,head_icu 
  WHERE 
  (
    drug = 'Vancomycin '
    OR 
    drug = 'Vancomycin'
    OR 
    drug = 'Vancomycin HCl'
  )
  AND 
  prescriptions.icustay_id = head_icu.icustay_id
)
UPDATE head_icu SET vancomycin = 1 FROM hello WHERE hello.icustay_id = head_icu.icustay_id;
UPDATE head_icu SET vancomycin = 0 WHERE vancomycin IS NULL;
7. polymyxin B -- 一个都没有。。。
ALTER TABLE head_icu ADD polymyxin_b INT;
WITH hello AS (
SELECT prescriptions.* FROM prescriptions,head_icu WHERE drug = 'Polymyxin B Sulfate' AND prescriptions.icustay_id = head_icu.icustay_id
)
UPDATE head_icu SET polymyxin_b = 1 FROM hello WHERE hello.icustay_id = head_icu.icustay_id;
UPDATE head_icu SET polymyxin_b = 0 WHERE polymyxin_b IS NULL;
8. ARB/ACE-I
ALTER TABLE head_icu ADD arb_acei INT;
WITH hello AS (
  SELECT prescriptions.* FROM prescriptions, head_icu WHERE (
    drug ILIKE '%losartan%'
    OR
    drug ILIKE '%valsartan%'
    OR
    drug ILIKE '%irbesartan%'
    OR
    drug ILIKE '%candesartan%'
    OR
    drug ILIKE '%captopril%'
    OR
    drug ILIKE '%candesartan%'
    OR
    drug ILIKE '%candesartan%'
    OR
    drug ILIKE '%enalapril%'
    OR
    drug ILIKE '%ramipril%'
    OR
    drug ILIKE '%benazepril%'
    OR
    drug ILIKE '%fosinopril%'
  )
  AND 
  prescriptions.icustay_id = head_icu.icustay_id
)
UPDATE head_icu SET arb_acei = 1 FROM hello WHERE hello.icustay_id = head_icu.icustay_id;
UPDATE head_icu SET arb_acei = 0 WHERE arb_acei IS NULL;
9. Transfusion
-- 此处修复float值的bug
ALTER TABLE head_icu ADD input numeric;
WITH temp AS (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_cv GROUP BY icustay_id
)
UPDATE head_icu SET input = temp.amount FROM temp WHERE head_icu.icustay_id = temp.icustay_id;
WITH temp AS (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_mv GROUP BY icustay_id
)
UPDATE head_icu SET input = temp.amount + input FROM temp WHERE head_icu.icustay_id = temp.icustay_id;
ALTER TABLE head_icu ADD red_blood_cell numeric;
WITH temp AS  (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_mv WHERE itemid = 225168 GROUP BY icustay_id
)
UPDATE head_icu SET red_blood_cell = temp.amount FROM temp WHERE temp.icustay_id = head_icu.icustay_id;
UPDATE head_icu SET red_blood_cell = 0 WHERE red_blood_cell IS NULL;

ALTER TABLE head_icu ADD PLASMA numeric;
UPDATE head_icu SET plasma = 0;
WITH temp AS (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_cv WHERE itemid IN (
    30005, 30180, 30103, 44236, 43009, 46530
  )
  GROUP BY icustay_id
)
UPDATE head_icu SET plasma = temp.amount FROM temp WHERE temp.icustay_id = head_icu.icustay_id;

WITH temp AS (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_mv WHERE itemid = 220970 GROUP BY icustay_id
)
UPDATE head_icu SET plasma = plasma + temp.amount FROM temp WHERE temp.icustay_id = head_icu.icustay_id;

ALTER TABLE head_icu ADD cryoprecipitate numeric;
UPDATE head_icu SET cryoprecipitate = 0;
WITH temp AS (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_cv WHERE itemid IN (30007, 45354) GROUP BY icustay_id
)
UPDATE head_icu SET cryoprecipitate = temp.amount FROM temp WHERE temp.icustay_id = head_icu.icustay_id;
WITH temp AS (
  SELECT icustay_id, sum(amount) AS amount FROM inputevents_mv WHERE itemid IN (225171, 226371) GROUP BY icustay_id
)
UPDATE head_icu SET cryoprecipitate = temp.amount + cryoprecipitate FROM temp WHERE temp.icustay_id = head_icu.icustay_id;


ALTER TABLE head_icu ADD transfusion numeric;
UPDATE head_icu SET transfusion = red_blood_cell + plasma + cryoprecipitate;
10. 
WITH 
SELECT head_info.* FROM head_icu, eligrp WHERE head_info.hadm_id = eligrp.hadm_id AND HRENWRF = 1 AND HHRWRF = 1 AND HHRWHRF = 1 AND RENLFAIL = 1
HRENWRF
HHRWRF
HHRWHRF
RENLFAIL
这要删掉的倒是一个都没有。


ALTER TABLE head_all ADD rifle_stage_7day_creat INT;
ALTER TABLE head_all ADD akin_stage_48hr_creat INT;
ALTER TABLE head_all ADD ck_stage_creat INT;
ALTER TABLE head_all ADD kdigo_stage_48hr_creat INT;
ALTER TABLE head_all ADD kdigo_stage_7day_creat INT;

UPDATE head_all SET rifle_stage_7day_creat = aki_stages.rifle_stage_7day_creat FROM aki_stages WHERE aki_stages.icustay_id = head_all.icustay_id;
UPDATE head_all SET akin_stage_48hr_creat = aki_stages.akin_stage_48hr_creat FROM aki_stages WHERE aki_stages.icustay_id = head_all.icustay_id;
UPDATE head_all SET ck_stage_creat = aki_stages.ck_stage_creat FROM aki_stages WHERE aki_stages.icustay_id = head_all.icustay_id;
UPDATE head_all SET kdigo_stage_48hr_creat = aki_stages.kdigo_stage_48hr_creat FROM aki_stages WHERE aki_stages.icustay_id = head_all.icustay_id;
UPDATE head_all SET kdigo_stage_7day_creat = aki_stages.kdigo_stage_7day_creat FROM aki_stages WHERE aki_stages.icustay_id = head_all.icustay_id;

ALTER TABLE head_all ADD craniotomy INT;
WITH temp AS (
  SELECT noteevents.* FROM noteevents, head_all WHERE category ILIKE '%discharge summary%' AND "text" ILIKE '%craniotomy%' AND head_all.hadm_id = noteevents.hadm_id
)
UPDATE head_all SET craniotomy = 1 FROM temp WHERE head_all.hadm_id = temp.hadm_id;
UPDATE head_all SET craniotomy = 0 WHERE craniotomy IS NULL;

ALTER TABLE head_all ADD heart_failure INT;
WITH temp AS (
  SELECT * FROM diagnoses_icd WHERE icd9_code = '39891' OR icd9_code BETWEEN '4280 ' AND '4289 '
)
UPDATE head_all SET heart_failure = 1 FROM temp WHERE temp.hadm_id = head_all.hadm_id;
UPDATE head_all SET heart_failure = 0 WHERE heart_failure IS NULL;

-- ATRIAL FIBRILLATION
ALTER TABLE head_all ADD atrail_fibrillation INT;
WITH temp AS (
  SELECT * FROM diagnoses_icd WHERE icd9_code IN (
    '42610', '42611', '42613', '4270 ', '4272 ', '42731', '42760', '4279 ', '7850 '
  ) OR (icd9_code BETWEEN '4262 ' AND '42653') OR (icd9_code BETWEEN '4266 ' AND '42689') 
  OR (icd9_code BETWEEN 'V450 ' AND 'V4509') OR (icd9_code BETWEEN 'V533 ' AND 'V5339')
)
UPDATE head_all SET atrail_fibrillation = 1 FROM temp WHERE temp.hadm_id = head_all.hadm_id;
UPDATE head_all SET atrail_fibrillation = 0 WHERE atrail_fibrillation IS NULL;

-- valvular
ALTER TABLE head_all ADD valvular INT;
WITH temp AS (
  SELECT * FROM diagnoses_icd WHERE icd9_code IN (
    '3979 ', 'V422 ', 'V433 '
  ) OR (icd9_code BETWEEN '09320' AND '09324') OR (icd9_code BETWEEN '3940 ' AND '3971 ') 
  OR (icd9_code BETWEEN '4240 ' AND '42499') OR (icd9_code BETWEEN '7463 ' AND '7466 ')
)
UPDATE head_all SET valvular = 1 FROM temp WHERE temp.hadm_id = head_all.hadm_id;
UPDATE head_all SET valvular = 0 WHERE valvular IS NULL;

-- diabetes
ALTER TABLE head_all ADD diabetes INT;
WITH temp AS (
  SELECT * FROM diagnoses_icd WHERE icd9_code IN (
    '7751 '
  ) 
  OR (icd9_code BETWEEN '25000' AND '25033') 
  OR (icd9_code BETWEEN '64800' AND '64804') 
  OR (icd9_code BETWEEN '24900' AND '24931') 
  OR (icd9_code BETWEEN '25040' AND '25093')
  OR (icd9_code BETWEEN '24940' AND '24991')
)
UPDATE head_all SET diabetes = 1 FROM temp WHERE temp.hadm_id = head_all.hadm_id;
UPDATE head_all SET diabetes = 0 WHERE diabetes IS NULL;

-- liver_disease
ALTER TABLE head_all ADD liver_disease INT;
WITH temp AS (
  SELECT * FROM diagnoses_icd WHERE icd9_code IN (
    '07022', '07023', '07032', '07033', '07044', '07054', 
    '4560 ', '4561 ', '45620', '45621', '5710 ', '5712 ',
    '5713 ', '5715 ', '5716 ', '5718 ', '5719 ', '5723 ',
    '5728 ', '5735 ', 'V427 '
  ) 
  OR (icd9_code BETWEEN '57140' AND '57149') 
)
UPDATE head_all SET liver_disease = 1 FROM temp WHERE temp.hadm_id = head_all.hadm_id;
UPDATE head_all SET liver_disease = 0 WHERE liver_disease IS NULL;

-- immunocompromised
ALTER TABLE head_all ADD immunocompromised INT;
WITH temp AS (
  SELECT * FROM diagnoses_icd WHERE icd9_code IN (
    '2386 ', '2733 '
  ) 
  OR (icd9_code between '042  ' and '0449 ') 
  OR (icd9_code between '20000' and '20238')
  OR (icd9_code between '20250' and '20301')
  OR (icd9_code between '20302' and '20382')
)
UPDATE head_all SET immunocompromised = 1 FROM temp WHERE temp.hadm_id = head_all.hadm_id;
UPDATE head_all SET immunocompromised = 0 WHERE immunocompromised IS NULL;

-- malignancy
ALTER TABLE head_all ADD malignancy INT;
WITH temp AS (
  SELECT * FROM diagnoses_icd WHERE icd9_code IN (
    '20979', '78951'
  ) 
  OR (icd9_code between '1960 ' and '1991 ') 
  OR (icd9_code between '20970' and '20975')
)
UPDATE head_all SET malignancy = 1 FROM temp WHERE temp.hadm_id = head_all.hadm_id;
UPDATE head_all SET malignancy = 0 WHERE malignancy IS NULL;

ALTER TABLE head_all ADD dod timestamp;
UPDATE head_all SET dod = patients.dod FROM patients WHERE patients.subject_id = head_all.subject_id;

-- DROP TABLE IF EXISTS head_aki CASCADE;
-- CREATE TABLE head_aki AS(

-- )
-- (75 * 1.73 + 1.154 * age + 0.203 * (0.742 if female) * (1.210 if black)) / 186

UPDATE head_all SET creatinine_mean = head_info.creatinine_mean FROM head_info WHERE head_all.hadm_id = head_info.hadm_id;
UPDATE head_all SET bmi = head_info.bmi FROM head_info WHERE head_all.hadm_id = head_info.hadm_id;


UPDATE head_all SET vent_duration = head_icu.vent_duration FROM head_icu WHERE head_all.icustay_id = head_icu.icustay_id;
UPDATE head_all SET mannitoldosage = head_icu.mannitoldosage FROM head_icu WHERE head_all.icustay_id = head_icu.icustay_id;
UPDATE head_all SET albumin_drup = head_icu.albumin_drup FROM head_icu WHERE head_all.icustay_id = head_icu.icustay_id;
UPDATE head_all SET bmi = head_icu.bmi FROM head_icu WHERE head_all.icustay_id = head_icu.icustay_id;
UPDATE head_all SET baseexcess = head_icu.baseexcess FROM head_icu WHERE head_all.icustay_id = head_icu.icustay_id;
UPDATE head_all SET input = head_icu.input FROM head_icu WHERE head_all.icustay_id = head_icu.icustay_id;
UPDATE head_all SET red_blood_cell = head_icu.red_blood_cell FROM head_icu WHERE head_all.icustay_id = head_icu.icustay_id;
UPDATE head_all SET plasma = head_icu.plasma FROM head_icu WHERE head_all.icustay_id = head_icu.icustay_id;
UPDATE head_all SET cryoprecipitate = head_icu.cryoprecipitate FROM head_icu WHERE head_all.icustay_id = head_icu.icustay_id;
UPDATE head_all SET transfusion = head_icu.transfusion FROM head_icu WHERE head_all.icustay_id = head_icu.icustay_id;

ALTER TABLE head_all ADD rifle_stage_7day_admin_creat INT;
UPDATE head_all SET rifle_stage_7day_admin_creat = aki_stages_admin.rifle_stage_7day_creat FROM aki_stages_admin
WHERE 
head_all.icustay_id = aki_stages_admin.icustay_id;

ALTER TABLE head_all ADD rifle_stage_7day_admin_uo INT;
UPDATE head_all SET rifle_stage_7day_admin_uo = kdigo_7day_admin_uo_stage;

ALTER TABLE head_all ADD rifle_stage_7day_admin INT;
UPDATE head_all SET rifle_stage_7day_admin = NULL;
UPDATE head_all SET rifle_stage_7day_admin = rifle_stage_7day_admin_creat;
UPDATE head_all SET rifle_stage_7day_admin = rifle_stage_7day_admin_uo WHERE rifle_stage_7day_admin_uo IS NOT NULL
AND rifle_stage_7day_admin_uo > rifle_stage_7day_admin;
UPDATE head_all SET rifle_stage_7day_admin = 0 WHERE rifle_stage_7day_admin_creat = 0;

ALTER TABLE head_all ADD rifle_stage_7day_admin_origin INT;
UPDATE head_whole SET rifle_stage_7day_admin_origin = rifle_stage_7day_admin_creat;
UPDATE head_whole SET rifle_stage_7day_admin_origin = rifle_stage_7day_admin_uo WHERE rifle_stage_7day_admin_uo IS NOT NULL
AND rifle_stage_7day_admin_uo > rifle_stage_7day_admin;

ALTER TABLE head_all ADD akin_stage_48hr_admin_creat INT;
UPDATE head_all SET akin_stage_48hr_admin_creat = aki_stages_admin.akin_stage_48hr_creat FROM aki_stages_admin
WHERE 
head_all.icustay_id = aki_stages_admin.icustay_id;

ALTER TABLE head_all ADD akin_stage_48hr_admin_uo INT;
UPDATE head_all SET akin_stage_48hr_admin_uo = kdigo_7day_admin_uo_stage;

ALTER TABLE head_all ADD akin_stage_48hr_admin_origin INT;
UPDATE head_whole SET akin_stage_48hr_admin_origin = akin_stage_48hr_admin_creat;
UPDATE head_whole SET akin_stage_48hr_admin_origin = akin_stage_48hr_admin_uo where akin_stage_48hr_admin_uo is not null and 
akin_stage_48hr_admin_uo > akin_stage_48hr_admin_creat;

ALTER TABLE head_all ADD akin_stage_48hr_admin INT;
UPDATE head_all SET akin_stage_48hr_admin = akin_stage_48hr_admin_origin;
UPDATE head_all SET akin_stage_48hr_admin = 0 WHERE akin_stage_48hr_admin_creat = 0;


DELETE FROM head_all WHERE fullcode_first = 0;
DELETE FROM head_all WHERE dnr_first = 1;
DELETE FROM head_all WHERE cmo_last = 1;
DELETE FROM head_all WHERE dnr_last = 1;
DELETE FROM head_all WHERE dni_last = 1;
DELETE FROM head_all WHERE dnr = 1;
DELETE FROM head_all WHERE dni = 1;
DELETE FROM head_all WHERE cmo_ds = 1;

ALTER TABLE head_all ADD creatinine_admin numeric;
UPDATE head_all SET creatinine_admin = kdigo_creat.admcreat FROM kdigo_creat
 WHERE kdigo_creat.icustay_id = head_all.icustay_id;


ALTER TABLE head_all ADD bun_admin numeric;
 with cr as
(
select
    ie.icustay_id
  , ie.intime, ie.outtime
  , le.valuenum as creat
  , le.charttime
  from icustays ie
  left join labevents le
    on ie.subject_id = le.subject_id
    and le.ITEMID = 51006
    and le.VALUENUM is not null
    and le.CHARTTIME between (ie.intime - interval '6' hour) and (ie.intime + interval '7' day)
), cr_temp AS (
select
    cr.icustay_id
  , cr.creat
  , cr.charttime
  -- Create an index that goes from 1, 2, ..., N
  -- The index represents how early in the patient's stay a creatinine value was measured
  -- Consequently, when we later select index == 1, we only select the first (admission) creatinine
  -- In addition, we only select the first stay for the given subject_id
  , ROW_NUMBER ()
          OVER (PARTITION BY cr.icustay_id
                ORDER BY cr.charttime
              ) as rn_first

  -- Similarly, we can get the highest and the lowest creatinine by ordering by VALUENUM
  , ROW_NUMBER ()
          OVER (PARTITION BY cr.icustay_id
                ORDER BY cr.creat DESC
              ) as rn_highest
  , ROW_NUMBER ()
          OVER (PARTITION BY cr.icustay_id
                ORDER BY cr.creat
              ) as rn_lowest
  from cr
  -- limit to the first 48 hours (source table has data up to 7 days)
  where cr.charttime <= cr.intime + interval '24' hour
)
UPDATE head_all SET bun_admin = cr_temp.creat FROM cr_temp where head_all.icustay_id = cr_temp.icustay_id
AND cr_temp.rn_first = 1;

ALTER TABLE head_all ADD albumin_admin numeric;
 with cr as
(
select
    ie.icustay_id
  , ie.intime, ie.outtime
  , le.valuenum as creat
  , le.charttime
  from icustays ie
  left join labevents le
    on ie.subject_id = le.subject_id
    and le.ITEMID = 50862
    and le.VALUENUM is not null
    and le.CHARTTIME between (ie.intime - interval '6' hour) and (ie.intime + interval '7' day)
), cr_temp AS (
select
    cr.icustay_id
  , cr.creat
  , cr.charttime
  -- Create an index that goes from 1, 2, ..., N
  -- The index represents how early in the patient's stay a creatinine value was measured
  -- Consequently, when we later select index == 1, we only select the first (admission) creatinine
  -- In addition, we only select the first stay for the given subject_id
  , ROW_NUMBER ()
          OVER (PARTITION BY cr.icustay_id
                ORDER BY cr.charttime
              ) as rn_first

  -- Similarly, we can get the highest and the lowest creatinine by ordering by VALUENUM
  , ROW_NUMBER ()
          OVER (PARTITION BY cr.icustay_id
                ORDER BY cr.creat DESC
              ) as rn_highest
  , ROW_NUMBER ()
          OVER (PARTITION BY cr.icustay_id
                ORDER BY cr.creat
              ) as rn_lowest
  from cr
  -- limit to the first 48 hours (source table has data up to 7 days)
  where cr.charttime <= cr.intime + interval '48' hour
)
UPDATE head_all SET albumin_admin = cr_temp.creat FROM cr_temp where head_all.icustay_id = cr_temp.icustay_id
AND cr_temp.rn_first = 1;

UPDATE head_all SET creatinine_max = head_info.creatinine_max FROM head_info WHERE head_info.hadm_id = head_all.hadm_id;

ALTER TABLE head_whole ADD has_kdigo INT;
ALTER TABLE head_whole ADD has_kdigo_origin INT;

UPDATE head_whole SET has_kdigo = 1 WHERE kdigo_7day_admin_stage > 0;
UPDATE head_whole SET has_kdigo = 0 WHERE kdigo_7day_admin_stage = 0;

UPDATE head_whole SET has_kdigo_origin = 1 WHERE kdigo_7day_admin_stage_origin > 0;
UPDATE head_whole SET has_kdigo_origin = 0 WHERE kdigo_7day_admin_stage_origin = 0;



UPDATE head_whole SET shock_at_ed = NULL;
UPDATE head_whole SET shock_at_ed = 0 FROM sofa WHERE sofa.cardiovascular = 0 
AND head_whole.icustay_id = sofa.icustay_id;
UPDATE head_whole SET shock_at_ed = 1 FROM sofa WHERE sofa.cardiovascular > 0
AND head_whole.icustay_id = sofa.icustay_id;

ALTER TABLE head_whole ADD shock_at_ed90 INT;
-- UPDATE head_icu SET shock_at_ed = 1 FROM vitalsfirstday WHERE head_icu.icustay_id = vitalsfirstday.icustay_id AND vitalsfirstday.diasbp_min < 60;
UPDATE head_whole SET shock_at_ed90 = 1 FROM vitalsfirstday 
WHERE head_whole.icustay_id = vitalsfirstday.icustay_id AND vitalsfirstday.diasbp_min < 90;

WITH head_icd9_temp AS (
  SELECT diagnoses_icd.* FROM diagnoses_icd, head_whole WHERE head_whole.hadm_id = diagnoses_icd.hadm_id
)
SELECT head_icd9_temp.hadm_id, cs_single.css_name FROM head_icd9_temp, css_single_level_dx
WHERE head_icd9_temp.icd9_code = cs_single.icd9_code

UPDATE head_whole SET shock_at_ed = 0 WHERE shock_at_ed IS NULL;

WITH head_icd9_temp AS (
  SELECT diagnoses_icd.* FROM diagnoses_icd, head_whole WHERE head_whole.hadm_id = diagnoses_icd.hadm_id
), temp AS (
	SELECT * FROM ccs_single_level_dx WHERE ccs_id IN (207,240,236,231,227,234,230,226)
), hello AS (
	SELECT DISTINCT head_icd9_temp.hadm_id FROM head_icd9_temp, temp WHERE "temp".icd9_code = head_icd9_temp.icd9_code
)
DELETE FROM head_whole WHERE hadm_id IN (SELECT hadm_id FROM hello);

ALTER TABLE head_whole ADD coronary_artery INT;
WITH hello AS (
	SELECT * FROM ccs_single_level_dx WHERE ccs_name ILIKE '%Coronary%'
)
, hello1 AS (
	SELECT diagnoses_icd.* FROM hello,head_whole, diagnoses_icd WHERE head_whole.hadm_id = diagnoses_icd.hadm_id
	AND diagnoses_icd.icd9_code = hello.icd9_code
)
UPDATE head_whole SET coronary_artery = 1 FROM hello1 WHERE head_whole.hadm_id = hello1.hadm_id;
UPDATE head_whole SET coronary_artery = 0 WHERE coronary_artery IS NULL;

ALTER TABLE head_whole ADD hemoglobin numeric;
WITH gg AS (
SELECT ch.subject_id, ch.hadm_id, min(charttime) as charttime FROM chartevents as ch, head_whole WHERE 
itemid IN (814, 220228) 
AND 
ch.hadm_id = head_whole.hadm_id
GROUP BY
ch.subject_id, ch.hadm_id
)
, gg2 AS (
  SELECT chartevents.hadm_id, value FROM chartevents, gg 
  WHERE gg.hadm_id = chartevents.hadm_id 
  AND chartevents.charttime = gg.charttime
  AND chartevents.itemid IN (814, 220228) 
)
UPDATE head_whole SET hemoglobin = gg2.value::numeric FROM gg2 WHERE head_whole.hadm_id = gg2.hadm_id;

-- 啥信息都没有，被我删了
DELETE FROM head_whole WHERE hadm_id = 148324;



UPDATE head_whole SET aspirin = 0;

WITH aspr AS (
  SELECT DISTINCT prescriptions.hadm_id FROM head_whole, prescriptions WHERE
(
	drug ILIKE '%clopidogrel%'
	OR drug ILIKE '%Tirofiban%'
	OR drug ILIKE '%abciximab%'
	OR drug ILIKE '%Warfarin%'
	OR drug ILIKE '%coumadin%'
	OR drug ILIKE '%aspirin%'
)
AND
head_whole.hadm_id = prescriptions.hadm_id
)
UPDATE head_whole SET aspirin = 1 FROM aspr WHERE aspr.hadm_id = head_whole.hadm_id;

-- clopidogrel, Tirofiban, abciximab, aspirin 属于antiplate
-- Warfarin, coumadin 属于anticoaguation

ALTER TABLE head_whole ADD antiplate INT;
UPDATE head_whole SET antiplate = 0;
WITH anti AS (
  SELECT DISTINCT prescriptions.hadm_id FROM head_whole, prescriptions WHERE (
    drug ILIKE '%clopidogrel%'
    OR drug ILIKE '%Tirofiban%'
    OR drug ILIKE '%abciximab%'
    OR drug ILIKE '%aspirin%'
  )
  AND
  head_whole.hadm_id = prescriptions.hadm_id
)
UPDATE head_whole SET antiplate = 1 FROM anti WHERE anti.hadm_id = head_whole.hadm_id;

ALTER TABLE head_whole ADD anticoaguation INT;
UPDATE head_whole SET anticoaguation = 0;
WITH anti AS (
  SELECT DISTINCT prescriptions.hadm_id FROM head_whole, prescriptions WHERE (
    drug ILIKE '%Warfarin%'
	  OR drug ILIKE '%coumadin%'
  )
  AND
  head_whole.hadm_id = prescriptions.hadm_id
)
UPDATE head_whole SET anticoaguation = 1 FROM anti WHERE anti.hadm_id = head_whole.hadm_id;


UPDATE kdigo_head SET weight = inputevents_mv.patientweight 
FROM 
inputevents_mv
WHERE 
kdigo_head.weight IS NULL
AND 
inputevents_mv.icustay_id = kdigo_head.icustay_id;


CREATE TABLE head_only_urine AS (
  SELECT * FROM head_whole WHERE kdigo_7day_admin_uo_stage IS NOT NULL
);

CREATE TABLE head_creatinine AS (
  SELECT labevents.subject_id, labevents.hadm_id, charttime, "valuenum"::NUMERIC 
FROM labevents, head_whole WHERE labevents.hadm_id = head_whole.hadm_id
AND labevents.itemid = 50912 ORDER BY labevents.subject_id, labevents.hadm_id, labevents.charttime
);

CREATE TABLE head_chart_creatinine AS (
  SELECT chartevents.subject_id, chartevents.hadm_id, chartevents.charttime, "valuenum"::NUMERIC
  FROM chartevents, head_whole WHERE chartevents.hadm_id = head_whole.hadm_id
  AND chartevents.itemid IN (1525, 220615) ORDER BY chartevents.subject_id, chartevents.hadm_id, chartevents.charttime
);

CREATE TABLE head_kdigo_chart_creatinine AS (
  SELECT * FROM head_kdigo_creatinine
);

-- ALTER TABLE head_whole ADD kdigo_creat INT;
UPDATE head_whole SET kdigo_stage_7day_creat = NULL;
UPDATE head_whole SET kdigo_stage_7day_creat = head_kdigo_creatinine.stage 
FROM head_kdigo_creatinine WHERE head_whole.hadm_id = head_kdigo_creatinine.hadm_id;
UPDATE head_whole SET kdigo_stage_7day_creat = 0 WHERE kdigo_stage_7day_creat IS NULL;

DELETE FROM head_whole WHERE uo_6hr IS NULL;
DELETE FROM head_whole WHERE uo_12hr IS NULL;
DELETE FROM head_whole WHERE uo_24hr IS NULL;