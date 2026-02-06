import 'package:flutter/material.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';

class CreateSamparkTagPage extends StatefulWidget {
  const CreateSamparkTagPage({super.key});

  @override
  State<CreateSamparkTagPage> createState() => _CreateSamparkTagPageState();
}

class _CreateSamparkTagPageState extends State<CreateSamparkTagPage> {
  bool _isLoggedIn = false;

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _alternatePhoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final TextEditingController _nearbyLandmarkController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _vehicleNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _alternatePhoneController.dispose();
    _emailController.dispose();
    _houseNumberController.dispose();
    _localityController.dispose();
    _nearbyLandmarkController.dispose();
    _pincodeController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _vehicleNumberController.dispose();
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
    // Validate required fields
    if (_nameController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _pincodeController.text.isEmpty) {
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
                            'Order SAMPARK Tag',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizePageTitle,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Where should we send you the tags?',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeSubtitle,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(AppConstants.paddingMedium),
                            decoration: BoxDecoration(
                              color: AppColors.activeYellow.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.activeYellow.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'You can change these details later also. These details will be used for shipping only. Vehicle details can be filled when you have the tag. It can be re-written.',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeCardDescription,
                                color: AppColors.black,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingLarge),

                          // Delivery Date Info
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
                              children: [
                                Icon(
                                  Icons.local_shipping_outlined,
                                  color: AppColors.activeYellow,
                                  size: AppConstants.iconSizeGrid,
                                ),
                                const SizedBox(width: AppConstants.spacingMedium),
                                Expanded(
                                  child: Text(
                                    'You will receive your order between\n23/Jan (Fri) to 25/Jan (Sun)',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeCardDescription,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.black,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingLarge),

                          // Complete Name
                          _buildSectionTitle('Your Complete name'),
                          _buildTextField(
                            controller: _nameController,
                            hint: 'test client 12',
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
                            hint: 'Alternate Phone',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),

                          // Email ID
                          _buildSectionTitle('Your Email ID (optional)'),
                          _buildTextField(
                            controller: _emailController,
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
                                      hint: '123',
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
                                      hint: 'Tilak nagar',
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
                            hint: 'Locality, landmark etc',
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),

                          // PIN Code
                          _buildSectionTitle('6 digit PIN Code'),
                          _buildTextField(
                            controller: _pincodeController,
                            hint: 'PIN Code',
                            keyboardType: TextInputType.number,
                            isRequired: true,
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
                                      hint: 'Illinois',
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
                                      hint: 'Bhojpur',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),

                          // Vehicle Number (Optional)
                          _buildSectionTitle('Optional Vehicle Number'),
                          Text(
                            'You can change this when you receive the tag.',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeCardDescription,
                              color: AppColors.textGrey,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingSmall),
                          _buildTextField(
                            controller: _vehicleNumberController,
                            hint: 'Vehicle Number (Optional)',
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
