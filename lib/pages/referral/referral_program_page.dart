import 'package:flutter/material.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';

class ReferralProgramPage extends StatefulWidget {
  const ReferralProgramPage({super.key});

  @override
  State<ReferralProgramPage> createState() => _ReferralProgramPageState();
}

class _ReferralProgramPageState extends State<ReferralProgramPage> {
  bool _isLoggedIn = false;
  final _formKey = GlobalKey<FormState>();
  bool _isNotRobot = false;

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (!_isNotRobot) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please verify you are not a robot'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
            ),
          ),
        );
        return;
      }

      // Submit form logic here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Business signup submitted successfully! 🎉'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
        ),
      );

      // Clear form
      _formKey.currentState!.reset();
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _passwordController.clear();
      _noteController.clear();
      setState(() {
        _isNotRobot = false;
      });
    }
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

                // Main Content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),

                            // Page Title
                            Row(
                              children: [
                                Text(
                                  'Signup as a Business. ',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizePageTitle,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.black,
                                  ),
                                ),
                                Text(
                                  '🔥',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizePageTitle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizeSubtitle,
                                  color: AppColors.textGrey,
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                ),
                                children: [
                                  TextSpan(text: 'Signup as a business, Start selling eTags and referals. Refer '),
                                  TextSpan(
                                    text: 'Login',
                                    style: TextStyle(
                                      color: AppColors.activeYellow,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Form
                            _buildForm(),

                            const SizedBox(height: 20),
                          ],
                        ),
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

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Your name
            _buildLabel('Your name'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: 'your name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Your Phone
            _buildLabel('Your Phone'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _phoneController,
              hint: 'your Phone',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.length != 10) {
                  return 'Please enter a valid 10-digit phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Your Email
            _buildLabel('Your Email'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hint: 'your Email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Create a Password
            _buildLabel('Create a Password'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _passwordController,
              hint: 'Choose a Password',
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please create a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Note for the reviewer
            _buildTextField(
              controller: _noteController,
              hint: 'A note for the reviewer, how many refers can you get every week? and where do you prefer to market it?',
              maxLines: 4,
            ),
            const SizedBox(height: 20),

            // reCAPTCHA Checkbox
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.lightGrey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _isNotRobot,
                    onChanged: (value) {
                      setState(() {
                        _isNotRobot = value ?? false;
                      });
                    },
                    activeColor: AppColors.activeYellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'I\'m not a robot',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeCardDescription,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  // reCAPTCHA logo placeholder
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh,
                        color: AppColors.textGrey,
                        size: 20,
                      ),
                      Text(
                        'reCAPTCHA',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ✅ Submit Button - YELLOW (Your app design)
            SizedBox(
              width: double.infinity,
              height: AppConstants.buttonHeightMedium,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.activeYellow, // ✅ Yellow background
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                  ),
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeButtonText,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black, // ✅ Black text
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: AppConstants.fontSizeCardDescription,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: AppConstants.fontSizeCardDescription,
        fontWeight: FontWeight.w400,
        color: AppColors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: AppConstants.fontSizeCardDescription,
          color: AppColors.textGrey.withOpacity(0.5),
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.lightGrey,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.lightGrey,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.activeYellow,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
