import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailScreen extends StatelessWidget {
  final DocumentSnapshot product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.network(product['imageUrl'], height: 200),
            const SizedBox(height: 12),
            Text(product['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Xuất xứ: ${product['origin']}'),
            Text('Giá: ${product['price']} đ'),
            const SizedBox(height: 8),
            Text(product['description']),
          ],
        ),
      ),
    );
  }
}
