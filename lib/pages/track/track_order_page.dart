import 'package:flutter/material.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../../services/order_tracking_service.dart';

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

  // Track order states
  bool _isSearching = false;
  OrderItem? _foundOrder;
  List<OrderItem> _recentOrders = [];
  bool _isLoadingRecentOrders = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _generateMathEquation();
    _loadRecentOrders();
  }

  Future<void> _loadRecentOrders() async {
    if (!_isLoggedIn) return;

    setState(() {
      _isLoadingRecentOrders = true;
    });

    try {
      final response = await OrderTrackingService.fetchOrderDetails(orderId: '');
      if (mounted) {
        setState(() {
          _recentOrders = response.recentOrders;
          _isLoadingRecentOrders = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRecentOrders = false;
        });
      }
      print('Error loading recent orders: $e');
    }
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

  void _findOrder() async {
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

    setState(() {
      _isSearching = true;
      _foundOrder = null;
    });

    try {
      final orderId = _orderIdController.text.trim();
      final response = await OrderTrackingService.fetchOrderDetails(
        orderId: orderId,
      );

      if (mounted) {
        if (response.orderDetails != null) {
          setState(() {
            _foundOrder = response.orderDetails;
            _isSearching = false;
          });
          _showMessage('Order found successfully!');
        } else {
          _showMessage('Order not found. Please check your Order ID.', isError: true);
          setState(() {
            _isSearching = false;
          });
        }
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }

      _showMessage(errorMessage, isError: true);
      setState(() {
        _isSearching = false;
      });
    }
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showMessage('Could not open tracking URL', isError: true);
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

                          // Main Search Card Container
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

                                // Verification
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
                                    onPressed: _isSearching ? null : _findOrder,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.activeYellow,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                      ),
                                      elevation: 0,
                                      disabledBackgroundColor: AppColors.activeYellow.withOpacity(0.5),
                                    ),
                                    child: _isSearching
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation(AppColors.black),
                                            ),
                                          )
                                        : Text(
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

                          // ✅ Display Found Order Details (AFTER search form, BEFORE recent orders)
                          if (_foundOrder != null) ...[
                            const SizedBox(height: AppConstants.spacingLarge),
                            _buildOrderDetailsCard(_foundOrder!),
                          ],

                          // Recent Orders Section
                          // FIXED: Only show recent orders if NO search result is currently displayed
                          if (_isLoggedIn && _foundOrder == null) ...[
                            const SizedBox(height: AppConstants.spacingLarge),
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

                            // Show loading or recent orders
                            if (_isLoadingRecentOrders)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(AppColors.activeYellow),
                                  ),
                                ),
                              )
                            else if (_recentOrders.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                                  child: Text(
                                    'No recent orders',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeCardTitle,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ..._recentOrders.take(2).map((order) {
                                final statusColor = OrderTrackingService.getStatusColor(order.statusColor);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
                                  child: _buildRecentOrderCard(
                                    order: order,
                                    statusColor: statusColor,
                                  ),
                                );
                              }).toList(),
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

  // Order Details Card
  Widget _buildOrderDetailsCard(OrderItem order) {
    final statusColor = OrderTrackingService.getStatusColor(order.statusColor);

    return Container(
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
          // Header with Order ID and Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSectionTitle,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.orderId,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeCardDescription,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // ADDED: Close button to dismiss the search result
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _foundOrder = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 20, color: AppColors.black),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // Status Message Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.activeYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.activeYellow.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange.shade700,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    order.statusMessage,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeCardDescription,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.paddingLarge),

          // Customer & Order Info
          _buildInfoRow(Icons.person_outline, 'Customer', order.name),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.shopping_bag_outlined, 'Items', order.qtyShow),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.currency_rupee, 'Amount', '₹${order.amount.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.payment_outlined, 'Payment', order.cod ? 'Prepaid' : 'COD'),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.calendar_today_outlined, 'Order Date', _formatDate(order.orderDate)),

          const SizedBox(height: AppConstants.paddingLarge),

          // Shipping Details Section
          Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: AppColors.black,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Shipping Details',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeCardTitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.address,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardDescription,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.city}, ${order.state} - ${order.pin}',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardDescription,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                if (order.courierName != null && order.courierName!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Courier: ',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeCardDescription,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey,
                        ),
                      ),
                      Text(
                        order.courierName!,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeCardDescription,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Track Button
          if (order.trackUrl != null && order.trackUrl!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingLarge),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl(order.trackUrl!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.activeYellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                  ),
                  elevation: 0,
                ),
                icon: Icon(
                  Icons.open_in_new,
                  color: AppColors.black,
                  size: 18,
                ),
                label: Text(
                  'Track on ${order.courierName ?? "Courier"} Website',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardTitle,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.textGrey,
          size: 16,
        ),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: AppConstants.fontSizeCardDescription,
            fontWeight: FontWeight.w500,
            color: AppColors.textGrey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardDescription,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      // Parse: "2026-02-12 12:09:35"
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildRecentOrderCard({
    required OrderItem order,
    required Color statusColor,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _orderIdController.text = order.orderId;
          _foundOrder = null; // Clear previous search result
        });
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
                    order.orderId,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeCardTitle,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatDate(order.orderDate),
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
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                order.status,
                style: TextStyle(
                  fontSize: 11,
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