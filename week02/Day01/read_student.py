import json

with open('student.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

print("Thông tin SV:")
print("MSSV:", data.get("student_code"))
print("Họ tên:", data.get("full_name"))
print("Birth:", data.get("date_of_birth"))
print("Gender:", data.get("gender"))
print("Major:", data.get("major"))
print("GPA:", data.get("gpa"))