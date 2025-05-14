import redis

r = redis.Redis(
    host='34.126.126.183',
    port=6379,
    decode_responses=True,
    socket_timeout=5  # Add timeout to handle connection issues
)