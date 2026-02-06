import 'package:flutter/material.dart';
import 'package:my_new_app/pages/main_navigation.dart';
import 'package:my_new_app/pages/AppWebView/appweb.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/auth_service.dart';
import '../../auth/login_page.dart';
import '../../demo/widgets/demo.dart';
import '../../support/widgets/support.dart';
import '../../shop/widgets/shop.dart';
import '../../scan/scan_page.dart';

class ActionGrid extends StatefulWidget {
  const ActionGrid({super.key});

  @override
  State<ActionGrid> createState() => _ActionGridState();
}

class _ActionGridState extends State<ActionGrid> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 32;
    final smallBoxSize = (screenWidth - 48) / 5;
    final largeBoxSize = smallBoxSize * 2 + 12;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      child: Column(
        children: [
          Row(
            children: [
              _buildLargeShopCard(largeBoxSize),
              const SizedBox(width: AppConstants.spacingMedium),
              Column(
                children: [
                  _buildSmallCard(
                    ActionItem(
                      icon: Icons.videocam_rounded,
                      label: 'Demo',
                      useImage: true,
                      imagePath: 'assets/icons/youtube.png',
                    ),
                    smallBoxSize,
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  _buildSmallCard(
                    ActionItem(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'Activate',
                      iconColor: const Color(0xFFFF6B9D),
                    ),
                    smallBoxSize,
                  ),
                ],
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Column(
                children: [
                  _buildSmallCard(
                    ActionItem(
                      icon: _isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
                      label: _isLoggedIn ? 'Logout' : 'Login',
                      iconColor: _isLoggedIn ? const Color(0xFFFF6B6B) : const Color(0xFF4A9FFF),
                    ),
                    smallBoxSize,
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  _buildSmallCard(
                    ActionItem(
                      icon: Icons.picture_as_pdf_rounded,
                      label: 'eTag',
                      iconColor: const Color(0xFFFF4444),
                    ),
                    smallBoxSize,
                  ),
                ],
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              _buildTallSupportCard(largeBoxSize, smallBoxSize),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLargeShopCard(double size) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShopPage(showBackButton: true)),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.activeYellow,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.activeYellow.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront_rounded,
              size: 42,
              color: const Color(0xFFFFB300),
            ),
            const SizedBox(height: 10),
            Text(
              'Shop',
              style: TextStyle(
                fontSize: AppConstants.fontSizeSectionTitle,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTallSupportCard(double height, double width) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SupportPage()),
        );
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.lightGrey,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/whatsapp.png',
              width: AppConstants.iconSizeGrid + 4,
              height: AppConstants.iconSizeGrid + 4,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Support',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSmallText,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCard(ActionItem action, double size) {
    return GestureDetector(
      onTap: () {
        if (action.label == 'Login') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else if (action.label == 'Logout') {
          _showLogoutDialog();
        } else if (action.label == 'Demo') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DemoPage()),
          );
        } else if (action.label == 'Activate') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScanPage()),
          );
        } else if (action.label == 'eTag') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InAppWebViewPage(
                url: 'https://app.ngf132.com/demo-tag',
                title: 'eTag',
              ),
            ),
          );
        } else if (action.label == 'Support') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SupportPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${action.label} - Coming Soon')),
          );
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.lightGrey,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (action.useImage && action.imagePath != null)
              Image.asset(
                action.imagePath!,
                width: AppConstants.iconSizeGrid + 2,
                height: AppConstants.iconSizeGrid + 2,
              )
            else
              Icon(
                action.icon,
                size: AppConstants.iconSizeGrid,
                color: action.iconColor ?? AppColors.black,
              ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSmallText,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            fontSize: AppConstants.fontSizeSectionTitle,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: AppConstants.fontSizeCardTitle,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: AppConstants.fontSizeCardTitle,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainNavigation()),
                (route) => false,
              );
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: AppConstants.fontSizeCardTitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionItem {
  final IconData icon;
  final String label;
  final bool useImage;
  final String? imagePath;
  final Color? iconColor;

  ActionItem({
    required this.icon,
    required this.label,
    this.useImage = false,
    this.imagePath,
    this.iconColor,
  });
}
