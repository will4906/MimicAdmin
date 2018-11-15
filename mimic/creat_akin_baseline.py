# -*- coding: utf-8 -*-
"""
根据kdigo等评级标准计算肌酐的评级。
Created on 2018/7/15

@author: will4906
"""
import psycopg2 as psql
from decimal import Decimal


def akin(min_value, max_value):
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


if __name__ == '__main__':
    TABLE_NAME = 'head_project'
    STANDARD = 'akin'
    conn = psql.connect(database="tmimic", user="postgres", password="1234")
    cursor = conn.cursor()
    try:
        cursor.execute("ALTER TABLE {} ADD stage_{}_creat_by_base INT;".format(TABLE_NAME, STANDARD))
        conn.commit()
    except Exception as e:
        conn.rollback()
        cursor.execute("UPDATE {} SET stage_{}_creat_by_base = NULL;".format(TABLE_NAME, STANDARD))
        conn.commit()

    cursor.execute("SELECT hadm_id, age, gender, ethnicity FROM {};".format(TABLE_NAME))
    patients = cursor.fetchall()
    for patient in patients:
        hadm_id = patient[0]
        age = patient[1]
        gender = int(patient[2]) # 0：female, 1: male
        ethnicity = int(patient[3])
        print(hadm_id, age, gender, ethnicity)
        # cursor.execute("SELECT MIN(valuenum) FROM {}_creatinine_chart WHERE hadm_id = {};".format(TABLE_NAME, hadm_id))
        # min_value = cursor.fetchone()[0]
        # Baseline is (75 * 1.73 + 1.154 * age + 0.203 * (0.742 if female) * (1.210 if black)) / 186
        temp1 = 0.742 if gender == 0 else 1
        temp2 = 1.210 if ethnicity == 2 else 1
        min_value = (Decimal(75) * Decimal(1.73) + Decimal(1.154) * age + Decimal(0.203) * Decimal(temp1) * Decimal(temp2)) / Decimal(186)
        if min_value is None:
            continue
        cursor.execute("SELECT MAX(valuenum) FROM {}_creatinine_chart_2d WHERE hadm_id = {};".format(TABLE_NAME, hadm_id))
        max_value = cursor.fetchone()[0]
        if max_value is None:
            continue
        
        if STANDARD == 'akin':
            stage = akin(min_value, max_value)
        elif STANDARD == 'rifie':
            stage = rifie(min_value, max_value)
        else:
            pass
        # print(hadm_id, 'kdigo:', kdigo_stage)
        print(hadm_id, STANDARD, stage)
        cursor.execute("UPDATE {} SET stage_{}_creat_by_base = {} WHERE hadm_id = {};".format(TABLE_NAME, STANDARD, stage, hadm_id))
        conn.commit()

