import 'package:flutter/material.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import 'package:my_new_app/pages/widgets/media_slider.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/shop_service.dart';

class ProductDetailsPage extends StatefulWidget {
  final String? productId;

  const ProductDetailsPage({
    super.key,
    this.productId,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool _isLoggedIn = false;
  int _cartItemCount = 0;
  bool _showAllFeatures = false;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Dynamic data from API
  ProductDetails? _productDetails;
  
  // Variant management
  String _selectedVariantId = '18'; // Default to Bike
  final Map<String, String> _variants = {
    'Car': '17',
    'CA/Doc': '39',
    'Bike': '18',
  };
  
  // Static data (not from API)
  final double _rating = 4.5;
  final int _totalRatings = 1234;
  final int _totalReviews = 456;
  
  // Static images for product slider
  final List<MediaSliderItem> _productImages = [
    MediaSliderItem.assetImage(assetPath: 'assets/Banner/shop/1.png'),
    MediaSliderItem.assetImage(assetPath: 'assets/Banner/shop/2.png'),
    MediaSliderItem.assetImage(assetPath: 'assets/Banner/shop/3.png'),
    MediaSliderItem.assetImage(assetPath: 'assets/Banner/shop/4.png'),
    MediaSliderItem.assetImage(assetPath: 'assets/Banner/shop/5.png'),
    MediaSliderItem.assetImage(assetPath: 'assets/Banner/shop/6.png'),

  ];
  
  final List<String> _staticOffers = [
    'Bank Offer: 10% instant discount on HDFC Bank Credit Cards',
    'Special Price: Get extra 5% off (price inclusive of discount)',
    'No Cost EMI: Avail No Cost EMI on select cards',
    'Partner Offers: Purchase now & get 1 surprise cashback coupon',
  ];
  

  
  final List<SpecItem> _staticSpecs = [
    SpecItem(label: 'Material', value: 'Premium Waterproof PVC'),
    SpecItem(label: 'Size', value: 'Standard (fits all vehicles)'),
    SpecItem(label: 'Warranty', value: '1 Year Replacement'),
  ];
  
  final List<String> _staticFeatures = [
    'Weather resistant and durable',
    'Easy to install and remove',
    'High-quality QR code print',
    'Works in all lighting conditions',
    'Comes with installation guide',
  ];
  
  final List<ReviewItem> _staticReviews = [
    ReviewItem(
      name: 'Pulkit K.',
      rating: 5,
      title: 'Great and responsive Product',
      review: 'Nice and easy to install/setup. People keep asking me where did you get it. Everyone finds it helpful.',
    ),
    ReviewItem(
      name: 'Suresh',
      rating: 5,
      title: 'Sampark is perfect name',
      review: 'Sampark item is very good and useful to car owners. I like this item',
    ),
    ReviewItem(
      name: 'Mahadev Mathapati',
      rating: 4,
      title: 'Value for money.',
      review: 'It helps a lot of parked in non parking lot.',
    ),
    ReviewItem(
      name: 'Manzoor Ahmad',
      rating: 5,
      title: 'Working good',
      review: 'Good',
    ),
    ReviewItem(
      name: 'Suman Roy',
      rating: 3,
      title: 'Good Concept',
      review: 'The complete application lifecycle seems to be still being worked upon. Product concept is GOOD but NOT FINISHED.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedVariantId = widget.productId ?? '18';
    _checkLoginStatus();
    _loadProductDetails();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }
  }

  Future<void> _loadProductDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      const String smValue = '67s87s6yys66';
      const String dgValue = 'testYU78dII8iiUIPSISJ';

      final productDetails = await ShopService.fetchProductDetails(
        productId: _selectedVariantId,
        smValue: smValue,
        dgValue: dgValue,
      );

      if (mounted) {
        setState(() {
          _productDetails = productDetails;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _selectVariant(String variantName) {
    final newVariantId = _variants[variantName];
    if (newVariantId != null && newVariantId != _selectedVariantId) {
      setState(() {
        _selectedVariantId = newVariantId;
      });
      _loadProductDetails();
    }
  }

  String _getSelectedVariantName() {
    return _variants.entries
        .firstWhere(
          (entry) => entry.value == _selectedVariantId,
          orElse: () => MapEntry('Bike', '18'),
        )
        .key;
  }

  void _buyNow() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Proceeding to checkout...'),
        backgroundColor: AppColors.activeYellow,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
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
                AppHeader(
                  isLoggedIn: _isLoggedIn,
                  showBackButton: true,
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
                          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                        ),
                      ),
                    );
                  },
                ),
                
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(
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
                            : _buildProductContent(),
                  ),
                ),
              ],
            ),
          ),
          
          if (!_isLoading && _errorMessage == null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomActionBar(),
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
            const Text(
              'Failed to Load Product',
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
              onPressed: _loadProductDetails,
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

  Widget _buildProductContent() {
    if (_productDetails == null) return const SizedBox();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSlider(),
          _buildProductHeader(),
          const SizedBox(height: 8),
          _buildPriceSection(),
          const SizedBox(height: 12),
          _buildVariantSection(),
          const SizedBox(height: 8),
          _buildOffersSection(),
          const SizedBox(height: 8),
          _buildServicesSection(),
          const SizedBox(height: 8),
          _buildSpecificationsSection(),
          const SizedBox(height: 8),
          _buildReviewsSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildImageSlider() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    MediaSlider(
                      items: _productImages,
                      height: 160,
                      autoScroll: false,
                      show3DEffect: false,
                      viewportFraction: 1.0,
                      showIndicators: true,
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite_border,
                          color: AppColors.black,
                          size: AppConstants.iconSizeMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _productDetails!.name,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeSectionTitle,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingSmall,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Text(
                      '$_rating',
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeCardDescription,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.star,
                      size: AppConstants.fontSizeCardDescription,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$_totalRatings ratings & $_totalReviews reviews',
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeCardDescription,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingPage,
        vertical: AppConstants.paddingMedium,
      ),
      color: AppColors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '₹${_productDetails!.price}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.black,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '₹${_productDetails!.mrp}',
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeCardTitle,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              Text(
                '${_productDetails!.discountPercent}% off',
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeCardTitle,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVariantSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Variant',
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardTitle,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _variants.keys
                .map((variantName) => _buildVariantChip(variantName))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantChip(String variantName) {
    final isSelected = variantName == _getSelectedVariantName();
    
    return GestureDetector(
      onTap: () => _selectVariant(variantName),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.activeYellow : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.activeYellow : AppColors.lightGrey,
            width: 1.5,
          ),
        ),
        child: Text(
          variantName,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeCardDescription,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildOffersSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingPage),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_offer_rounded,
                size: AppConstants.iconSizeMedium + 2,
                color: AppColors.activeYellow,
              ),
              const SizedBox(width: 6),
              const Text(
                'Available Offers',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSectionTitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._staticOffers.map((offer) => _buildOfferItem(offer)),
        ],
      ),
    );
  }

  Widget _buildOfferItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.activeYellow,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingPage),
      // Removed the Column and Title text
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.lightGrey,
            width: 1.5,
          ),
          // ✅ REMOVED boxShadow
        ),
        child: Column(
          children: [
            // Row 1
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildServiceItem(
                    Icons.phone_in_talk,
                    'Masked Audio\nCalls',
                    const Color(0xFF2196F3), // Blue
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildServiceItemWithImage(
                    'assets/icons/whatsapp.png',
                    'WhatsApp\nNotifications',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildServiceItem(
                    Icons.picture_as_pdf,
                    'PDF Tag\n(Offline)',
                    const Color(0xFFE91E63), // Pink
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Row 2
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildServiceItem(
                    Icons.videocam,
                    'Masked Video\nCalls',
                    const Color(0xFF9C27B0), // Purple
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildServiceItem(
                    Icons.phone_callback,
                    'Call Back\nCaller',
                    const Color(0xFF00BCD4), // Cyan
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildServiceItem(
                    Icons.location_on,
                    'Check\nLocation',
                    const Color(0xFF4CAF50), // Green
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Row 3
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildServiceItem(
                    Icons.sms,
                    'Offline SMS\nAvailable',
                    const Color(0xFFFF9800), // Orange
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildServiceItem(
                    Icons.headset_mic,
                    'Live Support\nAlways',
                    const Color(0xFFF44336), // Red
                  ),
                ),
                const SizedBox(width: 16),
                
                // New Service
                Expanded(
                  child: _buildServiceItem(
                    Icons.notification_important_rounded,
                    'Emergency\nAlerts',
                    const Color(0xFFFF5722), // Deep Orange
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String title, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 32,
          color: color,
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            height: 1.3,
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildServiceItemWithImage(String imagePath, String title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          imagePath,
          width: 32,
          height: 32,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.chat_bubble,
              size: 32,
              color: Color(0xFF25D366),
            );
          },
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            height: 1.3,
          ),
          maxLines: 2,
        ),
      ],
    );
  }

Widget _buildSpecificationsSection() {
  // Combine description with static features
  List<String> allFeatures = [];
  
  // Add description as first feature if available
  if (_productDetails!.description.isNotEmpty) {
    allFeatures.add(_productDetails!.description);
  }
  
  // Add static features
  allFeatures.addAll(_staticFeatures);
  
  final featuresToShow = _showAllFeatures 
      ? allFeatures 
      : allFeatures.take(3).toList();
  
  return Container(
    padding: const EdgeInsets.all(AppConstants.paddingPage),
    color: AppColors.white,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Specifications',
          style: TextStyle(
            fontSize: AppConstants.fontSizeSectionTitle,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        ..._staticSpecs.map((spec) => 
          _buildSpecRow(spec.label, spec.value)),
        const SizedBox(height: 12),
        ...featuresToShow.map((feature) => _buildFullLineSpec(feature)),
        
        if (allFeatures.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showAllFeatures = !_showAllFeatures;
                });
              },
              child: Row(
                children: [
                  Text(
                    _showAllFeatures ? 'Show Less' : 'Show More',
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeCardTitle,
                      fontWeight: FontWeight.w700,
                      color: AppColors.activeYellow,
                    ),
                  ),
                  Icon(
                    _showAllFeatures 
                        ? Icons.keyboard_arrow_up 
                        : Icons.keyboard_arrow_down,
                    size: AppConstants.iconSizeMedium,
                    color: AppColors.activeYellow,
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}


  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullLineSpec(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.activeYellow,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingPage),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Customer Reviews',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSectionTitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              // TextButton(
              //   onPressed: () {},
              //   style: TextButton.styleFrom(
              //     padding: EdgeInsets.zero,
              //     minimumSize: Size.zero,
              //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //   ),
              //   child: const Text(
              //     'See All',
              //     style: TextStyle(
              //       fontSize: AppConstants.fontSizeCardTitle,
              //       fontWeight: FontWeight.w600,
              //       color: AppColors.activeYellow,
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 10),
          ..._staticReviews.map((review) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildReviewCard(review),
              )),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewItem review) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.lightGrey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.activeYellow.withOpacity(0.2),
                child: Text(
                  review.name[0],
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeCardDescription,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeCardTitle,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < review.rating ? Icons.star : Icons.star_border,
                          size: AppConstants.fontSizeCardTitle,
                          color: AppColors.activeYellow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.title,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeCardTitle,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            review.review,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeCardTitle,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingPage),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppConstants.buttonHeightMedium,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _buyNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.activeYellow,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'BUY NOW (Cash on Delivery)',
              style: TextStyle(
                fontSize: AppConstants.fontSizeButtonText,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper classes for static data
class SpecItem {
  final String label;
  final String value;
  SpecItem({required this.label, required this.value});
}

class ReviewItem {
  final String name;
  final int rating;
  final String title;
  final String review;
  ReviewItem({
    required this.name,
    required this.rating,
    required this.title,
    required this.review,
  });
}
