import 'package:flutter/material.dart';
import 'package:my_new_app/pages/AppWebView/appweb.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import 'package:my_new_app/pages/widgets/media_slider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';


class ShopsGaragesPage extends StatefulWidget {
  const ShopsGaragesPage({super.key});


  @override
  State<ShopsGaragesPage> createState() => _ShopsGaragesPageState();
}


class _ShopsGaragesPageState extends State<ShopsGaragesPage> {
  bool _isLoggedIn = false;


  // Media Slider Items
  final List<MediaSliderItem> _sliderItems = [
    MediaSliderItem.assetImage(
      assetPath: 'assets/Banner/Home/1.png',
    ),
    MediaSliderItem.assetImage(
      assetPath: 'assets/Banner/Home/2.png',
    ),
    MediaSliderItem.assetImage(
      assetPath: 'assets/Banner/Home/3.png',
    ),
    MediaSliderItem.assetImage(
      assetPath: 'assets/Banner/Home/4.png',
    ),
    MediaSliderItem.assetImage(
      assetPath: 'assets/Banner/Home/5.png',
    ),
  ];


  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }


  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }
  }


 void _applyNow() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const InAppWebViewPage(
        url: 'https://payments.cashfree.com/forms/sampark_starter_pack',
        title: 'Payment',
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Yellow gradient background
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryYellow,
                  AppColors.primaryYellow.withOpacity(0.85),
                  AppColors.darkYellow,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),


          SafeArea(
            child: Column(
              children: [
                // App Header
                AppHeader(
                  isLoggedIn: _isLoggedIn,
                  showBackButton: true,
                  showUserInfo: false,
                  showCartIcon: false,
                ),


                // Main Content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppConstants.spacingMedium),

                          // ✅ Page Title ABOVE slider
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingPage),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shops and Garages',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizePageTitle,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Start your trial pack for shops and garages with exclusive offers',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizeSubtitle,
                                    color: AppColors.textGrey,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12), // ✅ Minimal gap

                          // ✅ Media Slider - Compact version
                          _buildImageSlider(),

                          const SizedBox(height: 16),


                          // Content Container
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingPage),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Yellow Price Banner
                                _buildPriceBanner(),


                                const SizedBox(height: 16),


                                // Starter Pack Info
                                _buildStarterPackInfo(),


                                const SizedBox(height: 16),


                                // Garage Option
                                _buildGarageOption(),


                                const SizedBox(height: 16),


                                // Your Logo Section
                                _buildYourLogoSection(),


                                const SizedBox(height: 16),


                                // Co-Branded Tags Section
                                _buildCoBrandedSection(),


                                const SizedBox(height: 16),


                                // Free Marketing Materials
                                _buildMarketingMaterialsSection(),


                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),


          // Bottom Apply Now Button
          _buildBottomApplyButton(),
        ],
      ),
    );
  }


  // ✅ Compact Image Slider - Minimal spacing
  Widget _buildImageSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MediaSlider(
          items: _sliderItems,
          height: 120, // ✅ Reduced height
          autoScroll: true,
          show3DEffect: false,
          autoScrollDuration: const Duration(seconds: 4),
          viewportFraction: 1.0,
          showIndicators: true,
        ),
      ),
    );
  }


  Widget _buildPriceBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.activeYellow,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
        boxShadow: [
          BoxShadow(
            color: AppColors.activeYellow.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        'Start now for just Rs 2999',
        style: TextStyle(
          fontSize: AppConstants.fontSizeSectionTitle,
          fontWeight: FontWeight.w800,
          color: AppColors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }


  Widget _buildStarterPackInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
        border: Border.all(
          color: AppColors.lightGrey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Start trial pack for shops and Garages.',
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardTitle,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            'If you have a Garage or a shop, Pack of 20 Car sampark tag only for Rs 2999.',
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardDescription,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildGarageOption() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppConstants.paddingMedium),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
      border: Border.all(
        color: AppColors.lightGrey,
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.garage_outlined,
              size: AppConstants.iconSizeMedium,
              color: AppColors.activeYellow, // ✅ Changed to yellow
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            Expanded(
              child: Text(
                'Do you have a garage ?',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeCardTitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        Text(
          'Get car sampark tag with your logo on it. Build happy customers.',
          style: TextStyle(
            fontSize: AppConstants.fontSizeCardDescription,
            fontWeight: FontWeight.w500,
            color: AppColors.textGrey,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}



  // ✅ NEW: Your Logo Section
  Widget _buildYourLogoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
        border: Border.all(
          color: AppColors.lightGrey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.business,
                size: AppConstants.iconSizeMedium,
                color: AppColors.activeYellow,
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Text(
                'Your logo',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeCardTitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            'Get your garage logo on the tags for free.',
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardDescription,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }


  // ✅ NEW: Co-Branded Tags Section
  Widget _buildCoBrandedSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
        border: Border.all(
          color: AppColors.lightGrey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.handshake_outlined,
                size: AppConstants.iconSizeMedium,
                color: AppColors.activeYellow,
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Expanded(
                child: Text(
                  'Gurgaon, Societies, insurance companies / corporates.',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardTitle,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            'Get co-branded tags.',
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardDescription,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }


  // ✅ NEW: Free Marketing Materials Section
  Widget _buildMarketingMaterialsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.campaign_outlined,
                size: AppConstants.iconSizeLarge,
                color: AppColors.activeYellow,
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Text(
                'Free Marketing materials',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSectionTitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildChecklistItem('Pamphlets, Brochure, Standee, Sales Pitch, Videos & Pictures.'),
          _buildChecklistItem('Certificate, Agreements & Booklets.'),
          _buildChecklistItem('Dedicated manager'),
          _buildChecklistItem('Exclusive Rights in Your City*.'),
        ],
      ),
    );
  }


  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: AppConstants.iconSizeSmall,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardDescription,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Bottom Apply Now Button
  Widget _buildBottomApplyButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.buttonPaddingVertical),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: AppConstants.buttonHeightMedium,
            child: ElevatedButton(
              onPressed: _applyNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.activeYellow,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                ),
              ),
              child: Text(
                'Apply Now',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeButtonText,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// Custom Painter for Dashed Border
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;


  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.borderRadius,
  });


  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;


    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );


    final dashPath = _createDashedPath(path, dashWidth, dashSpace);
    canvas.drawPath(dashPath, paint);
  }


  Path _createDashedPath(Path source, double dashWidth, double dashSpace) {
    final Path dashedPath = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final double length = draw ? dashWidth : dashSpace;
        if (distance + length > metric.length) {
          if (draw) {
            dashedPath.addPath(
              metric.extractPath(distance, metric.length),
              Offset.zero,
            );
          }
          break;
        }
        if (draw) {
          dashedPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return dashedPath;
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
