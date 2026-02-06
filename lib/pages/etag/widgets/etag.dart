import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/auth_service.dart';
import '../../widgets/app_header.dart';

class ETagPage extends StatefulWidget {
  const ETagPage({super.key});

  @override
  State<ETagPage> createState() => _ETagPageState();
}

class _ETagPageState extends State<ETagPage> {
  bool _isLoggedIn = false;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _captchaController = TextEditingController();
  
  String _selectedVehicleType = 'Car';
  final List<String> _vehicleTypes = ['Car', 'Bike', 'Scooter', 'Truck'];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _vehicleNumberController.dispose();
    _captchaController.dispose();
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
      // Check captcha
      if (_captchaController.text.trim() != '15') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Incorrect answer to the equation!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
            ),
          ),
        );
        return;
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('eTag order submitted successfully!'),
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
      _emailController.clear();
      _mobileController.clear();
      _vehicleNumberController.clear();
      _captchaController.clear();
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

          // Main content
          SafeArea(
            child: Column(
              children: [
                // App Header with back button
                AppHeader(
                  isLoggedIn: _isLoggedIn,
                  showBackButton: true,
                  showUserInfo: false,
                ),

                // White content container
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppConstants.paddingPage,
                          AppConstants.paddingLarge,
                          AppConstants.paddingPage,
                          AppConstants.paddingPage,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title with underline
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Get eTag Delivery.',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.black,
                                      letterSpacing: -0.5,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '(Soft copy)',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeCardTitle,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: 50,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.activeYellow,
                                          AppColors.primaryYellow,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppConstants.spacingMedium),

                              // ✅ Description - Increased font size
                              Text(
                                'eTag Delivery at your email/WhatsApp instant. this will get you an eTag on your whatsApp and email. for physical delivery please visit shop page.',
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizeCardTitle, // ✅ Increased from fontSizeCardDescription
                                  height: 1.5,
                                  color: AppColors.textGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingLarge),

                              // Your Name
                              _buildTextField(
                                controller: _nameController,
                                label: 'Your Name',
                                hint: 'Enter your name',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppConstants.spacingMedium),

                              // Your Email (optional)
                              _buildTextField(
                                controller: _emailController,
                                label: 'Your Email (optional)',
                                hint: 'Enter your email',
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: AppConstants.spacingMedium),

                              // Your Mobile Number
                              _buildTextField(
                                controller: _mobileController,
                                label: 'Your Mobile Number',
                                hint: 'Enter your mobile number',
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your mobile number';
                                  }
                                  if (value.length != 10) {
                                    return 'Mobile number must be 10 digits';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppConstants.spacingMedium),

                              // Your vehicle Number
                              _buildTextField(
                                controller: _vehicleNumberController,
                                label: 'Your Vehicle Number',
                                hint: 'Enter your vehicle number',
                                textCapitalization: TextCapitalization.characters,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your vehicle number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppConstants.spacingMedium),

                              // Vehicle Type Dropdown
                              Text(
                                'Vehicle Type',
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizeCardTitle,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingSmall),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.paddingLarge,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                  border: Border.all(
                                    color: AppColors.lightGrey,
                                    width: 1.5,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedVehicleType,
                                    isExpanded: true,
                                    items: _vehicleTypes.map((type) {
                                      return DropdownMenuItem(
                                        value: type,
                                        child: Text(
                                          type,
                                          style: const TextStyle(
                                            fontSize: AppConstants.fontSizeCardTitle,
                                            color: AppColors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedVehicleType = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingMedium),

                              // Captcha
                              Text(
                                'Please Solve the Equation: 2 + 13',
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizeCardTitle,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingSmall),
                              TextFormField(
                                controller: _captchaController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Please Solve the Equation: 2 + 13',
                                  hintStyle: TextStyle(
                                    color: AppColors.textGrey.withOpacity(0.6),
                                    fontSize: AppConstants.fontSizeCardTitle,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                    borderSide: BorderSide(
                                      color: AppColors.lightGrey,
                                      width: 1.5,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                    borderSide: BorderSide(
                                      color: AppColors.lightGrey,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                    borderSide: BorderSide(
                                      color: AppColors.activeYellow,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppConstants.paddingLarge,
                                    vertical: AppConstants.paddingMedium,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please solve the equation';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppConstants.spacingLarge),

                              // ✅ Get eTag Button - Increased font size
                              SizedBox(
                                width: double.infinity,
                                height: AppConstants.buttonHeightMedium,
                                child: ElevatedButton(
                                  onPressed: _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.activeYellow,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Get eTag',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeButtonPriceText, // ✅ Increased from fontSizeButtonText
                                      fontWeight: FontWeight.w800, // ✅ Increased weight
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingMedium),

                              // ✅ Physical Tag Link - Increased font size
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Redirecting to Shop Page...'),
                                        backgroundColor: AppColors.activeYellow,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Get Physical Tag Home Delivery.',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeSectionTitle, // ✅ Increased from fontSizeCardTitle
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.darkYellow,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppConstants.paddingPage),
                            ],
                          ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeCardTitle,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textGrey.withOpacity(0.6),
              fontSize: AppConstants.fontSizeCardTitle,
            ),
            filled: true,
            fillColor: AppColors.white,
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
              borderSide: BorderSide(
                color: AppColors.lightGrey,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
              borderSide: BorderSide(
                color: AppColors.lightGrey,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
              borderSide: BorderSide(
                color: AppColors.activeYellow,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: AppConstants.paddingMedium,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
