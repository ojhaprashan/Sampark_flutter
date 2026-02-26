import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/tags_service.dart';
import '../../../services/offline_qr_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/offline_qr_download_sheet.dart';
import '../../widgets/edit_tag_sheet.dart';

class BusinessTagDetailsPage extends StatefulWidget {
  final Tag tag;

  const BusinessTagDetailsPage({super.key, required this.tag});

  @override
  State<BusinessTagDetailsPage> createState() => _BusinessTagDetailsPageState();
}

class _BusinessTagDetailsPageState extends State<BusinessTagDetailsPage> with SingleTickerProviderStateMixin {
  bool _isLoggedIn = false;
  int _selectedTab = 0; // 0 = Business, 1 = Options, 2 = Settings
  late PageController _pageController;
  late AnimationController _animationController;
  TagSettings? _tagSettings;
  bool _isLoadingSettings = true;
  String _settingsError = '';
  String _userPhone = ''; // ✅ Track user phone
  String _countryCode = '+91'; // ✅ Default to India

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
          _userPhone = phone; // ✅ Set user phone
          _countryCode = countryCode; // ✅ Set country code
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
                                Text(
                                  'Your tags, you control ! 😍',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizeSectionTitle,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.spacingMedium),

                                // Tabs
                                _buildTabs(),
                                const SizedBox(height: AppConstants.spacingSmall),

