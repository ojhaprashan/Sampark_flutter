import 'package:flutter/material.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../../services/login_pin_service.dart';
import '../main_navigation.dart';

class LoginPinPage extends StatefulWidget {
  const LoginPinPage({super.key});

  @override
  State<LoginPinPage> createState() => _LoginPinPageState();
}

class _LoginPinPageState extends State<LoginPinPage> {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isPinSet = false; // Track if PIN is already set
  bool _showPin = false;

  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
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

  void _setupPin() async {
    if (_pinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a PIN'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
        ),
      );
      return;
    }

    if (_pinController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PIN must be at least 4 digits'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
        ),
      );
      return;
    }

    if (_pinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PINs do not match'),
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
      // Get phone number from local storage
      final userData = await AuthService.getUserData();
      final phone = userData['phone'] as String? ?? '';

      if (phone.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Error: Phone number not found'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
              ),
            ),
          );
        }
        return;
      }

      // Call API to set PIN
      await LoginPinService.setPin(
        phone: phone,
        pin: _pinController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPinSet = true;
          _pinController.clear();
          _confirmPinController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login PIN set successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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

  void _resetPin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Reset Login PIN?'),
        content: const Text('Are you sure you want to reset your login PIN? You will need to set a new PIN.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.activeYellow,
                    ),
                  ),
                ),
              );

              try {
                // Get phone number from local storage
                final userData = await AuthService.getUserData();
                final phone = userData['phone'] as String? ?? '';

                if (phone.isEmpty) {
                  if (mounted) {
                    Navigator.pop(context); // Close loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Error: Phone number not found'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                        ),
                      ),
                    );
                  }
                  return;
                }

                // Call API to reset PIN
                await LoginPinService.resetPin(phone: phone);

                if (mounted) {
                  Navigator.pop(context); // Close loading
                  
                  setState(() {
                    _isPinSet = false;
                    _pinController.clear();
                    _confirmPinController.clear();
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Login PIN has been reset'),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Close loading
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              elevation: 0,
            ),
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logoutFromAllDevices() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Logout from All Devices?'),
        content: const Text(
          'This will log you out from all devices where you are currently logged in. You will need to login again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.activeYellow,
                    ),
                  ),
                ),
              );

              // Simulate API call
              await Future.delayed(const Duration(seconds: 2));

              if (mounted) {
                Navigator.pop(context); // Close loading dialog
                await AuthService.logout();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Logged out from all devices'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                      ),
                    ),
                  );

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainNavigation()),
                    (route) => false,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,
            ),
            child: const Text(
              'Logout All',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout from this device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.activeYellow,
                    ),
                  ),
                ),
              );

              // Simulate API call
              await Future.delayed(const Duration(seconds: 1));

              if (mounted) {
                Navigator.pop(context); // Close loading dialog
                await AuthService.logout();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Logged out successfully'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                      ),
                    ),
                  );

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainNavigation()),
                    (route) => false,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),

                            // Page Title
                            Text(
                              'Login PIN',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizePageTitle,
                                fontWeight: FontWeight.w800,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Secure your account with a login PIN',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeSubtitle,
                                color: AppColors.textGrey,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // PIN Setup Section
                            _buildPinSection(),

                            const SizedBox(height: 24),

                            // Logout Options Section
                            _buildLogoutSection(),

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

  Widget _buildPinSection() {
    return Container(
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
          // PIN Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isPinSet ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isPinSet ? Colors.green.shade200 : Colors.orange.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isPinSet ? Icons.check_circle : Icons.info,
                  color: _isPinSet ? Colors.green.shade700 : Colors.orange.shade700,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isPinSet
                        ? 'Your login PIN is set and active'
                        : 'You have not set a login PIN yet',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeCardDescription,
                      fontWeight: FontWeight.w500,
                      color: _isPinSet
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // PIN Input Fields
          if (!_isPinSet) ...[
            Text(
              'Setup Login PIN',
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _buildPinField(
              controller: _pinController,
              label: 'Enter PIN',
              hint: 'Enter 4-6 digit PIN',
            ),
            const SizedBox(height: 16),
            Text(
              'Confirm PIN',
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            _buildPinField(
              controller: _confirmPinController,
              label: 'Confirm PIN',
              hint: 'Re-enter your PIN',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: AppConstants.buttonHeightMedium,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _setupPin,
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
                        'Setup PIN',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeButtonText,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
              ),
            ),
          ] else ...[
            // PIN is already set - Show reset option
            SizedBox(
              width: double.infinity,
              height: AppConstants.buttonHeightMedium,
              child: ElevatedButton.icon(
                onPressed: _resetPin,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset PIN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Container(
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
          Text(
            'Session Management',
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardTitle,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your login sessions',
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardDescription,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // Logout from All Devices Button
          SizedBox(
            width: double.infinity,
            height: AppConstants.buttonHeightMedium,
            child: ElevatedButton.icon(
              onPressed: _logoutFromAllDevices,
              icon: const Icon(Icons.devices),
              label: const Text('Logout from All Devices'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Logout from This Device Button
          SizedBox(
            width: double.infinity,
            height: AppConstants.buttonHeightMedium,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout from This Device'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.shade200,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You are currently logged in on 2 devices',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeCardDescription,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade700,
                      height: 1.4,
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

  Widget _buildPinField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      obscureText: !_showPin,
      maxLength: 6,
      style: TextStyle(
        fontSize: AppConstants.fontSizeCardDescription,
        fontWeight: FontWeight.w400,
        color: AppColors.black,
        letterSpacing: 2,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: AppConstants.fontSizeCardDescription,
          color: AppColors.textGrey.withOpacity(0.5),
          fontWeight: FontWeight.w400,
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _showPin = !_showPin;
            });
          },
          child: Icon(
            _showPin ? Icons.visibility : Icons.visibility_off,
            color: AppColors.textGrey,
            size: 20,
          ),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
