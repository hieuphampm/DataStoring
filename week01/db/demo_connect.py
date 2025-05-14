import pymysql
import pymysql.cursors

connection = pymysql.connect(
    host="34.27.117.213",
    user="root",
    password="123456789",
    db="db1477",
    charset="utf8mb4",
    cursorclass=pymysql.cursors.DictCursor
)

try:
    with connection.cursor() as cursor:
        cursor.execute("""
                       select * from students;
                       """)
        result = cursor.fetchall()
        for row in result:
            print(row)
except pymysql.MySQLError as e:
    print(f"An error occurred: {e}")
finally:
    connection.close()