                                // Scan Count
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
                        ),

                        // Swipeable PageView for Tab Content
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: _onPageChanged,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildScrollableContent(_buildBusinessTabContent()),
                              _buildScrollableContent(_buildOptionsTabContent()),
                              _buildScrollableContent(_buildSettingsTabContent()),
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

          // Bottom Button - Only show on Settings tab with animation
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _selectedTab == 2 ? 20 : -100,
            left: 20,
            right: 20,
            child: SafeArea(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _selectedTab == 2 ? 1.0 : 0.0,
                child: ElevatedButton.icon(
                  onPressed: _selectedTab == 2 ? _shareBusinessOnWhatsApp : null,
                  icon: const Icon(
                    Icons.share,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    'Share business on WhatsApp',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeButtonPriceText,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.buttonPaddingVertical,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.buttonBorderRadius * 2,
                      ),
                    ),
                    elevation: 4,
                    shadowColor: Colors.green.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildTabs() {
    return Row(
      children: [
        _buildTab('Business', 0),
        const SizedBox(width: AppConstants.spacingLarge),
        _buildTab('Options', 1),
        const SizedBox(width: AppConstants.spacingLarge),
        _buildTab('Settings', 2),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _onTabTapped(index);
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
              color: isSelected ? AppColors.activeYellow : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: AppConstants.fontSizeSectionTitle,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? AppColors.black : AppColors.textGrey,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  // BUSINESS TAB - View Business, View Leads, Edit Business
  Widget _buildBusinessTabContent() {
    return Column(
      children: [
        // ✅ Demo Tag Disclaimer
        if (_tagSettings?.data.isDemoTag ?? false)
          _buildDemoTagDisclaimer(),
        if (_tagSettings?.data.isDemoTag ?? false)
          const SizedBox(height: AppConstants.spacingMedium),

        // Alert Box
        Container(
          padding: const EdgeInsets.all(AppConstants.cardPaddingMedium),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
            border: Border.all(
              color: Colors.red.shade200,
              width: 1,
            ),
          ),
          child: Text(
            'You have not added your logo, portfolio and services, please add them so people can contact you.',
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardTitle,
              color: Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingMedium),

        // Manage URL with Copy
        if (widget.tag.manageUrl.isNotEmpty)
          Container(
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
              children: [
                Expanded(
                  child: Text(
                    widget.tag.manageUrl,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeCardTitle,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(
                      ClipboardData(text: widget.tag.manageUrl),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Copied to clipboard'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.black,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Copy',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeCardTitle,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: AppConstants.spacingMedium),

        _buildActionButton(
          icon: Icons.visibility,
          iconColor: Colors.blue.shade600, // ✅ Colorful icon
          label: 'View Business',
          trailing: Icons.remove_red_eye,
          onTap: _showComingSoonDialog,
        ),

        _buildActionButton(
          icon: Icons.people,
          iconColor: Colors.green.shade600, // ✅ Colorful icon
          label: 'View Leads',
          trailing: Icons.chat_bubble_outline,
          onTap: _showComingSoonDialog,
        ),

        _buildActionButton(
          icon: Icons.edit,
          iconColor: Colors.orange.shade600, // ✅ Colorful icon
          label: 'Edit Business',
          trailing: Icons.edit,
          onTap: _showComingSoonDialog,
        ),

        const SizedBox(height: AppConstants.spacingMedium),

        // Info Text
        Text(
          'You can add photo, pdf and more from options tab',
          style: TextStyle(
            fontSize: AppConstants.fontSizeCardDescription,
            color: AppColors.textGrey,
          ),
        ),

        const SizedBox(height: AppConstants.spacingSmall),

        // Demo Button
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.play_circle_filled,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Demo',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardTitle,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppConstants.spacingMedium),

        // Alert Box
        Container(
          padding: const EdgeInsets.all(AppConstants.cardPaddingMedium),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
            border: Border.all(
              color: Colors.red.shade200,
              width: 1,
            ),
          ),
          child: Text(
            'ALERT: Please Add Cover photo for your business.',
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardTitle,
              color: Colors.red.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // OPTIONS TAB - Manage Profile, Catalog, Brochure, Offers, Portfolio, Social Media
  Widget _buildOptionsTabContent() {
    return Column(
      children: [
        // Alert Box
        Container(
          padding: const EdgeInsets.all(AppConstants.cardPaddingMedium),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
            border: Border.all(
              color: Colors.red.shade200,
              width: 1,
            ),
          ),
          child: Text(
            'You have not added your logo, portfolio and services, please add them so people can contact you.',
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardTitle,
              color: Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingMedium),

        _buildActionButton(
          icon: Icons.image,
          iconColor: Colors.purple.shade600, // ✅ Colorful icon
          label: 'Manage Profile Pic / Video',
          trailing: Icons.image,
          onTap: _showComingSoonDialog,
        ),

        _buildActionButton(
          icon: Icons.category,
          iconColor: Colors.indigo.shade600, // ✅ Colorful icon
          label: 'Catalog',
          trailing: Icons.shopping_bag,
          onTap: _showComingSoonDialog,
        ),

        _buildActionButton(
          icon: Icons.upload_file,
          iconColor: Colors.blue.shade600, // ✅ Colorful icon
          label: 'Upload Brochure',
          trailing: Icons.description,
          onTap: _showComingSoonDialog,
        ),

        _buildActionButton(
          icon: Icons.local_offer,
          iconColor: Colors.amber.shade700, // ✅ Colorful icon
          label: 'Add Offer Codes',
          trailing: Icons.star,
          onTap: _showComingSoonDialog,
        ),

        _buildActionButton(
          icon: Icons.photo_library,
          iconColor: Colors.pink.shade600, // ✅ Colorful icon
          label: 'Add Portfolio Images',
          trailing: Icons.photo,
          onTap: _showComingSoonDialog,
        ),

        _buildActionButtonWithDescription(
          icon: Icons.share,
          iconColor: Colors.teal.shade600, // ✅ Colorful icon
          label: 'Manage Social Media',
          description: 'Add / Redirect to Social Pages.',
          trailing: Icons.link,
          onTap: _showComingSoonDialog,
        ),

        const SizedBox(height: AppConstants.spacingSmall),

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

        const SizedBox(height: AppConstants.spacingMedium),

        // Alert Box
        Container(
          padding: const EdgeInsets.all(AppConstants.cardPaddingMedium),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
            border: Border.all(
              color: Colors.red.shade200,
              width: 1,
            ),
          ),
          child: Text(
            'ALERT: Please Add Cover photo for your business.',
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardTitle,
              color: Colors.red.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // SETTINGS TAB - Offline QR Download, Disable Contact, NGF132 TAP, Delete, Share QR
  Widget _buildSettingsTabContent() {
    return Column(
      children: [
        // Alert Box
        Container(
          padding: const EdgeInsets.all(AppConstants.cardPaddingMedium),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
            border: Border.all(
              color: Colors.red.shade200,
              width: 1,
            ),
          ),
          child: Text(
            'You have not added your logo, portfolio and services, please add them so people can contact you.',
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardTitle,
              color: Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingMedium),

        _buildActionButtonWithDescription(
          icon: Icons.download,
          iconColor: Colors.green.shade600, // ✅ Colorful icon
          label: 'Offline QR Download',
          description: 'Download the QR code for offline, Usage of your business card.',
          badge: 'New',
          trailing: Icons.download,
          onTap: () {
            _generateOfflineQR();
          },
        ),

        _buildActionButton(
          icon: (_tagSettings?.data.callStatus.whatsappEnabled ?? false) ? Icons.chat_bubble : Icons.chat_bubble_outline,
          iconColor: (_tagSettings?.data.callStatus.whatsappEnabled ?? false) ? Colors.green.shade600 : Colors.grey.shade600,
          label: (_tagSettings?.data.callStatus.whatsappEnabled ?? false) ? 'Disable WhatsApp Contact' : 'Enable WhatsApp Contact',
          trailing: (_tagSettings?.data.callStatus.whatsappEnabled ?? false) ? Icons.toggle_on : Icons.toggle_off_outlined,
          onTap: () => _toggleWhatsapp(),
        ),

        _buildActionButton(
          icon: Icons.nfc,
          iconColor: Colors.blue.shade600, // ✅ Colorful icon
          label: 'NGF132 TAP IS ACTIVE',
          trailing: Icons.nfc,
          onTap: _showComingSoonDialog,
        ),

        _buildActionButton(
          icon: Icons.delete_outline,
          iconColor: Colors.red.shade600, // ✅ Colorful icon (red delete)
          label: 'Delete',
          trailing: Icons.close,
          isRed: true,
          onTap: _showComingSoonDialog,
        ),

        // ✅ Edit and re-write tag
        _buildActionButton(
          icon: Icons.edit,
          iconColor: Colors.red.shade600,
          label: 'Edit and re-write tag',
          trailing: Icons.close,
          isRed: true,
          onTap: () {
            final phoneWithCountryCode = _countryCode.replaceFirst('+', '') + _userPhone;
            EditTagSheet.show(
              context,
              vehicleNumber: widget.tag.displayName,
              tagId: widget.tag.tagInternalId,
              phone: phoneWithCountryCode,
            );
          },
        ),

        const SizedBox(height: AppConstants.spacingLarge),

        // Share QR Section
        Container(
          padding: const EdgeInsets.all(AppConstants.cardPaddingLarge),
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
              Text(
                'Share your QR',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSectionTitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardDescription,
                    color: AppColors.textGrey,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'You can '),
                    TextSpan(
                      text: 'print your QR on your phamplets',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const TextSpan(
                      text: ' and business cards for more business. ',
                    ),
                    TextSpan(
                      text: 'Download your QR from here',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildActionButton({
    required IconData icon,
    Color? iconColor, // ✅ Added icon color parameter
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
              color: iconColor ?? (isRed ? Colors.red : AppColors.black), // ✅ Use custom color
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
    Color? iconColor, // ✅ Added icon color parameter
    required String label,
    required String description,
    String? badge,
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
              color: iconColor ?? AppColors.black, // ✅ Use custom color
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
                color: AppColors.textGrey,
              ),
          ],
        ),
      ),
    );
  }

  // ========================
  // ✅ OFFLINE QR FUNCTIONS
  // ========================

  void _generateOfflineQR() async {
    HapticFeedback.mediumImpact();
    
    _showLoadingOverlay();

    try {
      final userData = await AuthService.getUserData();
      final phone = userData['phone'] ?? '';
      final countryCode = userData['countryCode'] ?? '+91';

      final response = await OfflineQRService.generateOfflineQR(
        tagId: widget.tag.tagInternalId.toString(),
        phone: phone,
        countryCode: countryCode,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
      }

      // Show the offline QR download sheet
      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (context) => OfflineQRDownloadSheet(
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
        _showErrorDialog('Error', 'Failed to generate QR: $e');
      }
    }
  }

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

  // ✅ Show Error Dialog
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
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.shade600,
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.buttonBorderRadius,
                        ),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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

  // ==========================
  // ✅ COMING SOON POPUP
  // ==========================
  void _showComingSoonDialog() {
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
                Icon(
                  Icons.schedule,
                  size: 48,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(height: 20),
                Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'This feature will be updated soon. Please use on Chrome for now.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.buttonBorderRadius,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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

  // ==========================
  // ✅ WHATSAPP SHARING
  // ==========================
  void _shareBusinessOnWhatsApp() async {
    try {
      final userData = await AuthService.getUserData();
      final phone = userData['phone'] ?? '';
      final countryCode = userData['countryCode'] ?? '91';
      final name = userData['name'] ?? 'Sampark User';

      // Combine country code and phone
      String formattedPhone = countryCode.replaceFirst('+', '') + phone;

      // Create WhatsApp message
      String message = 'Hi! Check out my business on Sampark: ';
      if (widget.tag.manageUrl.isNotEmpty) {
        message += widget.tag.manageUrl;
      } else {
        message += 'Sampark Business Tag';
      }

      // Show confirmation dialog with business details
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
                  Icon(
                    Icons.check_circle,
                    size: 48,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Share on WhatsApp',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Share your business with:',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+$formattedPhone',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Message:',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.black,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.buttonBorderRadius,
                              ),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Opening WhatsApp...'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.buttonBorderRadius,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Share',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      _showErrorDialog('Error', 'Failed to share: $e');
    }
  }

  // ===================
  // ✅ WHATSAPP FUNCTIONS
  // ===================
  // ✅ Toggle WhatsApp
  void _toggleWhatsapp() async {
    HapticFeedback.lightImpact();
    
    try {
      setState(() {
        if (_tagSettings != null) {
          _tagSettings!.data.callStatus.whatsappEnabled = !_tagSettings!.data.callStatus.whatsappEnabled;
        }
      });

      final userData = await AuthService.getUserData();
      final phone = userData['phone'] ?? '';
      final countryCode = userData['countryCode'] ?? '+91';
      final phoneWithCountryCode = countryCode.replaceFirst('+', '') + phone;

      await TagsService.updateTagSettings(
        tagId: widget.tag.tagInternalId,
        phone: phoneWithCountryCode,
        callsEnabled: true,
        whatsappEnabled: _tagSettings?.data.callStatus.whatsappEnabled ?? false,
        callMaskingEnabled: _tagSettings?.data.callStatus.callMaskingEnabled ?? false,
        videoCallEnabled: _tagSettings?.data.callStatus.videoCallEnabled ?? false,
        smValue: '67s87s6yys66',
        dgValue: 'testYU78dII8iiUIPSISJ',
      );

      await _loadTagSettings();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((_tagSettings?.data.callStatus.whatsappEnabled ?? false) ? 'WhatsApp Enabled' : 'WhatsApp Disabled'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      setState(() {
        if (_tagSettings != null) {
          _tagSettings!.data.callStatus.whatsappEnabled = !_tagSettings!.data.callStatus.whatsappEnabled;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
