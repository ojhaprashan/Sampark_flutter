import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_new_app/pages/widgets/edit_tag_sheet.dart';
import 'package:my_new_app/pages/widgets/file_upload_sheet.dart';
import 'package:my_new_app/pages/widgets/offline_qr_download_sheet.dart';
import 'package:my_new_app/utils/colors.dart';
import 'package:my_new_app/utils/constants.dart';
import 'package:my_new_app/services/tags_service.dart';
import 'package:my_new_app/services/auth_service.dart';
import 'package:my_new_app/services/offline_qr_service.dart';
import 'package:my_new_app/services/premium_service.dart';
import 'package:my_new_app/pages/widgets/tag_replacement_dialog.dart';
import 'package:my_new_app/pages/AppWebView/appweb.dart';

class MoreTab extends StatefulWidget {
  final Tag tag;
  final TagSettings? tagSettings;
  final VoidCallback? onDataUpdated;  // ✅ Callback to refresh data when updated

  const MoreTab({
    super.key,
    required this.tag,
    this.tagSettings,
    this.onDataUpdated,
  });

  @override
  State<MoreTab> createState() => _MoreTabState();
}

class _MoreTabState extends State<MoreTab> {
  // ✅ State variables for toggling
  bool _isWhatsappEnabled = false;
  bool _isCallMaskingEnabled = false;
  bool _isVideoCallEnabled = false;
  bool _isLoading = false;
  String _countryCode = '+91'; // Track country code for India-specific features
  String _userPhone = ''; // ✅ Track user phone
  bool _hasPremium = false; // ✅ Premium status
  bool _isLoadingPremium = false; // ✅ Loading premium data

  @override
  void initState() {
    super.initState();
    // Initialize from tagSettings if available
    _isWhatsappEnabled = widget.tagSettings?.data.callStatus.whatsappEnabled ?? false;
    _isCallMaskingEnabled = widget.tagSettings?.data.callStatus.callMaskingEnabled ?? false;
    _isVideoCallEnabled = widget.tagSettings?.data.callStatus.videoCallEnabled ?? false;
    _loadCountryCode();
  }

