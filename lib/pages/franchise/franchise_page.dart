import 'package:flutter/material.dart';
import 'package:my_new_app/pages/AppWebView/appweb.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import 'package:my_new_app/pages/widgets/media_slider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';


class FranchisePage extends StatefulWidget {
  const FranchisePage({super.key});


  @override
  State<FranchisePage> createState() => _FranchisePageState();
}


class _FranchisePageState extends State<FranchisePage> {
  bool _isLoggedIn = false;


  // Media items for slider
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
                                  'Franchise with Sampark Tags',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizePageTitle,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Start by Selling, become our partner in your city for Sampark Tags. We will get you orders, marketing materials and more.',
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

                          const SizedBox(height: 12), // ✅ Minimal gap

                          // ✅ Media Slider - Compact version
                          _buildImageSlider(),

                          const SizedBox(height: AppConstants.spacingLarge),

                          // Investment Card
                          _buildInvestmentCard(),

                          const SizedBox(height: AppConstants.spacingMedium),

                          // Assured Income Card
                          _buildAssuredIncomeCard(),

                          const SizedBox(height: AppConstants.spacingLarge),

                          // Services Section
                          _buildServicesSection(),

                          const SizedBox(height: AppConstants.spacingLarge),

                          // Support and Promise
                          _buildSupportSection(),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),


          // Bottom Button
          _buildBottomButton(),
        ],
      ),
    );
  }


  // ✅ Compact Image Slider - Minimal spacing
  Widget _buildImageSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ClipRRect(
        // borderRadius: BorderRadius.circular(12),
        child: MediaSlider(
          items: _mediaItems,
          height: 180, // ✅ Reduced height
          autoScroll: true,
          show3DEffect: false,
          autoScrollDuration: const Duration(seconds: 4),
          viewportFraction: 1.0,
          showIndicators: true,
        ),
      ),
    );
  }


  Widget _buildInvestmentCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingPage),
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.activeYellow,
            AppColors.darkYellow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Minimum Investment 1.7L Rs.',
            style: TextStyle(
              fontSize: AppConstants.fontSizeSectionTitle,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Franchise with Sampark Tags',
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardTitle,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start by Selling, become our partner in your city for Sampark Tags. We will get you orders, marketing materials and more.',
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardDescription,
              fontWeight: FontWeight.w500,
              color: AppColors.black.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAssuredIncomeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingPage),
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.lightGrey,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Make assured Min 50k-1L / Month',
            style: TextStyle(
              fontSize: AppConstants.fontSizeSectionTitle,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You buy stock, we will send you orders, we will get you shipping company, and everything. you only have to ship all orders you ship from sampark business. (Min Stock 1K)',
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardTitle,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }


  // ✅ Services Section - 3 items per row with colorful icons
  Widget _buildServicesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Services',
            style: TextStyle(
              fontSize: AppConstants.fontSizeSectionTitle,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          
          // Single container with grid layout inside (3 columns)
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.lightGrey,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Row 1
                Row(
                  children: [
                    Expanded(
                      child: _buildServiceItem(
                        Icons.phone_in_talk,
                        'Masked Audio\nCalls',
                        const Color(0xFF2196F3), // Blue
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildServiceItemWithImage(
                        'assets/icons/whatsapp.png',
                        'WhatsApp\nNotifications',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildServiceItem(
                        Icons.picture_as_pdf,
                        'PDF Tag\n(Offline)',
                        const Color(0xFFE91E63), // Pink
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Row 2
                Row(
                  children: [
                    Expanded(
                      child: _buildServiceItem(
                        Icons.videocam,
                        'Masked Video\nCalls',
                        const Color(0xFF9C27B0), // Purple
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildServiceItem(
                        Icons.phone_callback,
                        'Call Back\nCaller',
                        const Color(0xFF00BCD4), // Cyan
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildServiceItem(
                        Icons.location_on,
                        'Check\nLocation',
                        const Color(0xFF4CAF50), // Green
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Row 3
                Row(
                  children: [
                    Expanded(
                      child: _buildServiceItem(
                        Icons.sms,
                        'Offline SMS\nAvailable',
                        const Color(0xFFFF9800), // Orange
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildServiceItem(
                        Icons.headset_mic,
                        'Live Support\nAlways',
                        const Color(0xFFF44336), // Red
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Empty space to maintain 3-column grid
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // ✅ Service item with colorful icon
  Widget _buildServiceItem(IconData icon, String title, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 32,
          color: color,
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            height: 1.3,
          ),
          maxLines: 2,
        ),
      ],
    );
  }


  // ✅ Service item with WhatsApp PNG image
  Widget _buildServiceItemWithImage(String imagePath, String title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          imagePath,
          width: 32,
          height: 32,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.chat_bubble,
              size: 32,
              color: Color(0xFF25D366),
            );
          },
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            height: 1.3,
          ),
          maxLines: 2,
        ),
      ],
    );
  }


  Widget _buildSupportSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Support and Promise',
            style: TextStyle(
              fontSize: AppConstants.fontSizeSectionTitle,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          
          _buildPromiseItem('Pamphlets, Brochure, Standee, Sales Pitch, Videos & Pictures.'),
          const SizedBox(height: AppConstants.spacingSmall),
          _buildPromiseItem('Certificate, Agreements & Booklets.'),
          const SizedBox(height: AppConstants.spacingSmall),
          _buildPromiseItem('Dedicated Manager.'),
          const SizedBox(height: AppConstants.spacingSmall),
          _buildPromiseItem('Exclusive Rights in Your City*.'),
        ],
      ),
    );
  }


  Widget _buildPromiseItem(String text) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        border: Border.all(
          color: AppColors.lightGrey,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: AppConstants.iconSizeLarge,
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBottomButton() {
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
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InAppWebViewPage(
                    url: 'https://app.ngf132.com/resellers-form',
                    title: 'Franchise Form',
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
            child: Text(
              'Start Franchise',
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
