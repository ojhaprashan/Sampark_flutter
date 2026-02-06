import 'package:flutter/material.dart';
import 'package:my_new_app/pages/AppWebView/appweb.dart';
import 'package:my_new_app/pages/business_card/business_card_page.dart';
import 'package:my_new_app/pages/demo/widgets/demo.dart';
import 'package:my_new_app/pages/franchise/franchise_page.dart';
import 'package:my_new_app/pages/main_navigation.dart';
import 'package:my_new_app/pages/sampark_tag/sampark_tag_page.dart';
import 'package:my_new_app/pages/shop/widgets/shop.dart';
import 'package:my_new_app/pages/shops_garages/shops_garages_page.dart';
import 'package:my_new_app/pages/society_hotels/society_hotels_page.dart';
import 'package:my_new_app/pages/support/widgets/support.dart';
import 'package:my_new_app/pages/track/track_order_page.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import 'package:my_new_app/pages/widgets/media_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../auth/login_page.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> with SingleTickerProviderStateMixin {
  bool _isLoggedIn = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // Tab changed
      });
    });
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  // ✅ URL Launcher Methods
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }


Future<void> launchURL(String url) async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => InAppWebViewPage(
        url: url,
        title: 'Loading...',
      ),
    ),
  );
}


  Future<void> _openTelegram() async {
    const channelId = 'qJManqEcyWowNWY0';
    final url = 'https://t.me/joinchat/$channelId';
    await _launchURL(url);
  }

  Future<void> _openWhatsApp() async {
    const groupId = '0029VactrdM2v1IruFRrDq3W';
    final url = 'https://www.whatsapp.com/channel/$groupId';
    await _launchURL(url);
  }

  Future<void> _openInstagram() async {
    const username = 'ngf132';
    final url = 'https://www.instagram.com/$username';
    await _launchURL(url);
  }

  Future<void> _openTwitter() async {
    const url = 'https://x.com/ngf132';
    await _launchURL(url);
  }

  Future<void> _openFacebook() async {
    const url = 'https://www.facebook.com/NGF132';
    await _launchURL(url);
  }

  Future<void> _openPlayStore() async {
    const url = 'https://play.google.com/store/apps/details?id=com.myapp.ngf132';
    await _launchURL(url);
  }

  Future<void> _openAppStore() async {
    const url = 'https://apps.apple.com/in/app/sampark-me/id1562510071';
    await _launchURL(url);
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

          // Main content
          SafeArea(
            child: Column(
              children: [
                // App Header
                AppHeader(
                  isLoggedIn: _isLoggedIn,
                  showBackButton: false,
                  showUserInfo: false,
                  showCartIcon: false,
                ),

                // White content container
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Compact Page Title
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppConstants.paddingPage,
                            AppConstants.paddingMedium,
                            AppConstants.paddingPage,
                            AppConstants.paddingSmall,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Settings & More',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizePageTitle,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Manage your account',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeSubtitle,
                                      color: AppColors.textGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Compact Tab Bar
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingPage,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              color: AppColors.activeYellow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelColor: AppColors.black,
                            unselectedLabelColor: AppColors.textGrey,
                            labelStyle: const TextStyle(
                              fontSize: AppConstants.fontSizeCardTitle,
                              fontWeight: FontWeight.w700,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontSize: AppConstants.fontSizeCardTitle,
                              fontWeight: FontWeight.w600,
                            ),
                            dividerColor: Colors.transparent,
                            tabs: const [
                              Tab(text: 'Utility'),
                              Tab(text: 'Franchise'),
                              Tab(text: 'Offers'),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppConstants.spacingMedium),

                        // Tab Content
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildUtilityTab(),
                              _buildFranchiseTab(),
                              _buildOffersTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== UTILITY TAB ==========
  Widget _buildUtilityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingPage,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3-column grid (compact)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: AppConstants.spacingSmall,
            mainAxisSpacing: AppConstants.spacingSmall,
            childAspectRatio: 0.95,
            children: [
              _buildCompactMenuCard(
                icon: Icons.help_outline_rounded,
                title: 'How to?',
                iconColor: const Color(0xFF4A9FFF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DemoPage()),
                  );
                },
              ),
              _buildCompactMenuCard(
                icon: _isLoggedIn
                    ? Icons.dashboard_outlined
                    : Icons.login_rounded,
                title: _isLoggedIn ? 'Dashboard' : 'Login',
                iconColor: const Color(0xFFFFB300),
                onTap: () {
                  if (_isLoggedIn) {
                   Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const MainNavigation(initialIndex: 2),
            ),
          );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  }
                },
              ),
              _buildCompactMenuCard(
                icon: Icons.local_shipping_outlined,
                title: 'Track',
                iconColor: const Color(0xFF52C41A),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TrackOrderPage()),
                  );
                },
              ),
              _buildCompactMenuCard(
                icon: Icons.picture_as_pdf_outlined,
                title: 'PDF eTag',
                iconColor: const Color(0xFFFF4444),
                onTap: () {
                  launchURL('https://app.ngf132.com/demo-tag');
                },
              ),
              _buildCompactMenuCard(
                icon: Icons.badge_outlined,
                title: 'Business',
                iconColor: const Color(0xFFFF9C3B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BusinessCardPage()),
                  );
                },
              ),
              _buildCompactMenuCard(
                icon: Icons.qr_code_2_rounded,
                title: 'Sampark',
                iconColor: const Color(0xFF9C27B0),
                onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SamparkTagPage()),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Compact Shop Banner
          _buildCompactShopBanner(),

    
               _buildImageSlider(),
          // Support Card (Always visible)
        
          _buildCompactSupportCard(),
          const SizedBox(height: AppConstants.spacingMedium),


           // ✅ Media Slider
        
                          
        ],
      ),
    );
  }

  // ========== FRANCHISE TAB ==========
  Widget _buildFranchiseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingPage,
      ),
      child: Column(
        children: [
          _buildCompactFranchiseCard(
            icon: Icons.store_mall_directory_outlined,
            title: 'Franchise, Reseller (Bulk)',
            description:
                'Become our distributor. Minimum investment starts with 1.7L RS',
            badge: 'Popular',
            iconColor: const Color(0xFFFF9C3B),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FranchisePage()),
              );
            },
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          _buildCompactFranchiseCard(
            icon: Icons.garage_outlined,
            title: 'Shop and Garages',
            description: 'Get starter pack for your business with your logo.',
            iconColor: const Color(0xFF8B5A00),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShopsGaragesPage()),
              );
            },
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          _buildCompactFranchiseCard(
            icon: Icons.card_giftcard_outlined,
            title: 'Referral Program',
            description:
                'Refer friends & family, earn 20% commission on every sale.',
            badge: 'New',
            iconColor: const Color(0xFF4A9FFF),
            onTap: () {
              _launchURL('https://app.ngf132.com/refer-signup');
            },
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          _buildCompactFranchiseCard(
            icon: Icons.apartment_outlined,
            title: 'Society / Hotels',
            description:
                'Manage Flats, Parking & Vehicle entry. Min. investment Rs 51K',
            iconColor: const Color(0xFF52C41A),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SocietyHotelsPage()),
              );
            },
          ),
          
          const SizedBox(height: AppConstants.spacingTooSmall),
              _buildImageSlider(),
          // Support Card (Always visible)
          _buildCompactSupportCard(),

          const SizedBox(height: AppConstants.spacingMedium),

          // ✅ Media Slider
       
                          
        ],
      ),
    );
  }

  // ========== OFFERS TAB ==========
  Widget _buildOffersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingPage,
      ),
      child: Column(
        children: [
          // ✅ WhatsApp & Influencer Cards - Opens URLs
          Row(
            children: [
              Expanded(
                child: _buildCompactOfferCardWithImage(
                  title: 'WhatsApp Share',
                  imagePath: 'assets/icons/whatsapp.png', // ✅ WhatsApp PNG
                  description: 'Share & Get Rs 500. Winner every week.',
                  color: Colors.green,
                  onTap: () => launchURL('https://app.ngf132.com/lucky_draw'),
                ),
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Expanded(
                child: _buildCompactOfferCard(
                  title: 'Influencer',
                  icon: Icons.video_library,
                  description: 'Make videos, Get Rs 500/10K views.',
                  color: Colors.purple,
                  onTap: () => launchURL('https://app.ngf132.com/influencer'),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingSmall),

          // Rate Us Section with Social Media (Only in Offers tab)
          _buildCompactRateUsWithSocial(),

          const SizedBox(height: AppConstants.spacingTooSmall),
    // ✅ Media Slider
          // ✅ Media Slider
          _buildImageSlider(),
          // Support Card (Always visible)
          _buildCompactSupportCard(),

          const SizedBox(height: AppConstants.spacingMedium),

      
                          
        ],
      ),
    );
  }

  // ========== COMPACT WIDGETS ==========

  // Compact 3-column menu card
  Widget _buildCompactMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppConstants.largeIconSizeGrid,
              color: iconColor ?? AppColors.activeYellow,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeCardTitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Compact Shop Banner
  Widget _buildCompactShopBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ShopPage(showBackButton: true)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppConstants.cardPaddingMedium),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.activeYellow,
              AppColors.darkYellow,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: AppConstants.iconSizeGrid,
              color: AppColors.white,
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SHOP',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSectionTitle,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    'Checkout all products',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSubtitle,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.black,
              size: AppConstants.iconSizeMedium,
            ),
          ],
        ),
      ),
    );
  }

  // Compact Franchise Card
  Widget _buildCompactFranchiseCard({
    required IconData icon,
    required String title,
    required String description,
    String? badge,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.cardPaddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          border: Border.all(
            color: AppColors.lightGrey,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: AppConstants.iconSizeLarge,
              color: iconColor ?? AppColors.activeYellow,
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: AppConstants.fontSizeCardTitle,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badge == 'New' ? Colors.blue : Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: AppConstants.fontSizeSmallText,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
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
      ),
    );
  }

  // ✅ Compact Offer Card with PNG Image (for WhatsApp)
  Widget _buildCompactOfferCardWithImage({
  required String title,
  required String imagePath,
  required String description,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.cardPaddingMedium),
            child: Column(
              children: [
                // ✅ WhatsApp icon WITHOUT background color
                Image.asset(
                  imagePath,
                  width: AppConstants.iconSizeGrid,
                  height: AppConstants.iconSizeGrid,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.share,
                      size: AppConstants.iconSizeGrid,
                      color: color,
                    );
                  },
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeCardTitle,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeSmallText,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppConstants.borderRadiusCard),
                bottomRight: Radius.circular(AppConstants.borderRadiusCard),
              ),
            ),
            child: const Text(
              'Participate',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  // Compact Offer Card (for Influencer with icon)
  Widget _buildCompactOfferCard({
    required String title,
    required IconData icon,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.cardPaddingMedium),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: AppConstants.iconSizeGrid,
                    color: color,
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeCardTitle,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeSmallText,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppConstants.borderRadiusCard),
                  bottomRight: Radius.circular(AppConstants.borderRadiusCard),
                ),
              ),
              child: const Text(
                'Participate',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeCardTitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Compact Rate Us with Social Media - PNG icons with NO background
  Widget _buildCompactRateUsWithSocial() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
        border: Border.all(color: AppColors.lightGrey, width: 1),
      ),
      child: Column(
        children: [
          // Rate Us Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Rate us ',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSectionTitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              ...List.generate(
                5,
                (index) => const Icon(
                  Icons.star,
                  color: AppColors.activeYellow,
                  size: AppConstants.iconSizeLarge,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacingMedium),

          // Store Buttons
          Row(
            children: [
              Expanded(
                child: _buildStoreButton(
                  icon: Icons.play_arrow,
                  label: 'Play Store',
                  onTap: _openPlayStore,
                ),
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Expanded(
                child: _buildStoreButton(
                  icon: Icons.apple,
                  label: 'App Store',
                  onTap: _openAppStore,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Divider
          Container(
            height: 1,
            color: AppColors.lightGrey,
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Social Media Section
          const Text(
            'Follow us on Social Media',
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardTitle,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey,
            ),
          ),

          const SizedBox(height: AppConstants.spacingSmall),

          // ✅ All PNG Social Media Icons - NO BACKGROUND COLOR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialIconPNG(
                'assets/icons/telegram.png',
                'Telegram',
                _openTelegram,
              ),
              _buildSocialIconPNG(
                'assets/icons/whatsapp.png',
                'WhatsApp',
                _openWhatsApp,
              ),
              _buildSocialIconPNG(
                'assets/icons/instagram.png',
                'Instagram',
                _openInstagram,
              ),
              _buildSocialIconPNG(
                'assets/icons/twitter.png',
                'Twitter',
                _openTwitter,
              ),
              _buildSocialIconPNG(
                'assets/icons/facebook.png',
                'Facebook',
                _openFacebook,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.paddingSmall,
          horizontal: AppConstants.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(AppConstants.paddingSmall),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.white,
              size: AppConstants.iconSizeMedium,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeCardDescription,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Social icon with PNG - NO BACKGROUND COLOR, just the colorful PNG icon
  Widget _buildSocialIconPNG(
    String imagePath,
    String name,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        imagePath,
        width: 40, // Icon size
        height: 40,
        errorBuilder: (context, error, stackTrace) {
          // Fallback icon if PNG not found
          IconData fallbackIcon = Icons.language;
          if (name.contains('Telegram')) fallbackIcon = Icons.send;
          if (name.contains('WhatsApp')) fallbackIcon = Icons.chat;
          if (name.contains('Instagram')) fallbackIcon = Icons.camera_alt;
          if (name.contains('Twitter')) fallbackIcon = Icons.close;
          if (name.contains('Facebook')) fallbackIcon = Icons.facebook;
          
          return Icon(
            fallbackIcon,
            color: AppColors.black,
            size: 40,
          );
        },
      ),
    );
  }

  // Compact Support Card (Appears in all 3 tabs)
  Widget _buildCompactSupportCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPaddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
        border: Border.all(color: AppColors.lightGrey, width: 1),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/whatsapp.png',
            width: AppConstants.iconSizeGrid,
            height: AppConstants.iconSizeGrid,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.support_agent_rounded,
                size: AppConstants.iconSizeGrid,
                color: AppColors.activeYellow,
              );
            },
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Help?',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardTitle,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  'Contact support team',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardDescription,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showComingSoon('Support'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: AppColors.activeYellow,
                borderRadius: BorderRadius.circular(AppConstants.paddingSmall),
              ),
              child: const Text(
                'Chat',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeCardTitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SupportPage(),
      ),
    );
  }
}
 Widget _buildImageSlider() {
  return Padding(
     padding: const EdgeInsets.symmetric(horizontal: 0), // ✅ Reduced from 12 to 8
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: MediaSlider(
        items: [
          MediaSliderItem.assetImage(
            assetPath: 'assets/Banner/other/1.png', 
            title: 'Tag Feature 1',
          ),
          MediaSliderItem.assetImage(
            assetPath: 'assets/Banner/other/2.png', 
            title: 'Tag Feature 2',
          ),
          MediaSliderItem.assetImage(
            assetPath: 'assets/Banner/other/3.png', 
            title: 'Tag Feature 3',
          ),
        ],
        height: 110,
        autoScroll: true,
        show3DEffect: false,
        viewportFraction: 1.0,
        showIndicators: false,
      ),
    ),
  );
}