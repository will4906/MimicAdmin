UPDATE kdigo_uo SET weight = heightweight.weight_first FROM heightweight WHERE kdigo_uo.weight IS NULL
AND kdigo_uo.icustay_id = heightweight.icustay_id;

UPDATE kdigo_uo SET weight = (
    CASE patients.gender
    WHEN 'M' THEN 50 + 0.91 * (heightweight.height_first - 152.4)
    WHEN 'F' THEN 45.5 + 0.91 * (heightweight.height_first - 152.4) END
) 
FROM patients, heightweight, icustays
WHERE 
kdigo_uo.icustay_id = icustays.icustay_id
AND icustays.subject_id = patients.subject_id
AND icustays.subject_id = heightweight.subject_id
AND kdigo_uo.weight IS NULL;

UPDATE kdigo_uo SET weight = heightweight.weight_first FROM heightweight, icustays
WHERE 
kdigo_uo.weight IS NULL
AND kdigo_uo.icustay_id = icustays.icustay_id
AND heightweight.subject_id = icustays.subject_id;

UPDATE kdigo_uo SET weight = NULL WHERE weight = 0;