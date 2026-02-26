import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/owner_message_service.dart';
import '../../services/auth_service.dart';
import '../../providers/location_provider.dart';


class MessagePreviewSheet extends StatefulWidget {
  final String vehicleNumber;
  final String reasonText;
  final String? phoneNumber;
  final int? tagId;

  const MessagePreviewSheet({
    super.key,
    required this.vehicleNumber,
    required this.reasonText,
    this.phoneNumber,
    this.tagId,
  });

  @override
  State<MessagePreviewSheet> createState() => _MessagePreviewSheetState();

  static void show(
    BuildContext context, {
    required String vehicleNumber,
    required String reasonText,
    String? phoneNumber,
    int? tagId,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MessagePreviewSheet(
        vehicleNumber: vehicleNumber,
        reasonText: reasonText,
        phoneNumber: phoneNumber,
        tagId: tagId,
      ),
    );
  }
}

class _MessagePreviewSheetState extends State<MessagePreviewSheet> {
  final TextEditingController _last4DigitsController = TextEditingController();
  final TextEditingController _yourPhoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserPhone();
  }

  /// Load and autofill user phone from local storage
  Future<void> _loadUserPhone() async {
    try {
      final userData = await AuthService.getUserData();
      final phoneNumber = userData['phone'] ?? userData['phoneNumber'] ?? userData['mobile'];
      
      if (phoneNumber != null && mounted) {
        setState(() {
          _yourPhoneController.text = phoneNumber.toString();
        });
        print('💬 [MessagePreviewSheet] Phone autofilled: $phoneNumber');
      }
    } catch (e) {
      print('❌ [MessagePreviewSheet] Error loading user phone: $e');
    }
  }

  @override
  void dispose() {
    _last4DigitsController.dispose();
    _yourPhoneController.dispose();
    super.dispose();
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

  /// Get title
  String _getTitleText() {
    return 'Verify Vehicle Plate';
  }

  /// Get phone field label based on tag type
  String _getTitleForPhoneField() {
    return 'Your Phone Number:';
  }

  Future<void> _sendMessage() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate last 4 digits
    if (_last4DigitsController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = '❌ Please enter the last 4 digits of the plate';
      });
      return;
    }

    if (_last4DigitsController.text.trim().length != 4) {
      setState(() {
        _errorMessage = '❌ Please enter exactly 4 digits';
      });
      return;
    }

    // Verify last 4 digits match
    if (widget.vehicleNumber.length >= 4) {
      final actualLast4 = widget.vehicleNumber.substring(widget.vehicleNumber.length - 4);
      if (_last4DigitsController.text.trim() != actualLast4) {
        setState(() {
          _errorMessage = '❌ Last 4 digits do not match. Actual: $actualLast4';
        });
        return;
      }
    }

    if (widget.phoneNumber == null) {
      setState(() {
        _errorMessage = '❌ Phone number not available';
      });
      return;
    }

    // Get location from provider
    final locationProvider = context.read<LocationProvider>();
    if (locationProvider.currentLocation == null) {
      setState(() {
        _errorMessage = '❌ Location not available. Please enable location services.';
      });
      return;
    }

    // Build message for vehicle
    String messageText = 'Hi! Regarding your vehicle ${widget.vehicleNumber}: ${widget.reasonText}';
    
    if (_yourPhoneController.text.trim().isNotEmpty) {
      messageText += ' You can call me back at ${_yourPhoneController.text.trim()}.';
    }

    // Start loading
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final last4Digits = _last4DigitsController.text.trim();

      final response = await OwnerMessageService.sendOwnerMessage(
        tagId: widget.tagId,
        last4Digits: last4Digits,
        messageText: messageText,
        userPhoneNumber: _yourPhoneController.text.trim().isEmpty 
            ? widget.phoneNumber!
            : _yourPhoneController.text.trim(),
        latitude: locationProvider.currentLocation!.latitude,
        longitude: locationProvider.currentLocation!.longitude,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (response.success) {
          Navigator.pop(context);
          _showSuccess('✅ Message sent successfully!\n${response.message ?? ''}');
        } else {
          setState(() {
            _errorMessage = '❌ ${response.message ?? 'Failed to send message'}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '❌ ${e.toString().replaceAll('Exception: ', '')}';
        });
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppConstants.paddingPage),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTitleText(),
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
                            text: 'last 4 digits (shown as ****)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: ' of the vehicle plate number to verify.'),
                        ],
                      ),
                    ),
                    SizedBox(height: AppConstants.spacingLarge),
                    
                    // Masked Plate Number Display
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppConstants.paddingLarge),
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
                                  size: AppConstants.iconSizeMedium,
                                ),
                                SizedBox(width: AppConstants.spacingSmall),
                                Text(
                                  'Vehicle Plate Number',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizeCardTitle,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppConstants.spacingSmall),
                            Text(
                              _getMaskedPlateNumber(widget.vehicleNumber),
                              style: TextStyle(
                                fontSize: AppConstants.fontSizePageTitle + 4,
                                fontWeight: FontWeight.w900,
                                color: AppColors.black,
                                letterSpacing: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppConstants.spacingLarge),
                    
                    // --- HIGHLIGHTED INPUT FIELD - Verification for Vehicle Tags ---
                    Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.activeYellow.withOpacity(0.2),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _last4DigitsController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          textAlign: TextAlign.center,
                          autofocus: true, // Auto focus
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: 'Enter Last 4 Digits',
                            hintStyle: TextStyle(
                              color: AppColors.black.withOpacity(0.4),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                            counterText: '',
                            // Standard Border
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: AppColors.activeYellow,
                                width: 1.5,
                              ),
                            ),
                            // Focused/Active Border
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: AppColors.activeYellow,
                                width: 3.0,
                              ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingMedium,
                            vertical: 20, // Taller
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 24, // Larger Text
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                          letterSpacing: 8,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: AppConstants.spacingLarge),
                    Text(
                      _getTitleForPhoneField(),
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeCardTitle,
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppConstants.spacingSmall),
                    
                    // --- PHONE INPUT - ReadOnly for vehicles, Editable for non-vehicles ---
                    TextField(
                      controller: _yourPhoneController,
                      readOnly: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone_locked,
                          color: AppColors.textGrey,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingMedium,
                          vertical: AppConstants.paddingMedium,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeCardTitle,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    
                    SizedBox(height: AppConstants.spacingLarge * 1.5),
                    
                    // Error Message Display
                    if (_errorMessage != null) ...[
                      Container(
                        padding: EdgeInsets.all(AppConstants.paddingMedium),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.5),
                            width: 1.5,
                          ),
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
                                _errorMessage!,
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizeCardTitle,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppConstants.spacingMedium),
                    ],
                    
                    // Send Message Button
                    SizedBox(
                      width: double.infinity,
                      height: 55, // Taller button
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _sendMessage,
                        icon: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.black,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.send_rounded,
                                color: AppColors.black,
                                size: 24,
                              ),
                        label: Text(
                          _isLoading ? 'Sending...' : 'Send Message',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.activeYellow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 2,
                          shadowColor: AppColors.activeYellow.withOpacity(0.5),
                        ),
                      ),
                    ),
                    SizedBox(height: AppConstants.spacingMedium),
                    
                    // Cancel Button
                    Center(
                      child: TextButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
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