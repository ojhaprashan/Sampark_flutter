import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_new_app/pages/scan/contact_reasons.dart';
import 'package:my_new_app/pages/scan/message_preview_sheet.dart';
import 'package:my_new_app/pages/scan/masked_call_sheet.dart';
import 'package:my_new_app/pages/scan/mt_message_preview_sheet.dart';
import 'package:my_new_app/pages/scan/mt_masked_call_sheet.dart';
import 'package:my_new_app/pages/scan/door_message_preview_sheet.dart';
import 'package:my_new_app/pages/scan/door_masked_call_sheet.dart';
import 'package:my_new_app/pages/scan/emergency_section_widget.dart';
import 'package:my_new_app/pages/scan/tag_profile_skeleton.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import '../AppWebView/appweb.dart';

import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/tag_profile_service.dart';
import '../../services/location_service.dart';
import '../../services/auth_service.dart';
import '../../services/save_tag_location_service.dart';

class ContactVehicleOwnerPage extends StatefulWidget {
  final int tagId;
  final String vehicleNumber;
  final String vehicleName;
  final String? phoneNumber;
  final String? maskedNumber;

  const ContactVehicleOwnerPage({
    super.key,
    required this.tagId,
    required this.vehicleNumber,
    this.vehicleName = '',
    this.phoneNumber,
    this.maskedNumber,
  });

  @override
  State<ContactVehicleOwnerPage> createState() =>
      _ContactVehicleOwnerPageState();
}

class _ContactVehicleOwnerPageState extends State<ContactVehicleOwnerPage> {
  bool _isLoggedIn = false;
  bool _showReasonList = false;
  String? _selectedReason;

  // Tag profile data
  TagProfileData? _tagProfileData;
  bool _isLoadingProfile = true;
  String? _profileError;

