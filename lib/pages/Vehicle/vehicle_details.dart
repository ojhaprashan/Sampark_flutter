import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_new_app/pages/scan/contact_vehicle_owner_page.dart';
import '../../utils/colors.dart';
import '../widgets/app_header.dart';
import '../../services/vehicle_search_service.dart';

class VehicleDetailsPage extends StatelessWidget {
  final String vehicleNumber;
  final String? vehicleType;
  final String? color;
  final String? model;
  final String? ownerName;
  final String? city;
  final String? fitnessDate;
  final String? make;
  final String? makeDetails;
  final VehicleSearchData? vehicleData;
  final int? tagId;

  const VehicleDetailsPage({
    super.key,
    required this.vehicleNumber,
    this.vehicleType,
    this.color,
    this.model,
    this.ownerName,
    this.city,
    this.fitnessDate,
    this.make,
    this.makeDetails,
    this.vehicleData,
    this.tagId,
  });

  /// Get vehicle type from dynamic or fallback data
  String _getVehicleType() {
    return vehicleData?.vehicle.fuelType ?? vehicleType ?? 'PETROL';
  }

  /// Get color from dynamic or fallback data
  String _getColor() {
    return vehicleData?.vehicle.color ?? color ?? 'RADIANT RED';
  }

  /// Get model from dynamic or fallback data
  String _getModel() {
    return vehicleData?.vehicle.model ?? model ?? 'AMAZE 1.2 S MT (I-VTEC)';
  }

  /// Get owner name from dynamic or fallback data
  String _getOwnerName() {
    return vehicleData?.vehicle.ownerNameMasked ?? ownerName ?? 'OWNER';
  }

  /// Get city from dynamic or fallback data
  String _getCity() {
    return vehicleData?.vehicle.state ?? city ?? 'Uttar Pradesh';
  }

  /// Get norms from dynamic or fallback data
  String _getNorms() {
    return vehicleData?.vehicle.norms ?? make ?? 'BHARAT STAGE IV';
  }

  /// Get manufacturer from dynamic or fallback data
  String _getManufacturer() {
    return vehicleData?.vehicle.manufacturerName ?? makeDetails ?? 'HONDA CARS INDIA LTD';
  }

  /// Get tag ID from dynamic or fallback data
  int _getTagId() {
    return vehicleData?.tagId ?? tagId ?? 0;
  }

  @override
  Widget build(BuildContext context) {
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

          // Content
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: AppHeader(
                  isLoggedIn: true,
                  showBackButton: true,
                  showUserInfo: false,
                  showCartIcon: false,
                ),
              ),

              // White curved container
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
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),

                            // ✅ Premium Vehicle Number Card
                            _buildPremiumVehicleCard(),

                            const SizedBox(height: 16),

                            // ✅ Premium Info Grid - 2x2
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCompactInfoCard(
                                    icon: Icons.person_outline_rounded,
                                    iconColor: Colors.blue.shade600,
                                    label: 'Owner',
                                    value: _getOwnerName(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildCompactInfoCard(
                                    icon: Icons.location_city_rounded,
                                    iconColor: Colors.orange.shade600,
                                    label: 'City',
                                    value: _getCity(),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildCompactInfoCard(
                                    icon: Icons.calendar_today_rounded,
                                    iconColor: Colors.green.shade600,
                                    label: 'Fitness Up to',
                                    value: fitnessDate ?? '12-Aug-2033',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildCompactInfoCard(
                                    icon: Icons.settings_rounded,
                                    iconColor: Colors.purple.shade600,
                                    label: 'Make',
                                    value: _getNorms(),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ✅ Full Width Make Details Card
                            _buildMakeDetailsCard(),

                            const SizedBox(height: 20),

                            // ✅ Premium Contact Section
                            _buildPremiumContactSection(),

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ✅ Premium Bottom Button
          _buildPremiumBottomButton(context),
        ],
      ),
    );
  }

  // ✅ Premium Vehicle Number Card with Glass Effect
  Widget _buildPremiumVehicleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryYellow.withOpacity(0.15),
            AppColors.activeYellow.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryYellow.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hashtag with Number
          Row(
            children: [
              Text(
                '# ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black.withOpacity(0.4),
                ),
              ),
              Text(
                vehicleNumber,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Vehicle Info with Smart Typography
          Wrap(
            spacing: 4,
            runSpacing: 2,
            children: [
              Text(
                _getVehicleType().toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black.withOpacity(0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getColorFromName(_getColor()).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _getColorFromName(_getColor()).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getColor().toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _getColorFromName(_getColor()),
                  ),
                ),
              ),
              Text(
                _getModel(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Compact Info Card - Grid Style
  Widget _buildCompactInfoCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightGrey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ✅ Make Details Card - Full Width
  Widget _buildMakeDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightGrey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.build_circle_rounded,
              color: Colors.indigo.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Make Details',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getManufacturer(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Premium Contact Section
  Widget _buildPremiumContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50.withOpacity(0.5),
            Colors.blue.shade50.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade100,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: Colors.blue.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact the vehicle owner.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'If you are facing any issue with this vehicle, contact ${_getOwnerName().toUpperCase()} now.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Premium Bottom Button
  Widget _buildPremiumBottomButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactVehicleOwnerPage(
                    tagId: _getTagId(),
                    vehicleNumber: vehicleNumber,
                    vehicleName: _getModel(),
                    maskedNumber: vehicleNumber.substring(vehicleNumber.length - 4),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.activeYellow,
              foregroundColor: AppColors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_rounded,
                  color: AppColors.black,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Contact Vehicle Owner',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Smart Color Matching
  Color _getColorFromName(String colorName) {
    final name = colorName.toLowerCase();
    if (name.contains('red') || name.contains('radiant')) return Colors.red.shade600;
    if (name.contains('blue')) return Colors.blue.shade600;
    if (name.contains('black')) return Colors.grey.shade800;
    if (name.contains('white')) return Colors.grey.shade600;
    if (name.contains('silver') || name.contains('grey')) return Colors.blueGrey.shade600;
    if (name.contains('green')) return Colors.green.shade600;
    if (name.contains('yellow') || name.contains('gold')) return Colors.amber.shade700;
    if (name.contains('brown') || name.contains('bronze')) return Colors.brown.shade600;
    if (name.contains('orange')) return Colors.deepOrange.shade600;
    return AppColors.black;
  }
}
