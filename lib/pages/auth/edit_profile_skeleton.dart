import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class EditProfileSkeleton extends StatelessWidget {
  const EditProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
        ),
        child: Column(
          children: [
            const SizedBox(height: AppConstants.spacingMedium),
            _buildShimmerContainer(height: 24, width: 120),
            const SizedBox(height: 12),
            _buildShimmerContainer(height: 48, width: double.infinity),
            const SizedBox(height: 20),
            _buildShimmerContainer(height: 24, width: 100),
            const SizedBox(height: 12),
            _buildShimmerContainer(height: 48, width: double.infinity),
            const SizedBox(height: 20),
            _buildShimmerContainer(height: 24, width: 100),
            const SizedBox(height: 12),
            _buildShimmerContainer(height: 48, width: double.infinity),
            const SizedBox(height: 20),
            _buildShimmerContainer(height: 24, width: 80),
            const SizedBox(height: 12),
            _buildShimmerContainer(height: 80, width: double.infinity),
            const SizedBox(height: 20),
            _buildShimmerContainer(height: 24, width: 120),
            const SizedBox(height: 12),
            _buildShimmerContainer(height: 48, width: double.infinity),
            const SizedBox(height: 20),
            _buildShimmerContainer(height: 24, width: 100),
            const SizedBox(height: 12),
            _buildShimmerContainer(height: 48, width: double.infinity),
            const SizedBox(height: 20),
            _buildShimmerContainer(height: 24, width: 80),
            const SizedBox(height: 12),
            _buildShimmerContainer(height: 48, width: double.infinity),
            const SizedBox(height: 20),
            _buildShimmerContainer(height: 24, width: 100),
            const SizedBox(height: 12),
            _buildShimmerContainer(height: 48, width: double.infinity),
            const SizedBox(height: 20),
            _buildShimmerContainer(height: 24, width: 100),
            const SizedBox(height: 12),
            _buildShimmerContainer(height: 80, width: double.infinity),
            const SizedBox(height: 20),
            _buildShimmerContainer(height: 24, width: 90),
            const SizedBox(height: 12),
            _buildShimmerContainer(height: 48, width: double.infinity),
            const SizedBox(height: 20),
            _buildShimmerContainer(height: 24, width: 80),
            const SizedBox(height: 12),
            _buildShimmerContainer(height: 48, width: double.infinity),
            const SizedBox(height: 20),
            _buildShimmerContainer(height: 24, width: 90),
            const SizedBox(height: 12),
            _buildShimmerContainer(height: 48, width: double.infinity),
            const SizedBox(height: 28),
            _buildShimmerContainer(height: 50, width: double.infinity),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerContainer(
      {required double height, required double width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