  List<ContactReason> _reasons = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchTagProfile();
    // Save tag location when page loads (only if tag ID is from scan, not 0)
    if (widget.tagId != 0) {
      _saveTagLocation();
    }
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }
  }
  /// Save tag location to the server once the page loads
  /// Uses location data from LocalStorage and phone number from user data
  Future<void> _saveTagLocation() async {
    try {
      // Get saved location from local storage
      final locationData = await LocationService.getLastLocation();
      
      if (locationData == null) {
        print('⚠️ [ContactVehicleOwnerPage] Location not available for saving');
        return;
      }

      // Get user phone number
      final userData = await AuthService.getUserData();
      final phoneNumber = userData['phone'] ?? '';

      print('📍 [ContactVehicleOwnerPage] Attempting to save tag location');
      print('   ├─ Tag ID: ${widget.tagId}');
      print('   ├─ Phone: $phoneNumber');
      print('   ├─ Location: ${locationData.latitude}, ${locationData.longitude}');

      // Call the API to save tag location
      await SaveTagLocationService.saveTagLocation(
        tagId: widget.tagId,
        latitude: locationData.latitude,
        longitude: locationData.longitude,
        phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
      );

      print('✅ [ContactVehicleOwnerPage] Tag location saved successfully');
    } catch (e) {
      print('❌ [ContactVehicleOwnerPage] Error saving tag location: $e');
      // Don't show error to user - this is a background operation
    }
  }






  Future<void> _fetchTagProfile() async {
    // Skip fetch if tagId is 0 (manual navigation, not from QR scan)
    if (widget.tagId == 0) {
      setState(() {
        _isLoadingProfile = false;
      });
      return;
    }

    try {
      final response = await TagProfileService.getTagProfile(
        tagId: widget.tagId,
      );

      if (mounted) {
        setState(() {
          _tagProfileData = response.data;
          _isLoadingProfile = false;
          // Load reasons based on tag type
          _reasons = ContactReasons.getReasonsByTagType(
              _tagProfileData!.tagTypeCode);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _profileError = e.toString();
          _isLoadingProfile = false;
        });
      }
    }
  }

  void _makeCall() {
    // Check if tag is paused
    if (_tagProfileData != null && _tagProfileData!.isPaused) {
      _showErrorSnackBar('Tag is paused. Please enable it first');
      return;
    }

    // Check if calls are enabled - if not, all call types are disabled
    if (_tagProfileData == null || !_tagProfileData!.callFlags.callsEnabled) {
      _showErrorSnackBar('Calls are not enabled for this tag');
      return;
    }

    // Check if call masking is enabled
    if (_tagProfileData!.callFlags.callMaskingEnabled) {
      // Open appropriate masked call sheet based on tag type
      if (_tagProfileData!.tagTypeCode.toUpperCase() == 'DR') {
        // Use door sheet for Door tags
        DoorMaskedCallSheet.show(
          context,
          doorTagId: widget.tagId.toString(),
          phoneNumber: _tagProfileData!.phone,
        );
      } else if (ContactReasons.isVehicleTag(_tagProfileData!.tagTypeCode)) {
        // Use vehicle sheet for Car/Bike tags
        MaskedCallSheet.show(
          context,
          vehicleNumber: _tagProfileData!.plateNumber,
          phoneNumber: _tagProfileData!.phone,
          tagId: widget.tagId,
        );
      } else {
        // Use MT sheet for Lost & Found tags
        MTMaskedCallSheet.show(
          context,
          tagName: _tagProfileData!.plateNumber,
          phoneNumber: _tagProfileData!.phone,
          tagId: widget.tagId,
        );
      }
    } else {
      // Direct call without masking
      _makeDirectCall();
    }
  }

  void _makeDirectCall() {
    if (_tagProfileData == null || _tagProfileData!.phone.isEmpty) {
      _showErrorSnackBar('Phone number not available');
      return;
    }

    // Open phone dialer with the phone number from tag profile
    final Uri phoneUri = Uri(scheme: 'tel', path: _tagProfileData!.phone);
    launchUrl(phoneUri);
  }

  void _initiateVideoCall() {
    // Check if tag is paused
    if (_tagProfileData != null && _tagProfileData!.isPaused) {
      _showErrorSnackBar('Tag is paused. Please enable it first');
      return;
    }

    // Check if video calls are enabled
    if (_tagProfileData == null || !_tagProfileData!.callFlags.videoCallEnabled) {
      _showErrorSnackBar('Video calls are not enabled for this tag');
      return;
    }

    // Placeholder for video call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Video Call feature coming soon'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.paddingSmall),
        ),
      ),
    );
  }

  void _onMessageButtonClicked() {
    // Check if tag is paused
    if (_tagProfileData != null && _tagProfileData!.isPaused) {
      _showErrorSnackBar('Tag is paused. Please enable it first');
      return;
    }

    setState(() {
      _showReasonList = true;
      _selectedReason = null;
    });
  }

  void _sendMessage() {
    if (_selectedReason == null) {
      _showErrorSnackBar('Please select a reason');
      return;
    }

    if (_tagProfileData == null || _tagProfileData!.phone.isEmpty) {
      _showErrorSnackBar('Phone number not available');
      return;
    }

    final reasonText =
        _reasons.firstWhere((r) => r.value == _selectedReason).text;

    // Use appropriate sheet based on tag type
    if (_tagProfileData!.tagTypeCode.toUpperCase() == 'DR') {
      // Door tag - use integer reason code
      final reasonCode = int.tryParse(_selectedReason!) ?? 1;
      DoorMessagePreviewSheet.show(
        context,
        doorTagId: widget.tagId.toString(),
        reasonCode: reasonCode,
        reasonText: reasonText,
      );
    } else if (ContactReasons.isVehicleTag(_tagProfileData!.tagTypeCode)) {
      // Use vehicle sheet for Car/Bike tags
      final reasonCode = _reasons.indexWhere((r) => r.value == _selectedReason) + 1;
      MessagePreviewSheet.show(
        context,
        vehicleNumber: _tagProfileData!.plateNumber,
        reasonText: reasonText,
        phoneNumber: _tagProfileData!.phone,
        tagId: widget.tagId,
      );
    } else {
      // Use MT sheet for Lost & Found tags
      final reasonCode = _reasons.indexWhere((r) => r.value == _selectedReason) + 1;
      MTMessagePreviewSheet.show(
        context,
        tagName: _tagProfileData!.plateNumber,
        reasonText: reasonText,
        phoneNumber: _tagProfileData!.phone,
        tagId: widget.tagId,
        reasonCode: reasonCode,
      );
    }
  }

  void _openWhatsAppSupport() async {
    final tagPublicId = _tagProfileData?.tagPublicId ?? widget.tagId.toString();
    final message = "Hi, i want to connect with vehicle owner Tag ID: $tagPublicId, Please Help me.";
    final phoneNumber = '918069409475';
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = 'https://wa.me/$phoneNumber?text=$encodedMessage';
    
    final Uri url = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showErrorSnackBar('Unable to open WhatsApp');
    }
  }

  void _reportWrongInfo() {
    final tagId = _tagProfileData?.tagId ?? widget.tagId;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InAppWebViewPage(
          url: 'https://app.ngf132.com/report_tag/$tagId',
          title: 'Report Wrong Info',
        ),
      ),
    );
  }

  void _shareDetails() async {
    final tagId = _tagProfileData?.tagId ?? widget.tagId;
    final message = "Hi, please contact vehicle owner here: https://app.ngf132.com/car/$tagId, This is sampark APP, download today.";
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = 'https://wa.me/?text=$encodedMessage';
    
    final Uri url = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showErrorSnackBar('Unable to open WhatsApp');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.paddingSmall),
        ),
      ),
    );
  }

  /// Get display name - mask for vehicles, show full for non-vehicles
  String _getDisplayName(String name) {
    if (_tagProfileData == null) return name;
    
    final tagTypeCode = _tagProfileData!.tagTypeCode.toUpperCase();
    
    // For non-vehicle tags (MT, BS, DR, etc.), show full name
    if (!['C', 'B'].contains(tagTypeCode)) {
      return name;
    }
    
    // For vehicle tags (Car, Bike), mask the name
    return _getMaskedPlateNumber(name);
  }

  /// Mask last 4 digits of plate number
  String _getMaskedPlateNumber(String plateNumber) {
    if (plateNumber.length <= 4) {
      return '****';
    }
    final unmaskedLength = plateNumber.length - 4;
    final unmaskedPart = plateNumber.substring(0, unmaskedLength);
    return '$unmaskedPart****';
  }

  /// Get page title based on tag type
  String _getPageTitle() {
    if (_tagProfileData == null) return 'Contact owner';
    
    final tagTypeCode = _tagProfileData!.tagTypeCode.toUpperCase();
    if (tagTypeCode == 'DR') {
      return 'Contact tag owner';
    }
    if (ContactReasons.isVehicleTag(tagTypeCode)) {
      return 'Contact vehicle owner.';
    }
    return 'Contact tag owner.';
  }

  /// Get contact question based on tag type
  String _getContactQuestion() {
    if (_tagProfileData == null) return 'How would you like to contact?';
    
    final tagTypeCode = _tagProfileData!.tagTypeCode.toUpperCase();
    if (tagTypeCode == 'DR') {
      return 'How would you like to contact the resident?';
    }
    if (ContactReasons.isVehicleTag(tagTypeCode)) {
      return 'Would you like to call or text the owner ?';
    }
    return 'How would you like to contact?';
  }

  /// Get reason selection question based on tag type
  String _getReasonSelectionQuestion() {
    if (_tagProfileData == null) return 'Why would you like to contact?';
    
    final tagTypeCode = _tagProfileData!.tagTypeCode.toUpperCase();
    if (tagTypeCode == 'DR') {
      return 'Why are you visiting?';
    }
    if (ContactReasons.isVehicleTag(tagTypeCode)) {
      return 'Why would you like to contact the vehicle owner?';
    }
    return 'Why would you like to contact the tag owner?';
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
                // Content
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: _isLoadingProfile
                        ? const TagProfileSkeleton()
                        : SingleChildScrollView(
                      padding: EdgeInsets.all(AppConstants.paddingPage),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title - Dynamic based on tag type
                          Text(
                            _getPageTitle(),
                            style: TextStyle(
                              fontSize: AppConstants.fontSizePageTitle,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: AppConstants.spacingMedium),

                           // Standalone Enlarged Number Plate
                          if (_tagProfileData != null &&
                              _tagProfileData!.plateNumber.isNotEmpty) ...[
                            _buildIndianNumberPlate(
                              _getDisplayName(_tagProfileData!.plateNumber),
                              isLarge: true,
                            ),
                            SizedBox(height: AppConstants.spacingLarge),
                          ] else if (_isLoadingProfile) ...[
                            // ✅ Demo Tag Disclaimer
                            if (_tagProfileData != null && _tagProfileData!.isDemoTag)
                              Container(
                                padding: EdgeInsets.all(AppConstants.paddingLarge),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.borderRadiusCard),
                                  border: Border.all(
                                    color: Colors.blue.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue.shade700,
                                      size: 28,
                                    ),
                                    SizedBox(
                                        width:
                                            AppConstants.spacingMedium),
                                    Expanded(
                                      child: Text(
                                        'This is a free tag. It will have its limitations.',
                                        style: TextStyle(
                                          fontSize: AppConstants
                                              .fontSizeCardTitle,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (_tagProfileData != null && _tagProfileData!.isDemoTag)
                              SizedBox(height: AppConstants.spacingLarge),
                          ] else if (_isLoadingProfile) ...[
                            // Skeleton is handled at container level
                            const SizedBox.shrink(),
                          ] else if (_profileError != null) ...[
                            Container(
                              padding: EdgeInsets.all(AppConstants.paddingMedium),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadiusCard),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: AppConstants.iconSizeMedium,
                                  ),
                                  SizedBox(width: AppConstants.spacingMedium),
                                  Expanded(
                                    child: Text(
                                      'Error loading profile',
                                      style: TextStyle(
                                        fontSize:
                                            AppConstants.fontSizeCardTitle,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: AppConstants.spacingLarge),
                          ],

                          // Show either buttons OR reason list
                          if (!_showReasonList && _tagProfileData != null) ...[
                            // Check if tag is paused
                            if (_tagProfileData!.isPaused) ...[
                              // Show paused message
                              Container(
                                padding: EdgeInsets.all(AppConstants.paddingLarge),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.borderRadiusCard),
                                  border: Border.all(
                                    color: Colors.orange.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.pause_circle_outline,
                                      color: Colors.orange.shade700,
                                      size: 28,
                                    ),
                                    SizedBox(
                                        width:
                                            AppConstants.spacingMedium),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tag is Paused',
                                            style: TextStyle(
                                              fontSize: AppConstants
                                                  .fontSizeCardTitle,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.orange.shade700,
                                            ),
                                          ),
                                          SizedBox(
                                              height: AppConstants
                                                  .spacingSmall),
                                          Text(
                                            'Please enable this tag first to call or message the owner.',
                                            style: TextStyle(
                                              fontSize: AppConstants
                                                  .fontSizeCardDescription,
                                              color: Colors.orange.shade600,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              // Tag is active - show Question and Action Cards
                              Text(
                                _getContactQuestion(),
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizeCardTitle,
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                  height: AppConstants.spacingLarge),

                              // Action Cards - Box Design
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      // Call Options - Keep original layout
                                      Expanded(
                                        child: _tagProfileData!.callFlags.callsEnabled
                                            ? (_tagProfileData!.callFlags.callMaskingEnabled
                                                ? _buildActionCard(
                                                    icon: Icons.phone,
                                                    label: 'Masked Call',
                                                    color: Colors.orange,
                                                    isEnabled: true,
                                                    onTap: _makeCall,
                                                  )
                                                : _buildActionCard(
                                                    icon: Icons.phone,
                                                    label: 'Call',
                                                    color: Colors.orange,
                                                    isEnabled: true,
                                                    onTap: _makeCall,
                                                  ))
                                            : Opacity(
                                                opacity: 0.5,
                                                child: _buildActionCard(
                                                  icon: Icons.phone,
                                                  label: 'Call',
                                                  color: Colors.grey,
                                                  isEnabled: false,
                                                  onTap: () {},
                                                ),
                                              ),
                                      ),
                                      SizedBox(width: AppConstants.spacingLarge),
                                      // Message - Original layout
                                      Expanded(
                                        child: _buildActionCard(
                                          icon: Icons.chat_bubble,
                                          label: 'Message',
                                          color: Colors.blue,
                                          isEnabled: true,
                                          onTap: _onMessageButtonClicked,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Video Call Mini Button in a separate Row below Masked Call
                                  if (_tagProfileData!.callFlags.videoCallEnabled) ...[
                                    SizedBox(height: AppConstants.spacingSmall),
                                    Row(
                                      children: [
                                        _buildMiniButton(
                                          icon: Icons.videocam,
                                          label: 'Video Call',
                                          color: Colors.green,
                                          onTap: _initiateVideoCall,
                                        ),
                                        const Spacer(), // Keeps Video Call on the left
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ] else if (!_showReasonList &&
                              !_isLoadingProfile) ...[
                            // Error state
                            Center(
                              child: Text(
                                _profileError != null
                                    ? 'Unable to load tag details'
                                    : '',
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizeCardTitle,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ] else if (!_showReasonList) ...[
                            // Initial loading state
                            Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.activeYellow,
                                  ),
                                ),
                              ),
                            ),
                          ] else if (_showReasonList) ...[
                            // Question for reason selection
                            // Row(
                            //   children: [
                            //     IconButton(
                            //       onPressed: () {
                            //         setState(() {
                            //           _showReasonList = false;
                            //           _selectedReason = null;
                            //         });
                            //       },
                            //       icon: Icon(
                            //         Icons.arrow_back,
                            //         color: AppColors.black,
                            //       ),
                            //     ),
                            //     // Expanded(
                            //     //   child: Text(
                            //     //     _getReasonSelectionQuestion(),
                            //     //     style: TextStyle(
                            //     //       fontSize: AppConstants.fontSizeCardTitle,
                            //     //       fontWeight: FontWeight.w600,
                            //     //       color: AppColors.black,
                            //     //     ),
                            //     //   ),
                            //     // ),
                            //   ],
                            // ),
                            SizedBox(height: AppConstants.spacingTooSmall),

                            // Reason Options
                            ..._reasons
                                .map((reason) => _buildReasonOption(reason)),
                            SizedBox(height: AppConstants.spacingLarge),

                            // Question for contact method
                            Text(
                              _getContactQuestion(),
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeCardTitle,
                                color: AppColors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: AppConstants.spacingMedium),

                            // Action Buttons Row
                                Row(
                                  children: [
                                    // Call Button (with check for calls_enabled)
                                    Expanded(
                                      child: Opacity(
                                        opacity: _tagProfileData != null &&
                                                _tagProfileData!
                                                    .callFlags.callsEnabled
                                            ? 1.0
                                            : 0.5,
                                        child: _buildSimpleButton(
                                          icon: Icons.phone,
                                          label: _tagProfileData != null &&
                                                  _tagProfileData!.callFlags
                                                      .callMaskingEnabled
                                              ? 'Masked Call'
                                              : 'Call',
                                          color: _tagProfileData != null &&
                                                  _tagProfileData!
                                                      .callFlags.callsEnabled
                                              ? Colors.orange
                                              : Colors.grey,
                                          onTap: _tagProfileData != null &&
                                                  _tagProfileData!
                                                      .callFlags.callsEnabled
                                              ? _makeCall
                                              : () {
                                                  _showErrorSnackBar(
                                                      'Calls are not enabled for this tag');
                                                },
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: AppConstants.spacingMedium),
                                    // Message Button
                                    Expanded(
                                      child: _buildSimpleButton(
                                        icon: Icons.chat_bubble,
                                        label: 'Message',
                                        color: Colors.blue,
                                        onTap: _sendMessage,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_tagProfileData != null &&
                                    _tagProfileData!.callFlags.videoCallEnabled) ...[
                                  SizedBox(height: AppConstants.spacingSmall),
                                  Row(
                                    children: [
                                      _buildMiniButton(
                                        icon: Icons.videocam,
                                        label: 'Video Call',
                                        color: Colors.green,
                                        onTap: _initiateVideoCall,
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                ],
                          ],

                          SizedBox(height: AppConstants.spacingLarge),

                          // Emergency Section
                          EmergencySectionWidget(
                            tagId: widget.tagId,
                            tagTypeCode: _tagProfileData?.tagTypeCode ?? 'c',
                          ),

                          SizedBox(height: AppConstants.paddingPage),
                          
                          // Urgent Support / Report / Share Section
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/icons/whatsapp.png',
                                      width: 14,
                                      height: 14,
                                      errorBuilder: (context, error, stackTrace) => 
                                        Icon(Icons.chat, size: 14, color: AppColors.textGrey),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: _openWhatsAppSupport,
                                      child: Text(
                                        'Urgent — Sampark us',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textGrey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '·',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _reportWrongInfo,
                                  child: Text(
                                    'Report wrong info',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  '·',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _shareDetails,
                                  child: Text(
                                    'Share',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppConstants.paddingPage),
                        ],
                      ),
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

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          border: Border.all(
            color: color.withOpacity(isEnabled ? 0.6 : 0.3),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: color.withOpacity(isEnabled ? 0.15 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            SizedBox(height: AppConstants.spacingMedium),
            Text(
              label,
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            if (!isEnabled) ...[
              SizedBox(height: 4),
              Text(
                'Disabled',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeCardDescription,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppConstants.paddingMedium + 2,
          horizontal: AppConstants.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          border: Border.all(
            color: color,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: AppConstants.iconSizeMedium,
            ),
            SizedBox(width: AppConstants.spacingSmall),
            Text(
              label,
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 6,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius / 1.5),
          border: Border.all(
            color: color,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonOption(ContactReason reason) {
    final isSelected = _selectedReason == reason.value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReason = reason.value;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppConstants.spacingMedium),
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.activeYellow.withOpacity(0.2)
              : AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          border: Border.all(
            color: isSelected ? AppColors.activeYellow : AppColors.lightGrey,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.activeYellow.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              reason.icon,
              size: 24,
              color: isSelected ? AppColors.black : AppColors.textGrey,
            ),
            SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: Text(
                reason.text,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeCardTitle,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.black : AppColors.textGrey,
                  height: 1.3,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.activeYellow
                      : AppColors.lightGrey,
                  width: 2,
                ),
                color: isSelected ? AppColors.activeYellow : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.black,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndianNumberPlate(String plateNumber, {bool isLarge = false}) {
    final double height = isLarge ? 54 : 48;
    final double blueStripWidth = isLarge ? 32 : 24;
    final double fontSize = isLarge ? 22 : 18;
    final double chakraSize = isLarge ? 14 : 12;
    final double indFontSize = isLarge ? 10 : 8;
    final double letterSpacing = isLarge ? 1.5 : 1.2;
    final double screwSize = isLarge ? 6 : 5;
    final double screwPos = isLarge ? 4 : 3;

    return Container(
      height: height,
      margin: EdgeInsets.symmetric(
        horizontal: isLarge ? 0 : AppConstants.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        // Thick black border for the plate frame
        border: Border.all(color: Colors.black87, width: isLarge ? 3.0 : 2.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: isLarge ? MainAxisSize.min : MainAxisSize.max,
        children: [
          // Left Blue Strip (IND)
          Container(
            width: blueStripWidth,
            decoration: const BoxDecoration(
              color: Color(0xFF003399), // Standard HSRP Blue
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5.0),
                bottomLeft: Radius.circular(5.0),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIndianFlag(width: isLarge ? 24 : 16, height: isLarge ? 16 : 10),
                const SizedBox(height: 4),
                Text(
                  'IND',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: indFontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Right Side - Plate Number with Screws
          Container(
            padding: EdgeInsets.symmetric(horizontal: isLarge ? 12 : 15),
            child: Stack(
              children: [
                // Simulated screws in the corners
                Positioned(top: screwPos / 2, left: -10, child: _buildScrew(size: screwSize)),
                Positioned(top: screwPos / 2, right: -10, child: _buildScrew(size: screwSize)),
                Positioned(bottom: screwPos / 2, left: -10, child: _buildScrew(size: screwSize)),
                Positioned(bottom: screwPos / 2, right: -10, child: _buildScrew(size: screwSize)),

                // The actual plate number
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    plateNumber,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: letterSpacing,
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

  /// Builds a tiny grey circle to simulate a screw on the number plate
  Widget _buildScrew({double size = 6}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade600, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: const Offset(-1, -1),
            blurRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildIndianFlag({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFF9933),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(1.5), topRight: Radius.circular(1.5)),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                child: Icon(
                  Icons.radio_button_checked,
                  color: const Color(0xFF000080),
                  size: height * 0.3,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF138808),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(1.5), bottomRight: Radius.circular(1.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}