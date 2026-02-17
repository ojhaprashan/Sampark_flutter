import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_new_app/pages/AppWebView/appweb.dart';
import 'package:my_new_app/pages/widgets/notification_sheet.dart';
import 'package:my_new_app/pages/widgets/etag_download_sheet.dart';
import 'package:my_new_app/pages/widgets/error_dialog.dart';
import 'package:my_new_app/utils/colors.dart';
import 'package:my_new_app/utils/constants.dart';
import 'package:my_new_app/services/tags_service.dart';
import 'package:my_new_app/services/auth_service.dart';
import 'package:my_new_app/services/etag_service.dart';
import 'package:my_new_app/services/emergency_service.dart';
import 'package:my_new_app/pages/scan/contact_vehicle_owner_page.dart';
import 'add_secondary_number_sheet.dart';
import 'add_emergency_contact_sheet.dart';

class ManageTagTab extends StatefulWidget {
  final Tag tag;
  final TagSettings? tagSettings;
  final VoidCallback? onDataUpdated;  // ✅ Callback to refresh data when updated

  const ManageTagTab({
    super.key,
    required this.tag,
    this.tagSettings,
    this.onDataUpdated,
  });

  @override
  State<ManageTagTab> createState() => _ManageTagTabState();
}

class _ManageTagTabState extends State<ManageTagTab> {
  // ✅ State variables for toggling
  bool _isCallsEnabled = true;
  bool _isTagEnabled = true;
  bool _isLoading = false;
  String _userPhone = '';
  String _countryCode = '+91'; // Track country code for India-specific features

  @override
  void initState() {
    super.initState();
    // Initialize from tagSettings if available
    _isCallsEnabled = widget.tagSettings?.data.callStatus.callsEnabled ?? true;
    _isTagEnabled = widget.tagSettings?.data.status == 'Active';
    _loadUserPhone();
  }

