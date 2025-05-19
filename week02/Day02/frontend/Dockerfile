# Stage 1: Build React app
FROM node:18 AS build

# Tạo thư mục làm việc
WORKDIR /app

# Copy package.json và package-lock.json trước để cache npm install
COPY package*.json ./

# Cài đặt dependencies
RUN npm install

# Copy toàn bộ mã nguồn
COPY . .

# Build ứng dụng React
RUN npm run build

# -------------------------------------

# Stage 2: Serve app với Nginx
FROM nginx:stable-alpine

# Xóa cấu hình default của nginx
RUN rm -rf /usr/share/nginx/html/*

# Copy bản build từ stage 1 vào Nginx
COPY --from=build /app/build /usr/share/nginx/html

# Copy config Nginx tùy chỉnh nếu có
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Khởi động Nginx
CMD ["nginx", "-g", "daemon off;"]
