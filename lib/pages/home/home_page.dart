import 'package:flutter/material.dart';
import 'package:my_new_app/pages/Vehicle/vehicle_details.dart';
import '../../utils/colors.dart';
import '../../services/auth_service.dart';
import '../widgets/app_header.dart';
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
    }
  }

  // ✅ Handle vehicle search
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

    // Simulate API call (replace with your actual API call)
    await Future.delayed(const Duration(seconds: 2));

    // Close loading dialog
    if (mounted) {
      Navigator.pop(context);
    }

    // Navigate to vehicle details page
    // TODO: Replace with actual API data
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
                          const SizedBox(height: 1), 
                          const SafetyCarousel(),
                          const SizedBox(height: 10), // Reduced from 16
                          SearchContactBar(
                            onSearch: _handleVehicleSearch, // ✅ Added callback
                          ),
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
