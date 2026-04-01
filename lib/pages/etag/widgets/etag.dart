import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/etag_service.dart';
import '../../widgets/app_header.dart';

class ETagPage extends StatefulWidget {
  const ETagPage({super.key});

  @override
  State<ETagPage> createState() => _ETagPageState();
}

class _ETagPageState extends State<ETagPage> {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isVerifying = false;
  bool _hasGeneratedETag = false;
  String _generatedPhone = '';
  String? _sessionCookie;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _captchaController = TextEditingController();
  final _otpController = TextEditingController();
  
  String _selectedVehicleType = 'Car';
  final List<String> _vehicleTypes = ['Car', 'Bike', 'Scooter', 'Truck'];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _checkETagStatus();
  }

  Future<void> _checkETagStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasGenerated = prefs.getBool('has_generated_demo_etag') ?? false;
    final phone = prefs.getString('demo_etag_phone') ?? '';
    if (mounted) {
      setState(() {
        _hasGeneratedETag = hasGenerated;
        _generatedPhone = phone;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _vehicleNumberController.dispose();
    _captchaController.dispose();
    _otpController.dispose();
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

  Future<void> _submitForm() async {
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

      setState(() {
        _isLoading = true;
      });

      try {
        // Map vehicle type to API param
        String vty = 'c';
        if (_selectedVehicleType == 'Bike' || _selectedVehicleType == 'Scooter') {
          vty = 'b';
        } else if (_selectedVehicleType == 'Truck') {
          vty = 't';
        } else {
          vty = 'c';
        }

        final response = await ETagService.requestDemoETagOTP(
          name: _nameController.text.trim(),
          phone: _mobileController.text.trim(),
          plate: _vehicleNumberController.text.trim(),
          email: _emailController.text.trim(),
          vty: vty,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
            _sessionCookie = response.cookie;
          });
          _showOTPSheet();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
              ),
            ),
          );
        }
      }
    }
  }

  void _showOTPSheet() {
    _otpController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingPage),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Enter OTP',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          const Text(
                            'Please enter the 4-digit OTP sent to your mobile number.',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeCardTitle,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingLarge),
                          TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 4,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8,
                            ),
                            decoration: InputDecoration(
                              hintText: '----',
                              counterText: '',
                              filled: true,
                              fillColor: AppColors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                borderSide: BorderSide(color: AppColors.lightGrey, width: 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                borderSide: BorderSide(color: AppColors.lightGrey, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                borderSide: const BorderSide(color: AppColors.activeYellow, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingLarge),
                          SizedBox(
                            width: double.infinity,
                            height: AppConstants.buttonHeightMedium,
                            child: ElevatedButton(
                              onPressed: _isVerifying
                                  ? null
                                  : () async {
                                      if (_otpController.text.length != 4) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Please enter 4-digit OTP')),
                                        );
                                        return;
                                      }

                                      setModalState(() {
                                        _isVerifying = true;
                                      });

                                      try {
                                        final response = await ETagService.verifyDemoETagOTP(
                                          otp: _otpController.text,
                                          cookie: _sessionCookie,
                                        );

                                        if (mounted) {
                                          final prefs = await SharedPreferences.getInstance();
                                          await prefs.setBool('has_generated_demo_etag', true);
                                          await prefs.setString('demo_etag_phone', _mobileController.text.trim());

                                          // Store scaffold messenger before pop
                                          final messenger = ScaffoldMessenger.of(this.context);
                                          
                                          Navigator.pop(context); // Close sheet

                                          setState(() {
                                            _hasGeneratedETag = true;
                                            _generatedPhone = _mobileController.text.trim();
                                          });

                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(response.message),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          setModalState(() {
                                            _isVerifying = false;
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString().replaceAll('Exception: ', '')),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.activeYellow,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                ),
                                elevation: 0,
                              ),
                              child: _isVerifying
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: AppColors.black,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Verify OTP',
                                      style: TextStyle(
                                        fontSize: AppConstants.fontSizeButtonPriceText,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.black,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingLarge),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() {
          _isVerifying = false; // Reset verifying state when closed
        });
      }
    });
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

                              if (_hasGeneratedETag)
                                Container(
                                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.green),
                                          SizedBox(width: 8),
                                          Text(
                                            'eTag Generated',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'You have already generated an eTag for the mobile number $_generatedPhone.',
                                        style: const TextStyle(
                                          fontSize: AppConstants.fontSizeCardTitle,
                                          color: AppColors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Please check your email and WhatsApp for details.',
                                        style: TextStyle(
                                          fontSize: AppConstants.fontSizeCardTitle,
                                          color: AppColors.textGrey,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              _hasGeneratedETag = false;
                                              _mobileController.clear();
                                            });
                                          },
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: AppColors.activeYellow),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                            ),
                                          ),
                                          child: const Text(
                                            'Generate for another number',
                                            style: TextStyle(
                                              color: AppColors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else ...[
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
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: AppColors.black,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
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
                              ],
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
