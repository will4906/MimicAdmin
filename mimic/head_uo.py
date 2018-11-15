# -*- coding: utf-8 -*-
"""
Created on 2018/2/28

@author: will4906
"""
from datetime import datetime, timedelta

import numpy as np
import psycopg2 as psql

TABLE_NAME = 'head_project'
conn = psql.connect(database="tmimic", user="postgres", password="1234")
cursor = conn.cursor()
cursor.execute(
    '''
    DROP TABLE IF EXISTS head_uo CASCADE;
    CREATE TABLE head_uo (
        icustay_id INT,
        uo_6hr NUMERIC,
        uo_12hr NUMERIC,
        uo_24hr NUMERIC
    );
    '''
)
conn.commit()
cursor.execute(
    '''
    DROP TABLE IF EXISTS kdigo_head CASCADE;
    CREATE TABLE kdigo_head AS (
        SELECT kdigo_uo.* FROM kdigo_uo
    );
    '''
)
cursor.execute(
    '''
    SELECT icustays.icustay_id, icustays.intime, icustays.outtime FROM icustays, "{}" AS head_whole WHERE head_whole.icustay_id = icustays.icustay_id;
    '''.format(TABLE_NAME)
)
#     
icu_info_list = cursor.fetchall()
for icu_info in icu_info_list:
    icustay_id = icu_info[0]
    if icu_info[1].minute < 10:
        intime = datetime(icu_info[1].year, icu_info[1].month, icu_info[1].day, icu_info[1].hour)
    else:
        intime_temp = icu_info[1] + timedelta(hours=1)
        intime = datetime(intime_temp.year, intime_temp.month, intime_temp.day, intime_temp.hour)
    if icu_info[2] is None:
        continue
    outtime = datetime(icu_info[2].year, icu_info[2].month, icu_info[2].day, icu_info[2].hour)
    print(intime, outtime)

    cursor.execute(
        "SELECT * FROM kdigo_head WHERE icustay_id = %s;", (icustay_id, )
    )
    kdigo_list = cursor.fetchall()
    min_6 = 1000000
    min_12 = 1000000
    min_24 = 1000000
    hour_6_list = []
    hour_12_list = []
    hour_24_list = []
    for kdigo in kdigo_list:

        if kdigo[1] + timedelta(hours=6) <= outtime:
            if kdigo[2] is not None and kdigo[3] is not None:
                uo_6hr = kdigo[3] / kdigo[2] / 6
                if min_6 > uo_6hr:
                    min_6 = uo_6hr
        if kdigo[1] + timedelta(hours=12) <= outtime:
            if kdigo[2] is not None and kdigo[4] is not None:
                uo_12hr = kdigo[4] / kdigo[2] / 12
                if min_12 > uo_12hr:
                    print(kdigo)
                    min_12 = uo_12hr
        if kdigo[1] + timedelta(hours=24) <= outtime:
            if kdigo[2] is not None and kdigo[5] is not None:
                uo_24hr = kdigo[5] / kdigo[2] / 24
                if min_24 > uo_24hr:
                    min_24 = uo_24hr

    cursor.execute(
        "INSERT INTO head_uo(icustay_id) VALUES (%s);", (icustay_id,)
    )
    conn.commit()

    if min_6 != 1000000:
        cursor.execute(
            "UPDATE head_uo SET uo_6hr = %s WHERE icustay_id = %s;", (min_6, icustay_id)
        )
        conn.commit()

    if min_12 != 1000000:
        cursor.execute(
            "UPDATE head_uo SET uo_12hr = %s WHERE icustay_id = %s;", (min_12, icustay_id)
        )
        conn.commit()

    if min_24 != 1000000:
        cursor.execute(
            "UPDATE head_uo SET uo_24hr = %s WHERE icustay_id = %s;", (min_24, icustay_id)
        )
        conn.commit()
    elif len(kdigo_list) > 0:
        kdigo = kdigo_list[0]
        if kdigo[2] is not None and kdigo[5] is not None:
            uo_24hr = kdigo[5] / kdigo[2] / 24
            cursor.execute(
                "UPDATE head_uo SET uo_24hr = %s WHERE icustay_id = %s;", (uo_24hr, icustay_id)
            )
            conn.commit()
