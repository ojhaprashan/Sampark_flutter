import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../../services/vehicle_profile_service.dart';
import '../main_navigation.dart';

class VehicleDetailsPage extends StatefulWidget {
  // ✅ 1. Flag to determine source
  final bool isFromSignup;

  const VehicleDetailsPage({
    super.key,
    this.isFromSignup = false, // Defaults to false (from Home)
  });

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  final _vehicleTypeController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  List<Map<String, String>> _vehicles = [];
  bool _isLoading = false;

  final List<String> _vehicleTypes = [
    'Car',
    'Bike',
    'Scooter',
    'Auto Rickshaw',
    'Truck',
    'Bus',
    'Bicycle',
    'E-Scooter',
  ];

  String? _selectedVehicleType;

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }

  void _addVehicle() {
    if (_vehicleTypeController.text.isEmpty ||
        _vehicleNumberController.text.isEmpty) {
      _showSnackBar('Please fill in all fields', Colors.red);
      return;
    }

    if (_vehicleNumberController.text.length < 4) {
      _showSnackBar('Please enter a valid vehicle number', Colors.red);
      return;
    }

    setState(() {
      _vehicles.add({
        'type': _vehicleTypeController.text.trim(),
        'number': _vehicleNumberController.text.trim().toUpperCase(),
      });
      _vehicleTypeController.clear();
      _vehicleNumberController.clear();
      _selectedVehicleType = null;
    });
    _showSnackBar('Vehicle added successfully', Colors.green);
  }

  void _removeVehicle(int index) {
    setState(() {
      _vehicles.removeAt(index);
    });
    _showSnackBar('Vehicle removed', Colors.orange);
  }

  // ✅ 2. Handle Skip Action
  void _handleSkip() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MainNavigation(initialIndex: 2),
      ),
      (route) => false,
    );
  }

  Future<void> _handleSubmit() async {
    // If from Home (Settings) and list is empty, block submission
    if (!widget.isFromSignup && _vehicles.isEmpty) {
      _showSnackBar('Please add at least one vehicle', Colors.red);
      return;
    }

    // If from Signup and list is empty, treat as Skip
    if (widget.isFromSignup && _vehicles.isEmpty) {
      _handleSkip();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get user phone number from local storage
      final userData = await AuthService.getUserData();
      final userPhone = userData['phone'] as String? ?? '';

      if (userPhone.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar('Error: User phone number not found', Colors.red);
        }
        return;
      }

      if (_vehicles.isNotEmpty) {
        // First, save vehicles locally using AuthService
        for (final vehicle in _vehicles) {
          if (vehicle['type']!.isNotEmpty && vehicle['number']!.isNotEmpty) {
            await AuthService.addVehicle(
              type: vehicle['type']!,
              number: vehicle['number']!,
            );
          }
        }
        await Future.delayed(const Duration(milliseconds: 500));

        // Then, send vehicles to API with proper format (type abbreviation)
        final vehiclesForApi = _vehicles.map((vehicle) {
          // Map vehicle types to API format
          final typeAbbr = _getVehicleTypeAbbreviation(vehicle['type']!);
          return {
            'type': typeAbbr,
            'no': vehicle['number'] ?? '',
          };
        }).toList();

        // Call API to add vehicles to profile
        await VehicleProfileService.addProfileVehicles(
          phone: userPhone,
          vehicles: vehiclesForApi,
        );
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (widget.isFromSignup) {
          // Navigate to Home
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const MainNavigation(initialIndex: 2),
            ),
            (route) => false,
          );
        } else {
          // Go back to previous screen
          Navigator.pop(context);
          _showSnackBar('Vehicles saved successfully', Colors.green);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Error saving vehicles: $e', Colors.red);
      }
    }
  }

  // Helper function to convert vehicle type to API abbreviation
  String _getVehicleTypeAbbreviation(String type) {
    switch (type.toLowerCase()) {
      case 'car':
        return 'c';
      case 'bike':
        return 'b';
      case 'scooter':
        return 's';
      case 'auto rickshaw':
        return 'a';
      case 'truck':
        return 't';
      case 'bus':
        return 'bu';
      case 'bicycle':
        return 'bi';
      case 'e-scooter':
        return 'e';
      default:
        return type[0].toLowerCase();
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ✅ 3. Hide Back Button if from Signup
                  if (!widget.isFromSignup)
                    Positioned(
                      left: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.lightGrey),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 18),
                        ),
                      ),
                    ),
                  
                  // Logo
                  Image.asset(
                    'assets/images/sampark_black.png',
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Add Your Vehicles',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add vehicles to track and manage your tags',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Inputs Section
                    Text(
                      'Vehicle Type',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedVehicleType,
                          isExpanded: true,
                          hint: const Text('Select vehicle type'),
                          items: _vehicleTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.black,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedVehicleType = value;
                              _vehicleTypeController.text = value ?? '';
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Vehicle Number',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _vehicleNumberController,
                      decoration: InputDecoration(
                        hintText: 'Enter vehicle number',
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.lightGrey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.lightGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: AppColors.activeYellow, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Add Button
                    SizedBox(
                      width: double.infinity,
                      height: AppConstants.buttonHeightMedium,
                      child: OutlinedButton(
                        onPressed: _addVehicle,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.buttonBorderRadius),
                          ),
                          side: BorderSide(color: AppColors.activeYellow, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add, color: Colors.black),
                            const SizedBox(width: 8),
                            Text(
                              'Add Vehicle',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // List Display
                    if (_vehicles.isNotEmpty) ...[
                      Text(
                        'Your Vehicles (${_vehicles.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._vehicles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final vehicle = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.directions_car,
                                color: Colors.green.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vehicle['type'] ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      vehicle['number'] ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _removeVehicle(index),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.red.shade700,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 24),
                    ],

                    // Info Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You can add vehicles later from your profile settings.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit / Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: AppConstants.buttonHeightLarge,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.activeYellow,
                          disabledBackgroundColor:
                              AppColors.activeYellow.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.buttonBorderRadius),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    AppColors.black,
                                  ),
                                ),
                              )
                            : Text(
                                widget.isFromSignup ? 'Continue' : 'Submit',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                      ),
                    ),

                    // ✅ 4. Separate Skip Link (Only for Signup)
                    if (widget.isFromSignup) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: _handleSkip,
                          child: Text(
                            'Skip for Now',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textGrey,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}