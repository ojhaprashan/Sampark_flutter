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

  // ✅ UPDATED: Changed to BoxFit.cover for aspect ratio filling
  final List<MediaSliderItem> _sliderItems = [
    MediaSliderItem.networkImage(
      url: 'https://sampark.me/assets/app/society_1.png',
      boxFit: BoxFit.cover,
    ),
    MediaSliderItem.networkImage(
      url: 'https://sampark.me/assets/app/society_2.png',
      boxFit: BoxFit.cover,
    ),
    MediaSliderItem.networkImage(
      url: 'https://sampark.me/assets/app/society_3.png',
      boxFit: BoxFit.cover,
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

  // Open Apply Form in WebView
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

                          // ✅ Media Slider with 1024/500 Aspect Ratio
                          _buildImageSlider(),

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

                                const SizedBox(height: 24),

                                // How It Works Section
                                _buildSectionTitle('How It Works'),
                                const SizedBox(height: 12),
                                _buildStepCard(
                                  step: '1',
                                  title: 'Register Your Society',
                                  description: 'Sign up your society or hotel with us and get approved.',
                                ),
                                const SizedBox(height: 10),
                                _buildStepCard(
                                  step: '2',
                                  title: 'Order Custom Tags',
                                  description: 'Order tags with your society logo and branding.',
                                ),
                                const SizedBox(height: 10),
                                _buildStepCard(
                                  step: '3',
                                  title: 'Distribute to Residents',
                                  description: 'Distribute tags to all vehicle owners in your society.',
                                ),
                                const SizedBox(height: 10),
                                _buildStepCard(
                                  step: '4',
                                  title: 'Monitor & Manage',
                                  description: 'Track vehicle movement and manage parking easily.',
                                ),

                                const SizedBox(height: 24),

                                // Benefits Section
                                _buildSectionTitle('Key Benefits'),
                                const SizedBox(height: 12),
                                _buildBenefitItem('🎯 Enhanced Security', 'Better vehicle identification and access control'),
                                const SizedBox(height: 10),
                                _buildBenefitItem('📊 Real-time Data', 'Get instant vehicle logs and reports'),
                                const SizedBox(height: 10),
                                _buildBenefitItem('👥 Resident Safety', 'Emergency contact system with privacy protection'),
                                const SizedBox(height: 10),
                                _buildBenefitItem('💼 Professional Image', 'Branded tags enhance your society\'s profile'),

                                const SizedBox(height: 24),

                                // Investment Section
                                _buildInvestmentCard(),

                                const SizedBox(height: 24),

                                // FAQ Section
                                _buildSectionTitle('Frequently Asked Questions'),
                                const SizedBox(height: 12),
                                _buildFAQItem(
                                  question: 'What is the minimum investment?',
                                  answer: 'Minimum investment starts from Rs 51,000 for a complete setup.',
                                ),
                                const SizedBox(height: 10),
                                _buildFAQItem(
                                  question: 'How long does registration take?',
                                  answer: 'Usually 3-5 business days after document verification.',
                                ),
                                const SizedBox(height: 10),
                                _buildFAQItem(
                                  question: 'Can we customize the tag design?',
                                  answer: 'Yes, we can print your society logo on every tag.',
                                ),

                                const SizedBox(height: 24),

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

  // ✅ Image Slider with 1024/500 Aspect Ratio
  Widget _buildImageSlider() {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidePadding = 16.0; 
    double sliderWidth = screenWidth - (sidePadding * 2);
    
    // ✅ Aspect Ratio Calculation
    double sliderHeight = sliderWidth / (1024 / 500);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sidePadding),
      child: MediaSlider(
        items: _sliderItems,
        height: sliderHeight, // ✅ Dynamic height
        borderRadius: BorderRadius.circular(20), // ✅ Rounded corners
        autoScroll: true,
        show3DEffect: false,
        autoScrollDuration: const Duration(seconds: 4),
        viewportFraction: 1.0,
        showIndicators: true,
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: AppConstants.fontSizeCardTitle,
        fontWeight: FontWeight.w800,
        color: AppColors.black,
      ),
    );
  }

  // Step Card for How It Works
  Widget _buildStepCard({
    required String step,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
        border: Border.all(
          color: AppColors.primaryYellow.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryYellow,
                  AppColors.activeYellow,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeCardTitle,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardDescription - 1,
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

  // Benefit Item
  Widget _buildBenefitItem(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.activeYellow.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
        border: Border.all(
          color: AppColors.activeYellow.withOpacity(0.2),
          width: 1,
        ),
      ),
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
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardDescription - 1,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // Investment Card
  Widget _buildInvestmentCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryYellow.withOpacity(0.1),
            AppColors.activeYellow.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
        border: Border.all(
          color: AppColors.primaryYellow.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_money_rounded,
                size: AppConstants.iconSizeMedium,
                color: AppColors.black,
              ),
              const SizedBox(width: 10),
              Text(
                'Investment Details',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeCardTitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInvestmentRow('Minimum Investment', 'Rs 51,000'),
          const SizedBox(height: 10),
          _buildInvestmentRow('Tags (250 units)', 'Included'),
          const SizedBox(height: 10),
          _buildInvestmentRow('Setup & Training', 'Included'),
          const SizedBox(height: 10),
          _buildInvestmentRow('Annual Support', 'Available'),
        ],
      ),
    );
  }

  // Investment Row
  Widget _buildInvestmentRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppConstants.fontSizeCardDescription,
            fontWeight: FontWeight.w500,
            color: AppColors.textGrey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: AppConstants.fontSizeCardDescription,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }

  // FAQ Item
  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.activeYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  size: 16,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question,
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
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardDescription - 1,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey,
                height: 1.4,
              ),
            ),
          ),
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