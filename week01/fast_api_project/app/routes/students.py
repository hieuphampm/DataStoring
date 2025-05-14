from fastapi import APIRouter, HTTPException
import pymysql
from pydantic import BaseModel
from datetime import date

router = APIRouter()

# Pydantic model for student data validation
class StudentCreate(BaseModel):
    student_code: str
    full_name: str
    date_of_birth: date
    gender: str = "Other"

class StudentUpdate(BaseModel):
    full_name: str | None = None
    date_of_birth: date | None = None
    gender: str | None = None


def get_connection():
    return pymysql.connect(
        host="34.27.117.213",
        user="root",
        password="123456789",
        db="db1477",
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor
    )

# GET all students
@router.get("/student")
def get_student():
    con = None
    try:
        con = get_connection()
        with con.cursor() as cursor:
            cursor.execute("SELECT * FROM students")
            results = cursor.fetchall()
            return results
    finally:
        if con:
            con.close()

# GET single student by ID
@router.get("/student/{student_id}")
def get_student_by_id(student_id: int):
    con = None
    try:
        con = get_connection()
        with con.cursor() as cursor:
            cursor.execute("SELECT * FROM students WHERE id = %s", (student_id,))
            result = cursor.fetchone()
            if not result:
                raise HTTPException(status_code=404, detail="Student not found")
            return result
    finally:
        if con:
            con.close()

# POST create new student
@router.post("/student")
def create_student(student: StudentCreate):
    con = None
    try:
        con = get_connection()
        with con.cursor() as cursor:
            # Check if student_code already exists
            cursor.execute("SELECT id FROM students WHERE student_code = %s", (student.student_code,))
            if cursor.fetchone():
                raise HTTPException(status_code=400, detail="Student code already exists")
            
            sql = """
                INSERT INTO students (student_code, full_name, date_of_birth, gender)
                VALUES (%s, %s, %s, %s)
            """
            cursor.execute(sql, (
                student.student_code,
                student.full_name,
                student.date_of_birth,
                student.gender
            ))
            con.commit()
            return {"message": "Student created successfully", "student_code": student.student_code}
    finally:
        if con:
            con.close()

# PUT update student
@router.put("/student/{student_id}")
def update_student(student_id: int, student: StudentUpdate):
    con = None
    try:
        con = get_connection()
        with con.cursor() as cursor:
            # Check if student exists
            cursor.execute("SELECT id FROM students WHERE id = %s", (student_id,))
            if not cursor.fetchone():
                raise HTTPException(status_code=404, detail="Student not found")
            
            # Define allowed fields and their corresponding values
            fields = {
                'full_name': student.full_name,
                'date_of_birth': student.date_of_birth,
                'gender': student.gender
            }
            
            # Filter out None values and build update query
            updates = {k: v for k, v in fields.items() if v is not None}
            if not updates:
                raise HTTPException(status_code=400, detail="No fields to update")
            
            # Construct parameterized query
            set_clause = ", ".join(f"{key} = %s" for key in updates.keys())
            sql = f"UPDATE students SET {set_clause} WHERE id = %s"
            
            # Execute with values in correct order
            values = list(updates.values()) + [student_id]
            cursor.execute(sql, values)
            
            # Check if any rows were affected
            if cursor.rowcount == 0:
                raise HTTPException(status_code=400, detail="No changes made to student data")
            
            con.commit()
            return {"message": "Student updated successfully"}
    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        if con:
            con.close()

# DELETE student
@router.delete("/student/{student_id}")
def delete_student(student_id: int):
    con = None
    try:
        con = get_connection()
        with con.cursor() as cursor:
            # Check if student exists
            cursor.execute("SELECT id FROM students WHERE id = %s", (student_id,))
            if not cursor.fetchone():
                raise HTTPException(status_code=404, detail="Student not found")
            
            cursor.execute("DELETE FROM students WHERE id = %s", (student_id,))
            con.commit()
            return {"message": "Student deleted successfully"}
    finally:
        if con:
            con.close()