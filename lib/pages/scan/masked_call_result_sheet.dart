import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class MaskedCallResultSheet extends StatefulWidget {
  final String vehicleNumber;
  final String maskedNumber;

  const MaskedCallResultSheet({
    super.key,
    required this.vehicleNumber,
    required this.maskedNumber,
  });

  @override
  State<MaskedCallResultSheet> createState() => _MaskedCallResultSheetState();

  static void show(
    BuildContext context, {
    required String vehicleNumber,
    required String maskedNumber,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) => MaskedCallResultSheet(
        vehicleNumber: vehicleNumber,
        maskedNumber: maskedNumber,
      ),
    );
  }
}

class _MaskedCallResultSheetState extends State<MaskedCallResultSheet> {
  bool _isDialing = false;

  /// Make the actual phone call
  Future<void> _makeCall() async {
    try {
      setState(() {
        _isDialing = true;
      });

      final Uri phoneUri = Uri(scheme: 'tel', path: widget.maskedNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorSnackBar('Could not open dialer');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening dialer: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isDialing = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: AppConstants.paddingMedium),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppConstants.paddingPage),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Call vehicle owner if you have urgency.',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizePageTitle,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: AppConstants.spacingMedium),

                    // Warning Section
                    Container(
                      padding: EdgeInsets.all(AppConstants.paddingLarge),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusCard),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange.shade700,
                                size: AppConstants.iconSizeMedium,
                              ),
                              SizedBox(width: AppConstants.spacingMedium),
                              Text(
                                'Points which can get you blocked:',
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizeCardTitle,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppConstants.spacingMedium),
                          _buildBlockedPoint('🔴 Making a test Call'),
                          SizedBox(height: AppConstants.spacingSmall),
                          _buildBlockedPoint('🟢 Spam and Prank'),
                          SizedBox(height: AppConstants.spacingSmall),
                          _buildBlockedPoint('🟡 Inquire about buying, selling or renting a vehicle'),
                        ],
                      ),
                    ),

                    SizedBox(height: AppConstants.spacingLarge),

                    // Call Button
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.activeYellow.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _isDialing ? null : _makeCall,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: AppConstants.paddingLarge,
                              horizontal: AppConstants.paddingMedium,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.activeYellow,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.activeYellow,
                                width: 0,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isDialing)
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.black,
                                      ),
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.phone_in_talk,
                                    color: AppColors.black,
                                    size: 24,
                                  ),
                                SizedBox(width: AppConstants.spacingMedium),
                                Text(
                                  'Call: ${widget.maskedNumber}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.black,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: AppConstants.spacingLarge),

                    // Info Text
                    Container(
                      padding: EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusCard),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeCardTitle - 1,
                            color: AppColors.textGrey,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: 'You will have ',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: '59 seconds ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            TextSpan(
                              text: 'to let them know the issue. Increase in any abuse will block your account.',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: AppConstants.spacingLarge),

                    // Cancel Button
                    Center(
                      child: TextButton(
                        onPressed: _isDialing ? null : () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeCardTitle,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: AppConstants.spacingSmall),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedPoint(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: AppConstants.fontSizeCardTitle - 1,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade700,
        height: 1.4,
      ),
    );
  }
}
