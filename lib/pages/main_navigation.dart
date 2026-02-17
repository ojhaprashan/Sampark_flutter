import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_new_app/pages/more/more_page.dart';
import '../utils/colors.dart';
import '../services/auth_service.dart';
import '../providers/location_provider.dart';
import 'home/home_page.dart';
import 'tags/tags_page.dart';
import 'shop/widgets/shop.dart';
import 'scan/scan_page.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigation({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isLoggedIn = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _currentIndex = widget.initialIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  List<Widget> get _pages => _isLoggedIn
      ? [
          const HomePage(),
          const ScanPage(),
          const TagsPage(),
          const ShopPage(),
          const MorePage(),
        ]
      : [
          const HomePage(),
          const ScanPage(),
          const ShopPage(),
          const MorePage(),
        ];

  List<NavItem> get _navItems => _isLoggedIn
      ? [
          NavItem(icon: Icons.home_rounded, label: 'Home', isEnabled: true),
          NavItem(icon: Icons.qr_code_scanner_rounded, label: 'Scan', isEnabled: true),
          NavItem(icon: Icons.loyalty_rounded, label: 'Tags', isEnabled: true),
          NavItem(icon: Icons.storefront_rounded, label: 'Shop', isEnabled: true),
          NavItem(icon: Icons.more_horiz_rounded, label: 'More', isEnabled: true),
        ]
      : [
          NavItem(icon: Icons.home_rounded, label: 'Home', isEnabled: true),
          NavItem(icon: Icons.qr_code_scanner_rounded, label: 'Scan', isEnabled: true),
          NavItem(icon: Icons.storefront_rounded, label: 'Shop', isEnabled: true),
          NavItem(icon: Icons.more_horiz_rounded, label: 'More', isEnabled: true),
        ];

  void _onItemTapped(int index, bool isEnabled) {
    if (!isEnabled) return;
    _animationController.forward(from: 0.0);
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      extendBody: true,
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildFloatingNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.activeYellow.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (index) => _buildNavItem(
                _navItems[index],
                index,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavItem item, int index) {
    final isActive = _currentIndex == index;
    final isEnabled = item.isEnabled;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index, isEnabled),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.activeYellow
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isActive ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Icon(
                  item.icon,
                  color: isActive
                      ? AppColors.black
                      : isEnabled
                          ? AppColors.textGrey
                          : AppColors.textGrey.withOpacity(0.4),
                  size: 24,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: isActive ? 11 : 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? AppColors.black
                      : isEnabled
                          ? AppColors.textGrey
                          : AppColors.textGrey.withOpacity(0.4),
                  height: 1.1,
                ),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final bool isEnabled;

  NavItem({
    required this.icon,
    required this.label,
    required this.isEnabled,
  });
}

// MorePage placeholder
