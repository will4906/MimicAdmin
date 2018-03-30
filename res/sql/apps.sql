WITH apps_temp AS (
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
      {{ project_name }}
)
UPDATE {{ project_name }} SET apps = (hello.age_score + hello.p_score + hello.pp_score)
FROM
  hello
WHERE ards_whole.hadm_id = hello.hadm_id
      AND
      peep >= 10 AND pfio2 >= 50;