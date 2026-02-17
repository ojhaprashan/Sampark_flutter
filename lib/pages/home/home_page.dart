import 'package:flutter/material.dart';
import 'package:my_new_app/pages/Vehicle/vehicle_details.dart';
import '../../utils/colors.dart';
import '../../services/auth_service.dart';
import '../../services/vehicle_search_service.dart';
import '../widgets/app_header.dart';
import '../widgets/vehicle_search_agreement_sheet.dart';
import '../widgets/error_dialog.dart';
import '../AppWebView/appweb.dart';
import 'widgets/safety_carousel.dart';
import 'widgets/search_contact_bar.dart';
import 'widgets/action_grid.dart';
import 'widgets/features_section.dart';
import '../../utils/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  bool isLoggedIn = false;
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

      // Fetch user data to get country code
      if (loggedIn) {
        final userData = await AuthService.getUserData();
        final countryCode = userData['countryCode'] as String? ?? '+91';
        if (mounted) {
          setState(() {
            _countryCode = countryCode;
          });
        }
      }
    }
  }

  // ✅ Handle vehicle search with terms and conditions
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
          // Yellow background that extends down
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

              // Scrollable Content with curved top
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: Container(
                    color: AppColors.background,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 8), 
                          const SafetyCarousel(),
                          const SizedBox(height: 10), // Reduced from 16
                          // ✅ Only show search bar if country code is India
                          if (_countryCode == '+91')
                            SearchContactBar(
                              onSearch: _handleVehicleSearch, // ✅ Added callback
                            ),
                          if (_countryCode == '+91')
                            const SizedBox(height: 12), // Reduced from 16
                          ActionGrid(key: ValueKey(isLoggedIn)),
                          const SizedBox(height: 12), // Reduced from 20
                          const FeaturesSection(),
                          const SizedBox(height: 90), // Keep for bottom navigation
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
}
