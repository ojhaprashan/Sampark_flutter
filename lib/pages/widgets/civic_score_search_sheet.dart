import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/civic_score_service.dart';
import '../../../services/auth_service.dart';
import 'simple_rating_sheet.dart';

enum CivicScoreStep { search, result, rate }

class CivicScoreSearchSheet extends StatefulWidget {
  const CivicScoreSearchSheet({super.key});

  @override
  State<CivicScoreSearchSheet> createState() => _CivicScoreSearchSheetState();
}

class _CivicScoreSearchSheetState extends State<CivicScoreSearchSheet> {
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitting = false;
  CivicScoreData? _searchResult;
  String? _errorMessage;
  CivicScoreStep _currentStep = CivicScoreStep.search;
  int? _selectedRating;
  String? _userPhone;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
    _plateController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final plate = _plateController.text.trim();
    if (plate.isEmpty) {
      setState(() => _errorMessage = 'Please enter a vehicle number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResult = null;
    });

    try {
      final response = await CivicScoreService.getCivicScore(plate: plate);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _searchResult = response.data;
          if (_searchResult != null) {
            _currentStep = CivicScoreStep.result;
          } else {
            _errorMessage = 'No ratings found for this vehicle yet.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _submitRating() async {
    if (_selectedRating == null || _searchResult == null) return;
    if (_userPhone == null || _userPhone!.isEmpty) {
      setState(() => _errorMessage = 'User phone not found. Please log in.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final response = await CivicScoreService.submitCivicScore(
        plate: _searchResult!.plateClean,
        rating: _selectedRating!,
        phone: _userPhone!,
        comment: _feedbackController.text.trim().isNotEmpty ? _feedbackController.text.trim() : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${response.message}'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

            if (_currentStep == CivicScoreStep.search) _buildSearchStep(),
            if (_currentStep == CivicScoreStep.result) _buildResultStep(),
            if (_currentStep == CivicScoreStep.rate) _buildRateStep(),

            const SizedBox(height: AppConstants.spacingSmall),

            // Cancel/Close Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                _currentStep == CivicScoreStep.search ? 'Close' : 'Cancel',
                style: const TextStyle(color: AppColors.textGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchStep() {
    return Column(
      children: [
        const Text(
          'Civic Score',
          style: TextStyle(
            fontSize: AppConstants.fontSizePageTitle,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppConstants.spacingLarge),

        // Search Bar
        TextField(
          controller: _plateController,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => setState(() => _errorMessage = null),
          decoration: InputDecoration(
            hintText: 'Enter Vehicle Number',
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textGrey),
            filled: true,
            fillColor: AppColors.cardWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: const BorderSide(color: AppColors.activeYellow, width: 2),
            ),
          ),
          onSubmitted: (_) => _search(),
        ),

        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),

        const SizedBox(height: AppConstants.spacingLarge),

        // Large Check Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _search,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.activeYellow,
              foregroundColor: AppColors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius)),
            ),
            child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black))
              : const Text('Check', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildResultStep() {
    return Column(
      children: [
        const Text(
          'Vehicle Score',
          style: TextStyle(
            fontSize: AppConstants.fontSizePageTitle,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppConstants.spacingLarge),

        // Result Card
        if (_searchResult != null)
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Text(
                  _searchResult!.plateDisplay,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                
                // Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < _searchResult!.starsFull ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppColors.activeYellow,
                      size: 30,
                    );
                  }),
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                
                Text(
                  _searchResult!.hasRatings 
                    ? '${_searchResult!.avgRating} / 5.0'
                    : 'No Ratings',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  '(${_searchResult!.totalRatings} total ratings)',
                  style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ],
            ),
          ),

        const SizedBox(height: AppConstants.spacingLarge),

        // Rate Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _currentStep = CivicScoreStep.rate),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.activeYellow,
              foregroundColor: AppColors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius)),
            ),
            child: const Text('Give Civic Score', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
        
        const SizedBox(height: AppConstants.spacingSmall),
        
        // Back Button
        TextButton(
          onPressed: () => setState(() => _currentStep = CivicScoreStep.search),
          child: const Text('Back to Search', style: TextStyle(color: AppColors.textGrey)),
        ),
      ],
    );
  }

  Widget _buildRateStep() {
    return Column(
      children: [
        const Text(
          'Rate Vehicle',
          style: TextStyle(
            fontSize: AppConstants.fontSizePageTitle,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        
        // Mini Score Summary (Header) - Showing existing score
        if (_searchResult != null)
           Text(
            'Current Score: ${_searchResult!.plateDisplay} (${_searchResult!.avgRating}/5)',
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w600),
          ),
          
        const SizedBox(height: AppConstants.spacingLarge),

        // Star Select
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            int rating = index + 1;
            bool isSelected = _selectedRating != null && _selectedRating! >= rating;
            return GestureDetector(
              onTap: () => setState(() => _selectedRating = rating),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isSelected ? AppColors.activeYellow : AppColors.lightGrey,
                  size: 45,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: AppConstants.spacingLarge),

        // Feedback
        TextField(
          controller: _feedbackController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add feedback (optional)',
            filled: true,
            fillColor: AppColors.cardWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: const BorderSide(color: AppColors.activeYellow, width: 2),
            ),
          ),
        ),

        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),

        const SizedBox(height: AppConstants.spacingLarge),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_selectedRating != null && !_isSubmitting) ? _submitRating : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.activeYellow,
              foregroundColor: AppColors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius)),
            ),
            child: _isSubmitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black))
              : const Text('Submit Rating', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
        
        const SizedBox(height: AppConstants.spacingSmall),
        
        // Back Button
        TextButton(
          onPressed: () => setState(() => _currentStep = CivicScoreStep.result),
          child: const Text('Back to Results', style: TextStyle(color: AppColors.textGrey)),
        ),
      ],
    );
  }
}
