import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/location_provider.dart';
import '../../utils/colors.dart';

class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 40,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enable Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                children: [
                  Text(
                    'Location Access Needed',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We need your location to provide better services and help you connect with nearby vehicle owners.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      // Not Now Button
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            try {
                              if (context.mounted) {
                                Navigator.of(context, rootNavigator: true).pop();
                              }
                            } catch (e) {
                              print('⚠️ Could not close dialog: $e');
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: AppColors.lightGrey,
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: Text(
                            'Not Now',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Allow Button
                      Expanded(
                        child: Consumer<LocationProvider>(
                          builder: (context, locationProvider, _) {
                            // Check if there's an error about location services
                            final isLocationServiceDisabled = 
                                locationProvider.locationError?.contains('Location services are disabled') ?? false;
                            
                            return ElevatedButton(
                                  onPressed: isLocationServiceDisabled
                                  ? () async {
                                      try {
                                        if (context.mounted) {
                                          Navigator.of(context, rootNavigator: true).pop();
                                        }
                                      } catch (e) {
                                        print('⚠️ Could not close dialog: $e');
                                      }
                                      // Open location settings
                                      await Geolocator.openLocationSettings();
                                    }
                                  : () async {
                                      await locationProvider
                                          .requestLocationPermission();
                                      if (context.mounted) {
                                        try {
                                          Navigator.of(context, rootNavigator: true).pop();
                                        } catch (e) {
                                          print('⚠️ Could not close dialog: $e');
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.activeYellow,
                                foregroundColor: AppColors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isLocationServiceDisabled
                                        ? Icons.settings
                                        : Icons.check_circle_rounded,
                                    size: 18,
                                    color: AppColors.black,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isLocationServiceDisabled
                                        ? 'Enable in Settings'
                                        : 'Allow',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LocationPermissionDialog(),
    );
  }
}
