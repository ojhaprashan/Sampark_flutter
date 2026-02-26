import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/owner_call_service.dart';
import '../../services/auth_service.dart';
import '../../providers/location_provider.dart';
import 'masked_call_result_sheet.dart';

class MTMaskedCallSheet extends StatefulWidget {
  final String tagName;
  final String? phoneNumber;
  final int? tagId;

  const MTMaskedCallSheet({
    super.key,
    required this.tagName,
    this.phoneNumber,
    this.tagId,
  });

  @override
  State<MTMaskedCallSheet> createState() => _MTMaskedCallSheetState();

  static void show(
    BuildContext context, {
    required String tagName,
    String? phoneNumber,
    int? tagId,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MTMaskedCallSheet(
        tagName: tagName,
        phoneNumber: phoneNumber,
        tagId: tagId,
      ),
    );
  }
}

class _MTMaskedCallSheetState extends State<MTMaskedCallSheet> {
  final TextEditingController _yourPhoneController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController(text: '91'); // Default to India
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
        print('📞 [MTMaskedCallSheet] Phone autofilled: $phoneNumber');
      }
    } catch (e) {
      print('❌ [MTMaskedCallSheet] Error loading user phone: $e');
    }
  }

  @override
  void dispose() {
    _yourPhoneController.dispose();
    _countryCodeController.dispose();
    super.dispose();
  }

  Future<void> _setupMaskedCall() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate country code
    if (_countryCodeController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = '❌ Please enter country code';
      });
      return;
    }

    // Validate phone number
    if (_yourPhoneController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = '❌ Please enter your phone number';
      });
      return;
    }

    if (_yourPhoneController.text.trim().length < 5) {
      setState(() {
        _errorMessage = '❌ Phone number must be at least 5 digits';
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

    // Start loading
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Extract local phone (remove + if present)
      String phoneLocal = _yourPhoneController.text.trim();
      if (phoneLocal.startsWith('+')) {
        phoneLocal = phoneLocal.substring(1); // Remove + prefix
      }
      // Remove country code prefix if already in the number
      String countryCode = _countryCodeController.text.trim();
      if (phoneLocal.startsWith(countryCode)) {
        phoneLocal = phoneLocal.substring(countryCode.length);
      }

      // Call the international API
      final response = await OwnerCallService.makeInterNationalCall(
        tagId: widget.tagId ?? 0,
        phoneLocal: phoneLocal,
        countryCode: countryCode,
        latitude: locationProvider.currentLocation!.latitude,
        longitude: locationProvider.currentLocation!.longitude,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.success) {
          // Show result sheet with masked number
          if (response.maskedNumber != null && response.maskedNumber!.isNotEmpty) {
            Navigator.pop(context);
            
            MaskedCallResultSheet.show(
              context,
              vehicleNumber: widget.tagName,
              maskedNumber: response.maskedNumber!,
            );
          } else {
            setState(() {
              _errorMessage = '❌ Could not obtain masked number. Please try again.';
            });
          }
        } else {
          setState(() {
            _errorMessage = '❌ ${response.message ?? 'Failed to setup call'}';
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
                      'Connect via Masked Call',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizePageTitle,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: AppConstants.spacingMedium),
                    
                    Text(
                      'Please provide your phone number to connect with the tag owner.',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeCardDescription,
                        color: AppColors.textGrey,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: AppConstants.spacingLarge),
                    
                    // Country Code Field
                    Text(
                      'Country Code:',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeCardTitle,
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppConstants.spacingSmall),
                    
                    TextField(
                      controller: _countryCodeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.public,
                          color: AppColors.textGrey,
                        ),
                        hintText: 'e.g., 91 (India), 1 (USA), 44 (UK)',
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusCard,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.lightGrey,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusCard,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.lightGrey,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusCard,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.activeYellow,
                            width: 2.5,
                          ),
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
                    
                    SizedBox(height: AppConstants.spacingLarge),
                    
                    Text(
                      'Your Phone Number:',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeCardTitle,
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppConstants.spacingSmall),
                    
                    // Phone Input Field
                    TextField(
                      controller: _yourPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone,
                          color: AppColors.textGrey,
                        ),
                        hintText: 'Enter your phone number',
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusCard,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.lightGrey,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusCard,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.lightGrey,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusCard,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.activeYellow,
                            width: 2.5,
                          ),
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
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusCard,
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
                                  fontSize: AppConstants.fontSizeCardDescription,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppConstants.spacingMedium),
                    ],
                    
                    // Setup Call Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _setupMaskedCall,
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
                            : Icon(Icons.phone),
                        label: Text(
                          _isLoading ? 'Connecting...' : 'Setup Masked Call',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeButtonText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.activeYellow,
                          foregroundColor: AppColors.black,
                          elevation: 0,
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
