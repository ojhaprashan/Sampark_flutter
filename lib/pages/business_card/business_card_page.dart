import 'package:flutter/material.dart';
import 'package:my_new_app/pages/AppWebView/appweb.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import 'package:my_new_app/pages/widgets/media_slider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';

class BusinessCardPage extends StatefulWidget {
  const BusinessCardPage({super.key});

  @override
  State<BusinessCardPage> createState() => _BusinessCardPageState();
}

class _BusinessCardPageState extends State<BusinessCardPage> {
  bool _isLoggedIn = false;

  // Media items - using MediaSliderItem
final List<MediaSliderItem> _mediaItems = [

    MediaSliderItem.networkImage(
      url: 'https://sampark.me/assets/app/business_1.png',
    ),
    MediaSliderItem.networkImage(
      url: 'https://sampark.me/assets/app/business_2.png',
    ),
    MediaSliderItem.networkImage(
      url: 'https://sampark.me/assets/app/business_3.png',
    ),
    MediaSliderItem.networkImage(
      url: 'https://sampark.me/assets/app/business_4.png',
    ),
    MediaSliderItem.networkImage(
      url: 'https://sampark.me/assets/app/business_5.png',
    ),
    MediaSliderItem.networkImage(
      url: 'https://sampark.me/assets/app/business_6.png',
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
                          const SizedBox(height: 12),

                          // Page Title
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Business NFC Card',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizePageTitle,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Create a lasting impression with advanced digital business card',
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

                          const SizedBox(height: 12),

                          // Media Slider Component
                          MediaSlider(
                            items: _mediaItems,
                            height: 280,
                            autoScroll: true,
                            show3DEffect: false,
                            autoScrollDuration: const Duration(seconds: 4),
                            viewportFraction: 1.0,
                          ),

                          const SizedBox(height: 16),

                          // Main Features Section
                          _buildMainFeaturesSection(),

                          const SizedBox(height: 16),

                          // Additional Features Grid
                          _buildAdditionalFeaturesGrid(),

                          const SizedBox(height: 16),

                          // How to Use Section
                          _buildHowToUseSection(),

                          const SizedBox(height: 80),
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

  // Main Features Section
  Widget _buildMainFeaturesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Features',
            style: TextStyle(
              fontSize: AppConstants.fontSizeSectionTitle,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
          
          _buildFeatureItem(
            Icons.share,
            'Share Your Business Details By TAP',
            'No APP Is Required',
          ),
          const SizedBox(height: 8),
          _buildFeatureItem(
            Icons.location_on,
            'Share Business Google Location',
            'Help customers find you easily',
          ),
          const SizedBox(height: 8),
          _buildFeatureItem(
            Icons.chat_bubble_outline,
            'Get Business Leads On WhatsApp',
            'Direct customer communication',
          ),
          const SizedBox(height: 8),
          _buildFeatureItem(
            Icons.price_change,
            'Free Showcase Or Increase Of Any Issues',
            'No hidden charges or complications',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.lightGrey,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.activeYellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: AppConstants.iconSizeLarge,
              color: AppColors.black,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardTitle,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardDescription,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Additional Features Grid
  Widget _buildAdditionalFeaturesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What You Can Add',
            style: TextStyle(
              fontSize: AppConstants.fontSizeSectionTitle,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
          
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.9,
            children: [
              _buildFeatureCard(Icons.work_outline, 'Add Your\nPortfolio'),
              _buildFeatureCard(Icons.currency_rupee, 'Add your\nPricing'),
              _buildFeatureCard(Icons.chat, 'WhatsApp And\nCall'),
              _buildFeatureCard(Icons.location_on_outlined, 'Location\nTracking'),
              _buildFeatureCard(Icons.bookmark_border, 'Instant Save to\nContacts'),
              _buildFeatureCard(Icons.support_agent, 'Live Support\nAlways'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.lightGrey,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppConstants.iconSizeGrid,
            color: AppColors.black,
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppConstants.fontSizeSmallText,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // How to Use Section
  Widget _buildHowToUseSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
                Icons.touch_app,
                color: AppColors.activeYellow,
                size: AppConstants.iconSizeLarge,
              ),
              const SizedBox(width: 8),
              Text(
                'How to Use',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSectionTitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStep('1', 'Tap the card on any smartphone'),
          _buildStep('2', 'Your profile opens instantly'),
          _buildStep('3', 'Connect on all platforms at once'),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.activeYellow,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Buy Button
 // Bottom Buy Button
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
            onPressed: () {
               Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InAppWebViewPage(
          url: 'https://app.ngf132.com/order-business',
          title: 'Buy Business Card',
        ),
      ),
    );
            },
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
                  'CREATE A BUSINESS CARD - ',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeButtonText,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  '₹799',
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
