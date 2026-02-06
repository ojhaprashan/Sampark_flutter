import 'package:flutter/material.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';

class TrackOrderPage extends StatefulWidget {
  const TrackOrderPage({super.key});

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  bool _isLoggedIn = false;
  final TextEditingController _orderIdController = TextEditingController();
  final TextEditingController _verificationController = TextEditingController();
  
  // Random math equation
  int _num1 = 0;
  int _num2 = 0;
  int _correctAnswer = 0;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _generateMathEquation();
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    _verificationController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  void _generateMathEquation() {
    setState(() {
      _num1 = 5 + (DateTime.now().millisecond % 10);
      _num2 = 10 + (DateTime.now().second % 15);
      _correctAnswer = _num1 + _num2;
    });
  }

  void _findOrder() {
    if (_orderIdController.text.trim().isEmpty) {
      _showMessage('Please enter your Order ID', isError: true);
      return;
    }

    final userAnswer = int.tryParse(_verificationController.text.trim());
    if (userAnswer == null) {
      _showMessage('Please solve the equation', isError: true);
      return;
    }

    if (userAnswer != _correctAnswer) {
      _showMessage('Incorrect answer. Please try again.', isError: true);
      _generateMathEquation();
      _verificationController.clear();
      return;
    }

    // Success - Show order details (implement your logic here)
    _showMessage('Searching for Order ID: ${_orderIdController.text}');
    // Navigate to order details page or show results
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
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

          // Main content
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

                // White content container
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
                        AppConstants.paddingPage,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Page Title
                          Text(
                            'Track Your Order',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizePageTitle,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Enter your order ID to check the delivery status',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeSubtitle,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingLarge),

                          // Main Card Container
                          Container(
                            padding: const EdgeInsets.all(AppConstants.paddingLarge),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Order ID Input
                                Text(
                                  'Order ID',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizeCardTitle,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _orderIdController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your order ID',
                                    hintStyle: TextStyle(
                                      color: AppColors.textGrey.withOpacity(0.5),
                                      fontSize: AppConstants.fontSizeCardTitle,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.background,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                      borderSide: BorderSide(
                                        color: AppColors.activeYellow,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppConstants.paddingLarge,
                                      vertical: AppConstants.paddingMedium,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.shopping_bag_outlined,
                                      color: AppColors.textGrey,
                                      size: AppConstants.iconSizeLarge,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizeCardTitle,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.spacingLarge),

                                // Verification Math Question
                                Text(
                                  'Verification',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizeCardTitle,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                                  decoration: BoxDecoration(
                                    color: AppColors.activeYellow.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                    border: Border.all(
                                      color: AppColors.activeYellow.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calculate_outlined,
                                        color: AppColors.black,
                                        size: AppConstants.iconSizeGrid,
                                      ),
                                      const SizedBox(width: AppConstants.spacingMedium),
                                      Text(
                                        'Solve: $_num1 + $_num2 = ?',
                                        style: TextStyle(
                                          fontSize: AppConstants.fontSizeCardTitle,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppConstants.spacingMedium),
                                TextField(
                                  controller: _verificationController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your answer',
                                    hintStyle: TextStyle(
                                      color: AppColors.textGrey.withOpacity(0.5),
                                      fontSize: AppConstants.fontSizeCardTitle,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.background,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                      borderSide: BorderSide(
                                        color: AppColors.activeYellow,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppConstants.paddingLarge,
                                      vertical: AppConstants.paddingMedium,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.pin_outlined,
                                      color: AppColors.textGrey,
                                      size: AppConstants.iconSizeLarge,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizeCardTitle,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.spacingLarge),

                                // Find My Order Button
                                SizedBox(
                                  width: double.infinity,
                                  height: AppConstants.buttonHeightMedium,
                                  child: ElevatedButton(
                                    onPressed: _findOrder,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.activeYellow,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Find My Order',
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
                          const SizedBox(height: AppConstants.spacingLarge),

                          // Recent Orders (if logged in)
                          if (_isLoggedIn) ...[
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: AppColors.activeYellow,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Recent Orders',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizeSectionTitle,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    // Navigate to all orders
                                  },
                                  child: Text(
                                    'View All',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeCardTitle,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.spacingMedium),
                            _buildRecentOrderCard(
                              orderId: 'ORD123456',
                              status: 'In Transit',
                              date: 'Jan 15, 2026',
                              statusColor: Colors.orange,
                            ),
                            const SizedBox(height: AppConstants.spacingMedium),
                            _buildRecentOrderCard(
                              orderId: 'ORD123455',
                              status: 'Delivered',
                              date: 'Jan 10, 2026',
                              statusColor: Colors.green,
                            ),
                          ],
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

  Widget _buildRecentOrderCard({
    required String orderId,
    required String status,
    required String date,
    required Color statusColor,
  }) {
    return GestureDetector(
      onTap: () {
        _orderIdController.text = orderId;
      },
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                color: statusColor,
                size: AppConstants.iconSizeGrid,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderId,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeCardTitle,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeCardDescription,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeCardDescription,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
