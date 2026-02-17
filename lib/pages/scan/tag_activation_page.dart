import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/qr_signup_service.dart';
import '../../services/auth_service.dart';
import '../main_navigation.dart';
import '../widgets/app_header.dart';

class TagActivationPage extends StatefulWidget {
  final QRSignupData tagData;

  const TagActivationPage({
    super.key,
    required this.tagData,
  });

  @override
  State<TagActivationPage> createState() => _TagActivationPageState();
}

class _TagActivationPageState extends State<TagActivationPage> {
  bool _isLoading = false;
  bool _isActivated = false;
  bool _isLoadingUserData = true;
  
  // Form controllers
  late TextEditingController _vehicleNumberController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _vehicleNumberController = TextEditingController();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserPhone();
  }

  void _loadUserPhone() async {
    try {
      final userData = await AuthService.getUserData();
      if (mounted) {
        setState(() {
          _phoneController.text = userData['phone'] ?? '';
          _isLoadingUserData = false;
        });
      }
    } catch (e) {
      print('Error loading user phone: $e');
      if (mounted) {
        setState(() {
          _isLoadingUserData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _activateTag() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await QRSignupService.activateTag(
        codeS:  widget.tagData.tagId.toString(),
        qrcode: widget.tagData.qrCodeSuffix,
        carno: _vehicleNumberController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        codeT: widget.tagData.tagType.toLowerCase(),
      );

      if (mounted) {
        if (response.status == 'success' && response.data.activated) {
          setState(() {
            _isLoading = false;
            _isActivated = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tag activated successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
              ),
            ),
          );

          await Future.delayed(const Duration(seconds: 2));

          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const MainNavigation(),
              ),
              (route) => false,
            );
          }
        } else {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message.isNotEmpty 
                  ? response.message 
                  : 'Failed to activate tag'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.replaceFirst('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
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

  String _getVehicleTypeName(String typeCode) {
    switch (typeCode.toUpperCase()) {
      case 'C':
        return 'Car';
      case 'B':
        return 'Bike';
      case 'S':
        return 'Scooter';
      case 'T':
        return 'Truck';
      case 'A':
        return 'Auto';
      default:
        return 'Vehicle';
    }
  }

  String _getVehicleNumberPlaceholder() {
    switch (widget.tagData.tagType.toUpperCase()) {
      case 'C':
        return 'Enter your car number (e.g., DL8CX5566)';
      case 'B':
        return 'Enter your bike number (e.g., DL2SAB1234)';
      case 'S':
        return 'Enter your scooter number (e.g., DL3SCH7890)';
      case 'T':
        return 'Enter your truck number (e.g., DL9TRK4567)';
      case 'A':
        return 'Enter your auto number (e.g., DL1PAA8901)';
      default:
        return 'Enter your vehicle number';
    }
  }

  IconData _getVehicleIcon() {
    switch (widget.tagData.tagType.toUpperCase()) {
      case 'C':
        return Icons.directions_car_rounded;
      case 'B':
        return Icons.two_wheeler_rounded;
      case 'S':
        return Icons.electric_scooter_rounded;
      case 'T':
        return Icons.local_shipping_rounded;
      case 'A':
        return Icons.airport_shuttle_rounded;
      default:
        return Icons.local_offer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = _phoneController.text.isNotEmpty;
    
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Yellow gradient background (RESTORED)
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
                // ✅ CHANGE 1: Use AppHeader
                AppHeader(
                  isLoggedIn: isLoggedIn,
                  showBackButton: true,
                  showUserInfo: false,
                  showCartIcon: false,
                ),
                
                // Content with curved design (RESTORED)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),

                          // Status Icon with Vehicle Type
                          Center(
                            child: !_isActivated
                                ? Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primaryYellow,
                                          AppColors.primaryYellow.withOpacity(0.85),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryYellow.withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        _getVehicleIcon(),
                                        size: 40,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.green.shade400,
                                          Colors.green.shade600,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.check_circle,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 20),

                          // Title
                          Text(
                            _isActivated ? 'Tag Activated Successfully!' : 'Activate Your ${_getVehicleTypeName(widget.tagData.tagType)} Tag',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Description
                          Text(
                            _isActivated
                                ? 'Your tag is now active and ready to use with all premium features'
                                : 'Register your ${_getVehicleTypeName(widget.tagData.tagType).toLowerCase()} details to unlock all premium features',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textGrey,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Owner Details Form - Ultra Premium
                          if (!_isActivated)
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.lightGrey.withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Section Title
                                    Text(
                                      'Vehicle Details',
                                      style: GoogleFonts.inter(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Vehicle Number Field
                                    TextFormField(
                                      controller: _vehicleNumberController,
                                      textCapitalization: TextCapitalization.characters,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Vehicle number is required';
                                        }
                                        if (value.length < 6 || value.length > 11) {
                                          return 'Vehicle number must be 6-11 characters';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        labelText: '${_getVehicleTypeName(widget.tagData.tagType)} Number',
                                        hintText: _getVehicleNumberPlaceholder(),
                                        hintStyle: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: AppColors.textGrey.withOpacity(0.4),
                                          fontWeight: FontWeight.w400,
                                        ),
                                        labelStyle: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: AppColors.textGrey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        floatingLabelStyle: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.black,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: AppColors.lightGrey.withOpacity(0.6),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: AppColors.primaryYellow,
                                            width: 2.5,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Colors.red.shade400,
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Colors.red.shade600,
                                            width: 2.5,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 18,
                                        ),
                                        filled: true,
                                        fillColor: AppColors.background,
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.only(left: 14, right: 10),
                                          child: Icon(
                                            _getVehicleIcon(),
                                            size: 22,
                                            color: AppColors.textGrey,
                                          ),
                                        ),
                                      ),
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.black,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Owner Name Field
                                    TextFormField(
                                      controller: _nameController,
                                      textCapitalization: TextCapitalization.words,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Owner name is required';
                                        }
                                        if (value.trim().length < 2) {
                                          return 'Name must be at least 2 characters';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Owner Full Name',
                                        hintText: 'Enter the registered owner\'s name',
                                        hintStyle: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: AppColors.textGrey.withOpacity(0.4),
                                          fontWeight: FontWeight.w400,
                                        ),
                                        labelStyle: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: AppColors.textGrey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        floatingLabelStyle: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.black,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: AppColors.lightGrey.withOpacity(0.6),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: AppColors.primaryYellow,
                                            width: 2.5,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Colors.red.shade400,
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Colors.red.shade600,
                                            width: 2.5,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 18,
                                        ),
                                        filled: true,
                                        fillColor: AppColors.background,
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.only(left: 14, right: 10),
                                          child: Icon(
                                            Icons.person_rounded,
                                            size: 22,
                                            color: AppColors.textGrey,
                                          ),
                                        ),
                                      ),
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // ✅ CHANGE 2: Phone Number Field - Disabled & Auto-filled
                                    TextFormField(
                                      controller: _phoneController,
                                      enabled: false, // Disabled
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Phone number is required';
                                        }
                                        if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                                          return 'Enter a valid 10-digit phone number';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Contact Number (Auto-filled)',
                                        hintText: 'Your registered number',
                                        hintStyle: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: AppColors.textGrey.withOpacity(0.4),
                                          fontWeight: FontWeight.w400,
                                        ),
                                        labelStyle: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: AppColors.textGrey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        floatingLabelStyle: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.black,
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: AppColors.lightGrey.withOpacity(0.4),
                                            width: 1.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: AppColors.lightGrey.withOpacity(0.6),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: AppColors.primaryYellow,
                                            width: 2.5,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Colors.red.shade400,
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(
                                            color: Colors.red.shade600,
                                            width: 2.5,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 18,
                                        ),
                                        filled: true,
                                        fillColor: AppColors.lightGrey.withOpacity(0.1),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.only(left: 16, right: 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.phone_rounded,
                                                size: 20,
                                                color: AppColors.textGrey.withOpacity(0.6),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                '+91',
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textGrey,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Container(
                                                width: 1.5,
                                                height: 24,
                                                color: AppColors.lightGrey,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textGrey,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          if (!_isActivated) const SizedBox(height: 28),

                          // Action Button - ABOVE TAG INFORMATION
                          if (!_isActivated)
                            Container(
                              height: AppConstants.buttonHeightLarge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.buttonBorderRadius,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryYellow.withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _activateTag,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryYellow,
                                  disabledBackgroundColor: AppColors.lightGrey,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.buttonBorderRadius,
                                    ),
                                  ),
                                ),
                                child: _isLoading
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                AppColors.black,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Text(
                                            'Activating Your Tag...',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            size: 22,
                                            color: AppColors.black,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Activate Tag Now',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                          if (!_isActivated) const SizedBox(height: 28),

                          // Tag Information Card - BELOW BUTTON
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryYellow.withOpacity(0.08),
                                  AppColors.primaryYellow.withOpacity(0.03),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.primaryYellow.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryYellow.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.local_offer_rounded,
                                        size: 16,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Tag Information',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  'Tag ID',
                                  widget.tagData.tagId.toString(),
                                  Icons.tag_rounded,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'QR Code',
                                  widget.tagData.qrCode,
                                  Icons.qr_code_2_rounded,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'Vehicle Type',
                                  _getVehicleTypeName(widget.tagData.tagType),
                                  _getVehicleIcon(),
                                ),
                              ],
                            ),
                          ),

                          // Success Button (for activated state)
                          if (_isActivated) ...[
                            const SizedBox(height: 28),
                            Container(
                              height: AppConstants.buttonHeightLarge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.buttonBorderRadius,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const MainNavigation(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.buttonBorderRadius,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.home_rounded,
                                      size: 22,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Go to Home',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Features List - Enhanced
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade50,
                                  Colors.blue.shade50.withOpacity(0.3),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.blue.shade200.withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade400,
                                            Colors.blue.shade600,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Premium Features',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                _buildFeatureItem('Instant contact with tag owner', Icons.phone_in_talk_rounded),
                                const SizedBox(height: 12),
                                _buildFeatureItem('Real-time push notifications', Icons.notifications_active_rounded),
                                const SizedBox(height: 12),
                                _buildFeatureItem('Complete tag history & tracking', Icons.history_rounded),
                                const SizedBox(height: 12),
                                _buildFeatureItem('24/7 premium support access', Icons.support_agent_rounded),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
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

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: AppColors.black,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey,
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.shade400,
                Colors.green.shade600,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
