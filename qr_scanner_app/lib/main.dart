import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Thêm thư viện để sử dụng Timeout
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

// IMPORTANT: Thay đổi địa chỉ IP của bạn ở đây.
// 1. Mở Command Prompt (Windows) hoặc Terminal (macOS).
// 2. Gõ `ipconfig` (Windows) hoặc `ifconfig` (macOS).
// 3. Tìm địa chỉ IPv4 của bạn (ví dụ: 192.168.1.10).
// Đây là địa chỉ của máy tính đang chạy server backend.
const String YOUR_LOCAL_IP = '192.168.9.203'; 
const String API_BASE_URL = 'http://$YOUR_LOCAL_IP:5001/api/products';

void main() {
  runApp(QRScannerApp());
}

// --- Model cho sản phẩm ---
class Product {
  final String id;
  final String name;
  final String origin;
  final String description;
  final double price;
  final String imageUrl;
  final String? videoUrl;
  final String qrCodeUrl;
  final String status;

  Product({
    required this.id,
    required this.name,
    required this.origin,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.videoUrl,
    required this.qrCodeUrl,
    required this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'] ?? 'N/A',
      origin: json['origin'] ?? 'N/A',
      description: json['description'] ?? 'N/A',
      price: (json['price'] as num? ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      videoUrl: json['videoUrl'],
      qrCodeUrl: json['qrCodeUrl'] ?? '',
      status: json['status'] ?? 'N/A',
    );
  }
}

// --- Service để gọi API ---
class ApiService {
  static Future<Product> fetchProductById(String id) async {
    try {
      final response = await http.get(Uri.parse('$API_BASE_URL/$id')).timeout(
        const Duration(seconds: 10), // Thêm timeout 10 giây
        onTimeout: () {
          // Trả về một TimeoutException nếu request quá lâu
          throw TimeoutException('Không thể kết nối đến server, vui lòng thử lại.');
        },
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy sản phẩm với ID này.');
      } else {
        throw Exception('Server trả về lỗi. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      // Ném lại lỗi để lớp UI có thể bắt và hiển thị
      rethrow;
    }
  }
}

// --- Giao diện chính của App, đã khôi phục theme gốc ---
class QRScannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner', // Giữ lại title gốc
      theme: ThemeData(
        primarySwatch: Colors.blue, // Khôi phục theme màu xanh dương gốc
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- Màn hình chính, khôi phục 100% giao diện gốc ---
class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('QR Scanner'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.qr_code_scanner,
                size: 100,
                color: Colors.blue[600],
              ),
            ),
            SizedBox(height: 40),
            Text(
              'QR Code Scanner',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Tap the camera button to scan QR codes',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScannerScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 3,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Open Camera',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Màn hình quét, kết hợp logic mới và giao diện cũ ---
class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isProcessing = false;
  bool flashOn = false;

  Future<void> _handleScannedCode(String productId) async {
    // **DEBUGGING:** In ra ID đã quét được
    print('--- Đang xử lý mã QR với ID: $productId ---');

    try {
      final product = await ApiService.fetchProductById(productId);
      if (mounted) {
        print('--- Lấy dữ liệu thành công, đang chuyển màn hình ---');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
        );
      }
    } catch (e, stackTrace) {
      // **DEBUGGING:** In ra lỗi chi tiết trong Debug Console
      print('!!! ĐÃ XẢY RA LỖI !!!');
      print('Lỗi: $e');
      print('Stacktrace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        // Reset lại trạng thái để cho phép quét lại
        setState(() {
          isProcessing = false;
          controller.start();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              flashOn ? Icons.flash_on : Icons.flash_off,
              color: flashOn ? Colors.yellow : Colors.grey,
            ),
            onPressed: () async {
              await controller.toggleTorch();
              setState(() {
                flashOn = !flashOn;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.flip_camera_ios),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (isProcessing) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null && code.isNotEmpty) {
                  setState(() { isProcessing = true; });
                  controller.stop();
                  _handleScannedCode(code);
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isProcessing ? Colors.orange : Colors.green,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: isProcessing
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green)),
                        SizedBox(height: 16),
                        Text(
                          'Đang xử lý dữ liệu...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
                        SizedBox(height: 8),
                        Text(
                          'Position QR code within the frame',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

// --- Màn hình chi tiết sản phẩm, được thiết kế lại dựa trên giao diện ResultScreen cũ ---
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.product.videoUrl != null && widget.product.videoUrl!.isNotEmpty) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.product.videoUrl!))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Scan Result'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ảnh sản phẩm
            if (widget.product.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: CachedNetworkImage(
                  imageUrl: widget.product.imageUrl,
                  placeholder: (context, url) => Container(
                    height: 250,
                    color: Colors.grey[200],
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 250,
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 20),

            // Container chứa thông tin, style giống ResultScreen cũ
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.product.price.toStringAsFixed(0)} VNĐ',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.product.status == 'còn hàng' ? Colors.green[100] : Colors.red[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.product.status.toUpperCase(),
                          style: TextStyle(
                            color: widget.product.status == 'còn hàng' ? Colors.green[800] : Colors.red[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24),
                  _buildInfoRow(Icons.flag_outlined, 'Xuất xứ', widget.product.origin),
                  SizedBox(height: 16),
                  Text('Mô tả chi tiết:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Video Player
            if (_videoController != null && _videoController!.value.isInitialized)
              _buildVideoPlayer(),
            SizedBox(height: 20),

            // Các nút bấm hành động giống ResultScreen cũ
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.product.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã sao chép ID sản phẩm!')),
                      );
                    },
                    icon: Icon(Icons.copy),
                    label: Text('Copy ID'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: Icon(Icons.qr_code_scanner),
                    label: Text('Scan Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        SizedBox(width: 12),
        Text('$label: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 16, color: Colors.grey[800])),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Video minh họa',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_videoController!),
              IconButton(
                onPressed: () {
                  setState(() {
                    _videoController!.value.isPlaying
                        ? _videoController!.pause()
                        : _videoController!.play();
                  });
                },
                icon: Icon(
                  _videoController!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: Colors.white.withOpacity(0.8),
                  size: 60,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }
}