import 'package:flutter/material.dart';
import 'package:my_new_app/pages/Vehicle/vehicle_details.dart';
import 'package:my_new_app/pages/tags/widgets/announcement_banner.dart';
import 'package:my_new_app/pages/demo/widgets/demo.dart';
import 'package:my_new_app/pages/widgets/media_slider.dart';

import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../../services/tags_service.dart';
import '../widgets/app_header.dart';
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

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Close loading dialog
    if (mounted) {
      Navigator.pop(context);
    }

    // Navigate to vehicle details page
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VehicleDetailsPage(
            vehicleNumber: vehicleNumber.toUpperCase(),
            vehicleType: 'PETROL',
            color: 'RADIANT RED',
            model: 'M. AMAZE 1.2 S MT (I-VTEC)',
            ownerName: 'RAHUL',
            city: 'Uttar Pradesh',
            fitnessDate: '12-Aug-2033',
            make: 'BHARAT STAGE IV',
            makeDetails: 'HONDA CITY',
          ),
        ),
      );
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

                          // ✅ 2. Search Bar is now second
                          SearchVehicleBar(
                            onSearch: _handleVehicleSearch,
                          ),
                          
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MediaSlider(
          // items: [
          //   MediaSliderItem.networkImage(
          //     url: 'https://app.ngf132.com/assets/avator/pro/665886372476144511t71pngpngpng.png',
          //     title: 'Tag Feature 1',
          //   ),
          //   MediaSliderItem.networkImage(
          //     url: 'https://app.ngf132.com/assets/avator/pro/665886372476144511t71pngpngpng.png',
          //     title: 'Tag Feature 2',
          //   ),
          //   MediaSliderItem.networkImage(
          //     url: 'https://app.ngf132.com/assets/avator/pro/665886372476144511t71pngpngpng.png',
          //     title: 'Tag Feature 3',
          //   ),
          // ],

           items: [
          MediaSliderItem.assetImage(
            assetPath: 'assets/Banner/other/1.png', 
            title: 'Tag Feature 1',
          ),
          MediaSliderItem.assetImage(
            assetPath: 'assets/Banner/other/2.png', 
            title: 'Tag Feature 2',
          ),
          MediaSliderItem.assetImage(
            assetPath: 'assets/Banner/other/3.png', 
            title: 'Tag Feature 3',
          ),
        ],
          height: 100,
          autoScroll: true,
          show3DEffect: false,
          viewportFraction: 1.0,
          showIndicators: false,
        ),
      ),
    );
  }
}
