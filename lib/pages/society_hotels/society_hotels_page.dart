import 'package:flutter/material.dart';
import 'package:my_new_app/pages/AppWebView/appweb.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import 'package:my_new_app/pages/widgets/media_slider.dart';

import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';

class SocietyHotelsPage extends StatefulWidget {
  const SocietyHotelsPage({super.key});

  @override
  State<SocietyHotelsPage> createState() => _SocietyHotelsPageState();
}

class _SocietyHotelsPageState extends State<SocietyHotelsPage> {
  bool _isLoggedIn = false;

  // Media Slider Items
  final List<MediaSliderItem> _sliderItems = [
    MediaSliderItem.networkImage(
      url: 'https://sampark.me/assets/app/society_1.png',
      boxFit: BoxFit.contain,
    ),
    MediaSliderItem.networkImage(
      url: 'https://sampark.me/assets/app/society_2.png',
      boxFit: BoxFit.contain,
    ),
    MediaSliderItem.networkImage(
      url: 'https://sampark.me/assets/app/society_3.png',
      boxFit: BoxFit.contain,
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

  // ✅ Open Apply Form in WebView
  void _applyNow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InAppWebViewPage(
          url: 'https://app.ngf132.com/apply-society',
          title: 'Apply for Society',
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
                          const SizedBox(height: 12),

                          // Page Title
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Society / Hotels',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizePageTitle,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Exclusive solutions for societies and hotels',
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

                          // Media Slider
                          MediaSlider(
                            items: _sliderItems,
                            height: 280,
                            autoScroll: true,
                            show3DEffect: false,
                            autoScrollDuration: const Duration(seconds: 4),
                            viewportFraction: 1.0,
                          ),

                          const SizedBox(height: 16),

                          // Content Sections
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Feature 1
                                _buildFeatureCard(
                                  icon: Icons.description_outlined,
                                  title: 'Manage Vehicle Coming IN and Going OUT record.',
                                  description: 'Download Excel anytime anywhere.',
                                ),

                                const SizedBox(height: 12),

                                // Feature 2
                                _buildFeatureCard(
                                  icon: Icons.verified_user_outlined,
                                  title: 'Your Society Members can pre-Authorize any vehicle / Send OTP to visitor here.',
                                  description: '',
                                ),

                                const SizedBox(height: 12),

                                // Feature 3
                                _buildFeatureCard(
                                  icon: Icons.business_outlined,
                                  title: 'We will print your Society logo on the tag.',
                                  description: 'you can recogonizance vehicle from your society',
                                ),

                                const SizedBox(height: 12),

                                // Feature 4
                                _buildFeatureCard(
                                  icon: Icons.security_outlined,
                                  title: 'Your residents can contact any vehicle owner incase of any wrong parking.',
                                  description: 'Contact details will be kept private.',
                                ),

                                const SizedBox(height: 16),

                                // Yellow Banner
                                _buildYellowBanner(),

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

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: AppConstants.iconSizeMedium,
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
                        fontSize: AppConstants.fontSizeCardDescription,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                        height: 1.4,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeCardDescription - 1,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYellowBanner() {
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
      child: Row(
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: AppConstants.iconSizeLarge,
            color: AppColors.black,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Manage vehicle Come in and Go OUT easy.',
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
