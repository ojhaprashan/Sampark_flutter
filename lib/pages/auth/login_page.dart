import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../main_navigation.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  
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
    _nameController.dispose();
    super.dispose();
  }

  void _sendOTP() {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        _otpSent = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to $_selectedCountryCode ${_phoneController.text}'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_otpController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP must be 4 digits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate OTP verification (accept any 4-digit OTP)
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        if (_otpController.text.length == 4) {
          // Login successful - store user data
          final phoneNumber = _phoneController.text.trim();
          
          if (phoneNumber.isEmpty) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Phone number is empty'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          await AuthService.login(
            name: 'Sampark',
            phone: phoneNumber,
            countryCode: _selectedCountryCode,
          );

          // Add a longer delay to ensure data is written
          await Future.delayed(const Duration(milliseconds: 1000));

          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const MainNavigation(initialIndex: 2),
              ),
              (route) => false,
            );
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid OTP'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _otpSent
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  setState(() {
                    _otpSent = false;
                    _otpController.clear();
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
                _otpSent ? 'Verify OTP' : 'Welcome Back',
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
                    : 'Login to manage your tags',
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
                  onPressed: _isLoading ? null : (_otpSent ? _verifyOTP : _sendOTP),
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
                          _otpSent ? 'Verify & Login' : 'Send OTP',
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
              if (!_otpSent) ...[
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
                          recognizer: _createGestureRecognizer(() {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const SignupPage(),
                              ),
                            );
                          }),
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

  GestureRecognizer _createGestureRecognizer(VoidCallback onTap) {
    return TapGestureRecognizer()..onTap = onTap;
  }
}
