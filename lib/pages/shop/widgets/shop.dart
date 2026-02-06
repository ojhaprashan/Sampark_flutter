import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/shop_service.dart';
import '../../widgets/app_header.dart';
import 'product_details_page.dart';

class ShopPage extends StatefulWidget {
  final bool showBackButton;

  const ShopPage({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  bool _isLoggedIn = false;
  int _cartItemCount = 0;
  List<ShopProductUI> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

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
        _isLoggedIn = loggedIn;
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      const String smValue = '67s87s6yys66';
      const String dgValue = 'testYU78dII8iiUIPSISJ';

      final shopProducts = await ShopService.fetchProducts(
        smValue: smValue,
        dgValue: dgValue,
      );

      if (mounted) {
        setState(() {
          _products = shopProducts
              .map((product) => ShopProductUI.fromShopProduct(product))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _addToCart() {
    setState(() {
      _cartItemCount++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item added to cart!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
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
                  showBackButton: widget.showBackButton,
                  showUserInfo: false,
                  showCartIcon: true,
                  cartItemCount: _cartItemCount,
                  onCartTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cart: $_cartItemCount items'),
                        backgroundColor: AppColors.activeYellow,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),

                // White content container
                Expanded(
                  // ClipRRect ensures content scrolls BEHIND the curve
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.activeYellow,
                              ),
                            )
                          : _errorMessage != null
                              ? _buildErrorWidget()
                              : _buildProductsView(context),
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

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            Text(
              'Failed to Load Products',
              style: TextStyle(
                fontSize: AppConstants.fontSizeSectionTitle,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: const TextStyle(
                fontSize: AppConstants.fontSizeCardDescription,
                color: AppColors.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.activeYellow,
                foregroundColor: AppColors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.buttonBorderRadius,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsView(BuildContext context) {
    if (_products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: AppColors.activeYellow,
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              Text(
                'No Products Available',
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

    // =========================================================
    // ✅ FINAL FIXED HEIGHT CALCULATION
    // =========================================================
    
    // 1. Get exact screen width
    double screenWidth = MediaQuery.of(context).size.width;
    
    // 2. Calculate the available width for one card
    // (Screen - Side Padding - Grid Spacing) / 2
    double itemWidth = (screenWidth - (AppConstants.paddingLarge * 2) - 10) / 2;

    // 3. ✅ THE FIX: Reduced target height from 200.0 to 182.0
    // This removes the 18px-20px gap you were seeing.
    double desiredItemHeight = 182.0; 

    // 4. Calculate aspect ratio
    double childAspectRatio = itemWidth / desiredItemHeight;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.paddingLarge),

            // Section Title
            Row(
              children: [
                Text(
                  'Featured Products',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSectionTitle,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.activeYellow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_products.length}',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSmallText,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMedium),

            // Product Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                // ✅ Using the calculated ratio to keep height strictly 182px
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                return _buildProductCard(_products[index]);
              },
            ),
            const SizedBox(height: AppConstants.paddingPage),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ShopProductUI product) {
    return GestureDetector(
      onTap: () {
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
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, 
          children: [
            // 1. Product Image (90px)
            Stack(
              children: [
                Container(
                  height: 90, 
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.borderRadiusCard),
                      topRight: Radius.circular(AppConstants.borderRadiusCard),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.borderRadiusCard),
                      topRight: Radius.circular(AppConstants.borderRadiusCard),
                    ),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                if (product.discountPercent > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${product.discountPercent}%',
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // 2. Product Content - Tight Padding
            Padding(
              padding: const EdgeInsets.all(6), // 6px Padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeCardTitle,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                      height: 1.1,
                    ),
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 2),

                  // Description
                  Text(
                    product.shortTitle,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeCardDescription,
                      color: AppColors.textGrey,
                      height: 1.1,
                    ),
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Price Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${product.price}',
                        style: const TextStyle(
                          fontSize: AppConstants.fontSizeButtonPriceText,
                          fontWeight: FontWeight.w900,
                          color: AppColors.black,
                          height: 1.0, 
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (product.mrp > product.price)
                        Text(
                          '₹${product.mrp}',
                          style: const TextStyle(
                            fontSize: AppConstants.fontSizeSmallText,
                            color: AppColors.textGrey,
                            decoration: TextDecoration.lineThrough,
                            height: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

// UI Model for ShopProductUI
class ShopProductUI {
  final int id;
  final String name;
  final String shortTitle;
  final int price;
  final int mrp;
  final String imageUrl;
  final String productUrl;
  final bool isInCart;

  ShopProductUI({
    required this.id,
    required this.name,
    required this.shortTitle,
    required this.price,
    required this.mrp,
    required this.imageUrl,
    required this.productUrl,
    required this.isInCart,
  });

  factory ShopProductUI.fromShopProduct(ShopProduct product) {
    return ShopProductUI(
      id: product.id,
      name: product.name,
      shortTitle: product.shortTitle,
      price: product.price,
      mrp: product.mrp,
      imageUrl: product.imageUrl,
      productUrl: product.productUrl,
      isInCart: product.isInCart,
    );
  }

  int get discountPercent {
    if (mrp <= 0) return 0;
    return (((mrp - price) / mrp) * 100).toInt();
  }
}