import 'package:flutter/material.dart';
import 'package:my_new_app/pages/AppWebView/appweb.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  bool _isLoggedIn = false;
  int _selectedPlanIndex = 1; // Default to popular plan
  String _selectedCategory = 'parking';

  final List<Map<String, dynamic>> _plans = [
    {
      'duration': '1 Month',
      'price': 99,
      'popular': false,
      'savings': null,
    },
    {
      'duration': '6 Months',
      'price': 499,
      'popular': true,
      'savings': '17% OFF',
    },
    {
      'duration': '12 Months',
      'price': 799,
      'popular': false,
      'savings': '33% OFF',
    },
  ];

  final Map<String, List<Map<String, dynamic>>> _features = {
    'parking': [
      {
        'icon': Icons.masks_outlined,
        'iconColor': const Color(0xFF2196F3),
        'title': 'Call Masking service',
      },
      {
        'icon': Icons.search,
        'iconColor': const Color(0xFF4CAF50),
        'title': 'Search 6 vehicles/day',
      },
      {
        'icon': Icons.phone_in_talk,
        'iconColor': const Color(0xFFFF9800),
        'title': 'Call free eTags/Vehicles',
      },
      {
        'icon': Icons.phone_callback,
        'iconColor': const Color(0xFF9C27B0),
        'title': 'Call back missed callers',
      },
      {
        'icon': Icons.location_on_outlined,
        'iconColor': const Color(0xFFE91E63),
        'title': 'Scanner Geo Location & IP',
      },
      {
        'iconType': 'whatsapp',
        'iconColor': const Color(0xFF25D366),
        'title': 'WhatsApp Notification',
      },
      {
        'icon': Icons.folder_outlined,
        'iconColor': const Color(0xFF3F51B5),
        'title': 'Store 5 vehicle documents',
      },
      {
        'icon': Icons.verified_outlined,
        'iconColor': const Color(0xFF4CAF50),
        'title': 'Verified Badge',
      },
      {
        'icon': Icons.local_offer_outlined,
        'iconColor': const Color(0xFFFF9800),
        'title': 'Exclusive offers & early access',
      },
      {
        'icon': Icons.email_outlined,
        'iconColor': const Color(0xFF2196F3),
        'title': 'Direct founder email access',
      },
    ],
    'business': [
      {
        'icon': Icons.brush_outlined,
        'iconColor': const Color(0xFF9C27B0),
        'title': 'Theme Update',
      },
      {
        'iconType': 'whatsapp',
        'iconColor': const Color(0xFF25D366),
        'title': 'Notify followers',
      },
      {
        'icon': Icons.phone_in_talk,
        'iconColor': const Color(0xFFFF9800),
        'title': 'Priority support',
      },
      {
        'icon': Icons.local_offer_outlined,
        'iconColor': const Color(0xFF2196F3),
        'title': 'Exclusive offers & early access',
      },
      {
        'icon': Icons.verified_outlined,
        'iconColor': const Color(0xFF4CAF50),
        'title': 'Verified Badge',
      },
      {
        'icon': Icons.business_outlined,
        'iconColor': const Color(0xFFFF5722),
        'title': 'NGF132 Business Listing',
      },
    ],
    'other': [
      {
        'icon': Icons.masks_outlined,
        'iconColor': const Color(0xFF2196F3),
        'title': 'Call Masking service',
      },
      {
        'icon': Icons.phone_in_talk,
        'iconColor': const Color(0xFFFF9800),
        'title': 'International Calls',
      },
      {
        'iconType': 'whatsapp',
        'iconColor': const Color(0xFF25D366),
        'title': 'Video calls & Geo Fencing',
      },
      {
        'icon': Icons.phone_callback,
        'iconColor': const Color(0xFF9C27B0),
        'title': 'Priority support',
      },
      {
        'icon': Icons.local_offer_outlined,
        'iconColor': const Color(0xFF4CAF50),
        'title': 'Exclusive offers & early access',
      },
      {
        'icon': Icons.verified_outlined,
        'iconColor': const Color(0xFF00BCD4),
        'title': 'Verified Badge',
      },
    ],
  };

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

  void _goPro() async {
    try {
      // Get user phone from local storage
      final userData = await AuthService.getUserData();
      String phone = userData['phone'] ?? '';
      String countryCode = userData['countryCode'] ?? '91';

      // Combine country code and phone
      countryCode = countryCode.replaceFirst('+', '');
      final fullPhone = countryCode + phone;

      // Build the URL with phone parameter
      final membershipUrl = 'https://app.ngf132.com/member_app?ph=$fullPhone';

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InAppWebViewPage(
              url: membershipUrl,
              title: 'Get Membership',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
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
                AppHeader(
                  isLoggedIn: _isLoggedIn,
                  showBackButton: true,
                  showUserInfo: false,
                  showCartIcon: false,
                ),

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
                          const SizedBox(height: 16),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingPage),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.workspace_premium_rounded,
                                  color: AppColors.activeYellow,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Membership',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizePageTitle,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingPage),
                            child: Text(
                              'Become a member, you would love it.',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeSubtitle,
                                color: AppColors.textGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          _buildTrialBanner(),
                          const SizedBox(height: 16),
                          _buildPlanSelection(),
                          const SizedBox(height: 16),
                          _buildCategoryPills(),
                          const SizedBox(height: 16),
                          _buildFeaturesGrid(),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildTrialBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingPage),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.activeYellow.withOpacity(0.2),
            AppColors.primaryYellow.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
        border: Border.all(
          color: AppColors.activeYellow.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.activeYellow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.celebration_outlined,
              color: AppColors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '45 Days',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.activeYellow,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'FREE',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Auto-active when you activate your tag',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardDescription,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Plan',
            style: TextStyle(
              fontSize: AppConstants.fontSizeSectionTitle,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              _plans.length,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < _plans.length - 1 ? 8 : 0,
                  ),
                  child: _buildPlanCard(index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NO SHADOW
  Widget _buildPlanCard(int index) {
    final plan = _plans[index];
    final isSelected = _selectedPlanIndex == index;
    final isPopular = plan['popular'] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.activeYellow : AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          border: Border.all(
            color: isSelected ? AppColors.activeYellow : AppColors.lightGrey,
            width: isSelected ? 2.5 : 1.5,
          ),
          // ✅ REMOVED boxShadow
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.black : AppColors.activeYellow,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'POPULAR',
                  style: TextStyle(
                    fontSize: 6,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? AppColors.activeYellow : AppColors.black,
                  ),
                ),
              )
            else
              const SizedBox(height: 9),
            const SizedBox(height: 3),
            Text(
              plan['duration'],
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              '₹${plan['price']}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.black,
              ),
            ),
            if (plan['savings'] != null) ...[
              const SizedBox(height: 1),
              Text(
                plan['savings'],
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ] else
              const SizedBox(height: 9),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPills() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingPage),
      child: Row(
        children: [
          Expanded(
            child: _buildCategoryPill('parking', 'Parking Tags', Icons.local_parking_outlined),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildCategoryPill('business', 'Business Card', Icons.business_center_outlined),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildCategoryPill('other', 'All Other Tags', Icons.style_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(String category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.activeYellow : AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.activeYellow : AppColors.lightGrey,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: AppColors.black,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    final features = _features[_selectedCategory] ?? [];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium Features',
            style: TextStyle(
              fontSize: AppConstants.fontSizeSectionTitle,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: features.map((feature) => _buildFeatureCard(feature)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    return Container(
      width: (MediaQuery.of(context).size.width - 50) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (feature['iconType'] == 'whatsapp')
            Image.asset(
              'assets/icons/whatsapp.png',
              width: 20,
              height: 20,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.message_outlined,
                  size: 20,
                  color: feature['iconColor'],
                );
              },
            )
          else
            Icon(
              feature['icon'],
              size: 20,
              color: feature['iconColor'],
            ),
          const SizedBox(height: 8),
          Text(
            feature['title'],
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ✅ NO SHADOW
  Widget _buildBottomButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.buttonPaddingVertical),
        decoration: BoxDecoration(
          color: AppColors.white,
          // ✅ REMOVED boxShadow
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: AppConstants.buttonHeightMedium,
            child: ElevatedButton(
              onPressed: _goPro,
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
                  Icon(Icons.flash_on, size: 18, color: AppColors.black),
                  const SizedBox(width: 8),
                  Text(
                    'Go Pro - ₹${_plans[_selectedPlanIndex]['price']}',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeButtonPriceText,
                      fontWeight: FontWeight.w800,
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
