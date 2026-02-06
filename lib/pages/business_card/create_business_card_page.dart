import 'package:flutter/material.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';

class CreateBusinessCardPage extends StatefulWidget {
  const CreateBusinessCardPage({super.key});

  @override
  State<CreateBusinessCardPage> createState() => _CreateBusinessCardPageState();
}

class _CreateBusinessCardPageState extends State<CreateBusinessCardPage> {
  bool _isLoggedIn = false;
  bool _agreeToTerms = false;

  // Form Controllers
  final TextEditingController _shippingAddressController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _alternatePhoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final TextEditingController _nearbyLandmarkController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _shippingAddressController.dispose();
    _nameController.dispose();
    _businessNameController.dispose();
    _mobileController.dispose();
    _alternatePhoneController.dispose();
    _emailController.dispose();
    _houseNumberController.dispose();
    _localityController.dispose();
    _nearbyLandmarkController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
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
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to the terms and conditions'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
        ),
      );
      return;
    }

    // Validate required fields
    if (_nameController.text.isEmpty ||
        _businessNameController.text.isEmpty ||
        _mobileController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all required fields'),
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
        content: const Text('Order placed successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
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
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.paddingPage,
                        AppConstants.paddingLarge,
                        AppConstants.paddingPage,
                        100,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Page Title
                          Text(
                            'Create Business Card',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizePageTitle,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Fill in your details to create your digital business card',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeSubtitle,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingLarge),

                          // Shipping Address
                          _buildSectionTitle('Shipping Address'),
                          _buildTextField(
                            controller: _shippingAddressController,
                            label: 'Your Shipping Address',
                            hint: 'You can add your business information when you receive the card',
                            maxLines: 3,
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),

                          // Complete Name
                          _buildSectionTitle('Your Complete Name'),
                          _buildTextField(
                            controller: _nameController,
                            label: '',
                            hint: 'Your Name',
                            isRequired: true,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'You can change this anytime. And you can fill other business details later when you receive the card',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeCardDescription,
                              color: AppColors.textGrey,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),

                          // Business Name
                          _buildSectionTitle('Your Business Name'),
                          _buildTextField(
                            controller: _businessNameController,
                            label: '',
                            hint: 'Your Business Name',
                            isRequired: true,
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),

                          // Mobile Number
                          _buildSectionTitle('Your Mobile Number (10 digit)'),
                          Row(
                            children: [
                              Container(
                                width: 80,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.paddingLarge,
                                  vertical: AppConstants.paddingMedium,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                  border: Border.all(
                                    color: AppColors.lightGrey,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '+91 IN',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizeCardTitle,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacingMedium),
                              Expanded(
                                child: _buildTextField(
                                  controller: _mobileController,
                                  label: '',
                                  hint: 'Mobile Number*',
                                  keyboardType: TextInputType.phone,
                                  isRequired: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),

                          // Alternate Number
                          _buildSectionTitle('Your Alternate Number (10 digit)'),
                          _buildTextField(
                            controller: _alternatePhoneController,
                            label: '',
                            hint: 'Alternate Phone',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),

                          // Email ID
                          _buildSectionTitle('Your Email ID (optional)'),
                          _buildTextField(
                            controller: _emailController,
                            label: '',
                            hint: 'Your Email Id',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),

                          // House Number and Locality
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('House Number'),
                                    _buildTextField(
                                      controller: _houseNumberController,
                                      label: '',
                                      hint: 'House Number',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacingMedium),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('Locality, (Address)'),
                                    _buildTextField(
                                      controller: _localityController,
                                      label: '',
                                      hint: 'Complete Delivery Address',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),

                          // Near by area name
                          _buildSectionTitle('Near by area name'),
                          _buildTextField(
                            controller: _nearbyLandmarkController,
                            label: '',
                            hint: 'Locality, landmark etc',
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),

                          // State and City
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('State'),
                                    _buildTextField(
                                      controller: _stateController,
                                      label: '',
                                      hint: 'State',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacingMedium),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('City'),
                                    _buildTextField(
                                      controller: _cityController,
                                      label: '',
                                      hint: 'City',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),

                          // 6 digit PIN Code
                          _buildSectionTitle('6 digit PIN Code'),
                          _buildTextField(
                            controller: _pincodeController,
                            label: '',
                            hint: 'PIN Code',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: AppConstants.spacingLarge),

                          // Terms and Conditions Checkbox
                          Container(
                            padding: const EdgeInsets.all(AppConstants.paddingMedium),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                              border: Border.all(
                                color: AppColors.lightGrey,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _agreeToTerms,
                                    onChanged: (value) {
                                      setState(() {
                                        _agreeToTerms = value ?? false;
                                      });
                                    },
                                    activeColor: AppColors.activeYellow,
                                    checkColor: AppColors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppConstants.spacingMedium),
                                Expanded(
                                  child: Text(
                                    'I understand and agree to follow NGF132 terms of purchase.',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeCardTitle,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.black,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Proceed Button
          _buildBottomProceedButton(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppConstants.fontSizeCardTitle,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        border: Border.all(
          color: AppColors.lightGrey,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: AppConstants.fontSizeCardTitle,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
        decoration: InputDecoration(
          hintText: hint + (isRequired ? '*' : ''),
          hintStyle: TextStyle(
            fontSize: AppConstants.fontSizeCardTitle,
            fontWeight: FontWeight.w400,
            color: AppColors.textGrey.withOpacity(0.6),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomProceedButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.buttonPaddingVertical),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: AppConstants.buttonHeightMedium,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.activeYellow,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                ),
              ),
              child: Text(
                'Proceed',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeButtonText,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
