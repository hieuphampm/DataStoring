
# Hướng dẫn triển khai Redis bằng Docker trên Google Cloud VM

## Bước 1: Tạo VM Instance
- Vào Google Cloud Console
- Tạo VM Ubuntu 22.04
- Cho phép HTTP/HTTPS (nếu cần), chọn e2-micro hoặc e2-small

## Bước 2: SSH vào VM
- Upload file `setup_redis_docker.sh`
- Chạy: bash setup_redis_docker.sh

## Bước 3: Mở firewall cổng 6379
- Vào VPC Network > Firewall Rules
- Tạo rule mới: allow-redis
- Nguồn: 0.0.0.0/0 (hoặc IP cụ thể nếu muốn bảo mật)
- Mở TCP port: 6379

## Bước 4: Kết nối từ client
```python
import redis
r = redis.Redis(host='YOUR_VM_PUBLIC_IP', port=6379)
r.set("student:SV001", "Nguyen Van A")
print(r.get("student:SV001").decode())
```
