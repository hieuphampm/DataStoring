const express = require('express');
const router = express.Router();
const productController = require('../controllers/product.controller');

// POST /api/products -> Tạo sản phẩm mới
router.post('/', productController.createProduct);

// GET /api/products -> Lấy tất cả sản phẩm
router.get('/', productController.getAllProducts);

// GET /api/products/:id -> Lấy một sản phẩm theo ID
router.get('/:id', productController.getProductById);

// PUT /api/products/:id -> Cập nhật sản phẩm
router.put('/:id', productController.updateProduct);

// DELETE /api/products/:id -> Xóa sản phẩm
router.delete('/:id', productController.deleteProduct);

module.exports = router;