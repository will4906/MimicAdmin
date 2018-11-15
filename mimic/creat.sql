WITH 


ALTER TABLE head_project ADD creatinine_min_7day NUMERIC;
ALTER TABLE head_project ADD creatinine_base NUMERIC;

WITH temp AS (
    SELECT hadm_id, MIN(valuenum) AS valuenum FROM head_project_creatinine_chart GROUP BY hadm_id
)
UPDATE head_project SET creatinine_min_7day = temp.valuenum FROM temp
WHERE head_project.hadm_id = temp.hadm_id;

