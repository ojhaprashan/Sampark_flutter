import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_new_app/pages/widgets/edit_tag_sheet.dart';
import 'package:my_new_app/pages/widgets/file_upload_sheet.dart';
import 'package:my_new_app/pages/widgets/notification_sheet.dart';
import 'package:my_new_app/pages/widgets/etag_download_sheet.dart';
import 'package:my_new_app/pages/widgets/error_dialog.dart';
import 'package:my_new_app/pages/membership/membership_page.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/tags_service.dart';
import '../../../services/etag_service.dart';
import '../../../services/premium_service.dart';
import '../../widgets/app_header.dart';
import '../../scan/contact_vehicle_owner_page.dart';
import '../../widgets/tag_replacement_dialog.dart';
import '../car/add_emergency_contact_sheet.dart';
import '../car/add_secondary_number_sheet.dart';
import '../../../services/emergency_service.dart';

class BikeTagDetailsPage extends StatefulWidget {
  final Tag tag;

  const BikeTagDetailsPage({super.key, required this.tag});

  @override
  State<BikeTagDetailsPage> createState() => _BikeTagDetailsPageState();
}

class _BikeTagDetailsPageState extends State<BikeTagDetailsPage>
    with SingleTickerProviderStateMixin {
  bool _isLoggedIn = false;
  int _selectedTab = 0; // 0 = Manage tag, 1 = MORE
  late PageController _pageController;
  late AnimationController _animationController;
  TagSettings? _tagSettings;
  bool _isLoadingSettings = true;
  String _settingsError = '';
  bool _isLoading = false;
  bool _hasPremium = false; // ✅ Premium status
  bool _isLoadingPremium = false; // ✅ Loading premium data

  // ✅ State variables with default values (NOT late)
  bool _isCallsEnabled = true;
  bool _isTagEnabled = true;
  bool _isWhatsappEnabled = false;
  bool _isCallMaskingEnabled = false;
  bool _isVideoCallEnabled = false;
  String _userPhone = '';
  String _countryCode = '+91'; // Default to India

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
    _loadPremiumData(); // ✅ Load premium data
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
          _userPhone = phone;
          _countryCode = countryCode; // ✅ Set country code

          // ✅ Update state variables from API response
          _isCallsEnabled = tagSettings.data.callStatus.callsEnabled;
          _isTagEnabled = tagSettings.data.status == 'Active';
          _isWhatsappEnabled = tagSettings.data.callStatus.whatsappEnabled;
          _isCallMaskingEnabled = tagSettings.data.callStatus.callMaskingEnabled;
          _isVideoCallEnabled = tagSettings.data.callStatus.videoCallEnabled;
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
                                  // Tag Header (without card)
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
          // Bottom Button with animation
          // ✅ Show button only in More tab when NOT premium
          if (!_isLoadingSettings && 
              !_isLoadingPremium &&
              _selectedTab == 1 && 
              !_hasPremium)
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
                  // Animated bike icon
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
                            Icons.two_wheeler,
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
            const SizedBox(height: AppConstants.spacingMedium),
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

  Widget _buildTagHeader() {
    return Column(
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
                  color: _selectedTab == 1 ? AppColors.black : AppColors.textGrey,
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
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          iconColor: Colors.blue.shade600,
          label: 'View Contact Page.',
          trailing: Icons.chat_bubble_outline,
          onTap: () {
            final tagId = int.tryParse(widget.tag.tagInternalId) ?? 0;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactVehicleOwnerPage(
                  tagId: tagId,
                  vehicleNumber: widget.tag.displayName,
                  vehicleName: 'Bike Tag',
                ),
              ),
            );
          },
        ),
        _buildActionButton(
          icon: Icons.notifications_none,
          iconColor: Colors.orange.shade600,
          label: 'View Notifications',
          trailing: Icons.notifications_none,
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
          onTap: () => _toggleCalls(),
        ),
        // ✅ Dynamic Enable/Disable Tag Button (shows opposite action)
        _buildActionButton(
          icon: _isTagEnabled ? Icons.pause : Icons.play_arrow,
          iconColor: _isTagEnabled ? Colors.amber.shade700 : Colors.green.shade600,
          label: _isTagEnabled ? 'Pause the tag' : 'Resume the tag',
          trailing: _isTagEnabled ? Icons.pause : Icons.play_arrow,
          onTap: () => _toggleTag(),
        ),
        _buildActionButton(
          icon: Icons.phone,
          iconColor: Colors.teal.shade600,
          label: 'Add secondary number',
          trailing: Icons.phone,
          onTap: () => _showSecondaryNumberSheet(),
        ),
        _buildActionButton(
          icon: Icons.contact_emergency,
          iconColor: Colors.purple.shade600,
          label: 'Add Emergency contact',
          trailing: Icons.contacts,
          onTap: () => _showEmergencyContactSheet(),  // ✅ Call emergency contact sheet
        ),
        // ✅ Show eTag Download only for India
        if (_countryCode == '+91')
          _buildActionButton(
            icon: Icons.download,
            iconColor: Colors.indigo.shade600,
            label: 'Download eTag',
            badge: 'New',
            trailing: Icons.download,
            onTap: () {
              _generateOfflineQR();
            },
          ),
      ],
    );
  }

  Widget _buildMoreTabContent() {
    return Column(
      children: [
        // ✅ Shows opposite text (Enable when disabled, Disable when enabled)
        _buildActionButton(
          icon: _isWhatsappEnabled ? Icons.chat_bubble : Icons.chat_bubble_outline,
          iconColor: _isWhatsappEnabled ? Colors.green.shade600 : Colors.grey.shade600,
          label: _isWhatsappEnabled ? 'Disable WhatsApp Notifications' : 'Enable WhatsApp Notifications',
          trailing: _isWhatsappEnabled ? Icons.toggle_on : Icons.toggle_off_outlined,
          onTap: () => _toggleWhatsapp(),
        ),
        _buildActionButton(
          icon: _isCallMaskingEnabled ? Icons.phone : Icons.phone_disabled,
          iconColor: _isCallMaskingEnabled ? Colors.green.shade600 : Colors.red.shade600,
          label: _isCallMaskingEnabled ? 'Disable Call Masking' : 'Enable Call Masking',
          trailing: _isCallMaskingEnabled ? Icons.toggle_on : Icons.toggle_off_outlined,
          onTap: () => _toggleCallMasking(),
        ),
        _buildActionButton(
          icon: Icons.upload_file,
          iconColor: Colors.blue.shade600,
          label: 'Upload files',
          trailing: Icons.file_upload,
          onTap: () {
    // ✅ OPEN THE NEW SHEET HERE
    final tagId = int.tryParse(widget.tag.tagInternalId) ?? 0;
    FileUploadSheet.show(context, tagId: tagId);
  },
        ),
        _buildActionButton(
          icon: _isVideoCallEnabled ? Icons.videocam : Icons.videocam_off,
          iconColor: _isVideoCallEnabled ? Colors.green.shade600 : Colors.grey.shade600,
          label: _isVideoCallEnabled ? 'Disable Video Call' : 'Enable Video Call',
          trailing: _isVideoCallEnabled ? Icons.toggle_on : Icons.toggle_off_outlined,
          onTap: () => _toggleVideoCall(),
        ),
        // ✅ Show Offline QR Download only for India
        if (_countryCode == '+91')
          _buildActionButtonWithDescription(
            icon: Icons.wifi_off,
            iconColor: Colors.orange.shade600,
            label: 'Offline QR Download',
            description: 'Download the QR code for offline Usage of your business card.',
            badge: 'New!',
            trailing: Icons.wifi_off,
            onTap: () {
              _generateOfflineQR();
            },
          ),
        _buildActionButton(
          icon: Icons.autorenew,
          iconColor: Colors.teal.shade600,
          label: 'Get a Tag Replacement',
          trailing: Icons.autorenew,
          onTap: () {
            TagReplacementDialog.show(context);
          },
        ),
        // Edit and re-write tag (red color)
        _buildActionButtonWithDescription(
          icon: Icons.edit,
          iconColor: Colors.red.shade600,
          label: 'Edit and re-write tag',
          description: 'Change phone or vehicle Number',
          trailing: Icons.close,
          isRed: true,
          onTap: () {
            // Get phone with country code
            final phoneWithCountryCode = _countryCode.replaceFirst('+', '') + _userPhone;
            EditTagSheet.show(
              context,
              vehicleNumber: widget.tag.displayName,
              tagId: widget.tag.tagInternalId,
              phone: phoneWithCountryCode,
            );
          },
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        // Membership Badge
        Container(
          padding: const EdgeInsets.all(AppConstants.cardPaddingMedium),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: AppColors.lightGrey,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium,
                size: AppConstants.iconSizeLarge,
                color: Colors.purple,
              ),
              const SizedBox(width: 6),
              Text(
                'Membership*',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSectionTitle,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    Color? iconColor,
    required String label,
    String? badge,
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
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmallText,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
            ],
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

  Widget _buildActionButtonWithDescription({
    required IconData icon,
    Color? iconColor,
    required String label,
    required String description,
    String? badge,
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
              size: AppConstants.iconSizeMedium,
              color: iconColor ?? (isRed ? Colors.red : AppColors.black),
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeCardTitle,
                            fontWeight: FontWeight.w600,
                            color: isRed ? Colors.red : AppColors.black,
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
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeSmallText,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeCardDescription,
                      color: AppColors.textGrey,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.paddingSmall),
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

  // ========================
  // ✅ LOADING OVERLAY
  // ========================

  // ✅ Show Loading Overlay
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
  // ✅ MANAGE TAB FUNCTIONS
  // ========================

  // ✅ Toggle Calls with API and Loading Dialog
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

      // Toggle the state
      final newCallsEnabled = !_isCallsEnabled;

      // Call API to update settings
      await TagsService.updateTagSettings(
        tagId: widget.tag.tagInternalId,
        phone: phoneWithCountryCode,
        callsEnabled: newCallsEnabled,
        whatsappEnabled: _isWhatsappEnabled,
        callMaskingEnabled: _isCallMaskingEnabled,
        videoCallEnabled: _isVideoCallEnabled,
        smValue: '67s87s6yys66',
        dgValue: 'testYU78dII8iiUIPSISJ',
      );

      _hideLoadingOverlay();

      // ✅ Reload data from API to get fresh data
      await _loadTagSettings();

      // Show success dialog with opposite text
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

  // ✅ Toggle Tag with API and Loading Dialog
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

      // Toggle the state
      final newTagEnabled = !_isTagEnabled;
      // ✅ Set status based on newTagEnabled (active/pause)
      final newStatus = newTagEnabled ? 'active' : 'pause';

      // Call API to update tag status
      await TagsService.updateTagSettings(
        tagId: widget.tag.tagInternalId,
        phone: phoneWithCountryCode,
        callsEnabled: _isCallsEnabled,
        whatsappEnabled: _isWhatsappEnabled,
        callMaskingEnabled: _isCallMaskingEnabled,
        videoCallEnabled: _isVideoCallEnabled,
        smValue: '67s87s6yys66',
        dgValue: 'testYU78dII8iiUIPSISJ',
        status: newStatus,  // ✅ Pass status parameter
      );

      _hideLoadingOverlay();

      // ✅ Reload data from API to get fresh data
      await _loadTagSettings();

      // Show success dialog
      _showSuccessDialog(
        icon: newTagEnabled ? Icons.check_circle : Icons.pause_circle,
        iconColor: newTagEnabled ? Colors.green : Colors.orange,
        title: newTagEnabled ? 'Tag Enabled' : 'Tag Paused',
        message: newTagEnabled
            ? 'Your tag is now active and can be scanned.'
            : 'Your tag has been temporarily paused.',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _hideLoadingOverlay();
      _showErrorDialog('Error', 'Failed to update tag status: $e');
    }
  }

  // ====================
  // ✅ MORE TAB FUNCTIONS
  // ====================

  // ✅ Toggle WhatsApp with API and Loading Dialog
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

      // Toggle the state
      final newWhatsappEnabled = !_isWhatsappEnabled;

      await TagsService.updateTagSettings(
        tagId: widget.tag.tagInternalId,
        phone: phoneWithCountryCode,
        callsEnabled: _isCallsEnabled,
        whatsappEnabled: newWhatsappEnabled,
        callMaskingEnabled: _isCallMaskingEnabled,
        videoCallEnabled: _isVideoCallEnabled,
        smValue: '67s87s6yys66',
        dgValue: 'testYU78dII8iiUIPSISJ',
      );

      _hideLoadingOverlay();

      // ✅ Reload data from API to get fresh data
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

  // ✅ Toggle Call Masking with API and Loading Dialog
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

      // Toggle the state
      final newCallMaskingEnabled = !_isCallMaskingEnabled;

      await TagsService.updateTagSettings(
        tagId: widget.tag.tagInternalId,
        phone: phoneWithCountryCode,
        callsEnabled: _isCallsEnabled,
        whatsappEnabled: _isWhatsappEnabled,
        callMaskingEnabled: newCallMaskingEnabled,
        videoCallEnabled: _isVideoCallEnabled,
        smValue: '67s87s6yys66',
        dgValue: 'testYU78dII8iiUIPSISJ',
      );

      _hideLoadingOverlay();

      // ✅ Reload data from API to get fresh data
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

  // ✅ Toggle Video Call with API and Loading Dialog
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

      // Toggle the state
      final newVideoCallEnabled = !_isVideoCallEnabled;

      await TagsService.updateTagSettings(
        tagId: widget.tag.tagInternalId,
        phone: phoneWithCountryCode,
        callsEnabled: _isCallsEnabled,
        whatsappEnabled: _isWhatsappEnabled,
        callMaskingEnabled: _isCallMaskingEnabled,
        videoCallEnabled: newVideoCallEnabled,
        smValue: '67s87s6yys66',
        dgValue: 'testYU78dII8iiUIPSISJ',
      );

      _hideLoadingOverlay();

      // ✅ Reload data from API to get fresh data
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
  void _generateOfflineQR() async {
    HapticFeedback.mediumImpact();
    
    _showLoadingOverlay();

    try {
      final userData = await AuthService.getUserData();
      final phone = userData['phone'] ?? '';
      final countryCode = userData['countryCode'] ?? '+91';

      final response = await ETagService.getETag(
        tagId: widget.tag.tagInternalId.toString(),
        phone: phone,
        countryCode: countryCode,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
      }

      // Show the eTag download sheet
      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (context) => ETagDownloadSheet(
            tagId: response.data.tagId.toString(),
            plate: response.data.plate,
            downloadUrl: response.data.downloadUrl,
            pdfFile: response.data.pdfFile,
            message: response.message,
            onClose: () {
              // User closed the sheet
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
      }

      if (mounted) {
        ErrorDialog.show(
          context: context,
          title: 'eTag Download Failed',
          message: e.toString().replaceFirst('Exception: ', ''),
          onRetry: _generateOfflineQR,
        );
      }
    }
  }

  // ===================

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
                // Animated Icon
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
        tagInternalId: widget.tag.tagInternalId.toString(),
        phone: _userPhone,
      ),
    );
  }

  // ✅ Show Secondary Number Sheet
  void _showSecondaryNumberSheet() async {
    HapticFeedback.mediumImpact();
    final phoneNumber = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSecondaryNumberSheet(
        tagId: widget.tag.tagInternalId.toString(),
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
          tagId: widget.tag.tagInternalId,
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

  // ✅ Show Emergency Contact Sheet
  void _showEmergencyContactSheet() async {
    HapticFeedback.mediumImpact();
    try {
      // ✅ Convert tagInternalId to int for API call
      final tagIdInt = int.tryParse(widget.tag.tagInternalId) ?? 0;
      
      // ✅ Fetch existing emergency contact data
      final existingEmergency = await EmergencyService.fetchEmergencyInfo(
        tagId: tagIdInt,
      );
      
      if (mounted) {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => AddEmergencyContactSheet(
            tagId: widget.tag.tagInternalId.toString(),
            existingPrimaryPhone: existingEmergency.data.primaryPhone,
            existingSecondaryPhone: existingEmergency.data.secondaryPhone,
            existingBloodGroup: existingEmergency.data.bloodGroup,
            existingInsurance: existingEmergency.data.insurance,
            existingNote: existingEmergency.data.note,
          ),
        );
        // ✅ Refresh tag settings after sheet closes (data might have been updated)
        await _loadTagSettings();
      }
    } catch (e) {
      print('❌ Error fetching emergency info: $e');
      // ✅ If no existing data or error, open sheet with empty fields
      if (mounted) {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => AddEmergencyContactSheet(
            tagId: widget.tag.tagInternalId.toString(),
          ),
        );
        // ✅ Refresh tag settings after sheet closes
        await _loadTagSettings();
      }
    }
  }
}