  // ✅ Load country code and phone from AuthService
  Future<void> _loadCountryCode() async {
    try {
      final userData = await AuthService.getUserData();
      final countryCode = userData['countryCode'] ?? '+91';
      final phone = userData['phone'] ?? '';
      if (mounted) {
        setState(() {
          _countryCode = countryCode;
          _userPhone = phone; // ✅ Set user phone
        });
      }
      // ✅ Load premium data
      _loadPremiumData();
    } catch (e) {
      print('Error loading country code: $e');
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
            // ✅ Shows opposite text (Enable when disabled, Disable when enabled)
            _buildActionButton(
              context,
              icon: _isWhatsappEnabled ? Icons.chat_bubble : Icons.chat_bubble_outline,
              iconColor: _isWhatsappEnabled ? Colors.green.shade600 : Colors.blue.shade600,
              label: _isWhatsappEnabled ? 'Disable WhatsApp Notifications' : 'Enable WhatsApp Notifications',
              trailing: _isWhatsappEnabled ? Icons.toggle_on : Icons.toggle_off_outlined,
              onTap: () {
                _toggleWhatsapp(context);
              },
            ),
            _buildActionButton(
              context,
              icon: _isCallMaskingEnabled ? Icons.phone : Icons.phone_disabled,
              iconColor: _isCallMaskingEnabled ? Colors.green.shade600 : Colors.red.shade600,
              label: _isCallMaskingEnabled ? 'Disable Call Masking' : 'Enable Call Masking',
              trailing: _isCallMaskingEnabled ? Icons.toggle_on : Icons.toggle_off_outlined,
              onTap: () {
                _toggleCallMasking(context);
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.upload_file,
              iconColor: Colors.purple.shade600,
              label: 'Upload files',
              trailing: Icons.file_upload,
              onTap: () {
                // ✅ OPEN THE NEW SHEET HERE
                final tagId = int.tryParse(widget.tag.tagInternalId) ?? 0;
                FileUploadSheet.show(context, tagId: tagId);
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.videocam,
              iconColor: Colors.teal.shade600,
              label: 'Enable Video Call',
              trailing: Icons.toggle_off_outlined,
              onTap: () {
                _showComingSoonDialog(context);
              },
            ),
            // ✅ Show Offline QR Download only for India
            if (_countryCode == '+91')
              _buildActionButtonWithDescription(
                context,
                icon: Icons.wifi_off,
                iconColor: Colors.orange.shade600,
                label: 'Offline QR Download',
                description: 'Download the QR code for offline Usage of your business card.',
                badge: 'New!',
                trailing: Icons.wifi_off,
                onTap: () {
                  _generateOfflineQR(context);
                },
              ),
            // ✅ Show FasTag Recharge only for India
            if (_countryCode == '+91')
              _buildActionButton(
                context,
                icon: Icons.credit_card_rounded,
                iconColor: Colors.indigo.shade600,
                label: 'FasTag Recharge',
                trailing: Icons.arrow_forward_ios_rounded,
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
              ),
            _buildActionButton(
              context,
              icon: Icons.autorenew,
              iconColor: Colors.brown.shade600,
              label: 'Get a Tag Replacement',
              trailing: Icons.autorenew,
              onTap: () {
                TagReplacementDialog.show(context);
              },
            ),
            _buildActionButtonWithDescription(
              context,
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
            // ✅ Show premium UI based on state
            if (_isLoadingPremium)
              // Loading state
              Container(
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Loading membership status...',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSectionTitle,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple.shade600,
                      ),
                    ),
                  ],
                ),
              )
            else if (_hasPremium)
              // ✅ Show Membership Badge if user has premium
              Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppConstants.paddingSmall),
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
                        const SizedBox(width: AppConstants.spacingMedium),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Premium Member',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeSectionTitle,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Enjoy exclusive features',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeCardTitle,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: AppConstants.iconSizeLarge,
                    ),
                  ],
                ),
              ),
              
            const SizedBox(height: 100), // Ensures scroll area reaches the bottom properly
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

  // ✅ Toggle WhatsApp with API and Loading Dialog
  void _toggleWhatsapp(BuildContext context) async {
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

      final newWhatsappEnabled = !_isWhatsappEnabled;

      await TagsService.updateTagSettings(
        tagId: widget.tag.tagInternalId,
        phone: phoneWithCountryCode,
        callsEnabled: widget.tagSettings?.data.callStatus.callsEnabled ?? true,
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

      _hideLoadingOverlay(context);

      // ✅ Call refresh callback to reload data from API
      widget.onDataUpdated?.call();

      _showSuccessDialog(
        context,
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
      _hideLoadingOverlay(context);
      _showErrorDialog(context, 'Error', 'Failed to update settings: $e');
    }
  }

  // ✅ Toggle Call Masking with API and Loading Dialog
  void _toggleCallMasking(BuildContext context) async {
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

      final newCallMaskingEnabled = !_isCallMaskingEnabled;

      await TagsService.updateTagSettings(
        tagId: widget.tag.tagInternalId,
        phone: phoneWithCountryCode,
        callsEnabled: widget.tagSettings?.data.callStatus.callsEnabled ?? true,
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

      _hideLoadingOverlay(context);
      // ✅ Call refresh callback to reload data from API
      widget.onDataUpdated?.call();
      _showSuccessDialog(
        context,
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
      _hideLoadingOverlay(context);
      _showErrorDialog(context, 'Error', 'Failed to update settings: $e');
    }
  }

  // ✅ Toggle Video Call with API and Loading Dialog
  void _toggleVideoCall(BuildContext context) async {
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

      final newVideoCallEnabled = !_isVideoCallEnabled;

      await TagsService.updateTagSettings(
        tagId: widget.tag.tagInternalId,
        phone: phoneWithCountryCode,
        callsEnabled: widget.tagSettings?.data.callStatus.callsEnabled ?? true,
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

      _hideLoadingOverlay(context);

      // ✅ Call refresh callback to reload data from API
      widget.onDataUpdated?.call();

      _showSuccessDialog(
        context,
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
      _hideLoadingOverlay(context);
      _showErrorDialog(context, 'Error', 'Failed to update settings: $e');
    }
  }

  // ========================
  // ✅ OFFLINE QR FUNCTIONS
  // ========================

  // ✅ Generate Offline QR
  void _generateOfflineQR(BuildContext context) async {
    HapticFeedback.mediumImpact();
    
    _showLoadingOverlay(context);

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
        _showErrorDialog(context, 'Error', 'Failed to generate QR: $e');
      }
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

  Widget _buildActionButtonWithDescription(
    BuildContext context, {
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

  // ✅ Show Coming Soon Dialog for Video Call
  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          ),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.videocam,
                    size: 32,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                Text(
                  'Coming Soon!',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardTitle,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                Text(
                  'Video call feature will be available soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardDescription,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
                    ),
                    child: Center(
                      child: Text(
                        'Got it',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeCardDescription,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
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
}