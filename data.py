import psycopg2

#establishing the connection
conn = psycopg2.connect(
   database="WoodenDoor", user='postgres', password='erfan1381', host='127.0.0.1', port= '5432'
)
#Creating a cursor object using the cursor() method
cursor = conn.cursor()

#Executing an MYSQL function using the execute() method
cursor.execute("select * from user_feild")

# Fetch a single row using fetchone() method.
data = cursor.fetchall()
print("Connection established to: ",data, type(data))

#Closing the connection
conn.close()

import json
data = list(data)
#data[2] = str(data[2])
#r = json.dumps(data)
print(data)
# Connection established to: (
#    'PostgreSQL 11.5, compiled by Visual C++ build 1914, 64-bit',
# )