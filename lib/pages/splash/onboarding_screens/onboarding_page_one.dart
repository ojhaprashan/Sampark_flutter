import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/colors.dart';

class OnboardingPageOne extends StatelessWidget {
  final String title;
  final String description;
  final String iconPath;
  final int pageNumber;
  final int totalPages;

  const OnboardingPageOne({
    super.key,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.pageNumber,
    required this.totalPages,
  });

  /// Checks if the provided path is a network URL
  bool _isNetworkUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  /// Builds the image widget based on whether it's a network URL or local asset
  Widget _buildIconImage() {
    if (_isNetworkUrl(iconPath)) {
      // Network image with loading and error handling
      return Image.network(
        iconPath,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColors.black.withOpacity(0.5),
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          return Container(
            width: 100,
            height: 100,
            color: AppColors.black.withOpacity(0.1),
            child: Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 40,
                color: AppColors.black.withOpacity(0.3),
              ),
            ),
          );
        },
      );
    } else {
      // Local asset image
      return Image.asset(
        iconPath,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Logo at top
            Image.asset(
              'assets/images/sampark_black.png',
              height: 45,
              fit: BoxFit.contain,
            ),
            const Spacer(flex: 1),
            // Main Icon with white background
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: ClipOval(
                  child: _buildIconImage(),
                ),
              ),
            ),
            const Spacer(flex: 1),
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.black.withOpacity(0.7),
                height: 1.6,
                letterSpacing: 0.3,
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
