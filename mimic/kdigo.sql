ALTER TABLE head_project ADD uo_6hr NUMERIC;
ALTER TABLE head_project ADD uo_12hr NUMERIC;
ALTER TABLE head_project ADD uo_24hr NUMERIC;

UPDATE "head_project" SET uo_6hr = NULL;
UPDATE "head_project" SET uo_12hr = NULL;
UPDATE "head_project" SET uo_24hr = NULL;

UPDATE "head_project" SET uo_6hr = head_uo.uo_6hr FROM head_uo WHERE head_uo.icustay_id = "head_project".icustay_id;
UPDATE "head_project" SET uo_12hr = head_uo.uo_12hr FROM head_uo WHERE head_uo.icustay_id = "head_project".icustay_id;
UPDATE "head_project" SET uo_24hr = head_uo.uo_24hr FROM head_uo WHERE head_uo.icustay_id = "head_project".icustay_id;

ALTER TABLE "head_project" ADD stage_rifle_7day_admin_uo INT;
ALTER TABLE "head_project" ADD stage_kdigo_7day_admin_uo INT;
UPDATE "head_project" SET stage_rifle_7day_admin_uo = NULL;
UPDATE "head_project" SET stage_kdigo_7day_admin_uo = NULL;


-- kdigo
WITH urine AS (
  SELECT icustay_id,
  CASE
    WHEN uo_24hr < 0.3 THEN 3
    WHEN uo_12hr = 0 THEN 3
    WHEN uo_12hr < 0.5 THEN 2
    WHEN uo_6hr < 0.5 THEN 1
    WHEN uo_6hr IS NULL THEN NULL
    ELSE 0 END AS AKI_stage_7day_uo
  FROM
  "head_project"
)
UPDATE "head_project" SET stage_kdigo_7day_admin_uo = urine.AKI_stage_7day_uo FROM urine WHERE "head_project".icustay_id = urine.icustay_id;
UPDATE "head_project" SET stage_kdigo_7day_admin_uo = 3 WHERE rrt = 1;
UPDATE "head_project" SET stage_rifle_7day_admin_uo = stage_kdigo_7day_admin_uo;

ALTER TABLE "head_project" ADD stage_kdigo_admin INT;
UPDATE "head_project" SET stage_kdigo_admin = NULL;

WITH temp AS (
  SELECT icustay_id,
    CASE
      WHEN stage_kdigo_creat_admin >= stage_kdigo_7day_admin_uo THEN stage_kdigo_creat_admin
      WHEN stage_kdigo_7day_admin_uo >= stage_kdigo_creat_admin THEN stage_kdigo_7day_admin_uo
      ELSE  coalesce(stage_kdigo_creat_admin, stage_kdigo_7day_admin_uo)
    END AS stage_kdigo_admin
    FROM "head_project"
)
UPDATE "head_project" SET stage_kdigo_admin = temp.stage_kdigo_admin FROM temp WHERE "head_project".icustay_id = temp.icustay_id;
UPDATE "head_project" SET stage_kdigo_admin = 0 WHERE stage_kdigo_creat_admin = 0;
UPDATE "head_project" SET stage_kdigo_admin = 3 WHERE rrt = 1;

ALTER TABLE "head_project" ADD stage_kdigo_admin_origin INT;
UPDATE "head_project" SET stage_kdigo_admin_origin = NULL;
UPDATE "head_project" SET stage_kdigo_admin_origin = stage_kdigo_creat_admin;
UPDATE "head_project" SET stage_kdigo_admin_origin = stage_kdigo_7day_admin_uo
WHERE stage_kdigo_7day_admin_uo IS NOT NULL AND stage_kdigo_7day_admin_uo > stage_kdigo_creat_admin;
UPDATE "head_project" SET stage_kdigo_admin_origin = 3 WHERE rrt = 1;

ALTER TABLE "head_project" ADD has_kdigo INT;
UPDATE "head_project" SET has_kdigo = NULL;
UPDATE "head_project" SET has_kdigo = 1 WHERE stage_kdigo_admin > 0;
UPDATE "head_project" SET has_kdigo = 0 WHERE stage_kdigo_admin = 0;

ALTER TABLE "head_project" ADD has_kdigo_origin INT;
UPDATE "head_project" SET has_kdigo_origin = NULL;
UPDATE "head_project" SET has_kdigo_origin = 1 WHERE stage_kdigo_admin_origin > 0;
UPDATE "head_project" SET has_kdigo_origin = 0 WHERE stage_kdigo_admin_origin = 0;

-- 没有origin和有origin的区别，
-- 没有：是当肌酐值为0的时候，将置为0
-- 有：  忽略肌酐值为0而尿输出不为0的情况.

-- rifle
UPDATE "head_project" SET rifle_stage_7day_admin = NULL;
UPDATE "head_project" SET rifle_stage_7day_admin = rifle_stage_7day_admin_creat;
UPDATE "head_project" SET rifle_stage_7day_admin = rifle_stage_7day_admin_uo WHERE rifle_stage_7day_admin_uo IS NOT NULL
AND rifle_stage_7day_admin_uo > rifle_stage_7day_admin;
UPDATE "head_project" SET rifle_stage_7day_admin = 0 WHERE rifle_stage_7day_admin_creat = 0;

UPDATE "head_project" SET rifle_stage_7day_admin_origin = NULL;
UPDATE "head_project" SET rifle_stage_7day_admin_origin = rifle_stage_7day_admin_creat;
UPDATE "head_project" SET rifle_stage_7day_admin_origin = rifle_stage_7day_admin_uo WHERE rifle_stage_7day_admin_uo IS NOT NULL
AND rifle_stage_7day_admin_uo > rifle_stage_7day_admin;


UPDATE "head_project" SET akin_stage_48hr_admin_uo = NULL;
-- akin
WITH urine AS (
  SELECT icustay_id,
  CASE
    WHEN uo_24hr < 0.3 THEN 3
    WHEN uo_12hr = 0 THEN 3
    WHEN uo_12hr < 0.5 THEN 2
    WHEN uo_6hr < 0.5 THEN 1
    WHEN uo_6hr IS NULL THEN NULL
    ELSE 0 END AS AKI_stage_2day_uo
  FROM
  head_uo_48hr
)
UPDATE "head_project" SET akin_stage_48hr_admin_uo = urine.AKI_stage_2day_uo FROM urine WHERE "head_project".icustay_id = urine.icustay_id;
UPDATE "head_project" SET akin_stage_48hr_admin_uo = 3 WHERE rrt = 1;

UPDATE "head_project" SET akin_stage_48hr_admin_origin = NULL;
UPDATE "head_project" SET akin_stage_48hr_admin_origin = akin_stage_48hr_admin_creat;
UPDATE "head_project" SET akin_stage_48hr_admin_origin = akin_stage_48hr_admin_uo where akin_stage_48hr_admin_uo is not null and
akin_stage_48hr_admin_uo > akin_stage_48hr_admin_creat;

UPDATE "head_project" SET akin_stage_48hr_admin = NULL;
UPDATE "head_project" SET akin_stage_48hr_admin = akin_stage_48hr_admin_origin;
UPDATE "head_project" SET akin_stage_48hr_admin = 0 WHERE akin_stage_48hr_admin_creat = 0;




-- mimic code
ALTER TABLE "head_project" ADD kdigo_7day_old INT;
UPDATE "head_project" SET kdigo_7day_old = kdigo_stages_7day.aki_stage_7day
FROM kdigo_stages_7day WHERE "head_project".icustay_id = kdigo_stages_7day.icustay_id;