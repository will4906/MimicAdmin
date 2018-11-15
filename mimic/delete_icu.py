# -*- coding: utf-8 -*-
"""
Created on 2018/7/15

@author: will4906
"""
import psycopg2 as psql

if __name__ == '__main__':
    TABLE_NAME = 'head_project'
    conn = psql.connect(database="tmimic", user="postgres", password="1234")
    cursor = conn.cursor()
    cursor.execute('''
    SELECT icustays.icustay_id FROM {}, icustays WHERE {}.icustay_id = icustays.icustay_id AND icustays.outtime - icustays.intime < interval '24' HOUR ;
    '''.format(TABLE_NAME, TABLE_NAME))
    patients = cursor.fetchall()

    for patient in patients:
        # cursor.execute("DELETE FROM {} WHERE icustay_id = {}".format(TABLE_NAME, patient[0]))
        # conn.commit()
        print(patient[0])
    print(len(patients))