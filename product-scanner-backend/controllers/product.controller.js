const Product = require('../models/product.model');
const qrcode = require('qrcode');
const fs = require('fs');
const path = require('path');

// Hàm tạo sản phẩm mới
exports.createProduct = async (req, res) => {
  try {
    const { name, origin, description, price, imageUrl, videoUrl, status } = req.body;

    // 1. Tạo sản phẩm trong database để lấy _id
    const newProduct = new Product({
      name,
      origin,
      description,
      price,
      imageUrl, // Sẽ lấy từ Firebase Storage
      videoUrl, // Sẽ lấy từ Firebase Storage
      status
    });

    const savedProduct = await newProduct.save();
    const productId = savedProduct._id.toString();

    // 2. Tạo QR code chứa ID của sản phẩm
    const qrCodeData = productId; // Nội dung của QR code chính là ID sản phẩm
    const qrCodeFolderPath = path.join(__dirname, '..', 'public', 'qrcodes');

    // Đảm bảo thư mục tồn tại
    if (!fs.existsSync(qrCodeFolderPath)) {
      fs.mkdirSync(qrCodeFolderPath, { recursive: true });
    }

    const qrCodeFilePath = path.join(qrCodeFolderPath, `${productId}.png`);
    
    await qrcode.toFile(qrCodeFilePath, qrCodeData);

    // 3. Cập nhật lại sản phẩm với đường dẫn QR code
    // URL này sẽ được client (Flutter app, admin page) sử dụng
    const serverBaseUrl = `${req.protocol}://${req.get('host')}`;
    const qrCodeUrl = `${serverBaseUrl}/public/qrcodes/${productId}.png`;
    
    savedProduct.qrCodeUrl = qrCodeUrl;
    await savedProduct.save();

    res.status(201).json({
      message: 'Sản phẩm đã được tạo thành công!',
      product: savedProduct,
    });

  } catch (error) {
    res.status(500).json({ message: 'Lỗi server khi tạo sản phẩm', error: error.message });
  }
};

// Hàm lấy tất cả sản phẩm
exports.getAllProducts = async (req, res) => {
  try {
    const products = await Product.find().sort({ createdAt: -1 });
    res.status(200).json(products);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server khi lấy danh sách sản phẩm', error: error.message });
  }
};

// Hàm lấy một sản phẩm bằng ID
exports.getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ message: 'Không tìm thấy sản phẩm' });
    }
    res.status(200).json(product);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server khi lấy thông tin sản phẩm', error: error.message });
  }
};

// Hàm cập nhật sản phẩm
exports.updateProduct = async (req, res) => {
    try {
        const updatedProduct = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
        if (!updatedProduct) {
            return res.status(404).json({ message: 'Không tìm thấy sản phẩm' });
        }
        res.status(200).json({ message: 'Cập nhật sản phẩm thành công', product: updatedProduct });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server khi cập nhật sản phẩm', error: error.message });
    }
};

// Hàm xóa sản phẩm
exports.deleteProduct = async (req, res) => {
    try {
        const product = await Product.findByIdAndDelete(req.params.id);
        if (!product) {
            return res.status(404).json({ message: 'Không tìm thấy sản phẩm' });
        }

        // Xóa file QR code tương ứng
        const qrCodeFilePath = path.join(__dirname, '..', 'public', 'qrcodes', `${req.params.id}.png`);
        if (fs.existsSync(qrCodeFilePath)) {
            fs.unlinkSync(qrCodeFilePath);
        }

        res.status(200).json({ message: 'Xóa sản phẩm thành công' });
    } catch (error) {
        res.status(500).json({ message: 'Lỗi server khi xóa sản phẩm', error: error.message });
    }
};