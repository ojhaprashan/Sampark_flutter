import 'package:flutter/material.dart';
import 'package:my_new_app/pages/Vehicle/vehicle_details.dart';
import 'package:my_new_app/pages/tags/widgets/announcement_banner.dart';
import 'package:my_new_app/pages/demo/widgets/demo.dart';
import 'package:my_new_app/pages/widgets/media_slider.dart';

import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../../services/tags_service.dart';
import '../../services/vehicle_search_service.dart';
import '../widgets/app_header.dart';
import '../widgets/vehicle_search_agreement_sheet.dart';
import '../widgets/error_dialog.dart';
import '../AppWebView/appweb.dart';
import 'widgets/search_vehicle_bar.dart';
import 'widgets/tag_grid.dart';

class TagsPage extends StatefulWidget {
  const TagsPage({super.key});

  @override
  State<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> with AutomaticKeepAliveClientMixin {
  bool isLoggedIn = false;
  UserTagsStats? userTagsStats;
  bool _isLoadingTags = true;
  String? _errorMessage;
  String _countryCode = '+91'; // Default to India

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (mounted) {
      setState(() {
        isLoggedIn = loggedIn;
      });
      
      if (loggedIn) {
        // Fetch user data to get country code
        final userData = await AuthService.getUserData();
        final countryCode = userData['countryCode'] as String? ?? '+91';
        if (mounted) {
          setState(() {
            _countryCode = countryCode;
          });
        }
        
        _loadUserTags();
      }
    }
  }

  Future<void> _loadUserTags() async {
    try {
      setState(() {
        _isLoadingTags = true;
        _errorMessage = null;
      });

      final userData = await AuthService.getUserData();
      final phone = userData['phone'] ?? '';

      if (phone.isEmpty) {
        throw Exception('Phone number not found');
      }

      // Replace these with actual values from your auth/config
      const String smValue = '67s87s6yys66'; // Replace with actual value
      const String dgValue = 'testYU78dII8iiUIPSISJ'; // Replace with actual value
 
 print('📞 Fetching tags for phone: $phone');
      final tags = await TagsService.fetchUserTags(
        phone: phone,
        smValue: smValue,
        dgValue: dgValue,
      );

      if (mounted) {
        setState(() {
          userTagsStats = tags;
          _isLoadingTags = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingTags = false;
        });
      }
    }
  }

