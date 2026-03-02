import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';

class ShopSkeleton extends StatelessWidget {
  final int itemCount;
  final double scale;

  const ShopSkeleton({
    super.key,
    this.itemCount = 6,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 16 * scale,
        right: 16 * scale,
        top: 20 * scale,
        bottom: 90 * scale,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12 * scale,
        mainAxisSpacing: 12 * scale,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12 * scale),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8 * scale,
                  offset: Offset(0, 4 * scale),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section Skeleton
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12 * scale),
                      ),
                    ),
                  ),
                ),

                // Details Section Skeleton
                Padding(
                  padding: EdgeInsets.all(10.0 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name Skeleton
                      Container(
                        height: 14 * scale,
                        width: 120 * scale,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),

                      SizedBox(height: 6 * scale),

                      // Short Title Skeleton
                      Container(
                        height: 12 * scale,
                        width: 100 * scale,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),

                      SizedBox(height: 8 * scale),

                      // Price Section Skeleton
                      Container(
                        height: 16 * scale,
                        width: 80 * scale,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
