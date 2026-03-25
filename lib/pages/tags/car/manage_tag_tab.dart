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
import 'package:my_new_app/pages/tags/scan_locations_page.dart';
import 'add_secondary_number_sheet.dart';
import 'add_emergency_contact_sheet.dart';

class ManageTagTab extends StatefulWidget {
  final Tag tag;
  final TagSettings? tagSettings;
  final VoidCallback? onDataUpdated;  

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
  bool _isCallsEnabled = true;
  bool _isTagEnabled = true;
  bool _isWhatsappEnabled = false;
  bool _isCallMaskingEnabled = false;
  bool _isVideoCallEnabled = false;
  bool _isLoading = false;
  String _userPhone = '';
  String _countryCode = '+91'; 

  @override
  void initState() {
    super.initState();
    _isCallsEnabled = widget.tagSettings?.data.callStatus.callsEnabled ?? true;
    _isTagEnabled = widget.tagSettings?.data.status == 'Active';
    _isWhatsappEnabled = widget.tagSettings?.data.callStatus.whatsappEnabled ?? false;
    _isCallMaskingEnabled = widget.tagSettings?.data.callStatus.callMaskingEnabled ?? false;
    _isVideoCallEnabled = widget.tagSettings?.data.callStatus.videoCallEnabled ?? false;
    _loadUserPhone();
  }

  @override
  void didUpdateWidget(ManageTagTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tagSettings != null && oldWidget.tagSettings != widget.tagSettings) {
      setState(() {
        _isCallsEnabled = widget.tagSettings!.data.callStatus.callsEnabled;
        _isTagEnabled = widget.tagSettings!.data.status == 'Active';
        _isWhatsappEnabled = widget.tagSettings!.data.callStatus.whatsappEnabled;
        _isCallMaskingEnabled = widget.tagSettings!.data.callStatus.callMaskingEnabled;
        _isVideoCallEnabled = widget.tagSettings!.data.callStatus.videoCallEnabled;
      });
    }
  }

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

  bool _isVehicleFromStateCode(List<String> stateCodes) {
    final vehicleNumber = widget.tag.displayName.toUpperCase();
    return stateCodes.any((code) => vehicleNumber.startsWith(code));
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
                HapticFeedback.mediumImpact();
                final phoneWithCountryCode = _countryCode.replaceFirst('+', '') + _userPhone;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScanLocationsPage(
                      tagId: widget.tag.tagInternalId.isNotEmpty ? int.tryParse(widget.tag.tagInternalId) ?? 0 : 0,
                      phoneWithCountryCode: phoneWithCountryCode,
                      tagName: widget.tag.displayName,
                    ),
                  ),
                );
              },
            ),
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
            if (_countryCode == '+91') ...[
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

  void _hideLoadingOverlay(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

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

      _hideLoadingOverlay(context);

      widget.onDataUpdated?.call();

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
      final newStatus = newTagEnabled ? 'active' : 'pause';

      await TagsService.updateTagSettings(
        tagId: widget.tag.tagInternalId,
        phone: phoneWithCountryCode,
        callsEnabled: _isCallsEnabled,
        whatsappEnabled: _isWhatsappEnabled,
        callMaskingEnabled: _isCallMaskingEnabled,
        videoCallEnabled: _isVideoCallEnabled,
        smValue: '67s87s6yys66',
        dgValue: 'testYU78dII8iiUIPSISJ',
        status: newStatus,  
      );

      setState(() {
        _isTagEnabled = newTagEnabled;
        _isLoading = false;
      });

      _hideLoadingOverlay(context);

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

  void _showAddSecondaryNumberSheet(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final phoneNumber = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSecondaryNumberSheet(
        tagId: widget.tag.tagInternalId.toString(),
        existingSecondaryNumber: widget.tagSettings?.data.secondaryNumber,  
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

  void _showEmergencyContactSheet(BuildContext context) async {
    HapticFeedback.mediumImpact();
    try {
      final tagIdInt = int.tryParse(widget.tag.tagInternalId) ?? 0;
      
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
        widget.onDataUpdated?.call();
      }
    } catch (e) {
      print('❌ Error fetching emergency info: $e');
      if (mounted) {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => AddEmergencyContactSheet(
            tagId: widget.tag.tagInternalId.toString(),  
          ),
        );
        widget.onDataUpdated?.call();
      }
    }
  }

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

      if (mounted) {
        Navigator.pop(context);
      }

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
            onClose: () {},
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }
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

  // ✅ Updated UI for Action Buttons
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
    final effectiveIconColor = iconColor ?? (isRed ? Colors.red : AppColors.black);
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        // Spacing between cards
        margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium), 
        // Internal padding - reduced to make the card more compact
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
              offset: const Offset(0, 3), // Subtle and clean shadow
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular icon background
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: effectiveIconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppConstants.iconSizeLarge, // 20.0
                color: effectiveIconColor,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSectionTitle, // 14.0
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
                    fontSize: AppConstants.fontSizeSmallText, // 8.0
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
                size: AppConstants.iconSizeLarge, // 20.0 (good size for toggle switches)
                color: isRed ? Colors.red.shade400 : Colors.grey.shade400,
              ),
              
            // Automatically add a subtle forward arrow if there's no custom trailing icon
            if (trailing == null && badge == null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: AppConstants.iconSizeMedium, // 16.0
                color: Colors.grey.shade300,
              )
          ],
        ),
      ),
    );
  }

  Widget _buildRechargeSection() {
    return Container(
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
              color: Colors.purple.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.credit_card_rounded,
              color: Colors.purple.shade600,
              size: AppConstants.iconSizeGrid, // 24.0
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FasTag Recharge',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSectionTitle, // 14.0
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2), // Very small gap
                Text(
                  'Win assured Cashback',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardTitle, // 12.0
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: AppConstants.iconSizeMedium, // 16.0
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}