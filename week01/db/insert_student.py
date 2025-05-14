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
                       INSERT INTO students (student_code, full_name, date_of_birth, gender)
                       VALUES ('SV001', 'Nguyen Van A', '2000-01-01', 'Male'),
                              ('SV002', 'Nguyen Van B', '2000-02-02', 'Female')
                       """)
        connection.commit()
        print("Inserted successfully")
except pymysql.MySQLError as e:
    print(f"An error occurred: {e}")
finally:
    connection.close()