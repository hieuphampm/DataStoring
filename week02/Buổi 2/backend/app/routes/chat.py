from fastapi import APIRouter, HTTPException, Request

from pydantic import BaseModel
from connect_redis import r

chat = APIRouter()

class Message(BaseModel):
    user: str
    message: str

@chat.post("/send")
async def send_message(msg: Message):
    try:
        r.rpush("chat:messages", f"{msg.user}: {msg.message}")
    finally:
        r.close()   
