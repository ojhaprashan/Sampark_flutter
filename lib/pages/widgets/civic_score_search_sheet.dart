import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/civic_score_service.dart';
import 'simple_rating_sheet.dart';

class CivicScoreSearchSheet extends StatefulWidget {
  const CivicScoreSearchSheet({super.key});

  @override
  State<CivicScoreSearchSheet> createState() => _CivicScoreSearchSheetState();
}

class _CivicScoreSearchSheetState extends State<CivicScoreSearchSheet> {
  final TextEditingController _plateController = TextEditingController();
  bool _isLoading = false;
  CivicScoreData? _searchResult;
  String? _errorMessage;

  @override
  void dispose() {
    _plateController.dispose();
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
          if (_searchResult != null && !_searchResult!.hasRatings) {
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

            // Title
            const Text(
              'Search Civic Score',
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
                suffixIcon: _isLoading 
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.activeYellow),
                      onPressed: _search,
                    ),
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
                padding: const EdgeInsets.all(8.0),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),

            const SizedBox(height: AppConstants.spacingLarge),

            // Result Section
            if (_searchResult != null) ...[
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

              // Rate Now Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => SimpleRatingSheet(
                        initialVehicleNumber: _searchResult!.plateClean,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.activeYellow,
                    foregroundColor: AppColors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius)),
                  ),
                  child: const Text('Rate this Vehicle Now', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],

            const SizedBox(height: AppConstants.spacingMedium),
            
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: AppColors.textGrey)),
            ),
          ],
        ),
      ),
    );
  }
}
