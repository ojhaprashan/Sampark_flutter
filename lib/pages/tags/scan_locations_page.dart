import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_new_app/utils/colors.dart';
import 'package:my_new_app/utils/constants.dart';
import 'package:my_new_app/services/scan_location_service.dart';
import 'package:my_new_app/pages/widgets/app_header.dart';
import 'package:my_new_app/pages/tags/widgets/scan_locations_skeleton.dart';

class ScanLocationsPage extends StatefulWidget {
  final int tagId;
  final String phoneWithCountryCode;
  final String tagName;

  const ScanLocationsPage({
    super.key,
    required this.tagId,
    required this.phoneWithCountryCode,
    required this.tagName,
  });

  @override
  State<ScanLocationsPage> createState() => _ScanLocationsPageState();
}

class _ScanLocationsPageState extends State<ScanLocationsPage> {
  late Future<ScanLocationsResponse> _scanLocationsFuture;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _scanLocationsFuture = ScanLocationService.fetchScanLocations(
      phoneWithCountryCode: widget.phoneWithCountryCode,
      tagId: widget.tagId,
    );
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Check if user is logged in (optional, for header display)
    setState(() {
      _isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // ✅ Yellow gradient background
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
          // ✅ Header and curved content
          Column(
            children: [
              // Header
              SafeArea(
                bottom: false,
                child: AppHeader(
                  isLoggedIn: _isLoggedIn,
                  showBackButton: true,
                  showUserInfo: false,
                  showCartIcon: false,
                ),
              ),
              // Curved white container
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
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
                        // Scrollable content
                        Expanded(
                          child: FutureBuilder<ScanLocationsResponse>(
                            future: _scanLocationsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const ScanLocationsSkeleton(itemCount: 5);
                              } else if (snapshot.hasError) {
                                return _buildErrorScreen(snapshot.error.toString());
                              } else if (!snapshot.hasData || snapshot.data!.locations.isEmpty) {
                                return _buildEmptyScreen();
                              }

                              final response = snapshot.data!;
                              return _buildLocationsList(response);
                            },
                          ),
                        ),
                      ],
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

  // ========================
  // UI BUILDERS
  // ========================

  Widget _buildErrorScreen(String error) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.shade600,
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            'Failed to load scan locations',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            error,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textGrey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          GestureDetector(
            onTap: () {
              setState(() {
                _scanLocationsFuture = ScanLocationService.fetchScanLocations(
                  phoneWithCountryCode: widget.phoneWithCountryCode,
                  tagId: widget.tagId,
                );
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
                vertical: AppConstants.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryYellow,
                borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 48,
            color: AppColors.textGrey,
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            'No scan locations found',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            'This tag hasn\'t been scanned yet',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsList(ScanLocationsResponse response) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
          vertical: AppConstants.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(AppConstants.cardPaddingMedium),
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withOpacity(0.1),
                border: Border.all(
                  color: AppColors.primaryYellow.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primaryYellow,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.spacingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tagName,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Total scans: ${response.count}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            // Locations List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: response.locations.length,
              itemBuilder: (context, index) {
                final location = response.locations[index];
                final isLast = index == response.locations.length - 1;
                
                return Column(
                  children: [
                    _buildLocationCard(location, index + 1, response.locations.length),
                    if (!isLast)
                      const SizedBox(height: AppConstants.spacingMedium),
                  ],
                );
              },
            ),
            const SizedBox(height: AppConstants.spacingMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(ScanLocation location, int index, int total) {
    // Parse the datetime
    DateTime? dateTime;
    try {
      dateTime = DateTime.parse(location.time);
    } catch (e) {
      print('Error parsing date: $e');
    }

    // Format the time
    String formattedTime = 'Unknown';
    if (dateTime != null) {
      formattedTime = _formatDateTime(dateTime);
    }

    return GestureDetector(
      onTap: () => _openLocation(location),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.cardPaddingMedium),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          border: Border.all(
            color: AppColors.lightGrey,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with index and timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.textGrey,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            // Time
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            // Coordinates
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.red.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(
                                text: '${location.latitude}, ${location.longitude}',
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Coordinates copied to clipboard'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Text(
                            '${location.latitude}, ${location.longitude}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            // Open Map Button
            GestureDetector(
              onTap: () => _openLocation(location),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 16,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Open in Google Maps',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================
  // HELPERS
  // ========================

  Future<void> _openLocation(ScanLocation location) async {
    try {
      HapticFeedback.mediumImpact();
      if (await canLaunchUrl(Uri.parse(location.mapsUrl))) {
        await launchUrl(
          Uri.parse(location.mapsUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open Google Maps'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('Error opening location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ========================
  // DATE FORMATTING HELPER
  // ========================

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final month = months[dateTime.month - 1];
    final day = dateTime.day.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final displayHour = (dateTime.hour % 12).toString().padLeft(2, '0');
    
    return '$day $month $year, $displayHour:$minute $period';
  }
}
