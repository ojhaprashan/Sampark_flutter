import 'package:flutter/material.dart';
import 'package:my_new_app/pages/main_navigation.dart';
import 'package:my_new_app/pages/AppWebView/appweb.dart';
// import 'package:my_new_app/pages/auth/vehicle_details_page.dart'; // Removed as button is gone

import 'package:my_new_app/pages/shop/widgets/shop.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/auth_service.dart';
import '../../auth/login_page.dart';
import '../../demo/widgets/demo.dart';
import '../../support/widgets/support.dart';
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
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get total available width
    final screenWidth = MediaQuery.of(context).size.width - (AppConstants.paddingLarge * 2);
    
    // 2. Calculate sizes strictly to fit screen
    // Layout: [Shop (2u+g)] + g + [Col1 (1u)] + g + [Col2 (1u)] + g + [Col3 (1u)]
    // Total Width = 5 units + 4 gaps
    
    final gapSize = AppConstants.spacingMedium;
    // Subtract 4 gaps from screen width, then divide by 5.2 units
    final smallBoxSize = (screenWidth - (gapSize * 3)) / 5.2; 
    final largeBoxSize = (smallBoxSize * 2) + gapSize;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Large Shop Card
            _buildLargeShopCard(largeBoxSize),
            
            SizedBox(width: gapSize),
            
            // 2. Middle Column 1
            Column(
              children: [
                _buildActionCard(
                  ActionItem(
                    icon: Icons.videocam_rounded,
                    label: 'Demo',
                    useImage: true,
                    imagePath: 'assets/icons/youtube.png',
                    iconColor: Colors.red,
                  ),
                  smallBoxSize, // Width
                  smallBoxSize, // Height
                ),
                SizedBox(height: gapSize),
                _buildActionCard(
                  ActionItem(
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'Activate',
                    iconColor: const Color(0xFFFF6B9D), // Pink
                  ),
                  smallBoxSize, // Width
                  smallBoxSize, // Height
                ),
              ],
            ),
            
            SizedBox(width: gapSize),
            
            // 3. Middle Column 2
            Column(
              children: [
                _buildActionCard(
                  ActionItem(
                    icon: _isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
                    label: _isLoggedIn ? 'Logout' : 'Login',
                    iconColor: _isLoggedIn ? const Color(0xFFFF6B6B) : const Color(0xFF4A9FFF),
                  ),
                  smallBoxSize, // Width
                  smallBoxSize, // Height
                ),
                SizedBox(height: gapSize),
                _buildActionCard(
                  ActionItem(
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'eTag',
                    iconColor: const Color(0xFFFF4444), // Red
                  ),
                  smallBoxSize, // Width
                  smallBoxSize, // Height
                ),
              ],
            ),

            SizedBox(width: gapSize),

            // 4. Right Column (Support - Tall Card)
            _buildActionCard(
              ActionItem(
                icon: Icons.support_agent_rounded,
                label: 'Support',
                useImage: true,
                imagePath: 'assets/icons/whatsapp.png',
                iconColor: const Color(0xFF25D366), // Whatsapp Green
              ),
              smallBoxSize, // Width
              largeBoxSize, // Height (Tall)
            ),
          ],
        ),
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
            const Icon(
              Icons.storefront_rounded,
              size: 42,
              color: Color(0xFFFFB300), // Golden Yellow
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

  // ✅ Renamed and updated to accept width/height separately
  Widget _buildActionCard(ActionItem action, double width, double height) {
    return GestureDetector(
      onTap: () {
        _handleActionTap(action);
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
          mainAxisSize: MainAxisSize.min,
          children: [
            if (action.useImage && action.imagePath != null)
              Image.asset(
                action.imagePath!,
                width: AppConstants.iconSizeGrid,
                height: AppConstants.iconSizeGrid,
                errorBuilder: (context, error, stackTrace) => Icon(
                  action.icon,
                  size: AppConstants.iconSizeGrid,
                  color: action.iconColor ?? AppColors.black,
                ),
              )
            else
              Icon(
                action.icon,
                size: AppConstants.iconSizeGrid,
                color: action.iconColor ?? AppColors.black,
              ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
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

  void _handleActionTap(ActionItem action) {
    switch (action.label) {
      case 'Login':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        break;
      case 'Logout':
        _showLogoutDialog();
        break;
      case 'Demo':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DemoPage()),
        );
        break;
      case 'Activate':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScanPage()),
        );
        break;
      case 'eTag':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const InAppWebViewPage(
              url: 'https://app.ngf132.com/demo-tag',
              title: 'eTag',
            ),
          ),
        );
        break;
      case 'Support':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SupportPage()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${action.label} - Coming Soon')),
        );
    }
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
              if (mounted) {
                Navigator.pop(context);
                setState(() {
                  _isLoggedIn = false;
                });
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MainNavigation()),
                  (route) => false,
                );
              }
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