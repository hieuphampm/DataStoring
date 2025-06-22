from pymongo import MongoClient
client = MongoClient('mongodb://localhost:27017/')
# client.drop_database('university')
db = client['university']
collection = db['students']

# collection.insert_one(
#     {
#         "name": "Nguyen Van A",
#         "student_id": "S001",
#         "score": 8.5
#     }
# )

# collection.insert_one(
#     {
#         "name": "Tran Van B",
#         "student_id": "S002",
#         "score": 7
#     }
# )

# collection.insert_one(
#     {
#         "name": "Tran Van C",
#         "student_id": "S003",
#         "score": 9
#     }
# )

# collection.insert_one(
#     {
#         "name": "Nguyen Thi D",
#         "student_id": "S004",
#         "score": 4
#     }
# )

for student in collection.find({"score": {"$gte": 8.5}}):
    print(f"Name: {student['name']}, ID: {student['student_id']}, Score: {student['score']}")

collection.update_many(
    {"score": {"$lt": 5}},
    {"$set": {"retake": True}}
)

for student in collection.find():
    print("Students have score < 5")
    print(f"Name: {student['name']}, ID: {student['student_id']}, Score: {student['score']}")

result = collection.delete_many({"retake": True})
print(f"Number of students deleted: {result.deleted_count}")
for student in collection.find():
    print(f"Name: {student['name']}, ID: {student['student_id']}, Score: {student['score']}")