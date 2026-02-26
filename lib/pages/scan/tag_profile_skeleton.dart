import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class TagProfileSkeleton extends StatelessWidget {
  const TagProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Skeleton
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 32,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: AppConstants.spacingMedium),

          // Tag Info Card Skeleton
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              padding: EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Blue tick circle skeleton
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: AppConstants.spacingMedium),
                      // Plate number skeleton
                      Expanded(
                        child: Container(
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      SizedBox(width: AppConstants.spacingMedium),
                      // Status badge skeleton
                      Container(
                        height: 32,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppConstants.spacingLarge),

          // Contact Question Skeleton
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 20,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          SizedBox(height: AppConstants.spacingLarge),

          // Action Cards Skeleton
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              children: [
                // Call Card
                Expanded(
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadiusCard),
                    ),
                  ),
                ),
                SizedBox(width: AppConstants.spacingLarge),
                // Message Card
                Expanded(
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadiusCard),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppConstants.spacingLarge),

          // Reason Options Skeleton (3 items)
          ...List.generate(
            3,
            (index) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                margin: EdgeInsets.only(bottom: AppConstants.spacingMedium),
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusCard),
                ),
              ),
            ),
          ),

          SizedBox(height: AppConstants.spacingLarge),

          // Emergency Section Skeleton
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusCard),
              ),
            ),
          ),

          SizedBox(height: AppConstants.paddingPage),
        ],
      ),
    );
  }
}
