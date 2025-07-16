console.log('--- Starting server.js ---');

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');

// Tải biến môi trường từ file .env
console.log('Loading environment variables...');
dotenv.config();
console.log('Environment variables loaded.');

const app = express();
console.log('Express app initialized.');

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
console.log('Middlewares configured.');

// Phục vụ các file tĩnh (như ảnh QR code) từ thư mục 'public'
app.use('/public', express.static(path.join(__dirname, 'public')));
console.log('Static file serving configured.');

// Routes
try {
    console.log('Loading routes...');
    app.use('/api/products', require('./routes/product.routes'));
    console.log('Routes loaded successfully.');
} catch (error) {
    console.error('!!! FATAL ERROR: Could not load routes. !!!');
    console.error(error);
    process.exit(1); // Thoát tiến trình nếu không thể tải routes
}

app.get('/', (req, res) => {
  res.send('<h1>Product Scanner API</h1><p>Welcome!</p>');
});

// Kết nối tới MongoDB
const MONGO_URI = process.env.MONGO_URI;
if (!MONGO_URI) {
    console.error('!!! FATAL ERROR: MONGO_URI is not defined in .env file. !!!');
    process.exit(1);
}

console.log('Connecting to MongoDB...');
// Các phiên bản Mongoose mới không cần các option cũ nữa
mongoose.connect(MONGO_URI)
.then(() => {
    console.log('✅ MongoDB connected successfully!');
    
    // Chỉ khởi động server SAU KHI kết nối DB thành công
    const PORT = process.env.PORT || 5001;
    app.listen(PORT, () => {
      console.log(`🚀 Server is running and listening on http://localhost:${PORT}`);
    });

})
.catch(err => {
    console.error('❌ MongoDB connection error:');
    console.error(err);
    process.exit(1); // Thoát tiến trình nếu không kết nối được DB
});

// Bắt các lỗi chưa được xử lý
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

console.log('--- End of server.js initial script ---');