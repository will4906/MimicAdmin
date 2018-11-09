-- bun_admin
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
UPDATE head_project SET bun_admin = cr_temp.creat FROM cr_temp where head_project.icustay_id = cr_temp.icustay_id
                                                                 AND cr_temp.rn_first = 1;
-- albumin_admin
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
UPDATE head_project SET albumin_admin = cr_temp.creat FROM cr_temp where head_project.icustay_id = cr_temp.icustay_id
                                                                     AND cr_temp.rn_first = 1;
-- coronary_artery
WITH hello AS (
    SELECT * FROM ccs_single_level_dx WHERE ccs_name ILIKE '%Coronary%'
)
  , hello1 AS (
    SELECT diagnoses_icd.* FROM hello,head_project, diagnoses_icd WHERE head_project.hadm_id = diagnoses_icd.hadm_id
                                                                      AND diagnoses_icd.icd9_code = hello.icd9_code
)
UPDATE head_project SET coronary_artery_flag = 1 FROM hello1 WHERE head_project.hadm_id = hello1.hadm_id;
UPDATE head_project SET coronary_artery_flag = 0 WHERE coronary_artery_flag IS NULL;