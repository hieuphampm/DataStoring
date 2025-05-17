#!/bin/bash

# Cập nhật hệ thống
sudo apt update

# Cài đặt Docker
sudo apt install -y docker.io

# Bật Docker khi khởi động
sudo systemctl enable docker
sudo systemctl start docker

# Tải và chạy Redis container
sudo docker run -d --name redis-server -p 6379:6379 redis

# Kiểm tra container
sudo docker ps

# Gợi ý kiểm tra Redis:
# docker exec -it redis-server redis-cli
