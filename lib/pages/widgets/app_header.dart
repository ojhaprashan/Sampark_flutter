import 'package:flutter/material.dart';
import 'package:my_new_app/pages/widgets/notification_sheet.dart';
import '../../utils/colors.dart';
import '../../services/auth_service.dart';
import '../auth/login_page.dart';
import '../auth/edit_profile_page.dart';
import '../auth/login_pin_page.dart';
import '../main_navigation.dart';

class AppHeader extends StatefulWidget {
  final bool isLoggedIn;
  final bool showLoginPinButton;
  final bool showBackButton;
  final bool showUserInfo;
  final bool showCartIcon;
  final int cartItemCount;
  final VoidCallback? onCartTap;
  
  const AppHeader({
    super.key,
    required this.isLoggedIn,
    this.showLoginPinButton = false,
    this.showBackButton = false,
    this.showUserInfo = true,
    this.showCartIcon = false,
    this.cartItemCount = 0,
    this.onCartTap,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  Map<String, String> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didUpdateWidget(AppHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoggedIn != widget.isLoggedIn) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    if (widget.isLoggedIn) {
      final data = await AuthService.getUserData();
      if (mounted) {
        setState(() {
          _userData = data;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _userData = {};
        _isLoading = false;
      });
    }
  }

  String get userName {
    final name = _userData['name'] ?? '';
    return name.trim().isEmpty ? 'RJ' : name;
  }

  String get userFirstName {
    return userName.split(' ').first;
  }

  String get userInitial {
    return userName[0].toUpperCase();
  }

  String get userPhone {
    final phone = _userData['phone'] ?? '';
    final code = _userData['countryCode'] ?? '+91';
    return phone.isEmpty ? '' : '$code $phone';
  }


void _showNotificationSheet() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    useRootNavigator: false,
    elevation: 0,
    builder: (context) => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: const NotificationSheet(),
    ),
  );
}

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              if (widget.isLoggedIn) ...[
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.activeYellow,
                  child: Text(
                    userInitial,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userPhone,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 24),
                _buildMenuButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfilePage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuButton(
                  icon: Icons.lock_outline,
                  label: 'Login PIN',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPinPage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuButton(
                  icon: Icons.logout,
                  label: 'Logout',
                  isDestructive: true,
                  onTap: () async {
                    await AuthService.logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainNavigation()),
                      (route) => false,
                    );
                  },
                ),
              ] else ...[
                Icon(
                  Icons.person_outline,
                  size: 60,
                  color: AppColors.activeYellow,
                ),
                const SizedBox(height: 16),
                Text(
                  'Login to Continue',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Access your tags and manage your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.activeYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Login Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDestructive 
              ? Colors.red.withOpacity(0.1) 
              : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : AppColors.black,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.red : AppColors.black,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDestructive ? Colors.red : AppColors.textGrey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && widget.isLoggedIn && widget.showUserInfo) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row - Different layout based on showBackButton
          widget.showBackButton
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    
                    // Center - Logo (Clickable)
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainNavigation(initialIndex: 2),
                          ),
                          (route) => false,
                        );
                      },
                      child: Image.asset(
                        'assets/images/sampark_black.png',
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    // Right side - Icons
                    Row(
                      children: [
                        // Show either cart or notification icon
                        if (widget.showCartIcon)
                          _buildCartButton()
                        else
                          _buildIconButton(Icons.notifications_outlined, () {
                            if (!widget.isLoggedIn) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Please login to view notifications'),
                                  action: SnackBarAction(
                                    label: 'Login',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const LoginPage()),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          }),
                        const SizedBox(width: 12),
                        _buildIconButton(Icons.person_outline, () {
                          _showProfileMenu(context);
                        }),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left - Logo (Clickable)
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainNavigation(initialIndex: 2),
                          ),
                          (route) => false,
                        );
                      },
                      child: Image.asset(
                        'assets/images/sampark_black.png',
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    // Right side - Icons
                    Row(
                      children: [
                        // Show either cart or notification icon
                        if (widget.showCartIcon)
                          _buildCartButton()
                        else
                        _buildIconButton(Icons.notifications_outlined, () {
  if (!widget.isLoggedIn) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please login to view notifications'),
        action: SnackBarAction(
          label: 'Login',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
      ),
    );
  } else {
    // ✅ Show notification sheet
    _showNotificationSheet();
  }
}),

                        const SizedBox(width: 12),
                        _buildIconButton(Icons.person_outline, () {
                          _showProfileMenu(context);
                        }),
                      ],
                    ),
                  ],
                ),
          
          // User info section (only if showUserInfo is true and logged in)
          if (widget.showUserInfo && widget.isLoggedIn && !_isLoading) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Hi, $userFirstName',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '👋',
                          style: TextStyle(fontSize: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      userPhone,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Wallet: ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey,
                        ),
                      ),
                      Text(
                        '₹500',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 22, color: AppColors.black),
      ),
    );
  }

  Widget _buildCartButton() {
    return GestureDetector(
      onTap: widget.onCartTap ?? () {},
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.shopping_cart_rounded,
              size: 22,
              color: AppColors.black,
            ),
          ),
          if (widget.cartItemCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryYellow,
                    width: 2,
                  ),
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  widget.cartItemCount > 9 ? '9+' : '${widget.cartItemCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