  // ✅ Load user phone from AuthService
  Future<void> _loadUserPhone() async {
    try {
      final userData = await AuthService.getUserData();
      final phone = userData['phone'] ?? '';
      final countryCode = userData['countryCode'] ?? '+91';
      if (mounted) {
        setState(() {
          _userPhone = phone;
          _countryCode = countryCode;
        });
      }
    } catch (e) {
      print('Error loading user phone: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
        ),
        child: Column(
          children: [
            const SizedBox(height: AppConstants.spacingMedium),
            _buildActionButton(
              context,
              icon: Icons.chat_bubble_outline,
              iconColor: Colors.blue.shade600,
              label: 'View Contact Page.',
              onTap: () {
                 final tagId = int.tryParse(widget.tag.tagInternalId) ?? 0;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactVehicleOwnerPage(
                      tagId: tagId,
                      vehicleNumber: widget.tag.displayName,
                      vehicleName: 'Car Tag',
                    ),
                  ),
                );
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.notifications_none,
              iconColor: Colors.orange.shade600,
              label: 'View Notifications',
              onTap: () {
                _showNotificationSheet(context);
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.location_on_outlined,
              iconColor: Colors.red.shade600,
              label: 'Check scan locations',
              onTap: () {
                // Add your logic
              },
            ),
            // ✅ Dynamic Disable/Enable Calls Button (shows opposite action)
            _buildActionButton(
              context,
              icon: _isCallsEnabled ? Icons.phone_disabled : Icons.phone_enabled,
              iconColor: _isCallsEnabled ? Colors.red.shade700 : Colors.green.shade600,
              label: _isCallsEnabled ? 'Disable Calls' : 'Enable Calls',
              trailing: _isCallsEnabled ? Icons.toggle_on : Icons.toggle_off_outlined,
              onTap: () {
                _toggleCalls(context);
              },
            ),
            // ✅ Dynamic Enable/Disable Tag Button (shows opposite action)
            _buildActionButton(
              context,
              icon: _isTagEnabled ? Icons.pause : Icons.play_arrow,
              iconColor: _isTagEnabled ? Colors.orange.shade600 : Colors.green.shade600,
              label: _isTagEnabled ? 'Disable the tag' : 'Enable the tag',
              trailing: _isTagEnabled ? Icons.pause : Icons.play_arrow,
              onTap: () {
                _toggleTag(context);
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.phone,
              iconColor: Colors.teal.shade600,
              label: 'Add secondary number',
              trailing: Icons.phone,
              onTap: () {
                _showAddSecondaryNumberSheet(context);
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.contact_emergency,
              iconColor: Colors.purple.shade600,
              label: 'Add Emergency contact',
              trailing: Icons.contacts,
              onTap: () {
                _showEmergencyContactSheet(context);
              },
            ),
            // ✅ Show India-specific features only for India
            if (_countryCode == '+91') ...[
              _buildActionButton(
                context,
                icon: Icons.car_repair,
                iconColor: Colors.red.shade600,
                label: 'Roadside Assistance (RSA)',
                badge: '24/7',
                trailing: Icons.arrow_forward_ios,
                onTap: () {
                  _openRSA(context);
                },
              ),
              _buildActionButton(
                context,
                icon: Icons.download,
                iconColor: Colors.indigo.shade600,
                label: 'Download eTag',
                badge: 'New!',
                trailing: Icons.download,
                onTap: () {
                  _generateETag(context);
                },
              ),
            ],
            const SizedBox(height: AppConstants.spacingMedium),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InAppWebViewPage(
                      url: 'https://app.ngf132.com/fastag',
                      title: 'FasTag Recharge',
                    ),
                  ),
                );
              },
              child: _buildRechargeSection(),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ========================
  // ✅ LOADING OVERLAY
  // ========================

  // ✅ Show Loading Overlay (Simple loader without text)
  void _showLoadingOverlay(BuildContext context) {
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
  void _hideLoadingOverlay(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // ========================
  // ✅ TOGGLE FUNCTIONS
  // ========================

  // ✅ Toggle Calls Function with API call and Loading Overlay
  void _toggleCalls(BuildContext context) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.mediumImpact();
    _showLoadingOverlay(context);

    try {
      final userData = await AuthService.getUserData();
      final phone = userData['phone'] ?? '';
      final countryCode = userData['countryCode'] ?? '+91';
      final phoneWithCountryCode = countryCode.replaceFirst('+', '') + phone;

      final newCallsEnabled = !_isCallsEnabled;

      await TagsService.updateTagSettings(
        tagId: widget.tag.tagInternalId,
        phone: phoneWithCountryCode,
        callsEnabled: newCallsEnabled,
        whatsappEnabled: widget.tagSettings?.data.callStatus.whatsappEnabled ?? false,
        callMaskingEnabled: widget.tagSettings?.data.callStatus.callMaskingEnabled ?? false,
        videoCallEnabled: widget.tagSettings?.data.callStatus.videoCallEnabled ?? false,
        smValue: '67s87s6yys66',
        dgValue: 'testYU78dII8iiUIPSISJ',
      );

      setState(() {
        _isCallsEnabled = newCallsEnabled;
        _isLoading = false;
      });

      _hideLoadingOverlay(context);

      _showSuccessDialog(
        context,
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
      _hideLoadingOverlay(context);
      _showErrorDialog(context, 'Error', 'Failed to update call settings: $e');
    }
  }

  // ✅ Toggle Tag Function with API call and Loading Overlay
  void _toggleTag(BuildContext context) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.mediumImpact();
    _showLoadingOverlay(context);

    try {
      final userData = await AuthService.getUserData();
      final phone = userData['phone'] ?? '';
      final countryCode = userData['countryCode'] ?? '+91';
      final phoneWithCountryCode = countryCode.replaceFirst('+', '') + phone;

      final newTagEnabled = !_isTagEnabled;
      // ✅ Set status based on newTagEnabled (active/pause)
      final newStatus = newTagEnabled ? 'active' : 'pause';

      await TagsService.updateTagSettings(
        tagId: widget.tag.tagInternalId,
        phone: phoneWithCountryCode,
        callsEnabled: widget.tagSettings?.data.callStatus.callsEnabled ?? true,
        whatsappEnabled: widget.tagSettings?.data.callStatus.whatsappEnabled ?? false,
        callMaskingEnabled: widget.tagSettings?.data.callStatus.callMaskingEnabled ?? false,
        videoCallEnabled: widget.tagSettings?.data.callStatus.videoCallEnabled ?? false,
        smValue: '67s87s6yys66',
        dgValue: 'testYU78dII8iiUIPSISJ',
        status: newStatus,  // ✅ Pass status parameter
      );

      setState(() {
        _isTagEnabled = newTagEnabled;
        _isLoading = false;
      });

      _hideLoadingOverlay(context);

      // ✅ Call refresh callback to reload data from API
      widget.onDataUpdated?.call();

      _showSuccessDialog(
        context,
        icon: newTagEnabled ? Icons.check_circle : Icons.pause_circle,
        iconColor: newTagEnabled ? Colors.green : Colors.orange,
        title: newTagEnabled ? 'Tag Enabled' : 'Tag Disabled',
        message: newTagEnabled
            ? 'Your tag is now active and can be scanned.'
            : 'Your tag has been temporarily disabled.',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _hideLoadingOverlay(context);
      _showErrorDialog(context, 'Error', 'Failed to update tag status: $e');
    }
  }

  // ===================
  // ✅ DIALOG FUNCTIONS
  // ===================

  // ✅ Success Dialog with Animation
  void _showSuccessDialog(
    BuildContext context, {
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
  void _showErrorDialog(BuildContext context, String title, String message) {
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

  // ========================
  // ✅ HELPER FUNCTIONS
  // ========================

  // ✅ Show Notification Sheet
  void _showNotificationSheet(BuildContext context) {
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

  // ✅ Show Add Secondary Number Sheet
  void _showAddSecondaryNumberSheet(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final phoneNumber = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSecondaryNumberSheet(
        tagId: widget.tag.tagInternalId.toString(),
        existingSecondaryNumber: widget.tagSettings?.data.secondaryNumber,  // ✅ Pass existing data
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
          callsEnabled: widget.tagSettings?.data.callStatus.callsEnabled ?? true,
          whatsappEnabled: widget.tagSettings?.data.callStatus.whatsappEnabled ?? false,
          callMaskingEnabled: widget.tagSettings?.data.callStatus.callMaskingEnabled ?? false,
          videoCallEnabled: widget.tagSettings?.data.callStatus.videoCallEnabled ?? false,
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
          widget.onDataUpdated?.call();
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
  void _showEmergencyContactSheet(BuildContext context) async {
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
            tagId: widget.tag.tagInternalId.toString(),  // ✅ Convert to String for sheet
            existingPrimaryPhone: existingEmergency.data.primaryPhone,
            existingSecondaryPhone: existingEmergency.data.secondaryPhone,
            existingBloodGroup: existingEmergency.data.bloodGroup,
            existingInsurance: existingEmergency.data.insurance,
            existingNote: existingEmergency.data.note,
          ),
        );
        // ✅ Refresh data after sheet closes
        widget.onDataUpdated?.call();
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
            tagId: widget.tag.tagInternalId.toString(),  // ✅ Convert to String for sheet
          ),
        );
        // ✅ Refresh data after sheet closes
        widget.onDataUpdated?.call();
      }
    }
  }

  // ✅ Open RSA in WebView
  void _openRSA(BuildContext context) {
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

  // ✅ Generate and Download eTag
  void _generateETag(BuildContext context) async {
    HapticFeedback.mediumImpact();
    
    _showLoadingOverlay(context);

    try {
      final userData = await AuthService.getUserData();
      final phone = userData['phone'] ?? '';
      final countryCode = userData['countryCode'] ?? '+91';

      final response = await ETagService.getETag(
        tagId: widget.tag.tagInternalId.toString(),
        phone: phone,
        countryCode: countryCode,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
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
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Show error dialog
      if (mounted) {
        ErrorDialog.show(
          context: context,
          title: 'eTag Download Failed',
          message: e.toString().replaceFirst('Exception: ', ''),
          onRetry: () {
            _generateETag(context);
          },
        );
      }
    }
  }



  // ========================
  // ✅ UI WIDGETS
  // ========================

  Widget _buildActionButton(
    BuildContext context, {
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

  Widget _buildRechargeSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPaddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
        border: Border.all(
          color: AppColors.lightGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.credit_card,
              color: Colors.grey.shade600,
              size: AppConstants.iconSizeLarge,
            ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FasTag Recharge',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardTitle,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  'Win assured Cashback',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardDescription,
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
}
