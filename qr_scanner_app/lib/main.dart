import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(QRScannerApp());
}

class QRScannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

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
            // QR Code Icon
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

            // Title
            Text(
              'QR Code Scanner',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),

            SizedBox(height: 16),

            // Description
            Text(
              'Tap the camera button to scan QR codes',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 60),

            // Camera Button
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

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late MobileScannerController controller;
  bool isScanning = true;
  String? scannedData;
  bool flashOn = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
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
          // Flash toggle
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
          // Camera flip
          IconButton(
            icon: Icon(Icons.flip_camera_ios),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: controller,
            onDetect: (BarcodeCapture capture) {
              if (isScanning) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final barcode = barcodes.first;
                  if (barcode.rawValue != null) {
                    setState(() {
                      isScanning = false;
                      scannedData = barcode.rawValue!;
                    });

                    // Navigate to result screen after a brief delay
                    Future.delayed(Duration(milliseconds: 500), () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultScreen(
                            scannedData: scannedData!,
                          ),
                        ),
                      );
                    });
                  }
                }
              }
            },
          ),

          // Scanning overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isScanning ? Colors.green : Colors.orange,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Corner indicators
          Center(
            child: Container(
              width: 250,
              height: 250,
              child: Stack(
                children: [
                  // Top-left corner
                  Positioned(
                    top: -3,
                    left: -3,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.green, width: 6),
                          left: BorderSide(color: Colors.green, width: 6),
                        ),
                      ),
                    ),
                  ),
                  // Top-right corner
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.green, width: 6),
                          right: BorderSide(color: Colors.green, width: 6),
                        ),
                      ),
                    ),
                  ),
                  // Bottom-left corner
                  Positioned(
                    bottom: -3,
                    left: -3,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.green, width: 6),
                          left: BorderSide(color: Colors.green, width: 6),
                        ),
                      ),
                    ),
                  ),
                  // Bottom-right corner
                  Positioned(
                    bottom: -3,
                    right: -3,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.green, width: 6),
                          right: BorderSide(color: Colors.green, width: 6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scanning line animation
          if (isScanning)
            Center(
              child: Container(
                width: 250,
                height: 250,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: Duration(seconds: 2),
                  builder: (context, value, child) {
                    return CustomPaint(
                      painter: ScannerLinePainter(value),
                    );
                  },
                  onEnd: () {
                    if (mounted && isScanning) {
                      setState(() {});
                    }
                  },
                ),
              ),
            ),

          // Bottom instruction panel
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isScanning) ...[
                      Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Position QR code within the frame',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'QR Code Detected!',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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

class ScannerLinePainter extends CustomPainter {
  final double animationValue;

  ScannerLinePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2;

    final y = size.height * animationValue;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class ResultScreen extends StatelessWidget {
  final String scannedData;

  const ResultScreen({Key? key, required this.scannedData}) : super(key: key);

  bool _isUrl(String text) {
    return text.startsWith('http://') || text.startsWith('https://');
  }

  bool _isEmail(String text) {
    return text.contains('@') && text.contains('.');
  }

  bool _isPhone(String text) {
    return RegExp(r'^[\+]?[0-9\-\(\)\s]+$').hasMatch(text);
  }

  String _getDataType() {
    if (_isUrl(scannedData)) return 'Website URL';
    if (_isEmail(scannedData)) return 'Email Address';
    if (_isPhone(scannedData)) return 'Phone Number';
    return 'Text';
  }

  IconData _getDataIcon() {
    if (_isUrl(scannedData)) return Icons.link;
    if (_isEmail(scannedData)) return Icons.email;
    if (_isPhone(scannedData)) return Icons.phone;
    return Icons.text_fields;
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
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success Icon
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(20),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Colors.green[600],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Success Message
            Text(
              'QR Code Scanned Successfully!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 30),

            // Data Type Indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getDataIcon(),
                    size: 16,
                    color: Colors.blue[600],
                  ),
                  SizedBox(width: 8),
                  Text(
                    _getDataType(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Result Container
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
                    'Scanned Data:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 12),
                  SelectableText(
                    scannedData,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: scannedData));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied to clipboard!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(Icons.copy),
                    label: Text('Copy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Additional info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: You can copy the result and use it in other apps',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 14,
                      ),
                    ),
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