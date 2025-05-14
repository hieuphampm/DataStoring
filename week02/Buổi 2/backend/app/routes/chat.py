from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from connect_redis import r
import json
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

chat = APIRouter()

class Message(BaseModel):
    user: str
    message: str

@chat.post("/send")
async def send_message(msg: Message):
    try:
        message_data = {
            "user": msg.user,
            "message": msg.message,
            "timestamp": datetime.utcnow().isoformat() + "Z"
        }
        logger.info(f"Sending message: {message_data}")
        r.rpush("chat:messages", json.dumps(message_data))
        r.expire("chat:messages", 3600)  # Set TTL to 1 hour
        if r.llen("chat:messages") > 100:
            r.ltrim("chat:messages", -100, -1)
        logger.info("Message stored successfully")
        return {"status": "success", "message": "Message stored"}
    except Exception as e:
        logger.error(f"Error in send_message: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@chat.get("/messages")
async def get_messages():
    try:
        messages = r.lrange("chat:messages", 0, -1)
        logger.info(f"Fetched {len(messages)} messages")
        return {"messages": [json.loads(msg) for msg in messages]}
    except Exception as e:
        logger.error(f"Error in get_messages: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))