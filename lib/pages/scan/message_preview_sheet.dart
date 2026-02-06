import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class MessagePreviewSheet extends StatefulWidget {
  final String vehicleNumber;
  final String maskedNumber;
  final String reasonText;
  final String? phoneNumber;

  const MessagePreviewSheet({
    super.key,
    required this.vehicleNumber,
    required this.maskedNumber,
    required this.reasonText,
    this.phoneNumber,
  });

  @override
  State<MessagePreviewSheet> createState() => _MessagePreviewSheetState();

  static void show(
    BuildContext context, {
    required String vehicleNumber,
    required String maskedNumber,
    required String reasonText,
    String? phoneNumber,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MessagePreviewSheet(
        vehicleNumber: vehicleNumber,
        maskedNumber: maskedNumber,
        reasonText: reasonText,
        phoneNumber: phoneNumber,
      ),
    );
  }
}

class _MessagePreviewSheetState extends State<MessagePreviewSheet> {
  final TextEditingController _last4DigitsController = TextEditingController();
  final TextEditingController _yourPhoneController = TextEditingController();

  @override
  void dispose() {
    _last4DigitsController.dispose();
    _yourPhoneController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_last4DigitsController.text.trim().length != 4) {
      _showError('Please enter exactly 4 digits');
      return;
    }

    if (widget.phoneNumber != null) {
      String message =
          'Hi! Regarding your vehicle ${widget.vehicleNumber}:\n\n${widget.reasonText}';

      if (_yourPhoneController.text.trim().isNotEmpty) {
        message +=
            '\n\nYou can call me back at: ${_yourPhoneController.text.trim()}';
      }

      final Uri smsUri = Uri(
        scheme: 'sms',
        path: widget.phoneNumber,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        _showError('Unable to send message');
      }
    } else {
      Navigator.pop(context);
      _showError('Phone number not available');
    }
  }

  void _showError(String message) {
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
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
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
            // FIXED: Wrapped in Flexible to prevent overflow
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppConstants.paddingPage),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please Verify the plate number of the vehicle.',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizePageTitle,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: AppConstants.spacingMedium),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeCardTitle,
                          color: AppColors.black,
                        ),
                        children: [
                          TextSpan(text: 'Please enter the '),
                          TextSpan(
                            text: 'last 4 digits of vehicle plate number',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppConstants.spacingLarge),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryYellow,
                            AppColors.activeYellow,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusCard),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.activeYellow.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_car,
                                color: AppColors.black,
                                size: AppConstants.iconSizeSmall,
                              ),
                              SizedBox(width: AppConstants.spacingSmall),
                              Text(
                                widget.vehicleNumber,
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizeCardTitle,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.black,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.maskedNumber,
                            style: TextStyle(
                              fontSize: AppConstants.fontSizePageTitle,
                              fontWeight: FontWeight.w900,
                              color: AppColors.black,
                              letterSpacing: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppConstants.spacingLarge),
                    TextField(
                      controller: _last4DigitsController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: 'Last 4 Digits',
                        hintStyle: TextStyle(
                          color: AppColors.black.withOpacity(0.5),
                          fontWeight: FontWeight.w600,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusCard),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusCard),
                          borderSide: BorderSide(
                            color: AppColors.lightGrey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusCard),
                          borderSide: BorderSide(
                            color: AppColors.activeYellow,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingMedium,
                          vertical: AppConstants.paddingMedium,
                        ),
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeCardTitle,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        letterSpacing: 6,
                      ),
                    ),
                    SizedBox(height: AppConstants.spacingLarge),
                    Text(
                      'Do you want the vehicle owner to call you? you can enter your number here.',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeCardTitle,
                        color: AppColors.black,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: AppConstants.spacingMedium),
                    TextField(
                      controller: _yourPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '(Optional) Your Phone',
                        hintStyle: TextStyle(
                          color: AppColors.black.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: AppColors.black.withOpacity(0.6),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusCard),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusCard),
                          borderSide: BorderSide(
                            color: AppColors.lightGrey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusCard),
                          borderSide: BorderSide(
                            color: AppColors.activeYellow,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingMedium,
                          vertical: AppConstants.paddingMedium,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeCardTitle,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: AppConstants.spacingLarge * 1.5),
                    SizedBox(
                      width: double.infinity,
                      height: AppConstants.buttonHeightMedium,
                      child: ElevatedButton.icon(
                        onPressed: _sendMessage,
                        icon: Icon(
                          Icons.send_rounded,
                          color: AppColors.black,
                          size: AppConstants.iconSizeMedium,
                        ),
                        label: Text(
                          'Message Now',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeButtonText,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.activeYellow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.buttonBorderRadius),
                          ),
                          elevation: 0,
                          shadowColor: AppColors.activeYellow.withOpacity(0.5),
                        ),
                      ),
                    ),
                    SizedBox(height: AppConstants.spacingMedium),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
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
}
