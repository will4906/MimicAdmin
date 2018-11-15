# -*- coding: utf-8 -*-
"""
Created on 2018/3/22

@author: will4906

kdigo评级
现在的做法是

baseline计算公式： (75 * 1.73 + 1.154 * age + 0.203 * (0.742 if female) * (1.210 if black)) / 186

| 1 | 48小时内，1.5–1.9 times baseline OR >= 0.3 mg/dl (>=26.5 mmol/l) increase |
| 2 | 7天内，2.0–2.9 times baseline
| 3 | 7天内， 3.0 times baseline OR Increase in serum creatinine to >= 4.0 mg/dl (>=353.6 mmol/l) OR CRRT

时间为滚动时间窗，基线值为时间窗第一个值，不应为最小值，因为有可能下降。

单位问题，labevents记录全为mg/dl可放心
"""
from datetime import timedelta

import psycopg2 as psql
from decimal import Decimal


table_name = 'head_project'

conn = psql.connect(database="tmimic", user="postgres", password="1234")
cursor = conn.cursor()

cursor.execute("SELECT hadm_id, age, gender, ethnicity FROM " + table_name)
patients = cursor.fetchall()
for patient in patients:
    baseline = (75 * 1.73 + 1.154 * patient[1] + 0.203 * (0.742 * 1 if str(patient[2]) * (1.210 if black)) / 186
    cursor.execute("SELECT * FROM " + table_name + "_creatinine_chart WHERE hadm_id = " + str(patient[0]) + " ORDER BY charttime;")
    creatinines = cursor.fetchall()
    for c in creatinines:
        print(c)
