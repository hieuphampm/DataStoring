import json

with open('students.json', 'r', encoding='utf-8') as f:
    students = json.load(f)

print("DS SV:")
for sv in students:
    print(f"- {sv['student_code']}: {sv['full_name']}")
print("Tổng số SV:", len(students))