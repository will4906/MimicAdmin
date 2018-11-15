import psycopg2 as psql
from decimal import Decimal

TABLE_NAME = 'head_project'

conn = psql.connect(database="tmimic", user="postgres", password="1234")
cursor = conn.cursor()

cursor.execute('SELECT valuenum FROM {}_creatinine_chart WHERE hadm_id = 144958;'.format(TABLE_NAME))
temp_values = cursor.fetchall()
values = []
for tv in temp_values:
    values.append(tv[0])
print(values)