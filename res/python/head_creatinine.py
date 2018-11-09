# -*- coding: utf-8 -*-
"""
Created on 2018/3/22

@author: will4906

现在的做法是

| 1 | 48小时内，1.5–1.9 times baseline OR >= 0.3 mg/dl (>=26.5 mmol/l) increase |
| 2 | 7天内，2.0–2.9 times baseline
| 3 | 7天内， 3.0 times baseline OR Increase in serum creatinine to >= 4.0 mg/dl (>=353.6 mmol/l) OR CRRT

时间为滚动时间窗，基线值为时间窗第一个值，不应为最小值，因为有可能下降。

单位问题，labevents记录全为mg/dl可放心
"""
from datetime import timedelta

import psycopg2 as psql
from decimal import Decimal


table_name = 'head_demo'


def analysis(group):
    if len(group) == 0:
        return None

    g_type = 0
    start_charttime = None
    start_value = None
    end_charttime = None
    end_value = None
    for i1, g1 in enumerate(group):
        start_time = g1[2]
        end_time_2_day = start_time + timedelta(days=2)
        end_time_7_day = start_time + timedelta(days=7)
        for i2 in range(i1 + 1, len(group)):
            if group[i2][2] < end_time_2_day:
                if group[i2][-1] - g1[-1] > Decimal(0.3) or Decimal(2) > group[i2][-1] / g1[-1] >= Decimal(1.5):
                    if g_type < 1:
                        g_type = 1
                        start_charttime, start_value, end_charttime, end_value = start_time, g1[-1], group[i2][2], group[i2][-1]
            if group[i2][2] < end_time_7_day:
                if Decimal(3) > group[i2][-1] / g1[-1] > Decimal(2):
                    if g_type < 2:
                        g_type = 2
                        start_charttime, start_value, end_charttime, end_value = start_time, g1[-1], group[i2][2], group[i2][-1]
                if group[i2][-1] - g1[-1] > Decimal(4) or group[i2][-1] / g1[-1] >= Decimal(3):
                    if g_type < 3:
                        g_type = 3
                        start_charttime, start_value, end_charttime, end_value = start_time, g1[-1], group[i2][2], group[i2][-1]
                        break
    cursor.execute("SELECT MAX(rrt) FROM rrt WHERE hadm_id = %s" % (group[0][1],))
    rrt = cursor.fetchone()[0]
    if rrt == 1:
        return group[0][1], 3, start_charttime, start_value, end_charttime, end_value, rrt, g_type
    else:
        return group[0][1], g_type, start_charttime, start_value, end_charttime, end_value, rrt, g_type


conn = psql.connect(database="tmimic", user="postgres", password="1234")
cursor = conn.cursor()

cursor.execute("DROP TABLE IF EXISTS " + table_name + "_kdigo_creatinine CASCADE;")
cursor.execute("CREATE TABLE " + table_name + "_kdigo_creatinine (HADM_ID INT NOT NULL, stage INT, start_time timestamp, start_value NUMERIC, end_time timestamp, end_value NUMERIC, rrt INT, no_rrt_stage INT)")
cursor.execute("SELECT * FROM " + table_name + "_creatinine_chart ORDER BY subject_id, hadm_id, charttime;")

creatinines = cursor.fetchall()

last_id = 0
group = []
for c in creatinines:
    is_new = False
    if last_id != c[1]:
        is_new = True
    # (79808, 186485, datetime.datetime(2196, 2, 9, 12, 0), Decimal('0.6'))
    if is_new:
        result = analysis(group)
        if result is not None:
            cursor.execute(
                "INSERT INTO " + table_name + "_kdigo_creatinine(hadm_id, stage, start_time, start_value, end_time, end_value, rrt, no_rrt_stage) VALUES (%s, %s, %s, %s, %s, %s, %s, %s);",
                result
            )
            conn.commit()
        group = []
    group.append(c)
    last_id = c[1]