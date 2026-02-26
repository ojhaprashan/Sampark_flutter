import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../services/emergency_service.dart';
import '../../pages/scan/contact_reasons.dart';


class EmergencySectionWidget extends StatelessWidget {
  final int tagId;
  final String tagTypeCode;


  const EmergencySectionWidget({
    super.key,
    required this.tagId,
    required this.tagTypeCode,
  });


  void _showEmergencyDialog(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.activeYellow),
        ),
      ),
    );


    try {
      final response = await EmergencyService.fetchEmergencyInfo(
        tagId: tagId,
      );


      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog


        if (!context.mounted) return;


        // Show emergency info dialog
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              padding: EdgeInsets.all(AppConstants.paddingPage),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppConstants.paddingMedium),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.emergency,
                            size: 32,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(width: AppConstants.spacingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Emergency Contact',
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizePageTitle,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                              Text(
                                response.data.hasEmergency
                                    ? 'Emergency info available'
                                    : 'No emergency info added',
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizeCardDescription,
                                  color: response.data.hasEmergency
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.spacingLarge),


                    // Emergency Information
                    if (response.data.hasEmergency) ...[
                      // Row 1: Primary Phone & Secondary Phone
                      if ((response.data.primaryPhone != null && response.data.primaryPhone!.isNotEmpty) ||
                          (response.data.secondaryPhone != null && response.data.secondaryPhone!.isNotEmpty))
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (response.data.primaryPhone != null && response.data.primaryPhone!.isNotEmpty)
                              Expanded(
                                child: _buildInfoRowWithCall(
                                  context: context,
                                  label: 'Primary Contact',
                                  value: response.data.primaryPhone!,
                                  icon: Icons.phone,
                                ),
                              ),
                            if (response.data.primaryPhone != null &&
                                response.data.primaryPhone!.isNotEmpty &&
                                response.data.secondaryPhone != null &&
                                response.data.secondaryPhone!.isNotEmpty)
                              SizedBox(width: AppConstants.spacingSmall),
                            if (response.data.secondaryPhone != null && response.data.secondaryPhone!.isNotEmpty)
                              Expanded(
                                child: _buildInfoRowWithCall(
                                  context: context,
                                  label: 'Secondary Contact',
                                  value: response.data.secondaryPhone!,
                                  icon: Icons.phone_android,
                                ),
                              ),
                          ],
                        ),
                      if ((response.data.primaryPhone != null && response.data.primaryPhone!.isNotEmpty) ||
                          (response.data.secondaryPhone != null && response.data.secondaryPhone!.isNotEmpty))
                        SizedBox(height: AppConstants.spacingSmall),


                      // Row 2: Blood Group & Insurance
                      if ((response.data.bloodGroup != null && response.data.bloodGroup!.isNotEmpty) ||
                          (response.data.insurance != null && response.data.insurance!.isNotEmpty))
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (response.data.bloodGroup != null && response.data.bloodGroup!.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'Blood Group',
                                  value: response.data.bloodGroup!,
                                  icon: Icons.bloodtype,
                                ),
                              ),
                            if (response.data.bloodGroup != null &&
                                response.data.bloodGroup!.isNotEmpty &&
                                response.data.insurance != null &&
                                response.data.insurance!.isNotEmpty)
                              SizedBox(width: AppConstants.spacingSmall),
                            if (response.data.insurance != null && response.data.insurance!.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'Insurance',
                                  value: response.data.insurance!,
                                  icon: Icons.shield,
                                ),
                              ),
                          ],
                        ),
                      if ((response.data.bloodGroup != null && response.data.bloodGroup!.isNotEmpty) ||
                          (response.data.insurance != null && response.data.insurance!.isNotEmpty))
                        SizedBox(height: AppConstants.spacingSmall),


                      // Row 3: Note (Full Width)
                      if (response.data.note != null && response.data.note!.isNotEmpty) ...[
                        _buildInfoRow(
                          label: 'Additional Note',
                          value: response.data.note!,
                          icon: Icons.note,
                          isExpanded: true,
                        ),
                      ],
                    ] else ...[
                      Container(
                        padding: EdgeInsets.all(AppConstants.paddingLarge),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppConstants.borderRadiusCard),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange,
                              size: AppConstants.iconSizeMedium,
                            ),
                            SizedBox(width: AppConstants.spacingMedium),
                            Expanded(
                              child: Text(
                                response.message,
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizeCardTitle,
                                  color: Colors.orange.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],


                    SizedBox(height: AppConstants.spacingLarge),


                    // All India Emergency Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Close current dialog and show All India Emergency
                          Navigator.pop(context);
                          _showAllIndiaEmergencyDialog(context);
                        },
                        icon: Icon(
                          Icons.emergency_share,
                          color: AppColors.white,
                          size: 18,
                        ),
                        label: Text(
                          'All India Emergency Numbers',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeCardTitle,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingMedium,
                            vertical: AppConstants.paddingMedium,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.buttonBorderRadius),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),


                    // Close Button
                    SizedBox(height: AppConstants.spacingSmall),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: AppConstants.fontSizeCardTitle,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog


        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.replaceFirst('Exception: ', '');
        }


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.paddingSmall),
            ),
          ),
        );
      }
    }
  }


  void _showAllIndiaEmergencyDialog(BuildContext context) {
    final emergencyNumbers = [
      {'label': 'Police', 'number': '100', 'icon': Icons.local_police, 'color': Colors.blue},
      {'label': 'Ambulance', 'number': '108', 'icon': Icons.local_hospital, 'color': Colors.red},
      {'label': 'Fire Brigade', 'number': '101', 'icon': Icons.local_fire_department, 'color': Colors.orange},
      {'label': 'Women Helpline', 'number': '1091', 'icon': Icons.woman, 'color': Colors.pink},
      {'label': 'Child Helpline', 'number': '1098', 'icon': Icons.child_care, 'color': Colors.purple},
      {'label': 'Road Accident', 'number': '1073', 'icon': Icons.car_crash, 'color': Colors.brown},
      {'label': 'Senior Citizen', 'number': '14567', 'icon': Icons.elderly, 'color': Colors.teal},
      {'label': 'National Emergency', 'number': '112', 'icon': Icons.emergency, 'color': Colors.red.shade700},
    ];


    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          padding: EdgeInsets.all(AppConstants.paddingPage),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppConstants.paddingSmall),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emergency_share,
                      size: 24,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All India Emergency',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizePageTitle,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          'Tap to call',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeCardDescription,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppColors.black),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: AppConstants.spacingLarge),


              // Emergency Numbers in 2 columns
              ...List.generate((emergencyNumbers.length / 2).ceil(), (rowIndex) {
                final startIndex = rowIndex * 2;
                final endIndex = (startIndex + 2).clamp(0, emergencyNumbers.length);
                final rowItems = emergencyNumbers.sublist(startIndex, endIndex);


                return Padding(
                  padding: EdgeInsets.only(bottom: AppConstants.spacingMedium),
                  child: Row(
                    children: rowItems.map((item) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: rowItems.indexOf(item) == 0 && rowItems.length > 1
                                ? AppConstants.spacingSmall
                                : 0,
                            left: rowItems.indexOf(item) == 1
                                ? AppConstants.spacingSmall
                                : 0,
                          ),
                          child: _buildCompactEmergencyCard(
                            context: context,
                            label: item['label'] as String,
                            number: item['number'] as String,
                            icon: item['icon'] as IconData,
                            color: item['color'] as Color,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildCompactEmergencyCard({
    required BuildContext context,
    required String label,
    required String number,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _makePhoneCall(number),
      child: Container(
        padding: EdgeInsets.all(AppConstants.paddingSmall),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: Colors.white,
              ),
            ),
            SizedBox(width: AppConstants.spacingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeCardDescription - 1,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    number,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeCardDescription,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.call,
              size: 16,
              color: color,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    bool isExpanded = false,
  }) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: Colors.blue,
              ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardDescription - 1,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardTitle - 1,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
              height: isExpanded ? 1.4 : 1.2,
            ),
            maxLines: isExpanded ? 5 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }


  Widget _buildInfoRowWithCall({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    String maskedValue = _maskPhoneNumber(value);

    return Container(
      padding: EdgeInsets.all(AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: Colors.blue,
              ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardDescription - 1,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  maskedValue,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeCardTitle - 1,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(width: 4),
              GestureDetector(
                onTap: () => _makePhoneCall(value),
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.call,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  String _maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.length <= 4) {
      return '****';
    }
    final unmaskedLength = phoneNumber.length - 4;
    final unmaskedPart = phoneNumber.substring(0, unmaskedLength);
    return '$unmaskedPart****';
  }


  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw Exception('Could not launch phone dialer');
      }
    } catch (e) {
      print('Error making phone call: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final isVehicleTag = ContactReasons.isVehicleTag(tagTypeCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show question text only for vehicle tags
        if (isVehicleTag) ...[
          Text(
            'Do you think the vehicle has an accident and needs to be contacted family members or emergency numbers?',
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardTitle,
              color: AppColors.black,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppConstants.spacingMedium),
        ],
        // Single Emergency Button (shown for all tags)
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 36,
            child: ElevatedButton.icon(
              onPressed: () => _showEmergencyDialog(context),
              icon: Icon(
                Icons.emergency,
                color: AppColors.white,
                size: 14,
              ),
              label: Text(
                'Emergency',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSmallText + 2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.buttonBorderRadius),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
