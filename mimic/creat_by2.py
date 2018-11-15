from datetime import timedelta

import psycopg2 as psql
from decimal import Decimal


TABLE_NAME = 'head_project'


def kdigo(min_value, max_list):
    stage = {
        '0': 0,
        '1': 0,
        '2': 0,
        '3': 0,
    }
    for max_value in max_list:
        if min_value > 0:
            if max_value - min_value > Decimal(4) or max_value / min_value >= Decimal(3):
                stage['3'] = stage['3'] + 1
            elif Decimal(3) > max_value / min_value > Decimal(2):
                stage['2'] = stage['2'] + 1
            elif max_value - min_value > Decimal(0.3) or Decimal(2) > max_value / min_value >= Decimal(1.5):
                stage['1'] = stage['1'] + 1
            else:
                stage['0'] = stage['0'] + 1
        else:
            if max_value - min_value > Decimal(4):
                stage['3'] = stage['3'] + 1
            elif max_value - min_value > Decimal(0.3):
                stage['1'] = stage['1'] + 1
            else:
                stage['0'] = stage['0'] + 1
    if stage.get('3') > 0:
        return 3
    elif stage.get('2') > 0:
        return 2
    elif stage.get('0') > 0:
        return 1
    else:
        return 0

def rifie(min_value, max_list):
    stage = {
        '0': 0,
        '1': 0,
        '2': 0,
        '3': 0,
    }
    for max_value in max_list:
        if min_value > 0:
            if (max_value - min_value) / min_value >= Decimal(2):
                stage['3'] = stage['3'] + 1
            elif (max_value - min_value) / min_value >= Decimal(1):
                stage['2'] = stage['2'] + 1
            elif (max_value - min_value) / min_value >= Decimal(0.5):
                stage['1'] = stage['1'] + 1
            else:
                stage['0'] = stage['0'] + 1
    for (key, value) in stage.items():
        if stage.get(key) >= 2:
            return key
    print(stage)
    return 

        
            
            
conn = psql.connect(database="tmimic", user="postgres", password="1234")
cursor = conn.cursor()

# 最小值，最大值
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
    cursor.execute(
        "SELECT valuenum FROM {}_creatinine_chart WHERE hadm_id = {} ORDER BY valuenum DESC LIMIT 2;".format(TABLE_NAME, hadm_id)
    )
    temp_max_list = cursor.fetchall()
    max_list = []
    for temp in temp_max_list:
        max_list.append(temp[0])
    # print(max_list)

    if len(max_list) >= 2:
        # print('Jinlaile')
        kdigo_stage = kdigo(min_value, max_list)
        rifie_stage = rifie(min_value, max_list)
        print(hadm_id, kdigo_stage, rifie_stage)

        # cursor.execute('UPDATE {} SET stage_kdigo_creat_min = {} WHERE hadm_id = {}'.format(TABLE_NAME, stage, hadm_id))
        # conn.commit()