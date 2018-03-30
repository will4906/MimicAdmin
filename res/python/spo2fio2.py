# -*- coding: utf-8 -*-
"""
Created on 2018/3/20

@author: will4906
"""
from datetime import timedelta

import psycopg2 as psql
import sys


# 数据库连接参数
conn = psql.connect(database="tmimic", user="postgres", password="1234")
cursor = conn.cursor()

table_name = sys.argv[1]
# cursor.execute(
#     '''
#     DROP TABLE IF EXISTS temp_spo2 CASCADE;
#     CREATE TABLE temp_spo2 AS (
#         SELECT chartevents.* FROM %s, chartevents WHERE %s.hadm_id = chartevents.hadm_id AND itemid IN (646,220277) AND valuenum >= 0 AND valuenum <= 100
#     );
#     ''' % (table_name, table_name)
# )
# conn.commit()
# cursor.execute(
#     '''
#     DROP TABLE IF EXISTS temp_spo2fio2 CASCADE;
#     CREATE TABLE temp_spo2fio2 (
#         hadm_id INT4,
#         value NUMERIC
#     );
#     '''
# )
# conn.commit()
cursor.execute(
    '''
    SELECT labevents.subject_id, labevents.hadm_id, labevents.charttime, labevents.valuenum as fio2
    FROM labevents, %s
    WHERE itemid = 50816 AND labevents.hadm_id = %s.hadm_id
    AND labevents.valuenum >= 21 AND labevents.valuenum <= 100;
    ''' % (table_name, table_name)
)

fio2_list = cursor.fetchall()

for fio2 in fio2_list:
    fio2_charttime = fio2[2]
    start_time = fio2_charttime - timedelta(days=2)
    end_time = fio2_charttime + timedelta(days=2)
    cursor.execute("SELECT MIN(value) FROM temp_spo2 WHERE hadm_id = %s AND charttime <= %s AND charttime >= %s;" , (fio2[1], end_time, start_time))
    try:
        spo2_fio2 = float(cursor.fetchone()[0]) / float(fio2[-1])
        cursor.execute("INSERT INTO temp_spo2fio2 VALUES (%s, %s)" , (fio2[1], spo2_fio2))
        print(fio2[1], spo2_fio2)
    except:
        print('None')
    conn.commit()
cursor.execute(
    '''
    DELETE FROM temp_spo2fio2 WHERE value = 0;
    WITH temp AS (
        SELECT hadm_id, MIN(value) AS value FROM temp_spo2fio2 GROUP BY hadm_id
    )
    UPDATE %s SET spo2fio2 = temp.value * 100 FROM temp WHERE temp.hadm_id = %s.hadm_id;
    ''' % (table_name, table_name)
)
conn.commit()
conn.close()