const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Tên sản phẩm là bắt buộc'],
    trim: true,
  },
  origin: {
    type: String,
    required: [true, 'Xuất xứ là bắt buộc'],
    trim: true,
  },
  description: {
    type: String,
    required: [true, 'Mô tả là bắt buộc'],
  },
  price: {
    type: Number,
    required: [true, 'Giá sản phẩm là bắt buộc'],
  },
  imageUrl: {
    type: String,
    required: [true, 'URL hình ảnh là bắt buộc'],
  },
  videoUrl: {
    type: String,
    default: '', // Video không bắt buộc
  },
  qrCodeUrl: {
    type: String, // URL để truy cập file ảnh QR code
    default: '',
  },
  status: {
    type: String,
    enum: ['còn hàng', 'hết hàng'],
    default: 'còn hàng',
  }
}, {
  timestamps: true, // Tự động thêm 2 trường createdAt và updatedAt
});

module.exports = mongoose.model('Product', productSchema);