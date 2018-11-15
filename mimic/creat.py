# -*- coding: utf-8 -*-
"""
根据kdigo,rifie等评级标准计算肌酐的评级。
Created on 2018/7/15

@author: will4906
"""
import psycopg2 as psql
from decimal import Decimal


def kdigo(min_value, max_value):
    if min_value > 0:
        if max_value - min_value > Decimal(4) or max_value / min_value >= Decimal(3):
            return 3
        elif Decimal(3) > max_value / min_value > Decimal(2):
            return 2
        elif max_value - min_value > Decimal(0.3) or Decimal(2) > max_value / min_value >= Decimal(1.5):
            return 1
        else:
            return 0
    return None


def rifie(min_value, max_value):
    if min_value > 0:
        if (max_value - min_value) / min_value >= Decimal(2):
            return 3
        elif (max_value - min_value) / min_value >= Decimal(1):
            return 2
        elif (max_value - min_value) / min_value >= Decimal(0.5):
            return 1
        else:
            return 0


if __name__ == '__main__':
    TABLE_NAME = 'head_project'
    conn = psql.connect(database="tmimic", user="postgres", password="1234")
    cursor = conn.cursor()
    try:
        cursor.execute("ALTER TABLE {} ADD stage_kdigo_creat_by_min INT;".format(TABLE_NAME))
        conn.commit()
    except Exception as e:
        conn.rollback()
        cursor.execute("UPDATE {} SET stage_kdigo_creat_by_min = NULL;".format(TABLE_NAME))
        conn.commit()
    try:
        cursor.execute("ALTER TABLE {} ADD stage_rifie_creat_by_min INT;".format(TABLE_NAME))
        conn.commit()
    except Exception as e:
        conn.rollback()
        cursor.execute("UPDATE {} SET stage_rifie_creat_by_min = NULL;".format(TABLE_NAME))
        conn.commit()

    cursor.execute("SELECT hadm_id, age, gender, ethnicity FROM {};".format(TABLE_NAME))
    patients = cursor.fetchall()
    for patient in patients:
        hadm_id = patient[0]
        age = patient[1]
        gender = patient[2]
        ethnicity = patient[3]
        cursor.execute("SELECT MIN(valuenum) FROM {}_creatinine_chart WHERE hadm_id = {};".format(TABLE_NAME, hadm_id))
        min_value = cursor.fetchone()[0]
        if min_value is None:
            continue
        cursor.execute("SELECT MAX(valuenum) FROM {}_creatinine_chart WHERE hadm_id = {};".format(TABLE_NAME, hadm_id))
        max_value = cursor.fetchone()[0]
        if max_value is None:
            continue
        kdigo_stage = kdigo(min_value, max_value)
        rifie_stage = rifie(min_value, max_value)
        print(hadm_id, 'kdigo:', kdigo_stage, 'rifie', rifie_stage)
        cursor.execute("UPDATE {} SET stage_kdigo_creat_by_min = {} WHERE hadm_id = {};".format(TABLE_NAME, kdigo_stage, hadm_id))
        conn.commit()
        cursor.execute("UPDATE {} SET stage_rifie_creat_by_min = {} WHERE hadm_id = {};".format(TABLE_NAME, rifie_stage, hadm_id))
        conn.commit()
