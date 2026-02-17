import 'package:flutter/material.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _isLoggedIn = false;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _userPhone; // Store phone for API calls

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  String _selectedGender = 'Male'; // Default value

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _cityController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    _dateOfBirthController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final loggedIn = await AuthService.isLoggedIn();
      if (mounted) {
        setState(() {
          _isLoggedIn = loggedIn;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await AuthService.getUserData();
      if (mounted) {
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
        });
      }

      // Get the phone number to use for API calls (with country code)
      final countryCode = userData['countryCode'] ?? '+91';
      final phone = userData['phone'] ?? '';
      // Remove + from country code if present and combine
      final phoneWithCode = countryCode.replaceFirst('+', '') + phone;
      _userPhone = phoneWithCode;

      print('📱 Loading profile for phone: $_userPhone');

      // Fetch profile from API
      if (_userPhone != null && _userPhone!.isNotEmpty) {
        final profileResponse = await ProfileService.getProfile(
          phone: _userPhone!,
        );

        if (profileResponse['success'] == true && mounted) {
          final profileData = profileResponse['data'] ?? {};
          print('✅ Profile loaded: ${profileData.keys}');

          setState(() {
            // Update all fields with API data
            _nameController.text = profileData['name'] ?? _nameController.text;
            _emailController.text = profileData['email'] ?? '';
            _addressController.text = profileData['address'] ?? '';
            _stateController.text = profileData['user_state'] ?? '';
            _zipCodeController.text = profileData['user_zip'] ?? '';
            _cityController.text = profileData['user_city'] ?? '';
            _facebookController.text = profileData['fb'] ?? '';
            _twitterController.text = profileData['tw'] ?? '';
            _instagramController.text = profileData['insta'] ?? '';
            _dateOfBirthController.text = profileData['user_dob'] ?? '';
            _aboutController.text = profileData['about'] ?? '';
            
            if (profileData['gender'] != null && profileData['gender'].toString().isNotEmpty) {
              _selectedGender = profileData['gender'];
            }
          });
        } else {
          print('❌ Failed to load profile: ${profileResponse['message']}');
        }
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_userPhone == null || _userPhone!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Phone number not found. Please login again.'),
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
        print('📝 Updating profile...');
        final response = await ProfileService.updateProfile(
          phone: _userPhone!,
          name: _nameController.text,
          email: _emailController.text,
          address: _addressController.text.isEmpty ? null : _addressController.text,
          zip: _zipCodeController.text.isEmpty ? null : _zipCodeController.text,
          state: _stateController.text.isEmpty ? null : _stateController.text,
          city: _cityController.text.isEmpty ? null : _cityController.text,
          gender: _selectedGender,
          about: _aboutController.text.isEmpty ? null : _aboutController.text,
          facebook: _facebookController.text.isEmpty ? null : _facebookController.text,
          twitter: _twitterController.text.isEmpty ? null : _twitterController.text,
          instagram: _instagramController.text.isEmpty ? null : _instagramController.text,
          dateOfBirth: _dateOfBirthController.text.isEmpty ? null : _dateOfBirthController.text,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (response['success'] == true) {
            print('✅ Profile updated successfully');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Profile updated successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                ),
              ),
            );
          } else {
            print('❌ Profile update failed: ${response['message']}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${response['message'] ?? 'Failed to update profile'}'),
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
        print('❌ Exception in _submitForm: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
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
                        padding: const EdgeInsets.all(AppConstants.paddingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),

                            // Page Title
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizePageTitle,
                                fontWeight: FontWeight.w800,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Update your personal information',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeSubtitle,
                                color: AppColors.textGrey,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
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
        padding: const EdgeInsets.all(AppConstants.cardPaddingLarge),
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
            // Full Name
            Text(
              'Full Name',
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: 'Enter your full name',
              prefixIcon: Icons.person_outline,
              validator: (value) => null,
            ),
            const SizedBox(height: 20),

            // Email
            Text(
              'Email Address',
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hint: 'Enter your email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => null,
            ),
            const SizedBox(height: 20),

            // Phone Number
            Text(
              'Phone Number',
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _phoneController,
              hint: 'Enter your phone number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) => null,
            ),
            const SizedBox(height: 20),

            // Address
            Text(
              'Address',
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _addressController,
              hint: 'Enter your address',
              prefixIcon: Icons.location_on_outlined,
              maxLines: 2,
              validator: (value) => null,
            ),
            const SizedBox(height: 20),

            // State/City
            Text(
              'State/City',
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _stateController,
              hint: 'Enter your state or city',
              prefixIcon: Icons.location_city_outlined,
              validator: (value) => null,
            ),
            const SizedBox(height: 20),

            // Zip Code
            Text(
              'Zip Code',
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _zipCodeController,
              hint: 'Enter your zip code',
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.number,
              validator: (value) => null,
            ),
            const SizedBox(height: 20),

            // Gender
            Text(
              'Gender',
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.lightGrey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _selectedGender,
                isExpanded: true,
                underline: const SizedBox(),
                style: TextStyle(
                  fontSize: AppConstants.fontSizeCardDescription,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black,
                ),
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedGender = newValue ?? 'Male';
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // City
            Text(
              'City',
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _cityController,
              hint: 'Enter your city',
              prefixIcon: Icons.location_city_outlined,
              validator: (value) => null,
            ),
            const SizedBox(height: 20),

            // Date of Birth
            Text(
              'Date of Birth',
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _dateOfBirthController,
              hint: 'DD/MM/YYYY',
              prefixIcon: Icons.calendar_today_outlined,
              keyboardType: TextInputType.datetime,
              validator: (value) => null,
            ),
            const SizedBox(height: 20),

            // About
            Text(
              'About',
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _aboutController,
              hint: 'Tell us about yourself',
              prefixIcon: Icons.info_outlined,
              maxLines: 3,
              validator: (value) => null,
            ),
            const SizedBox(height: 20),

            // Facebook
            Text(
              'Facebook',
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _facebookController,
              hint: 'Facebook profile URL or username',
              prefixIcon: Icons.language_outlined,
              keyboardType: TextInputType.url,
              validator: (value) => null,
            ),
            const SizedBox(height: 20),

            // Twitter
            Text(
              'Twitter',
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _twitterController,
              hint: 'Twitter profile URL or handle',
              prefixIcon: Icons.language_outlined,
              keyboardType: TextInputType.url,
              validator: (value) => null,
            ),
            const SizedBox(height: 20),

            // Instagram
            Text(
              'Instagram',
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _instagramController,
              hint: 'Instagram profile URL or username',
              prefixIcon: Icons.language_outlined,
              keyboardType: TextInputType.url,
              validator: (value) => null,
            ),

            const SizedBox(height: 28),

            // Save Changes Button
            SizedBox(
              width: double.infinity,
              height: AppConstants.buttonHeightMedium,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.activeYellow,
                  disabledBackgroundColor: AppColors.activeYellow.withOpacity(0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.black.withOpacity(0.7),
                          ),
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeButtonText,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
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
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: AppColors.textGrey,
                size: 20,
              )
            : null,
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
