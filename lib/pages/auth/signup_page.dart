import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import 'login_page.dart';
import '../../services/auth_service.dart';
import '../../services/tags_service.dart';
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

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _otpSent = true;
        });
        _showSnackBar(
          'OTP sent to $_selectedCountryCode ${_phoneController.text}',
          Colors.green,
        );
      }
    });
  }

  void _verifyOTP() {
    if (_otpController.text.isEmpty) {
      _showSnackBar('Please enter OTP', Colors.red);
      return;
    }

    if (_otpController.text.length != 4) {
      _showSnackBar('OTP should be 4 digits', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate OTP verification
    Future.delayed(const Duration(seconds: 1), () async {
      if (mounted) {
        try {
          // Store user data - ensure phone is properly formatted
          final phoneNumber = _phoneController.text.trim();
          if (phoneNumber.isEmpty) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              _showSnackBar('Phone number is empty', Colors.red);
            }
            return;
          }

          await AuthService.signup(
            name: 'Sampark',
            phone: phoneNumber,
            countryCode: _selectedCountryCode,
          );

          // Add a longer delay to ensure data is written to SharedPreferences
          await Future.delayed(const Duration(milliseconds: 1000));

          if (mounted) {
            // ✅ Check if user has tags before navigating
            await _navigateBasedOnUserTags(phoneNumber);
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            _showSnackBar('Error during signup: $e', Colors.red);
          }
        }
      }
    });
  }

  /// ✅ NEW: Check if user (who just signed up) already has tags
  /// If old user (has tags) -> MainNavigation (tags page)
  /// If new user (no tags) -> VehicleDetailsPage (add vehicles)
  Future<void> _navigateBasedOnUserTags(String phoneNumber) async {
    try {
      print('🏷️ [SignupPage] Checking if user has existing tags...');
      
      // API credentials
      const String smValue = '67s87s6yys66';
      const String dgValue = 'testYU78dII8iiUIPSISJ';
      
      // Extract country code from _selectedCountryCode (remove '+' prefix)
      final countryCode = _selectedCountryCode.replaceFirst('+', '');
      
      // Format phone with country code for API call
      final phone =  phoneNumber;
      
      // Fetch user tags
      final userTagsStats = await TagsService.fetchUserTags(
        phone: phone,
        smValue: smValue,
        dgValue: dgValue,
      );

      print('📊 [SignupPage] User Tags Check:');
      print('   ├─ Has Active Tags: ${userTagsStats.hasActiveTags}');
      print('   ├─ Total Tags: ${userTagsStats.summary.getTotalTags()}');
      print('   │  ├─ Car Tags: ${userTagsStats.summary.carTags}');
      print('   │  ├─ Bike Tags: ${userTagsStats.summary.bikeTags}');
      print('   │  ├─ Business Tags: ${userTagsStats.summary.businessTags}');
      print('   │  ├─ Menu Tags: ${userTagsStats.summary.menuTags}');
      print('   │  ├─ Emergency Tags: ${userTagsStats.summary.emergencyTags}');
      print('   │  └─ Door Tags: ${userTagsStats.summary.doorTags}');

      if (mounted) {
        if (userTagsStats.hasActiveTags) {
          // ✅ Old user - has existing tags, navigate to MainNavigation
          print('✅ [SignupPage] Old user with existing tags detected - navigating to tags page');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const MainNavigation(initialIndex: 2),
            ),
          );
        } else {
          // ✅ New user - no tags, navigate to VehicleDetailsPage
          print('✅ [SignupPage] New user detected - navigating to vehicle details page');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const VehicleDetailsPage(isFromSignup: true),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ [SignupPage] Error checking user tags: $e');
      
      if (mounted) {
        // If tag check fails, default to VehicleDetailsPage for new signup flow
        print('⚠️ [SignupPage] Tag check failed, defaulting to VehicleDetailsPage');
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // ✅ Remove AppBar - no back button needed
      body: SafeArea(
        child: Column(
          children: [
            // ✅ Simple Header - Just Logo
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
            // ✅ Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      _otpSent ? 'Verify OTP' : 'Create Account',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _otpSent
                          ? 'Enter the OTP sent to $_selectedCountryCode ${_phoneController.text}'
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
                      // OTP Field
                      Text(
                        'Enter OTP',
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
                                _otpSent ? 'Verify & Continue' : 'Send OTP',
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
