import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_new_app/pages/widgets/notification_sheet.dart';
import 'package:my_new_app/pages/widgets/edit_tag_sheet.dart';
import 'package:my_new_app/services/emergency_service.dart';
import 'package:my_new_app/services/premium_service.dart';
import 'package:my_new_app/pages/tags/car/add_secondary_number_sheet.dart';
import 'package:my_new_app/pages/tags/car/add_emergency_contact_sheet.dart';
import 'package:my_new_app/pages/membership/membership_page.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/tags_service.dart';
import '../../widgets/app_header.dart';
import 'lost_found_list_page.dart';
import '../../scan/contact_vehicle_owner_page.dart';

class LostFoundDetailsPage extends StatefulWidget {
  final LostFoundItem item;

  const LostFoundDetailsPage({super.key, required this.item});

  @override
  State<LostFoundDetailsPage> createState() => _LostFoundDetailsPageState();
}

class _LostFoundDetailsPageState extends State<LostFoundDetailsPage>
    with SingleTickerProviderStateMixin {
  bool _isLoggedIn = false;
  int _selectedTab = 0; // 0 = Manage tag, 1 = MORE
  late PageController _pageController;
  late AnimationController _animationController;
  int scanCount = 94; // Sample data
  TagSettings? _tagSettings;
  bool _isLoadingSettings = true;
  String _settingsError = '';
  bool _isLoading = false;

  // ✅ State variables with default values
  bool _isCallsEnabled = true;
  bool _isTagEnabled = true;
  bool _isWhatsappEnabled = false;
  bool _isCallMaskingEnabled = false;
  bool _isVideoCallEnabled = false;
  String _userPhone = '';
  String _countryCode = '+91'; // ✅ Default to India
  bool _hasPremium = false; // ✅ Premium status
  bool _isLoadingPremium = false; // ✅ Loading premium data

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
        tagId: widget.item.id,
        phone: phoneWithCountryCode,
        smValue: '67s87s6yys66',
        dgValue: 'testYU78dII8iiUIPSISJ',
      );

      if (mounted) {
        setState(() {
          _tagSettings = tagSettings;
          _isLoadingSettings = false;
          _settingsError = '';
          _userPhone = phone;
          _countryCode = countryCode; // ✅ Set country code

          // ✅ Update state variables from API
          _isCallsEnabled = tagSettings.data.callStatus.callsEnabled;
          _isTagEnabled = tagSettings.data.status == 'Active';
          _isWhatsappEnabled = tagSettings.data.callStatus.whatsappEnabled;
          _isCallMaskingEnabled = tagSettings.data.callStatus.callMaskingEnabled;
          _isVideoCallEnabled = tagSettings.data.callStatus.videoCallEnabled;
        });
      }
      
      // ✅ Load premium data
      _loadPremiumData();
    } catch (e) {
      if (mounted) {
        setState(() {
          _settingsError = 'Failed to load tag settings';
          _isLoadingSettings = false;
        });
      }
    }
  }

  // ✅ Load premium data from cache
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
                                  // Title
                                  Text(
                                    '#${widget.item.tagId}',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizePageTitle,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  const SizedBox(height: AppConstants.spacingSmall),
                                  // Tabs
                                  _buildTabs(),
                                  const SizedBox(height: AppConstants.spacingSmall),
                                  // Scan Count
                                  Text(
                                    'Hey, Your Tag got scanned $scanCount times',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeSubtitle,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
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
                                _buildScrollableContent(_buildManageTabContent()),
                                _buildScrollableContent(_buildMoreTabContent()),
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
          // Bottom Button
          if (!_isLoadingSettings && _selectedTab == 1 && !_hasPremium && !_isLoadingPremium)
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MembershipPage(),
                      ),
                    );
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
                    'Get Membership',
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
                            Icons.label_important,
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

  Widget _buildScrollableContent(Widget content) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
        ),
        child: Column(
          children: [
            content,
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ✅ Demo Tag Disclaimer Widget
  Widget _buildDemoTagDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(
          color: Colors.orange.shade200,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
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

  Widget _buildManageTabContent() {
    return Column(
      children: [
        const SizedBox(height: AppConstants.spacingMedium),
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          iconColor: Colors.blue.shade600,
          label: 'View Contact Page.',
          trailing: Icons.chat_bubble_outline,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactVehicleOwnerPage(
                  tagId: _tagSettings?.data.tagId ?? 0,
                  vehicleNumber: widget.item.tagId,
                  vehicleName: widget.item.type,
                ),
              ),
            );
          },
        ),
        _buildActionButtonHighlighted(
          icon: Icons.notifications,
          label: 'View Notifications',
          trailing: Icons.notifications,
          onTap: () => _showNotificationSheet(),
        ),
        _buildActionButton(
          icon: Icons.location_on_outlined,
          iconColor: Colors.red.shade600,
          label: 'Check scan locations',
          trailing: Icons.location_on_outlined,
          onTap: () {},
        ),
        // ✅ Dynamic Disable/Enable Calls Button (shows opposite action)
        _buildActionButton(
          icon: _isCallsEnabled ? Icons.phone_disabled : Icons.phone_enabled,
          iconColor: _isCallsEnabled ? Colors.red.shade700 : Colors.green.shade600,
          label: _isCallsEnabled ? 'Disable Calls' : 'Enable Calls',
          trailing: _isCallsEnabled ? Icons.toggle_on : Icons.toggle_off_outlined,
          onTap: () {
            _toggleCalls();
          },
        ),
        // ✅ Dynamic Enable/Disable Tag Button (shows opposite action)
        _buildActionButton(
          icon: _isTagEnabled ? Icons.pause : Icons.play_arrow,
          iconColor: _isTagEnabled ? Colors.orange.shade600 : Colors.green.shade600,
          label: _isTagEnabled ? 'Pause the tag' : 'Resume the tag',
          trailing: _isTagEnabled ? Icons.pause : Icons.play_arrow,
          onTap: () {
            _toggleTag();
          },
        ),
        _buildActionButton(
          icon: Icons.phone,
          iconColor: Colors.teal.shade600,
          label: 'Add secondary number',
          trailing: Icons.phone,
          onTap: () {
            _showAddSecondaryNumberSheet();
          },
        ),
        _buildActionButton(
          icon: Icons.delete_outline,
          iconColor: Colors.red.shade600,
          label: 'Delete and re-write tag',
          trailing: Icons.close,
          isRed: true,
          onTap: () {
            final phoneWithCountryCode = _countryCode.replaceFirst('+', '') + _userPhone;
            EditTagSheet.show(
              context,
              vehicleNumber: widget.item.tagId,
              tagId: widget.item.id,
              phone: phoneWithCountryCode,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMoreTabContent() {
    return Column(
      children: [
        const SizedBox(height: AppConstants.spacingMedium),
        // Membership Badge or Get Premium Button
        if (!_isLoadingPremium) ...[
          if (_hasPremium)
            Container(
              padding: const EdgeInsets.all(AppConstants.cardPaddingMedium),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: Colors.purple.shade200,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        size: AppConstants.iconSizeLarge,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Premium Member',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeSectionTitle,
                              fontWeight: FontWeight.w700,
                              color: Colors.purple,
                            ),
                          ),
                          Text(
                            'Enjoy exclusive features',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeCardDescription,
                              color: Colors.purple.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 24,
                  ),
                ],
              ),
            )
         
        ],
        // ✅ Shows opposite text (Enable when disabled, Disable when enabled)
        _buildActionButton(
          icon: _isWhatsappEnabled ? Icons.chat_bubble : Icons.chat_bubble_outline,
          iconColor: _isWhatsappEnabled ? Colors.green.shade600 : Colors.grey,
          label: _isWhatsappEnabled ? 'Disable WhatsApp Notifications' : 'Enable WhatsApp Notifications',
          trailing: _isWhatsappEnabled ? Icons.toggle_on : Icons.toggle_off_outlined,
          onTap: () {
            _toggleWhatsapp();
          },
        ),
        _buildActionButton(
          icon: _isCallMaskingEnabled ? Icons.phone : Icons.phone_disabled,
          iconColor: _isCallMaskingEnabled ? Colors.green.shade600 : Colors.red.shade600,
          label: _isCallMaskingEnabled ? 'Disable Call Masking' : 'Enable Call Masking',
          trailing: _isCallMaskingEnabled ? Icons.toggle_on : Icons.toggle_off_outlined,
          onTap: () {
            _toggleCallMasking();
          },
        ),
        _buildActionButton(
          icon: _isVideoCallEnabled ? Icons.videocam : Icons.videocam_off,
          iconColor: _isVideoCallEnabled ? Colors.green.shade600 : Colors.grey.shade600,
          label: _isVideoCallEnabled ? 'Disable Video Call' : 'Enable Video Call',
          trailing: _isVideoCallEnabled ? Icons.toggle_on : Icons.toggle_off_outlined,
          onTap: () {
            _toggleVideoCall();
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    Color? iconColor,
    required String label,
    IconData? trailing,
    bool isRed = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.cardPaddingMedium,
          vertical: AppConstants.cardPaddingMedium,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          border: Border.all(
            color: AppColors.lightGrey,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppConstants.iconSizeMedium,
              color: iconColor ?? (isRed ? Colors.red : AppColors.black),
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeCardTitle,
                  fontWeight: FontWeight.w500,
                  color: isRed ? Colors.red : AppColors.black,
                ),
              ),
            ),
            if (trailing != null)
              Icon(
                trailing,
                size: AppConstants.iconSizeMedium,
                color: isRed ? Colors.red : AppColors.textGrey,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonHighlighted({
    required IconData icon,
    required String label,
    IconData? trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.cardPaddingMedium,
          vertical: AppConstants.cardPaddingMedium,
        ),
        decoration: BoxDecoration(
          color: AppColors.activeYellow,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          border: Border.all(
            color: AppColors.activeYellow,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.notifications,
              size: AppConstants.iconSizeMedium,
              color: AppColors.black,
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeCardTitle,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
            if (trailing != null)
              Icon(
                trailing,
                size: AppConstants.iconSizeMedium,
                color: AppColors.black,
              ),
          ],
        ),
      ),
    );
  }

  // ========================
  // ✅ LOADING OVERLAY
  // ========================

  // ✅ Show Loading Overlay (Simple loader without text)
  void _showLoadingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.activeYellow),
              strokeWidth: 4,
            ),
          ),
        );
      },
    );
  }

  // ✅ Hide Loading Overlay
  void _hideLoadingOverlay() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // ========================
  // ✅ TOGGLE FUNCTIONS
  // ========================

  // ✅ Toggle Calls Function with API call and Loading Overlay
  void _toggleCalls() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.mediumImpact();
    _showLoadingOverlay();

    try {
      final userData = await AuthService.getUserData();
      final phone = userData['phone'] ?? '';
      final countryCode = userData['countryCode'] ?? '+91';
      final phoneWithCountryCode = countryCode.replaceFirst('+', '') + phone;

      final newCallsEnabled = !_isCallsEnabled;

      await TagsService.updateTagSettings(
        tagId: _tagSettings?.data.tagId.toString() ?? '',
        phone: phoneWithCountryCode,
        callsEnabled: newCallsEnabled,
        whatsappEnabled: _isWhatsappEnabled,
        callMaskingEnabled: _isCallMaskingEnabled,
        videoCallEnabled: _isVideoCallEnabled,
        smValue: '67s87s6yys66',
        dgValue: 'testYU78dII8iiUIPSISJ',
      );

      setState(() {
        _isCallsEnabled = newCallsEnabled;
        _isLoading = false;
      });

      _hideLoadingOverlay();

      _showSuccessDialog(
        icon: newCallsEnabled ? Icons.phone_enabled : Icons.phone_disabled,
        iconColor: newCallsEnabled ? Colors.green : Colors.red,
        title: newCallsEnabled ? 'Calls Enabled' : 'Calls Disabled',
        message: newCallsEnabled
            ? 'You can now receive calls on this tag.'
            : 'Calls have been disabled for this tag.',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _hideLoadingOverlay();
      _showErrorDialog('Error', 'Failed to update call settings: $e');
    }
  }

  // ✅ Toggle Tag Function with API call and Loading Overlay
  void _toggleTag() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.mediumImpact();
    _showLoadingOverlay();

    try {
      final userData = await AuthService.getUserData();
      final phone = userData['phone'] ?? '';
      final countryCode = userData['countryCode'] ?? '+91';
      final phoneWithCountryCode = countryCode.replaceFirst('+', '') + phone;

      final newTagEnabled = !_isTagEnabled;
      // ✅ Set status based on newTagEnabled (active/pause)
      final newStatus = newTagEnabled ? 'active' : 'pause';

      await TagsService.updateTagSettings(
        tagId: _tagSettings?.data.tagId.toString() ?? '',
        phone: phoneWithCountryCode,
        callsEnabled: _isCallsEnabled,
        whatsappEnabled: _isWhatsappEnabled,
        callMaskingEnabled: _isCallMaskingEnabled,
        videoCallEnabled: _isVideoCallEnabled,
        smValue: '67s87s6yys66',
        dgValue: 'testYU78dII8iiUIPSISJ',
        status: newStatus,  // ✅ Pass status parameter
      );

      setState(() {
        _isTagEnabled = newTagEnabled;
        _isLoading = false;
      });

      _hideLoadingOverlay();

      // ✅ Reload tag settings after update
      await _loadTagSettings();

      _showSuccessDialog(
        icon: newTagEnabled ? Icons.check_circle : Icons.pause_circle,
        iconColor: newTagEnabled ? Colors.green : Colors.orange,
        title: newTagEnabled ? 'Tag Enabled' : 'Tag Paused',
        message: newTagEnabled
            ? 'Your tag is now active and can be scanned.'
            : 'Your tag has been paused temporarily.',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _hideLoadingOverlay();
      _showErrorDialog('Error', 'Failed to update tag status: $e');
    }
  }

  // ✅ Toggle WhatsApp
  void _toggleWhatsapp() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.mediumImpact();
    _showLoadingOverlay();

    try {
      final userData = await AuthService.getUserData();
      final phone = userData['phone'] ?? '';
      final countryCode = userData['countryCode'] ?? '+91';
      final phoneWithCountryCode = countryCode.replaceFirst('+', '') + phone;

      final newWhatsappEnabled = !_isWhatsappEnabled;

      await TagsService.updateTagSettings(
        tagId: _tagSettings?.data.tagId.toString() ?? '',
        phone: phoneWithCountryCode,
        callsEnabled: _isCallsEnabled,
        whatsappEnabled: newWhatsappEnabled,
        callMaskingEnabled: _isCallMaskingEnabled,
        videoCallEnabled: _isVideoCallEnabled,
        smValue: '67s87s6yys66',
        dgValue: 'testYU78dII8iiUIPSISJ',
      );

      setState(() {
        _isWhatsappEnabled = newWhatsappEnabled;
        _isLoading = false;
      });

      _hideLoadingOverlay();

      // ✅ Reload settings
      await _loadTagSettings();

      _showSuccessDialog(
        icon: newWhatsappEnabled ? Icons.chat_bubble : Icons.chat_bubble_outline,
        iconColor: newWhatsappEnabled ? Colors.green : Colors.grey,
        title: newWhatsappEnabled ? 'WhatsApp Enabled' : 'WhatsApp Disabled',
        message: newWhatsappEnabled
            ? 'You will receive WhatsApp notifications'
            : 'WhatsApp notifications have been disabled',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _hideLoadingOverlay();
      _showErrorDialog('Error', 'Failed to update settings: $e');
    }
  }

  // ✅ Toggle Call Masking
  void _toggleCallMasking() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.mediumImpact();
    _showLoadingOverlay();

    try {
      final userData = await AuthService.getUserData();
      final phone = userData['phone'] ?? '';
      final countryCode = userData['countryCode'] ?? '+91';
      final phoneWithCountryCode = countryCode.replaceFirst('+', '') + phone;

      final newCallMaskingEnabled = !_isCallMaskingEnabled;

      await TagsService.updateTagSettings(
        tagId: _tagSettings?.data.tagId.toString() ?? '',
        phone: phoneWithCountryCode,
        callsEnabled: _isCallsEnabled,
        whatsappEnabled: _isWhatsappEnabled,
        callMaskingEnabled: newCallMaskingEnabled,
        videoCallEnabled: _isVideoCallEnabled,
        smValue: '67s87s6yys66',
        dgValue: 'testYU78dII8iiUIPSISJ',
      );

      setState(() {
        _isCallMaskingEnabled = newCallMaskingEnabled;
        _isLoading = false;
      });

      _hideLoadingOverlay();

      // ✅ Reload settings
      await _loadTagSettings();

      _showSuccessDialog(
        icon: newCallMaskingEnabled ? Icons.phone : Icons.phone_disabled,
        iconColor: newCallMaskingEnabled ? Colors.green : Colors.red,
        title: newCallMaskingEnabled ? 'Call Masking Enabled' : 'Call Masking Disabled',
        message: newCallMaskingEnabled
            ? 'Your number will be masked on outgoing calls'
            : 'Call masking has been disabled',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _hideLoadingOverlay();
      _showErrorDialog('Error', 'Failed to update settings: $e');
    }
  }

  // ✅ Toggle Video Call
  void _toggleVideoCall() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.mediumImpact();
    _showLoadingOverlay();

    try {
      final userData = await AuthService.getUserData();
      final phone = userData['phone'] ?? '';
      final countryCode = userData['countryCode'] ?? '+91';
      final phoneWithCountryCode = countryCode.replaceFirst('+', '') + phone;

      final newVideoCallEnabled = !_isVideoCallEnabled;

      await TagsService.updateTagSettings(
        tagId: _tagSettings?.data.tagId.toString() ?? '',
        phone: phoneWithCountryCode,
        callsEnabled: _isCallsEnabled,
        whatsappEnabled: _isWhatsappEnabled,
        callMaskingEnabled: _isCallMaskingEnabled,
        videoCallEnabled: newVideoCallEnabled,
        smValue: '67s87s6yys66',
        dgValue: 'testYU78dII8iiUIPSISJ',
      );

      setState(() {
        _isVideoCallEnabled = newVideoCallEnabled;
        _isLoading = false;
      });

      _hideLoadingOverlay();

      // ✅ Reload settings
      await _loadTagSettings();

      _showSuccessDialog(
        icon: newVideoCallEnabled ? Icons.videocam : Icons.videocam_off,
        iconColor: newVideoCallEnabled ? Colors.green : Colors.grey,
        title: newVideoCallEnabled ? 'Video Call Enabled' : 'Video Call Disabled',
        message: newVideoCallEnabled
            ? 'You can now receive video calls'
            : 'Video calls have been disabled',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _hideLoadingOverlay();
      _showErrorDialog('Error', 'Failed to update settings: $e');
    }
  }

  // ===================
  // ✅ DIALOG FUNCTIONS
  // ===================

  // ✅ Success Dialog with Animation
  void _showSuccessDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 400),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 48,
                          color: iconColor,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.activeYellow,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Got it',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ Error Dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ Show Notification Sheet
  void _showNotificationSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationSheet(
        tagInternalId: widget.item.id.toString(),
        phone: _userPhone,
      ),
    );
  }

  // ✅ Show Add Secondary Number Sheet
  void _showAddSecondaryNumberSheet() async {
    HapticFeedback.mediumImpact();
    final phoneNumber = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSecondaryNumberSheet(
        tagId: widget.item.id.toString(),
        existingSecondaryNumber: _tagSettings?.data.secondaryNumber,  // ✅ Pass existing data
      ),
    );

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      try {
        final userData = await AuthService.getUserData();
        final phone = userData['phone'] ?? '';
        final countryCode = userData['countryCode'] ?? '+91';
        final phoneWithCountryCode = countryCode.replaceFirst('+', '') + phone;

        await TagsService.updateTagSettings(
          tagId: _tagSettings?.data.tagId.toString() ?? '',
          phone: phoneWithCountryCode,
          secondaryNumber: phoneNumber,
          callsEnabled: _isCallsEnabled,
          whatsappEnabled: _isWhatsappEnabled,
          callMaskingEnabled: _isCallMaskingEnabled,
          videoCallEnabled: _isVideoCallEnabled,
          smValue: '67s87s6yys66',
          dgValue: 'testYU78dII8iiUIPSISJ',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Secondary number saved successfully!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
          // Refresh tag settings
          await _loadTagSettings();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }
}
