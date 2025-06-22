from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel
from connect_redis import r
import json
from datetime import datetime

chat = APIRouter()

class Message(BaseModel):
    user: str
    message: str

@chat.post("/messages")
async def send_message(msg: Message, room: str = Query(...)):
    key = f"chat:room:{room}"
    try:
        message_data = {
            "user": msg.user,
            "message": msg.message,
            "timestamp": datetime.utcnow().isoformat() + "Z"
        }
        r.rpush(key, json.dumps(message_data))
        r.expire(key, 3600)  # Set TTL to 1 hour
        if r.llen(key) > 100:
            r.ltrim(key, -100, -1)
        return {"status": "success", "message": "Message stored"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@chat.get("/messages")
async def get_messages(room: str = Query(...)):
    key = f"chat:room:{room}"
    try:
        messages = r.lrange(key, 0, -1)
        return {"messages": [json.loads(msg) for msg in messages]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))