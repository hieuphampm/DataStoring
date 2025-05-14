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
        return {"status": "success", "message": "Message stored"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@chat.get("/messages")
async def get_messages():
    try:
        message = r.lrange("chat:messages", 0, -1)
        return {"messages": message}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))