import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/civic_score_service.dart';
import '../../../services/auth_service.dart';

class SimpleRatingSheet extends StatefulWidget {
  final String? initialVehicleNumber;
  final Function(int rating, String? feedback)? onSubmit;

  const SimpleRatingSheet({
    super.key,
    this.initialVehicleNumber,
    this.onSubmit,
  });

  @override
  State<SimpleRatingSheet> createState() => _SimpleRatingSheetState();
}

class _SimpleRatingSheetState extends State<SimpleRatingSheet> {
  int? _selectedRating;
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  bool _isSubmitting = false;
  String _userPhone = '';
  String? _errorMessage; // ✅ Local error message state

  @override
  void initState() {
    super.initState();
    if (widget.initialVehicleNumber != null) {
      _plateController.text = widget.initialVehicleNumber!;
    }
    _fetchUserData();

    // ✅ Clear error message when user starts typing
    _plateController.addListener(_clearError);
    _feedbackController.addListener(_clearError);
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _fetchUserData() async {
    final userData = await AuthService.getUserData();
    if (mounted) {
      setState(() {
        _userPhone = userData['phone'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _plateController.removeListener(_clearError);
    _feedbackController.removeListener(_clearError);
    _feedbackController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine the bottom padding needed for system UI (navigation bar)
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppConstants.borderRadius),
          topRight: Radius.circular(AppConstants.borderRadius),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppConstants.paddingPage,
        right: AppConstants.paddingPage,
        top: AppConstants.paddingPage,
        // ✅ Added `bottomSafeArea` to push content above the system navigation buttons
        bottom: MediaQuery.of(context).viewInsets.bottom + bottomSafeArea + AppConstants.paddingPage,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),

            // Title
            const Text(
              'Rate Civic Score',
              style: TextStyle(
                fontSize: AppConstants.fontSizePageTitle,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),

            // Vehicle Plate TextField (Only if not provided)
            if (widget.initialVehicleNumber == null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacingLarge),
                child: TextField(
                  controller: _plateController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeSectionTitle,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter Vehicle Number (e.g. MH01AB1234)',
                    hintStyle: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w400),
                    prefixIcon: const Icon(Icons.directions_car_rounded, color: AppColors.textGrey),
                    filled: true,
                    fillColor: AppColors.cardWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      borderSide: const BorderSide(color: AppColors.activeYellow, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(AppConstants.paddingLarge),
                  ),
                ),
              ),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                int starValue = index + 1;
                bool isSelected = _selectedRating != null && _selectedRating! >= starValue;

                return GestureDetector(
                  onTap: () {
                    _clearError();
                    setState(() {
                      _selectedRating = starValue;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingSmall),
                    child: Icon(
                      isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 44, // Slightly larger for better touch interaction
                      color: isSelected ? AppColors.activeYellow : AppColors.lightGrey,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppConstants.spacingLarge),

            // Feedback TextField
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              maxLength: 150,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeSectionTitle,
                color: AppColors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Add feedback (optional)',
                hintStyle: const TextStyle(color: AppColors.textGrey),
                filled: true,
                fillColor: AppColors.cardWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  borderSide: const BorderSide(color: AppColors.lightGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  borderSide: const BorderSide(color: AppColors.lightGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  borderSide: const BorderSide(color: AppColors.activeYellow, width: 2),
                ),
                contentPadding: const EdgeInsets.all(AppConstants.paddingLarge),
                counterText: '',
              ),
            ),
            
            // ✅ Error Message Display
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: AppConstants.spacingLarge),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Extra margin above the buttons
            const SizedBox(height: AppConstants.spacingLarge * 1.2),

            // Submit Button
            GestureDetector(
              onTap: _isReadyToSubmit() && !_isSubmitting
                  ? () => _submit()
                  : null,
              child: Container(
                height: AppConstants.buttonHeightMedium, // Fixed height to prevent loader shifting
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _isReadyToSubmit() && !_isSubmitting
                      ? AppColors.activeYellow
                      : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                  // Drop shadow only when active
                  boxShadow: _isReadyToSubmit() && !_isSubmitting
                      ? [
                          BoxShadow(
                            color: AppColors.activeYellow.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.black, // High contrast loader
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Submit',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeSectionTitle,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                ),
              ),
            ),
            
            // Margin between Submit and Cancel buttons
            const SizedBox(height: AppConstants.spacingMedium),

            // Cancel Button (Outlined style for better hierarchy)
            GestureDetector(
              onTap: _isSubmitting ? null : () => Navigator.pop(context),
              child: Container(
                height: AppConstants.buttonHeightMedium, // Fixed height
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.transparent, 
                  border: Border.all(color: AppColors.lightGrey),
                  borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                ),
                child: Center(
                  child: Text(
                    'Cancel',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSectionTitle,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey, 
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
          ],
        ),
      ),
    );
  }

  bool _isReadyToSubmit() {
    return _selectedRating != null && _plateController.text.trim().isNotEmpty;
  }

  Future<void> _submit() async {
    final plate = _plateController.text.trim();
    final rating = _selectedRating!;
    final comment = _feedbackController.text.trim();

    if (plate.isEmpty) {
      setState(() => _errorMessage = 'Please enter a vehicle number');
      return;
    }

    if (_userPhone.isEmpty) {
      setState(() => _errorMessage = 'User phone not found. Please log in again.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null; // Clear old errors
    });

    try {
      final response = await CivicScoreService.submitCivicScore(
        plate: plate,
        rating: rating,
        phone: _userPhone,
        comment: comment.isNotEmpty ? comment : null,
      );

      if (mounted) {
        // Success
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${response.message}'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
            ),
          ),
        );

        // Call the callback if provided (for backward compatibility)
        if (widget.onSubmit != null) {
          widget.onSubmit!(rating, comment.isNotEmpty ? comment : null);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', ''); // ✅ Set inline error
        });
      }
    }
  }
}