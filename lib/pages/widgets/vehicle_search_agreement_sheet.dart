import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class VehicleSearchAgreementSheet extends StatefulWidget {
  final String vehicleNumber;
  final String phoneNumber;
  final VoidCallback onCancel;
  final VoidCallback onAgree;

  const VehicleSearchAgreementSheet({
    super.key,
    required this.vehicleNumber,
    required this.phoneNumber,
    required this.onCancel,
    required this.onAgree,
  });

  @override
  State<VehicleSearchAgreementSheet> createState() =>
      _VehicleSearchAgreementSheetState();
}

class _VehicleSearchAgreementSheetState
    extends State<VehicleSearchAgreementSheet> {
  bool _isAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppConstants.borderRadius * 2),
                topRight: Radius.circular(AppConstants.borderRadius * 2),
              ),
            ),
            child: Column(
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: AppConstants.spacingMedium),
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingPage,
                        vertical: AppConstants.paddingLarge,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Header with Gradient
                          _buildHeader(),
                          
                          const SizedBox(height: AppConstants.spacingSection),

                          // 2. Vehicle Number (Styled like a Number Plate)
                          _buildLabel('Vehicle Number'),
                          const SizedBox(height: AppConstants.spacingSmall),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppConstants.paddingLarge,
                              horizontal: AppConstants.paddingMedium,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
                              border: Border.all(color: AppColors.lightGrey),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                widget.vehicleNumber,
                                style: const TextStyle(
                                  fontSize: 22, // Larger for emphasis
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                  letterSpacing: 1.5, // License plate look
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: AppConstants.spacingSection),

                          // 3. Responsibility Warning
                          _buildLabel('Important Notice'),
                          const SizedBox(height: AppConstants.spacingSmall),
                          Container(
                            padding: const EdgeInsets.all(AppConstants.cardPaddingMedium),
                            decoration: BoxDecoration(
                              // Using primaryYellow with opacity for a soft warning look
                              color: AppColors.primaryYellow.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
                              border: Border.all(
                                color: AppColors.primaryYellow.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: AppColors.darkYellow,
                                  size: AppConstants.iconSizeLarge,
                                ),
                                const SizedBox(width: AppConstants.spacingMedium),
                                Expanded(
                                  child: Text(
                                    'You are solely responsible for the accuracy and use of vehicle data retrieved. Ensure compliance with all applicable laws.',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeCardDescription,
                                      color: AppColors.black.withOpacity(0.8),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppConstants.spacingSection),

                          // 4. Phone Number
                          _buildLabel('Registered Phone Number'),
                          const SizedBox(height: AppConstants.spacingSmall),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppConstants.paddingMedium),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
                              border: Border.all(color: AppColors.lightGrey),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.phone_android, size: AppConstants.iconSizeMedium, color: AppColors.textGrey),
                                const SizedBox(width: AppConstants.spacingSmall),
                                Text(
                                  widget.phoneNumber.isEmpty ? 'Not available' : widget.phoneNumber,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppConstants.spacingLarge),

                          // 5. Agreement Checkbox
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isAgreed = !_isAgreed;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(AppConstants.paddingMedium),
                              decoration: BoxDecoration(
                                color: _isAgreed
                                    ? AppColors.activeYellow.withOpacity(0.1)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
                                border: Border.all(
                                  color: _isAgreed
                                      ? AppColors.activeYellow
                                      : AppColors.lightGrey,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _isAgreed,
                                      onChanged: (value) {
                                        setState(() {
                                          _isAgreed = value ?? false;
                                        });
                                      },
                                      activeColor: AppColors.activeYellow,
                                      checkColor: AppColors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppConstants.spacingSmall),
                                  const Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'I agree to the terms. I confirm that I am responsible for bringing this data to the Sampark system.',
                                        style: TextStyle(
                                          fontSize: AppConstants.fontSizeButtonText,
                                          color: AppColors.textGrey,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30), // Extra space before buttons

                          // 6. Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: AppConstants.buttonHeightMedium,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      widget.onCancel();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.lightGrey,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppConstants.buttonBorderRadius,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: AppColors.textGrey,
                                        fontWeight: FontWeight.w600,
                                        fontSize: AppConstants.fontSizeButtonText,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacingMedium),
                              Expanded(
                                child: SizedBox(
                                  height: AppConstants.buttonHeightMedium,
                                  child: ElevatedButton(
                                    onPressed: _isAgreed
                                        ? () {
                                            Navigator.pop(context);
                                            widget.onAgree();
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.activeYellow,
                                      disabledBackgroundColor: AppColors.lightGrey.withOpacity(0.5),
                                      elevation: _isAgreed ? 2 : 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppConstants.buttonBorderRadius,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Search Vehicle',
                                      style: TextStyle(
                                        color: _isAgreed
                                            ? AppColors.black
                                            : AppColors.textGrey,
                                        fontWeight: FontWeight.w700,
                                        fontSize: AppConstants.fontSizeButtonText,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingLarge),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper widget for Section Labels
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: AppConstants.fontSizeCardTitle,
        fontWeight: FontWeight.w600,
        color: AppColors.textGrey,
      ),
    );
  }

  // Helper widget for Header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryYellow,
            AppColors.darkYellow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkYellow.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search,
              color: AppColors.black,
              size: AppConstants.iconSizeGrid,
            ),
          ),
          const SizedBox(width: AppConstants.spacingLarge),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Vehicle Search',
                style: TextStyle(
                  fontSize: AppConstants.fontSizePageTitle,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Data fetched from Government API',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSubtitle,
                  color: Color(0xFF424242), // Slightly darker than textGrey for contrast on yellow
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}