import redis

r = redis.Redis(
    host='34.126.126.183',
    port=6379,
    decode_responses=True,
)

try: 
    r.set("student:SV001", "Nguyen Van A")

    name = r.get("student:SV001")
    print("Tên sinh viên từ Redis:", name)

except Exception as e:
    print("Lỗi kết nối Redis:", e)

finally:
    r.close()