import 'package:flutter/material.dart';
import 'package:my_new_app/pages/scan/message_preview_sheet.dart';
import 'package:my_new_app/pages/scan/masked_call_sheet.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class ContactVehicleOwnerPage extends StatefulWidget {
  final String vehicleNumber;
  final String vehicleName;
  final String? phoneNumber;
  final String? maskedNumber;

  const ContactVehicleOwnerPage({
    super.key,
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

  final List<ContactReason> _reasons = [
    ContactReason(
      icon: Icons.lightbulb_outline,
      text: 'The lights of this car is on.',
      value: 'lights_on',
    ),
    ContactReason(
      icon: Icons.no_crash_outlined,
      text: 'The car is in no parking.',
      value: 'no_parking',
    ),
    ContactReason(
      icon: Icons.local_shipping_outlined,
      text: 'The car is getting towed.',
      value: 'getting_towed',
    ),
    ContactReason(
      icon: Icons.window_outlined,
      text: 'The window or car is open.',
      value: 'window_open',
    ),
    ContactReason(
      icon: Icons.warning_amber_outlined,
      text: 'Something wrong with this car.',
      value: 'something_wrong',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Check login status
  }

  void _makeCall() {
    MaskedCallSheet.show(
      context,
      vehicleNumber: widget.vehicleNumber,
      maskedNumber: widget.maskedNumber ?? '####',
      phoneNumber: widget.phoneNumber,
    );
  }

  void _onMessageButtonClicked() {
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

    final reasonText = _reasons
        .firstWhere((r) => r.value == _selectedReason)
        .text;

    MessagePreviewSheet.show(
      context,
      vehicleNumber: widget.vehicleNumber,
      maskedNumber: widget.maskedNumber ?? '####',
      reasonText: reasonText,
      phoneNumber: widget.phoneNumber,
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        contentPadding: EdgeInsets.all(AppConstants.paddingPage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emergency,
                size: 40,
                color: Colors.red,
              ),
            ),
            SizedBox(height: AppConstants.spacingLarge),
            Text(
              'Emergency Contact',
              style: TextStyle(
                fontSize: AppConstants.fontSizePageTitle,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: AppConstants.spacingSmall),
            Text(
              'Contact family members or emergency numbers?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showErrorSnackBar('Emergency contacts will be displayed here');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
                vertical: AppConstants.paddingMedium,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.buttonBorderRadius),
              ),
            ),
            child: Text(
              'Show Contacts',
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
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
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(AppConstants.paddingPage),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            'Contact vehicle owner.',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizePageTitle,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: AppConstants.spacingSmall),
                          // Vehicle Name (if provided)
                          if (widget.vehicleName.isNotEmpty) ...[
                            Text(
                              widget.vehicleName,
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeSectionTitle,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: AppConstants.spacingSmall),
                          ],
                          // Vehicle Number with Badge
                          Row(
                            children: [
                              Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: AppConstants.iconSizeMedium,
                              ),
                              SizedBox(width: AppConstants.spacingSmall),
                              Text(
                                widget.vehicleNumber,
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizeSectionTitle,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.black,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              SizedBox(width: AppConstants.spacingSmall),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppConstants.paddingSmall,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.activeYellow,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.maskedNumber ?? '####',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizeSubtitle,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppConstants.spacingLarge),
                          // Show either buttons OR reason list
                          if (!_showReasonList) ...[
                            // Question
                            Text(
                              'Would you like to call or text the owner ?',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeCardTitle,
                                color: AppColors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: AppConstants.spacingLarge),
                            // Action Buttons
                            Row(
                              children: [
                                // Masked Call
                                Expanded(
                                  child: _buildActionCard(
                                    icon: Icons.phone,
                                    label: 'Masked Call',
                                    color: Colors.orange,
                                    onTap: _makeCall,
                                  ),
                                ),
                                SizedBox(width: AppConstants.spacingLarge),
                                // Message
                                Expanded(
                                  child: _buildActionCard(
                                    icon: Icons.chat,
                                    label: 'Message',
                                    color: Colors.blue,
                                    onTap: _onMessageButtonClicked,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            // Question for reason selection
                            Text(
                              'Why would you like to contact the vehicle owner?',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeCardTitle,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: AppConstants.spacingMedium),
                            // Reason Options
                            ..._reasons.map((reason) => _buildReasonOption(reason)),
                            SizedBox(height: AppConstants.spacingLarge),
                            // Action Buttons Row
                            Row(
                              children: [
                                // Message Button
                                Expanded(
                                  child: _buildSimpleButton(
                                    icon: Icons.chat,
                                    label: 'Message',
                                    color: Colors.blue,
                                    onTap: _sendMessage,
                                  ),
                                ),
                                SizedBox(width: AppConstants.spacingSmall),
                                // Call Button
                                Expanded(
                                  child: _buildSimpleButton(
                                    icon: Icons.phone,
                                    label: 'Call',
                                    color: Colors.orange,
                                    onTap: _makeCall,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(height: AppConstants.spacingLarge),
                          // Emergency Section
                          Text(
                            'Do you think the vehicle has an accident and needs to be contacted family members or emergency numbers?',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeCardTitle,
                              color: AppColors.black,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: AppConstants.spacingMedium),
                          // FIXED: Emergency Button - Small and Left Aligned
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              height: 36, // Smaller height
                              child: ElevatedButton.icon(
                                onPressed: _showEmergencyDialog,
                                icon: Icon(
                                  Icons.emergency,
                                  color: AppColors.white,
                                  size: 14, // Smaller icon
                                ),
                                label: Text(
                                  'Emergency',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizeSmallText + 2, // 10
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppConstants.paddingMedium,
                                    vertical: AppConstants.paddingSmall,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.buttonBorderRadius),
                                  ),
                                  elevation: 0,
                                ),
                              ),
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
            color: color.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
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
          vertical: AppConstants.paddingMedium,
          horizontal: AppConstants.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          border: Border.all(
            color: color,
            width: 2,
          ),
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

  Widget _buildReasonOption(ContactReason reason) {
    final isSelected = _selectedReason == reason.value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReason = reason.value;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppConstants.spacingSmall),
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.activeYellow.withOpacity(0.15)
              : AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          border: Border.all(
            color: isSelected ? AppColors.activeYellow : AppColors.lightGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              reason.icon,
              size: AppConstants.iconSizeMedium,
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
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
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
                      size: 14,
                      color: AppColors.black,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class ContactReason {
  final IconData icon;
  final String text;
  final String value;

  ContactReason({
    required this.icon,
    required this.text,
    required this.value,
  });
}
