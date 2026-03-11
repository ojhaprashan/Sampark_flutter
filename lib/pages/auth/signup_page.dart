import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import 'login_page.dart';
import '../../services/auth_service.dart';
import '../../services/auth_api_service.dart';
import '../../services/tags_service.dart';
import '../../providers/wallet_provider.dart';
import '../main_navigation.dart';
import 'vehicle_details_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String _selectedCountryCode = '+91';
  
  bool _otpSent = false;
  bool _requiresPin = false; // Added to track if PIN is required
  bool _isLoading = false;

  final List<Map<String, String>> _countries = [
    {'code': '+91', 'name': 'India', 'flag': '🇮🇳'},
    {'code': '+1', 'name': 'USA', 'flag': '🇺🇸'},
    {'code': '+44', 'name': 'UK', 'flag': '🇬🇧'},
    {'code': '+971', 'name': 'UAE', 'flag': '🇦🇪'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOTP() {
    if (_phoneController.text.isEmpty) {
      _showSnackBar('Please enter phone number', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Format phone number with country code
    final countryCodeDigits = _selectedCountryCode.replaceFirst('+', '');
    final fullPhone = countryCodeDigits + _phoneController.text.trim();

    // ✅ Call the actual OTP API
    _requestOTPFromAPI(fullPhone);
  }

  /// Request OTP from API
  Future<void> _requestOTPFromAPI(String fullPhone) async {
    try {
      print('📞 [SignupPage] Requesting OTP for phone: $fullPhone');
      
      final response = await AuthAPIService.requestOTP(
        phone: fullPhone,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _otpSent = true;
          // ✅ Check if PIN is required instead of OTP
          _requiresPin = response.requirePin;
        });

        // Show appropriate message
        if (response.requirePin) {
          _showSnackBar(
            'Please enter your login PIN',
            Colors.blue,
          );
        } else if (response.sent) {
          _showSnackBar(
            'OTP sent to $_selectedCountryCode ${_phoneController.text}',
            Colors.green,
          );
        } else {
          _showSnackBar(
            response.message.isNotEmpty ? response.message : 'Failed to process request',
            Colors.orange,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Error: ${e.toString()}', Colors.red);
      }
    }
  }

  void _verifyOTP() {
    final inputLabel = _requiresPin ? 'PIN' : 'OTP';

    if (_otpController.text.isEmpty) {
      _showSnackBar('Please enter $inputLabel', Colors.red);
      return;
    }

    if (_otpController.text.length != 4) {
      _showSnackBar('$inputLabel should be 4 digits', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Format phone number with country code
    final countryCodeDigits = _selectedCountryCode.replaceFirst('+', '');
    final fullPhone = countryCodeDigits + _phoneController.text.trim();

    // ✅ Call the actual verification API
    _verifyOTPFromAPI(fullPhone, _otpController.text);
  }

  /// Verify OTP or PIN from API
  Future<void> _verifyOTPFromAPI(String fullPhone, String inputCode) async {
    try {
      print('🔐 [SignupPage] Verifying ${_requiresPin ? "PIN" : "OTP"} for phone: $fullPhone');
      
      // ✅ Pass PIN or OTP based on _requiresPin state
      final response = await AuthAPIService.verifyOTP(
        phone: fullPhone,
        otp: _requiresPin ? null : inputCode, // Pass as OTP if PIN not required
        pin: _requiresPin ? inputCode : null, // Pass as PIN if PIN required
      );

      if (mounted) {
        if (response.success) {
          print('✅ [SignupPage] Verification successful');
          // After successful verification, check the phone
          _checkPhoneAndCreateAccount(fullPhone);
        } else {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar(
            response.message.isNotEmpty ? response.message : 'Failed to verify',
            Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Error: ${e.toString()}', Colors.red);
      }
    }
  }

  /// Check phone API - Creates account if new, retrieves data if existing
  Future<void> _checkPhoneAndCreateAccount(String fullPhone) async {
    try {
      print('📱 [SignupPage] Checking phone and creating account...');
      
      final checkResponse = await AuthAPIService.checkPhone(
        phone: fullPhone,
      );

      if (mounted) {
        final countryCode = _selectedCountryCode;
        final phoneOnly = _phoneController.text.trim();

        // Determine user type
        print('👤 [SignupPage] User Type: ${checkResponse.isNewUser ? 'NEW' : 'EXISTING'}');

        // Save user data to local storage using AuthService
        await AuthService.loginFromAPI(
          phone: phoneOnly,
          countryCode: countryCode,
          name: checkResponse.name.isNotEmpty ? checkResponse.name : 'Sampark User',
          email: checkResponse.email,
          city: checkResponse.city,
          verified: checkResponse.verified,
        );

        // Give a moment for data to be saved
        await Future.delayed(const Duration(milliseconds: 500));

        // Get FCM token and send to server
        await _sendFCMTokenToServer(fullPhone, phoneOnly);

        if (mounted) {
          // Navigate based on new or existing user
          await _navigateBasedOnUserStatus(
            phoneOnly,
            checkResponse.isNewUser,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Error: ${e.toString()}', Colors.red);
      }
    }
  }

  /// Get FCM token and send it to the server
  Future<void> _sendFCMTokenToServer(String fullPhone, String phoneOnly) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      
      if (fcmToken != null && fcmToken.isNotEmpty) {
        try {
          await AuthAPIService.updateFCMToken(
            phone: phoneOnly,
            fcmToken: fcmToken,
            platform: 'android',
          );
        } catch (e) {
          print('⚠️ [SignupPage] Error sending FCM Token: $e');
        }
      }
    } catch (e) {
      print('⚠️ [SignupPage] Error getting FCM Token: $e');
    }
  }

  /// Navigate based on whether user is new or old
  Future<void> _navigateBasedOnUserStatus(
    String phoneNumber,
    bool isNewUser,
  ) async {
    try {
      if (isNewUser) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const VehicleDetailsPage(isFromSignup: true),
            ),
          );
        }
      } else {
        const String smValue = '67s87s6yys66';
        const String dgValue = 'testYU78dII8iiUIPSISJ';
        
        final userTagsStats = await TagsService.fetchUserTags(
          phone: phoneNumber,
          smValue: smValue,
          dgValue: dgValue,
        );

        if (mounted) {
          final walletProvider = Provider.of<WalletProvider>(context, listen: false);
          walletProvider.reset();
          walletProvider.fetchWallet(phoneNumber);

          if (userTagsStats.hasActiveTags) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const MainNavigation(initialIndex: 2),
              ),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const VehicleDetailsPage(isFromSignup: true),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const VehicleDetailsPage(isFromSignup: true),
          ),
        );
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Center(
                child: Image.asset(
                  'assets/images/sampark_black.png',
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      _otpSent 
                          ? (_requiresPin ? 'Enter PIN' : 'Verify OTP') 
                          : 'Create Account',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _otpSent
                          ? (_requiresPin 
                              ? 'Enter your 4-digit PIN' 
                              : 'Enter the OTP sent to $_selectedCountryCode ${_phoneController.text}')
                          : 'Join SAMPARK to manage your tags',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 40),

                    if (!_otpSent) ...[
                      // Country Selector
                      Text(
                        'Country',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountryCode,
                            isExpanded: true,
                            items: _countries.map((country) {
                              return DropdownMenuItem<String>(
                                value: country['code'],
                                child: Row(
                                  children: [
                                    Text(
                                      country['flag']!,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${country['name']} (${country['code']})',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCountryCode = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Phone Number
                      Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: InputDecoration(
                          hintText: 'Enter phone number',
                          prefixText: '$_selectedCountryCode ',
                          prefixStyle: TextStyle(
                            fontSize: 16,
                            color: AppColors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppColors.activeYellow, width: 2),
                          ),
                        ),
                      ),
                    ] else ...[
                      // OTP or PIN Field
                      Text(
                        _requiresPin ? 'Enter PIN' : 'Enter OTP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        obscureText: _requiresPin, // Hide PIN digits for security
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: '••••',
                          filled: true,
                          fillColor: AppColors.white,
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppColors.activeYellow, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _otpSent = false;
                              _requiresPin = false;
                              _otpController.clear();
                            });
                          },
                          child: Text(
                            'Change Number',
                            style: TextStyle(
                              color: AppColors.activeYellow,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: AppConstants.buttonHeightLarge,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : (_otpSent ? _verifyOTP : _sendOTP),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.activeYellow,
                          disabledBackgroundColor:
                              AppColors.activeYellow.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.buttonBorderRadius),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    AppColors.black,
                                  ),
                                ),
                              )
                            : Text(
                                _otpSent 
                                  ? (_requiresPin ? 'Verify PIN & Continue' : 'Verify OTP & Continue') 
                                  : 'Send OTP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login Link
                    if (!_otpSent) ...[
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textGrey,
                                ),
                              ),
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.activeYellow,
                                ),
                                recognizer: _createGestureRecognizer(() {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureRecognizer _createGestureRecognizer(VoidCallback onTap) {
    return TapGestureRecognizer()..onTap = onTap;
  }
}