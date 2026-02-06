import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_new_app/pages/AppWebView/appweb.dart';
import 'package:my_new_app/pages/membership/membership_page.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import 'package:my_new_app/services/auth_service.dart';
import 'package:my_new_app/services/tags_service.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import 'manage_tag_tab.dart';
import 'more_tab.dart';

class CarTagDetailsPage extends StatefulWidget {
  final Tag tag;

  const CarTagDetailsPage({super.key, required this.tag});

  @override
  State<CarTagDetailsPage> createState() => _CarTagDetailsPageState();
}

class _CarTagDetailsPageState extends State<CarTagDetailsPage>
    with SingleTickerProviderStateMixin {
  bool _isLoggedIn = false;
  int _selectedTab = 0; // 0 = Manage tag, 1 = MORE
  late PageController _pageController;
  late AnimationController _animationController;
  TagSettings? _tagSettings;
  bool _isLoadingSettings = true;
  String _settingsError = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _checkLoginStatus();
    _loadTagSettings();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }
  }

  Future<void> _loadTagSettings() async {
    try {
      final userData = await AuthService.getUserData();
      final phone = userData['phone'] ?? '';
      final countryCode = userData['countryCode'] ?? '+91';
      final phoneWithCountryCode = countryCode.replaceFirst('+', '') + phone;

      final tagSettings = await TagsService.fetchTagSettings(
        tagId: widget.tag.tagInternalId,
        phone: phoneWithCountryCode,
        smValue: '67s87s6yys66',
        dgValue: 'testYU78dII8iiUIPSISJ',
      );

      if (mounted) {
        setState(() {
          _tagSettings = tagSettings;
          _isLoadingSettings = false;
          _settingsError = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _settingsError = e.toString();
          _isLoadingSettings = false;
        });
      }
    }
  }

  void _onTabTapped(int index) {
    if (_selectedTab == index) return;
    setState(() {
      _selectedTab = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int index) {
    if (_selectedTab == index) return;
    setState(() {
      _selectedTab = index;
    });
    HapticFeedback.lightImpact();
  }

  // ✅ Open RSA in WebView
  void _openRSA() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InAppWebViewPage(
          url: 'https://app.ngf132.com/rsa',
          title: 'Roadside Assistance',
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
          // ✅ Yellow gradient background
          Container(
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
          // ✅ Show loading or content based on state
          if (_isLoadingSettings)
            _buildInitialLoadingScreen()
          else if (_settingsError.isNotEmpty)
            _buildErrorScreen()
          else
            // ✅ Content with curve
            Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: AppHeader(
                    isLoggedIn: _isLoggedIn,
                    showBackButton: true,
                    showUserInfo: false,
                    showCartIcon: false,
                  ),
                ),
                // ✅ Curved white container
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: Column(
                        children: [
                          // Fixed Header Section
                          Container(
                            color: AppColors.background,
                            child: Padding(
                              padding: const EdgeInsets.all(AppConstants.paddingLarge),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Tag Header
                                  _buildTagHeader(),
                                  const SizedBox(height: AppConstants.spacingSmall),
                                  // Scan Count
                                  _buildScanCount(),
                                  const SizedBox(height: AppConstants.spacingMedium),
                                  // Tabs
                                  _buildTabs(),
                                ],
                              ),
                            ),
                          ),
                          // Swipeable PageView for Tab Content
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: _onPageChanged,
                              physics: const BouncingScrollPhysics(),
                              children: [
                                ManageTagTab(
                                  tag: widget.tag,
                                  tagSettings: _tagSettings,
                                ),
                                MoreTab(
                                  tag: widget.tag,
                                  tagSettings: _tagSettings,
                                ),
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
          // Bottom Button with animation
          if (!_isLoadingSettings)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: 20,
              left: 20,
              right: 20,
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    // ✅ Updated logic
                    if (_selectedTab == 1) {
                      // Navigate to Membership Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MembershipPage(),
                        ),
                      );
                    } else {
                      // Show snackbar for "List your car"
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('List your car'),
                          backgroundColor: AppColors.activeYellow,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.activeYellow,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.buttonPaddingVertical,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.buttonBorderRadius,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _selectedTab == 1 ? 'Get Membership' : 'List your car',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeButtonPriceText,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ Initial Loading Screen Widget
  Widget _buildInitialLoadingScreen() {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: AppHeader(
            isLoggedIn: _isLoggedIn,
            showBackButton: true,
            showUserInfo: false,
            showCartIcon: false,
          ),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated icon
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.activeYellow.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.directions_car,
                            size: 64,
                            color: AppColors.activeYellow,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  // Yellow circular progress indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.activeYellow),
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Loading Tag Details...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ✅ Error Screen Widget
  Widget _buildErrorScreen() {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: AppHeader(
            isLoggedIn: _isLoggedIn,
            showBackButton: true,
            showUserInfo: false,
            showCartIcon: false,
          ),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Failed to Load',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Unable to fetch tag details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoadingSettings = true;
                          _settingsError = '';
                        });
                        _loadTagSettings();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.activeYellow,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPaddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
        border: Border.all(
          color: AppColors.lightGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${widget.tag.displayName}',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizePageTitle,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tag Status: ${widget.tag.status}',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSubtitle,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          // ✅ RSA Badge - Now clickable
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _openRSA();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.activeYellow,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.activeYellow.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    'RSA',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeCardTitle,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.car_repair,
                    size: AppConstants.iconSizeMedium,
                    color: AppColors.black,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        'Tag id: ${widget.tag.tagPublicId}',
        style: TextStyle(
          fontSize: AppConstants.fontSizeSubtitle,
          color: AppColors.textGrey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _onTabTapped(0);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
                vertical: AppConstants.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(
                  bottom: BorderSide(
                    color: _selectedTab == 0
                        ? AppColors.activeYellow
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSectionTitle,
                  fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w600,
                  color: AppColors.black,
                ),
                child: const Text('Manage tag'),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingLarge),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _onTabTapped(1);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _selectedTab == 1
                        ? AppColors.activeYellow
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSectionTitle,
                  fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w500,
                  color: _selectedTab == 1
                      ? AppColors.black
                      : AppColors.textGrey,
                ),
                child: const Text('MORE'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