  Future<void> _handleVehicleSearch(String vehicleNumber) async {
    if (vehicleNumber.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a vehicle number'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
        ),
      );
      return;
    }

    // ✅ Get phone number from local storage
    final userData = await AuthService.getUserData();
    final phoneNumber = userData['phone'] as String? ?? '';

    // ✅ Show Agreement Bottom Sheet
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) => VehicleSearchAgreementSheet(
          vehicleNumber: vehicleNumber.toUpperCase(),
          phoneNumber: phoneNumber,
          onCancel: () {
            // User cancelled
          },
          onAgree: () {
            _performVehicleSearch(vehicleNumber, phoneNumber);
          },
        ),
      );
    }
  }

  // ✅ Perform the actual vehicle search
  Future<void> _performVehicleSearch(String vehicleNumber, String phoneNumber) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.activeYellow,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Searching vehicle...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      final response = await VehicleSearchService.searchVehicle(
        plate: vehicleNumber.toUpperCase(),
        phone: phoneNumber, // ✅ Pass phone number
      );

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // ✅ Check if tag_found is false - show error dialog with API message
      if (!response.data.tagFound) {
        if (mounted) {
          ErrorDialog.show(
            context: context,
            title: 'Vehicle Not Found',
            message: response.data.message.isNotEmpty 
                ? response.data.message 
                : 'Vehicle not found in RTO or data is private.',
            onRetry: () {
              _performVehicleSearch(vehicleNumber, phoneNumber);
            },
            onCreateTag: () {
              // Navigate to demo tag page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InAppWebViewPage(
                    url: 'https://app.ngf132.com/demo-tag',
                    title: 'Create Demo Tag',
                  ),
                ),
              );
            },
          );
        }
        return;
      }

      // Navigate to vehicle details page with API data
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VehicleDetailsPage(
              vehicleNumber: vehicleNumber.toUpperCase(),
              vehicleData: response.data,
              tagId: response.data.tagId,
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Show error message using common error dialog
      if (mounted) {
        ErrorDialog.show(
          context: context,
          title: 'Vehicle Search Failed',
          message: e.toString().replaceFirst('Exception: ', ''),
          onRetry: () {
            _performVehicleSearch(vehicleNumber, phoneNumber);
          },
          onCreateTag: () {
            // Navigate to demo tag page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InAppWebViewPage(
                  url: 'https://app.ngf132.com/demo-tag',
                  title: 'Create Demo Tag',
                ),
              ),
            );
          },
        );
      }
    }
  }

 @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Yellow background
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

          // Content with curve
          Column(
            children: [
              // Header space
              SafeArea(
                bottom: false,
                child: AppHeader(
                  key: ValueKey(isLoggedIn),
                  isLoggedIn: isLoggedIn,
                ),
              ),

              // Scrollable Content
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: Container(
                    color: AppColors.background,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 1), // Top spacing

                          // ✅ 1. Slider Moved to Top
                          _buildImageSlider(),

                          const SizedBox(height: 1), // Spacing below slider

                          // ✅ 2. Search Bar is now second (only for India)
                          if (_countryCode == '+91')
                            SearchVehicleBar(
                              onSearch: _handleVehicleSearch,
                            ),
                          
                          if (_countryCode == '+91')
                            const SizedBox(height: 12),
                          
                          // Title with YouTube Icon and Description
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.paddingPage,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tags Management',
                                      style: TextStyle(
                                        fontSize: AppConstants.fontSizePageTitle,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const DemoPage(),
                                          ),
                                        );
                                      },
                                      child: Image.asset(
                                        'assets/icons/youtube.png',
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 6),
                                
                                // Description text
                                Text(
                                  'Manage all your tags from here for a complete overview.',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizeSubtitle,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textGrey,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Tag Grid
                          TagGrid(
                            tagStats: userTagsStats,
                            isLoading: _isLoadingTags,
                            errorMessage: _errorMessage,
                            onRetry: _loadUserTags,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Membership Announcement
                          MembershipAnnouncement(
                            onDismiss: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Announcement dismissed'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.buttonBorderRadius,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 90), // Bottom padding for navigation
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Image Slider styled like Product Details Page
 Widget _buildImageSlider() {
  // 1. Get screen width
  double screenWidth = MediaQuery.of(context).size.width;

  // 2. Define "little space" (Optional: set to 0.0 if you want edge-to-edge)
  double sidePadding = 0.0;

  // 3. Calculate Width
  double sliderWidth = screenWidth - (sidePadding * 2);

  // 4. Calculate Height dynamically (Ratio 3.6 makes it a thin banner)
  // Lower number = Taller banner. Higher number = Thinner banner.
  double sliderHeight = sliderWidth / 3.6; 

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: sidePadding),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: MediaSlider(
        // ✅ Fix 1: Height is calculated based on phone width
        height: sliderHeight, 
        
      items: [
          MediaSliderItem.networkImage(
            url: 'https://sampark.me/assets/app/profile_1.png',
            title: 'Tag Feature 1',
            boxFit: BoxFit.fill, 
          ),
          MediaSliderItem.networkImage(
            url: 'https://sampark.me/assets/app/profile_2.png', 
            title: 'Tag Feature 2',
            boxFit: BoxFit.fill,
          ),
          MediaSliderItem.networkImage(
            url: 'https://sampark.me/assets/app/profile_3.png', 
            title: 'Tag Feature 3',
            boxFit: BoxFit.fill,
          ),
        ],
        autoScroll: true,
        show3DEffect: false,
        viewportFraction: 1.0, 
        showIndicators: false,
      ),
    ),
  );
}
}
