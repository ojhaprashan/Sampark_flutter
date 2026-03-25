import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_new_app/pages/AppWebView/appweb.dart';
import 'package:my_new_app/pages/membership/membership_page.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import 'package:my_new_app/services/auth_service.dart';
import 'package:my_new_app/services/tags_service.dart';
import 'package:my_new_app/services/etag_service.dart';
import 'package:my_new_app/services/premium_service.dart';
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
  bool _hasPremium = false; 
  bool _isLoadingPremium = false; 

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
    _loadPremiumData(); 
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

  Future<void> _loadPremiumData() async {
    try {
      setState(() {
        _isLoadingPremium = true;
      });
      final premiumData = await PremiumService.getCachedPremiumData();
      if (mounted) {
        setState(() {
          _hasPremium = premiumData?.hasPremium ?? false;
          _isLoadingPremium = false;
        });
      }
    } catch (e) {
      print('Error loading premium data: $e');
      if (mounted) {
        setState(() {
          _isLoadingPremium = false;
        });
      }
    }
  }

  bool _isVehicleFromStateCode(List<String> stateCodes) {
    final vehicleNumber = widget.tag.displayName.toUpperCase();
    print('Checking vehicle number: $vehicleNumber against state codes: $stateCodes');
    return stateCodes.any((code) => vehicleNumber.startsWith(code));
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
          if (_isLoadingSettings)
            _buildInitialLoadingScreen()
          else if (_settingsError.isNotEmpty)
            _buildErrorScreen()
          else
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
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F6F8), // ✅ Professional Off-White Background
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
                          Container(
                            color: const Color(0xFFF5F6F8), // ✅ Ensure header matches
                            child: Padding(
                              padding: const EdgeInsets.all(AppConstants.paddingLarge),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTagHeader(),
                                  const SizedBox(height: AppConstants.spacingSmall),
                                  if (_tagSettings?.data.isDemoTag ?? false)
                                    _buildDemoTagDisclaimer(),
                                  if (_tagSettings?.data.isDemoTag ?? false)
                                    const SizedBox(height: AppConstants.spacingSmall),
                                  _buildTabs(),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: _onPageChanged,
                              physics: const BouncingScrollPhysics(),
                              children: [
                                ManageTagTab(
                                  tag: widget.tag,
                                  tagSettings: _tagSettings,
                                  onDataUpdated: _loadTagSettings, 
                                ),
                                MoreTab(
                                  tag: widget.tag,
                                  tagSettings: _tagSettings,
                                  onDataUpdated: _loadTagSettings, 
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
          if (!_isLoadingSettings && 
              !_isLoadingPremium &&
              ((_selectedTab == 0 && _isVehicleFromStateCode(['DL', 'UP'])) || 
               (_selectedTab == 1 && !_hasPremium)))
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
                    if (_selectedTab == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MembershipPage(),
                        ),
                      );
                    } else {
                      final vehicleNumber = widget.tag.displayName;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InAppWebViewPage(
                            url: 'https://app.ngf132.com/list_car?c=$vehicleNumber',
                            title: 'List Your Vehicle',
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
              color: Color(0xFFF5F6F8), // ✅ Match off-white
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
              color: Color(0xFFF5F6F8), // ✅ Match off-white
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white, // ✅ Keep card white
        borderRadius: BorderRadius.circular(16),
        // ✅ Add modern, subtle drop shadow instead of harsh border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tag id: ${widget.tag.tagPublicId}',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _openRSA();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.activeYellow,
                borderRadius: BorderRadius.circular(10),
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
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.car_repair,
                    size: 16,
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

  Widget _buildDemoTagDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: AppConstants.spacingSmall),
          Expanded(
            child: Text(
              'This is a demo tag for testing purposes only',
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardDescription,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
     margin: const EdgeInsets.only(
        top: AppConstants.paddingSmall,
        bottom: 0, // Set to 0
      ),
      padding: const EdgeInsets.all(4), // Inner padding to create a track effect
      decoration: BoxDecoration(
        color: AppColors.white, // Solid white background
        borderRadius: BorderRadius.circular(30), // Fully rounded pill shape
        
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Hugs the tabs tightly
        children: [
          // Manage Tag Tab
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _onTabTapped(0);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(
                horizontal: 24, 
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: _selectedTab == 0 
                    ? AppColors.activeYellow // Solid flat yellow
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(26), // Inner pill
                // ✅ Removed the yellow glowing shadow
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSectionTitle,
                  fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w600,
                  color: _selectedTab == 0 ? Colors.white : AppColors.textGrey,
                  letterSpacing: 0.3,
                ),
                child: const Text('Manage tag'),
              ),
            ),
          ),
          
          // MORE Tab
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _onTabTapped(1);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(
                horizontal: 28, // Slightly wider padding for shorter word to balance it
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: _selectedTab == 1 
                    ? AppColors.activeYellow // Solid flat yellow
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(26),
                // ✅ Removed the yellow glowing shadow
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSectionTitle,
                  fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w600,
                  color: _selectedTab == 1 ? Colors.white : AppColors.textGrey,
                  letterSpacing: 0.3,
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