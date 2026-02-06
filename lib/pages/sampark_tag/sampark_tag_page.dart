import 'package:flutter/material.dart';
import 'package:my_new_app/pages/AppWebView/appweb.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import 'package:my_new_app/pages/widgets/media_slider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';


class SamparkTagPage extends StatefulWidget {
  const SamparkTagPage({super.key});


  @override
  State<SamparkTagPage> createState() => _SamparkTagPageState();
}


class _SamparkTagPageState extends State<SamparkTagPage> {
  bool _isLoggedIn = false;


  // Define media items
  final List<MediaSliderItem> _mediaItems = [
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

  // Navigate to buy form
  void _navigateToBuyForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InAppWebViewPage(
          url: 'https://app.ngf132.com/qr-for-car',
          title: 'Buy Sampark Tag',
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
                          const SizedBox(height: 8),


                          // Page Title
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingPage),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Buy Sampark Tag',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizePageTitle,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Masked Calls and WhatsApp for any issues with your parked car.',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizeSubtitle,
                                    color: AppColors.textGrey,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),


                          const SizedBox(height: 8),


                          // Media Slider - Wrapped with intrinsic sizing
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: MediaSlider(
                              items: _mediaItems,
                              height: 160, // Slightly reduced height
                              autoScroll: true,
                              show3DEffect: false,
                              autoScrollDuration: const Duration(seconds: 3),
                              viewportFraction: 1.0,
                              showIndicators: true,
                            ),
                          ),


                          const SizedBox(height: 8),


                          // One time buy section
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.paddingPage,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(
                                AppConstants.paddingMedium,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusCard,
                                ),
                                border: Border.all(
                                  color: AppColors.lightGrey,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'One time buy | Pack of 2 | 10 Years warranty',
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizeCardTitle,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),


                          const SizedBox(height: 8),


                          // Buy Now Button with COD
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.paddingPage,
                            ),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.black,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.buttonBorderRadius,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _navigateToBuyForm,
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.buttonBorderRadius,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppConstants.paddingMedium,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'BUY NOW, COD Available.',
                                        style: TextStyle(
                                          fontSize: AppConstants.fontSizeSectionTitle,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.activeYellow,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),


                          const SizedBox(height: 8),


                          // All Features Box
                          _buildAllFeaturesBox(),


                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),


          // Bottom Buy Button
          _buildBottomBuyButton(),
        ],
      ),
    );
  }


  // All features in single box - 3 columns grid
  Widget _buildAllFeaturesBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingPage),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          border: Border.all(
            color: AppColors.lightGrey,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Row 1
            Row(
              children: [
                Expanded(
                  child: _buildCompactFeature(
                    icon: Icons.phone_in_talk,
                    title: 'Masked\nCalls',
                    iconColor: const Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCompactFeatureWithImage(
                    imagePath: 'assets/icons/whatsapp.png',
                    title: 'WhatsApp\nAlert',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCompactFeature(
                    icon: Icons.sms_outlined,
                    title: 'SMS\nNotify',
                    iconColor: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Row 2
            Row(
              children: [
                Expanded(
                  child: _buildCompactFeature(
                    icon: Icons.security,
                    title: 'Number\nMASKED',
                    iconColor: const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCompactFeature(
                    icon: Icons.contact_phone,
                    title: 'Emergency\nContact',
                    iconColor: const Color(0xFFF44336),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCompactFeature(
                    icon: Icons.qr_code_scanner,
                    title: 'QR Code\nScan',
                    iconColor: const Color(0xFF9C27B0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  // Compact feature item with icon - NO background
  Widget _buildCompactFeature({
    required IconData icon,
    required String title,
    required Color iconColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 28,
          color: iconColor,
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
            height: 1.2,
          ),
          maxLines: 2,
        ),
      ],
    );
  }


  // Compact feature with WhatsApp PNG image
  Widget _buildCompactFeatureWithImage({
    required String imagePath,
    required String title,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          imagePath,
          width: 28,
          height: 28,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.chat_bubble,
              size: 28,
              color: Color(0xFF25D366),
            );
          },
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
            height: 1.2,
          ),
          maxLines: 2,
        ),
      ],
    );
  }


  Widget _buildBottomBuyButton() {
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
              onPressed: _navigateToBuyForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.activeYellow,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'BUY SAMPARK TAG - ',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeButtonText,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    '₹299',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeButtonPriceText,
                      fontWeight: FontWeight.w900,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
