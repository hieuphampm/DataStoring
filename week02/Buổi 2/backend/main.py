from fastapi import FastAPI
from app.routes.chat import chat

app = FastAPI()
app.include_router(chat)