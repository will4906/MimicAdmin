# -*- coding: utf-8 -*-
"""
Created on 2017/3/19

@author: will4906
"""
import datetime
import sys

import psycopg2 as psql

# 数据库连接参数
conn = psql.connect(database="tmimic", user="postgres", password="1234")
cur = conn.cursor()
table_name = sys.argv[1]
cur.execute(
    '''
    SELECT labevents.hadm_id, labevents.itemid, labevents.charttime, labevents."value" 
    FROM labevents, %s 
    WHERE itemid IN (50821, 50816) AND labevents.hadm_id = %s.hadm_id
    ''' % (table_name, table_name)
)
pao2_list = []
fio2_list = []
all_list = cur.fetchall()
for row in all_list:
    if row[1] == 50821:
        pao2_list.append(row)
    elif row[1] == 50816:
        fio2_list.append(row)

cur.execute(
    '''
    SELECT stg_fio2.hadm_id, stg_fio2.charttime, stg_fio2.fio2_chartevents FROM stg_fio2, %s WHERE stg_fio2.hadm_id = %s.hadm_id
    ''' % (table_name, table_name)
)
fio2_chartevent_list = []
stg_list = cur.fetchall()
for stg in stg_list:
    fio2_chartevent_list.append(stg)

cur.execute(
    '''
    SELECT hadm_id FROM %s;
    ''' % table_name
)


def get_the_value_list(target_list, hadm_id):
    info_list = []
    for target in target_list:
        if target[0] == hadm_id:
            info_list.append(target)
    return info_list


def get_chart_value_list(target_list, hadm_id):
    info_list = []
    for target in target_list:
        if target[0] == hadm_id:
            info_list.append(target)
    return info_list


def get_a_time_fio2(fio2s, fio2_chars, hour):
    f1_list = []
    f2_list = []

    for f1 in fio2s:
        if (f1[2] - hour) < datetime.timedelta(hours=2):
            if f1[3] is not None and f1[3] != '':
                f1_list.append(f1[3])
    for f2 in fio2_chars:
        if (f2[1] - hour) < datetime.timedelta(hours=2):
            if f2[2] is not None and f2[2] != '':
                f2_list.append(f2[2])

    len_f1 = len(f1_list)
    len_f2 = len(f2_list)
    if len_f1 > 0 and len_f2 > 0:
        if max(f1_list) is None and max(f2_list) is None:
            return None
        elif max(f1_list) is None and max(f2_list) is not None:
            return max(f1_list)
        elif max(f1_list) is not None and max(f2_list) is None:
            return max(f2_list)
        else:
            if float(max(f1_list)) > float(max(f2_list)):
                return float(max(f1_list))
            else:
                return float(max(f2_list))
    elif len_f1 > 0 and len_f2 <= 0:
        return float(max(f1_list))
    elif len_f1 <= 0 and len_f2 > 0:
        return float(max(f2_list))
    else:
        return None


ards_list = cur.fetchall()
pao2_fio2_list = []

for ards in ards_list:
    pao2s = get_the_value_list(pao2_list, ards[0])
    fio2s = get_the_value_list(fio2_list, ards[0])
    fio2_chars = get_chart_value_list(fio2_chartevent_list, ards[0])

    result_list = []
    for p in pao2s:
        if p[3] is not None and p[3] != '':
            try:
                max_fio2 = get_a_time_fio2(fio2s, fio2_chars, p[2])
                if max_fio2 is not None:
                    result = float(p[3]) * 100 / float(max_fio2)
                    result_list.append(result)
            except:
                print(p)

    if len(result_list) > 0:
        pao2_fio2_list.append((ards[0], min(result_list)))

for pf in pao2_fio2_list:
    print('''
        UPDATE ards_whole SET pao2fio2 = %s WHERE hadm_id = %s;
        '''% (pf[1], pf[0]))
    cur.execute(
        '''
        UPDATE %s SET pao2fio2 = %s WHERE hadm_id = %s;
        '''% (table_name, pf[1], pf[0])
    )
    conn.commit()
conn.close()

# 4yue9 4:45