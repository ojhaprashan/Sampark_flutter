import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../../services/auth_api_service.dart';
import '../../services/firebase_notification_service.dart';
import '../main_navigation.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _otpPinController = TextEditingController();
  
  String _selectedCountryCode = '91';
  bool _otpPinSent = false;
  bool _requiresPin = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _fcmToken;


  final List<Map<String, String>> _countries = [
    {'code': '91', 'name': 'India', 'flag': '🇮🇳'},
    {'code': '1', 'name': 'USA', 'flag': '🇺🇸'},
    {'code': '44', 'name': 'UK', 'flag': '🇬🇧'},
    {'code': '971', 'name': 'UAE', 'flag': '🇦🇪'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  /// Initialize Firebase Cloud Messaging
  void _initializeFCM() async {
    try {
      print('📱 [LoginPage] Starting FCM initialization...');
      
      // Initialize FCM service
      await FirebaseNotificationService.initialize();
      print('✅ [LoginPage] FCM service initialized');
      
      // Get FCM token
      print('🔑 [LoginPage] Attempting to get FCM token...');
      final token = await FirebaseNotificationService.getFCMToken();
      
      if (token != null) {
        setState(() {
          _fcmToken = token;
        });
        print('✅ [LoginPage] FCM token received: ${token.substring(0, 30)}...');
        
        // Save token for later use
        await FirebaseNotificationService.saveFCMToken(token);
        print('✅ [LoginPage] FCM token saved to SharedPreferences');
      } else {
        print('⚠️ [LoginPage] FCM token is null - Firebase may not be properly initialized');
        print('⚠️ [LoginPage] User can still use the app, but won\'t receive push notifications');
        
        // Set a placeholder so we know it failed
        setState(() {
          _fcmToken = 'not_available';
        });
      }
    } catch (e) {
      print('❌ [LoginPage] FCM initialization error: $e');
      setState(() {
        _fcmToken = 'error_$e';
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpPinController.dispose();
    super.dispose();
  }

  /// Send OTP to phone number
  /// This calls request_otp_api which may ask for PIN instead
  void _sendOTP() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate phone number
    if (_phoneController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter phone number';
      });
      _showError('Please enter phone number');
      return;
    }

    // Format full phone number with country code
    final fullPhone =
        AuthAPIService.formatPhoneNumber(_phoneController.text, _selectedCountryCode);

    if (!AuthAPIService.validatePhoneNumber(fullPhone)) {
      setState(() {
        _errorMessage = 'Invalid phone number format';
      });
      _showError('Invalid phone number format');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('📞 Requesting OTP for: $fullPhone');
      
      // Call request_otp_api
      final response = await AuthAPIService.requestOTP(phone: fullPhone);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _otpPinSent = true;
          _requiresPin = response.requirePin;
          _errorMessage = null;
        });

        // Show success message based on response
        if (response.requirePin) {
          _showSuccess('Enter your 4-digit PIN');
        } else if (response.sent) {
          _showSuccess('OTP sent successfully');
        } else {
          _showSuccess(response.message);
        }

        print('✅ OTP Request successful');
        print('   ├─ Require PIN: ${response.requirePin}');
        print('   ├─ Sent: ${response.sent}');
        print('   └─ Message: ${response.message}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
        _showError(_errorMessage ?? 'Error requesting OTP');
      }
    }
  }

  /// Verify OTP or PIN
  void _verifyOTPPin() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate OTP/PIN
    if (_otpPinController.text.isEmpty) {
      setState(() {
        _errorMessage = _requiresPin ? 'Please enter PIN' : 'Please enter OTP';
      });
      _showError(_errorMessage!);
      return;
    }

    if (_otpPinController.text.length != 4) {
      setState(() {
        _errorMessage = _requiresPin ? 'PIN must be 4 digits' : 'OTP must be 4 digits';
      });
      _showError(_errorMessage!);
      return;
    }

    // Format full phone number
    final fullPhone =
        AuthAPIService.formatPhoneNumber(_phoneController.text, _selectedCountryCode);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final otpOrPin = _otpPinController.text;
      print('🔐 Verifying ${_requiresPin ? 'PIN' : 'OTP'}: ****');
      print('   ├─ Phone: $fullPhone');
      print('   ├─ FCM Token: ${_fcmToken != null ? '${_fcmToken!.substring(0, 10)}...' : 'Not available'}');
      print('   └─ Sending to verify_otp_api...');

      // Call verify_otp_api with either otp or pin
      final response = await AuthAPIService.verifyOTP(
        phone: fullPhone,
        otp: _requiresPin ? null : otpOrPin,
        pin: _requiresPin ? otpOrPin : null,
        fcmToken: _fcmToken, // Send FCM token for push notifications
      );

      if (mounted) {
        if (response.success) {
          // Verification successful - login user
          print('✅ Verification successful');
          print('   ├─ Name: ${response.userName}');
          print('   ├─ Email: ${response.userEmail}');
          print('   ├─ City: ${response.userCity}');
          print('   └─ Verified: ${response.verified}');
          
          // Extract phone without country code for local storage
          String phoneLocal = _phoneController.text.trim();
          phoneLocal = phoneLocal.replaceAll(RegExp(r'\s+'), '');
          if (phoneLocal.startsWith('+')) {
            phoneLocal = phoneLocal.substring(1);
          }
          if (phoneLocal.startsWith(_selectedCountryCode)) {
            phoneLocal = phoneLocal.substring(_selectedCountryCode.length);
          }

          // Login user with complete data from API
          await AuthService.loginFromAPI(
            phone: phoneLocal,
            countryCode: _selectedCountryCode,
            name: response.userName,
            email: response.userEmail,
            city: response.userCity,
            verified: response.verified ?? false,
          );

          // Save FCM token to SharedPreferences for future use
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_fcm_token', _fcmToken ?? '');
            await prefs.setString('last_login_phone', fullPhone);
            print('💾 User data, FCM token, and profile info saved');
          } catch (e) {
            print('⚠️ Warning: Could not save FCM token: $e');
          }

          // Add a delay to ensure data is written
          await Future.delayed(const Duration(milliseconds: 1000));

          if (mounted) {
            // Navigate to main app
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const MainNavigation(initialIndex: 2),
              ),
              (route) => false,
            );
          }
        } else {
          // Verification failed
          setState(() {
            _isLoading = false;
            _errorMessage = response.message;
          });
          _showError(response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
        _showError(_errorMessage ?? 'Error verifying OTP/PIN');
      }
    }
  }

  /// Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show success message
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _otpPinSent
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  setState(() {
                    _otpPinSent = false;
                    _requiresPin = false;
                    _otpPinController.clear();
                    _errorMessage = null;
                  });
                },
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/sampark_black.png',
                  height: 50,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                _otpPinSent 
                    ? (_requiresPin ? 'Enter PIN' : 'Verify OTP')
                    : 'Welcome Back',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _otpPinSent
                    ? (_requiresPin 
                        ? 'Enter your 4-digit PIN'
                        : 'Enter the OTP sent to +$_selectedCountryCode ${_phoneController.text}')
                    : 'Login to manage your tags',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 40),
              
              if (!_otpPinSent) ...[
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
                                '${country['name']} (+${country['code']})',
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
                    prefixText: '+$_selectedCountryCode ',
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
                // OTP/PIN Field
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
                  controller: _otpPinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
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
                        _otpPinSent = false;
                        _requiresPin = false;
                        _otpPinController.clear();
                        _errorMessage = null;
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
              
              // Error message display
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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
                      : (_otpPinSent ? _verifyOTPPin : _sendOTP),
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.black,
                            ),
                          ),
                        )
                      : Text(
                          _otpPinSent 
                              ? (_requiresPin ? 'Verify PIN & Login' : 'Verify OTP & Login')
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

              // Signup Link
              if (!_otpPinSent) ...[
                const SizedBox(height: 20),
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textGrey,
                          ),
                        ),
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.activeYellow,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const SignupPage(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

