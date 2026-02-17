import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../widgets/app_header.dart'; 
import '../../../services/auth_service.dart';
// Import your shop service file
import '../../../services/shop_service.dart';
import 'product_details_page.dart'; 

class ShopPage extends StatefulWidget {
  const ShopPage({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  bool isLoggedIn = false;
  bool _isLoading = true;
  String? _errorMessage; // To store error messages
  List<ShopProduct> _products = [];
  double _scale = 1.0; // For responsive design

  // Credentials
  final String _smValue = '67s87s6yys66';
  final String _dgValue = 'testYU78dII8iiUIPSISJ';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadProducts();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (mounted) {
      setState(() {
        isLoggedIn = loggedIn;
      });
    }
  }

  // ✅ Updated to use Real API
  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null; // Clear previous errors
      });

      // Call the API
      final products = await ShopService.fetchProducts(
        smValue: _smValue,
        dgValue: _dgValue,
      );

      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading products: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate Scale based on standard width (375.0)
    _scale = MediaQuery.of(context).size.width / 375.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
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

          // 2. Content
          Column(
            children: [
              // Header
              SafeArea(
                bottom: false,
                child: AppHeader(
                  key: ValueKey(isLoggedIn),
                  isLoggedIn: isLoggedIn,
                  showUserInfo: false, 
                  showBackButton: widget.showBackButton,
                ),
              ),

              // Scrollable Content
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30 * _scale),
                    topRight: Radius.circular(30 * _scale),
                  ),
                  child: Container(
                    color: AppColors.background,
                    child: _buildBodyContent(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Helper to switch between Loading, Error, and Grid
  Widget _buildBodyContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryYellow,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProducts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return const Center(child: Text("No products available"));
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 16 * _scale,
        right: 16 * _scale,
        top: 20 * _scale,
        bottom: 90 * _scale,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65, 
        crossAxisSpacing: 12 * _scale,
        mainAxisSpacing: 12 * _scale,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_products[index]);
      },
    );
  }

  Widget _buildProductCard(ShopProduct product) {
    int discount = 0;
    if (product.mrp > 0) {
      discount = (((product.mrp - product.price) / product.mrp) * 100).round();
    }

    return GestureDetector(
      onTap: () {
        // Navigate to product details page with product ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              productId: product.id.toString(),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12 * _scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8 * _scale,
              offset: Offset(0, 4 * _scale),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8.0 * _scale),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12 * _scale),
                      ),
                    ),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain, 
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                  ),
                  
                  // Discount Tag
                  if (discount > 0)
                    Positioned(
                      top: 8 * _scale,
                      left: 8 * _scale,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6 * _scale, 
                          vertical: 2 * _scale
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4 * _scale),
                        ),
                        child: Text(
                          '$discount% OFF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10 * _scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: EdgeInsets.all(10.0 * _scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13 * _scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                      height: 1.2,
                    ),
                  ),
                  
                  SizedBox(height: 4 * _scale),

                  // Short Title
                  Text(
                    product.shortTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11 * _scale,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey,
                      height: 1.2,
                    ),
                  ),

                  SizedBox(height: 8 * _scale),

                  // Price Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Current Price
                      Text(
                        '₹${product.price}',
                        style: TextStyle(
                          fontSize: 16 * _scale,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(width: 6 * _scale),
                      // MRP (Strikethrough)
                      if (product.mrp > product.price)
                        Padding(
                          padding: EdgeInsets.only(bottom: 2 * _scale),
                          child: Text(
                            '₹${product.mrp}',
                            style: TextStyle(
                              fontSize: 12 * _scale,
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}