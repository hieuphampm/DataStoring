import redis

r = redis.Redis(
    host='10.148.0.2',
    port=6379,
    decode_responses=True,
    socket_timeout=5  
)