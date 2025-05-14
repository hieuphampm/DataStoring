from fastapi import FastAPI
from app.routes.hello import router as hello
from app.routes.students import router as students

app = FastAPI()
app.include_router(hello)
app.include_router(students)