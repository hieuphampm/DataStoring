# import redis

# r = redis.Redis(
#     host='35.197.132.185',
#     port=6379,
#     decode_responses=True,
#     socket_timeout=5  
# )

import redis
import os

r = redis.Redis(
    host=os.getenv('REDIS_HOST', 'localhost'), 
    port=6379,
    decode_responses=True,
    socket_timeout=5  
)
