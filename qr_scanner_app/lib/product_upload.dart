import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProductUpload extends StatefulWidget {
  const ProductUpload({super.key});

  @override
  State<ProductUpload> createState() => _ProductUploadState();
}

class _ProductUploadState extends State<ProductUpload> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  File? _imageFile;
  final _nameController = TextEditingController();
  final _originController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) return;

    final productId = const Uuid().v4();
    final storageRef =
        FirebaseStorage.instance.ref().child('products/$productId.jpg');
    await storageRef.putFile(_imageFile!);
    final imageUrl = await storageRef.getDownloadURL();

    await FirebaseFirestore.instance.collection('products').doc(productId).set({
      'name': _nameController.text,
      'origin': _originController.text,
      'description': _descriptionController.text,
      'price': int.parse(_priceController.text),
      'imageUrl': imageUrl,
      'qrData': productId,
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mã QR cho sản phẩm'),
        content: QrImageView(data: productId, size: 200),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm sản phẩm')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile == null
                    ? Container(
                        width: double.infinity,
                        height: 180,
                        color: Colors.grey[300],
                        child: const Icon(Icons.camera_alt, size: 50),
                      )
                    : Image.file(_imageFile!, height: 180),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                validator: (val) => val!.isEmpty ? 'Bắt buộc' : null,
              ),
              TextFormField(
                controller: _originController,
                decoration: const InputDecoration(labelText: 'Xuất xứ'),
                validator: (val) => val!.isEmpty ? 'Bắt buộc' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả chi tiết'),
                validator: (val) => val!.isEmpty ? 'Bắt buộc' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Giá'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _uploadProduct,
                child: const Text('Lưu và tạo mã QR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
