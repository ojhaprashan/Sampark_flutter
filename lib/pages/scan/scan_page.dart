import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../utils/colors.dart';
import '../../services/qr_signup_service.dart';
import 'contact_vehicle_owner_page.dart';
import 'tag_activation_page.dart';
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isFlashOn = false;
  bool _isCameraActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_isCameraActive) {
          cameraController.start();
          setState(() => _isCameraActive = true);
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        if (_isCameraActive) {
          cameraController.stop();
          setState(() => _isCameraActive = false);
        }
        break;
      default:
        break;
    }
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    cameraController.toggleTorch();
  }

  void _switchCamera() {
    cameraController.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleScanResult(barcode.rawValue!);
                  break;
                }
              }
            },
          ),

          // Overlay with scanning frame
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: Container(),
          ),

          // Top Header Section
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Text(
                        'SAMPARK+',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      
                      // Flash Toggle
                      GestureDetector(
                        onTap: _toggleFlash,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _isFlashOn 
                                ? AppColors.activeYellow.withOpacity(0.9)
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: _isFlashOn ? Colors.black : Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Scan QR Code',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Align QR code within the frame to scan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls Section
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Switch Camera Button
                  GestureDetector(
                    onTap: _switchCamera,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.activeYellow,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.activeYellow.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flip_camera_android_rounded,
                            color: Colors.black,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Switch Camera',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Hint text
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Position the code inside the frame',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

/// Extract code from QR URL
/// Expected format: https://app.ngf132.com/qr-signup?code=415711&pin=2580
String _extractCodeFromUrl(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.queryParameters['code'] ?? url;
  } catch (e) {
    // If parsing fails, assume it's already a code
    return url;
  }
}

/// Handle scan result - extract code and call API
void _handleScanResult(String scannedData) async {
  // Stop camera temporarily
  cameraController.stop();
  setState(() => _isCameraActive = false);

  // Extract code from URL
  final code = _extractCodeFromUrl(scannedData);

  // Show loading dialog
  if (mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.activeYellow,
            ),
          ),
        ),
      ),
    );
  }

  try {
    // Call API to verify QR code
    print('\n🔍 Scanning QR Code: $code\n');
    final response = await QRSignupService.verifyQRCode(code: code);

    if (mounted) {
      Navigator.pop(context); // Close loading dialog

      if (response.status == 'success') {
        final statusCode = response.data.statusCode;
        print('\n✅ Scan Successful - Status Code: $statusCode\n');

        if (statusCode == '1') {
          // Navigate to contact vehicle owner page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactVehicleOwnerPage(
                tagId: response.data.tagId,
                vehicleNumber: code,
                phoneNumber: response.data.carUrl,
                maskedNumber: response.data.qrCodeSuffix,
              ),
            ),
          ).then((_) {
            // Restart camera when back
            cameraController.start();
            setState(() => _isCameraActive = true);
          });
        } else if (statusCode == '5') {
          // Navigate to tag activation page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TagActivationPage(
                tagData: response.data,
              ),
            ),
          ).then((_) {
            // Restart camera when back
            cameraController.start();
            setState(() => _isCameraActive = true);
          });
        } else {
          _showErrorAndResumeCamera(
            'Status Code: $statusCode',
          );
        }
      } else {
        _showErrorAndResumeCamera(
          response.message,
        );
      }
    }
  } catch (e) {
    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      // Extract only the error message
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      _showErrorAndResumeCamera(errorMessage);
    }
  }
}

/// Show error and resume camera
void _showErrorAndResumeCamera(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // Resume camera
  cameraController.start();
  setState(() => _isCameraActive = true);
}
}

// Custom painter for scanner overlay
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.black.withOpacity(0.6);
    
    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final Rect scanArea = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // Draw overlay with transparent scan area
    final Path path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(20)))
      ..fillType = PathFillType.evenOdd;
    
    canvas.drawPath(path, paint);

    // Draw corner borders
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double cornerLength = 30;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top + cornerLength),
      Offset(left, top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      borderPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + scanAreaSize - cornerLength, top),
      Offset(left + scanAreaSize, top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top),
      Offset(left + scanAreaSize, top + cornerLength),
      borderPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + scanAreaSize - cornerLength),
      Offset(left, top + scanAreaSize),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaSize),
      Offset(left + cornerLength, top + scanAreaSize),
      borderPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + scanAreaSize - cornerLength, top + scanAreaSize),
      Offset(left + scanAreaSize, top + scanAreaSize),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top + scanAreaSize - cornerLength),
      Offset(left + scanAreaSize, top + scanAreaSize),
      borderPaint,
    );

    // Draw yellow accent line at top
    final Paint accentPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(left + 10, top - 10),
      Offset(left + scanAreaSize - 10, top - 10),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
