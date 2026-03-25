import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/tags_service.dart';
import '../../../services/offline_qr_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/offline_qr_download_sheet.dart';
import '../../widgets/edit_tag_sheet.dart';
import '../../AppWebView/appweb.dart';

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

                // ✅ Curved off-white container matching car design
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
                          // Fixed Header Section
                          Container(
                            color: const Color(0xFFF5F6F8),
                            child: Padding(
                              padding: const EdgeInsets.all(AppConstants.paddingLarge),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Tag Header (styled card)
                                  _buildTagHeader(),
                                  if (_tagSettings?.data.isDemoTag ?? false)
                                    const SizedBox(height: AppConstants.spacingSmall),
                                  if (_tagSettings?.data.isDemoTag ?? false)
                                    _buildDemoTagDisclaimer(),
                                  const SizedBox(height: AppConstants.spacingSmall),
                                  
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
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _selectedTab == 2 ? _shareBusinessOnWhatsApp : null,
                    icon: Image.asset(
                      'assets/icons/whatsapp.png',
                      width: 20,
                      height: 20,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.share, size: 20);
                      },
                    ),
                    label: Text(
                      'Share business on WhatsApp',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.activeYellow,
                      foregroundColor: AppColors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
              color: Color(0xFFF5F6F8), // Match off-white
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated business icon
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
                            Icons.business_center,
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
              color: Color(0xFFF5F6F8), // Match off-white
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

  // ✅ Styled Header Card
  Widget _buildTagHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
                    'Tag id: ${widget.tag.tagPublicId} • Status: ${widget.tag.status}',
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
        ],
      ),
    );
  }

  // ✅ Modern Pill Tabs (3 tabs for Business)
  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.only(
        top: AppConstants.paddingSmall,
        bottom: 0,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPillTab('Business', 0),
            _buildPillTab('Options', 1),
            _buildPillTab('Settings', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildPillTab(String label, int index) {
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
          horizontal: 20, 
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.activeYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(26), 
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: AppConstants.fontSizeSectionTitle,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textGrey,
            letterSpacing: 0.3,
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

        // Manage URL with Copy (Redesigned)
        if (widget.tag.manageUrl.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(AppConstants.cardPaddingLarge),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingSmall),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.link,
                    size: AppConstants.iconSizeLarge,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Business Link',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.tag.manageUrl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSectionTitle,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSmall),
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
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.activeYellow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Copy',
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
          ),

        const SizedBox(height: AppConstants.spacingMedium),

        _buildActionButton(
          icon: Icons.visibility,
          iconColor: Colors.blue.shade600, 
          label: 'View Business',
          trailing: Icons.remove_red_eye,
          onTap: _openViewBusiness,
        ),

        _buildActionButton(
          icon: Icons.people,
          iconColor: Colors.green.shade600, 
          label: 'View Leads',
          trailing: Icons.chat_bubble_outline,
          onTap: _showComingSoonDialog,
        ),

        _buildActionButton(
          icon: Icons.edit,
          iconColor: Colors.orange.shade600, 
          label: 'Edit Business',
          trailing: Icons.edit,
          onTap: _showComingSoonDialog,
        ),

        const SizedBox(height: AppConstants.spacingMedium),

        // Info Text
        Container(
          padding: const EdgeInsets.all(AppConstants.cardPaddingMedium),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You can add photo, pdf and more from options tab',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardDescription,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.spacingMedium),

        // Demo Button
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_circle_filled,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Watch Demo Video',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSectionTitle,
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
          iconColor: Colors.purple.shade600, 
          label: 'Manage Profile Pic / Video',
          trailing: Icons.image,
          onTap: _showComingSoonDialog,
        ),

        _buildActionButton(
          icon: Icons.category,
          iconColor: Colors.indigo.shade600, 
          label: 'Catalog',
          trailing: Icons.shopping_bag,
          onTap: _showComingSoonDialog,
        ),

        _buildActionButton(
          icon: Icons.upload_file,
          iconColor: Colors.blue.shade600, 
          label: 'Upload Brochure',
          trailing: Icons.description,
          onTap: _showComingSoonDialog,
        ),

        _buildActionButton(
          icon: Icons.local_offer,
          iconColor: Colors.amber.shade700, 
          label: 'Add Offer Codes',
          trailing: Icons.star,
          onTap: _showComingSoonDialog,
        ),

        _buildActionButton(
          icon: Icons.photo_library,
          iconColor: Colors.pink.shade600, 
          label: 'Add Portfolio Images',
          trailing: Icons.photo,
          onTap: _showComingSoonDialog,
        ),

        _buildActionButtonWithDescription(
          icon: Icons.share,
          iconColor: Colors.teal.shade600, 
          label: 'Manage Social Media',
          description: 'Add / Redirect to Social Pages.',
          trailing: Icons.link,
          onTap: _showComingSoonDialog,
        ),

        const SizedBox(height: AppConstants.spacingSmall),

        // Membership Badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.cardPaddingLarge,
            vertical: AppConstants.cardPaddingMedium,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.workspace_premium,
                  size: AppConstants.iconSizeLarge,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Membership*',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSectionTitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                  letterSpacing: 0.2,
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
          iconColor: Colors.green.shade600, 
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
          iconColor: (_tagSettings?.data.callStatus.whatsappEnabled ?? false) ? Colors.green.shade600 : Colors.blue.shade600,
          label: (_tagSettings?.data.callStatus.whatsappEnabled ?? false) ? 'Disable WhatsApp Contact' : 'Enable WhatsApp Contact',
          trailing: (_tagSettings?.data.callStatus.whatsappEnabled ?? false) ? Icons.toggle_on : Icons.toggle_off_outlined,
          onTap: () => _toggleWhatsapp(),
        ),

        _buildActionButton(
          icon: Icons.nfc,
          iconColor: Colors.blue.shade600, 
          label: 'NGF132 TAP IS ACTIVE',
          trailing: Icons.nfc,
          onTap: _showComingSoonDialog,
        ),

        _buildActionButton(
          icon: Icons.delete_outline,
          iconColor: Colors.red.shade600, 
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.qr_code, color: Colors.blue.shade600),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Share your QR',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSectionTitle,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardDescription,
                    color: AppColors.textGrey,
                    height: 1.5,
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
                        color: Colors.blue.shade600,
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

  // ✅ New Action Button Design
  Widget _buildActionButton({
    required IconData icon,
    Color? iconColor, 
    required String label,
    String? badge,
    IconData? trailing,
    bool isRed = false,
    required VoidCallback onTap,
  }) {
    final effectiveIconColor = iconColor ?? (isRed ? Colors.red : AppColors.black);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.cardPaddingLarge,
          vertical: AppConstants.cardPaddingMedium,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: effectiveIconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppConstants.iconSizeLarge,
                color: effectiveIconColor,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSectionTitle,
                  fontWeight: FontWeight.w600,
                  color: isRed ? Colors.red : AppColors.black,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(AppConstants.spacingSmall),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeSmallText,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingSmall),
            ],
            
            if (trailing != null)
              Icon(
                trailing,
                size: AppConstants.iconSizeLarge,
                color: isRed ? Colors.red.shade400 : Colors.grey.shade400,
              ),
              
            if (trailing == null && badge == null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: AppConstants.iconSizeMedium,
                color: Colors.grey.shade300,
              )
          ],
        ),
      ),
    );
  }

  // ✅ New Action Button With Description Design
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
    final effectiveIconColor = iconColor ?? (isRed ? Colors.red : AppColors.black);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.cardPaddingLarge,
          vertical: AppConstants.cardPaddingMedium,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: effectiveIconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppConstants.iconSizeLarge,
                color: effectiveIconColor,
              ),
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
                          label,
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeSectionTitle,
                            fontWeight: FontWeight.w600,
                            color: isRed ? Colors.red : AppColors.black,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingSmall,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            borderRadius: BorderRadius.circular(AppConstants.spacingSmall),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: AppConstants.fontSizeSmallText,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingSmall),
                      ]
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeCardTitle,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            
            if (trailing != null) ...[
              const SizedBox(width: AppConstants.paddingSmall),
              Icon(
                trailing,
                size: AppConstants.iconSizeLarge,
                color: isRed ? Colors.red.shade400 : Colors.grey.shade400,
              ),
            ],
            
            if (trailing == null && badge == null) ...[
              const SizedBox(width: AppConstants.paddingSmall),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: AppConstants.iconSizeMedium,
                color: Colors.grey.shade300,
              ),
            ]
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade600,
                  ),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.schedule,
                    size: 48,
                    color: Colors.blue.shade600,
                  ),
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
                        color: AppColors.black,
                        fontWeight: FontWeight.w700,
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
  Future<void> _openWhatsApp(String message) async {
    final phoneNumber = '918069409475'; 
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = 'https://wa.me/$phoneNumber?text=$encodedMessage';
    
    final Uri url = Uri.parse(whatsappUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('WhatsApp is not installed on your device');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open WhatsApp: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _shareBusinessOnWhatsApp() async {
    try {
      final userData = await AuthService.getUserData();
      final phone = userData['phone'] ?? '';
      final countryCode = userData['countryCode'] ?? '91';

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
                  Image.asset(
                    'assets/icons/whatsapp.png',
                    width: 56,
                    height: 56,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.chat_bubble,
                        size: 56,
                        color: Colors.green.shade600,
                      );
                    },
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
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: AppColors.black, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pop(context);
                            _openWhatsApp(message);
                          },
                          icon: Image.asset(
                            'assets/icons/whatsapp.png',
                            width: 20,
                            height: 20,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.chat, size: 20);
                            },
                          ),
                          label: const Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: AppColors.black, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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

  // ==========================
  // ✅ WHATSAPP FUNCTIONS
  // ==========================
  // ✅ Open View Business in WebView
  void _openViewBusiness() {
    HapticFeedback.lightImpact();
    
    final url = 'https://app.ngf132.com/mybusiness/${widget.tag.tagInternalId}';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InAppWebViewPage(
          url: url,
          title: 'View Business',
        ),
      ),
    );
  }

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