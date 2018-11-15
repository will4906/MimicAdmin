from datetime import timedelta

import csv
import psycopg2 as psql
from decimal import Decimal


if __name__ == '__main__':
    TABLE_NAME = 'head_project'
    STANDARD = 'kdigo'
    conn = psql.connect(database="tmimic", user="postgres", password="1234")
    cursor = conn.cursor()

    cursor.execute("SELECT hadm_id, age, gender, ethnicity FROM {};".format(TABLE_NAME))
    patients = cursor.fetchall()
    for patient in patients:
        hadm_id = patient[0]
        age = patient[1]
        gender = int(patient[2]) # 0：female, 1: male
        ethnicity = int(patient[3])
        # cursor.execute("SELECT MIN(valuenum) FROM {}_creatinine_chart WHERE hadm_id = {};".format(TABLE_NAME, hadm_id))
        # min_value = cursor.fetchone()[0]
        # Baseline is (75 * 1.73 + 1.154 * age + 0.203 * (0.742 if female) * (1.210 if black)) / 186
        temp1 = 0.742 if gender == 0 else 1
        temp2 = 1.210 if ethnicity == 2 else 1
        # 基线值
        base_value = (Decimal(75) * Decimal(1.73) + Decimal(1.154) * age + Decimal(0.203) * Decimal(temp1) * Decimal(temp2)) / Decimal(186)

        cursor.execute(
            "UPDATE head_project SET creatinine_base = {} WHERE hadm_id = {};".format(base_value, hadm_id)
        )
        conn.commit()
