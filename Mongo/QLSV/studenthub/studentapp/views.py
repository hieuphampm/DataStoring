from bson import ObjectId
from django.shortcuts import redirect, render
from django.conf import settings
from studentapp.utlis import get_mongo_collection 

def home(request):
    return render(request, 'home.html')

def studentlist(request):
    mongo_db = settings.MONGO_DB_NAME
    collection = get_mongo_collection(mongo_db, 'students')  
    students = list(collection.find())
    return render(request, 'student/studentlist.html', {'students': students})

def student_delete(request):
    student_id = request.POST.get('student_id')
    mongo_db = settings.MONGO_DB_NAME
    collection = get_mongo_collection(mongo_db, 'students')
    collection.delete_one({'student_id': student_id}) 
    return redirect('studentlist')