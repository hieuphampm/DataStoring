import redis

r = redis.Redis(
    host='34.2.19.12',
    port=6379,
    decode_responses=True,
    socket_timeout=5  
)

