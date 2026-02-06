import 'package:flutter/material.dart';
import 'package:my_new_app/pages/tags/business/business_tags_list_page.dart';
import 'package:my_new_app/pages/tags/door/door_tags_list_page.dart';
import 'package:my_new_app/pages/tags/lost_found/lost_found_list_page.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/tags_service.dart';
import '../car/car_tags_list_page.dart';
import '../bike/bike_tags_list_page.dart';

class TagGrid extends StatelessWidget {
  final UserTagsStats? tagStats;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const TagGrid({
    super.key,
    this.tagStats,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.paddingLarge,
          horizontal: AppConstants.paddingLarge,
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.activeYellow,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.paddingLarge,
          horizontal: AppConstants.paddingLarge,
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load tags',
              style: TextStyle(
                fontSize: AppConstants.fontSizeSectionTitle, // ✅ Increased size
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.activeYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: AppConstants.fontSizeButtonText,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final List<TagItem> tags = [
      TagItem(
        icon: Icons.directions_car_rounded,
        label: 'Car Sampark', // ✅ Renamed
        count: tagStats?.summary.carTags ?? 0,
        iconColor: const Color(0xFF2196F3), // Blue
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CarTagsListPage()),
          );
        },
      ),
      TagItem(
        icon: Icons.two_wheeler_rounded,
        label: 'Bike Sampark', // ✅ Renamed
        count: tagStats?.summary.bikeTags ?? 0,
        iconColor: const Color(0xFFFF6B00), // Orange
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BikeTagsListPage()),
          );
        },
      ),
      TagItem(
        icon: Icons.backpack_rounded,
        label: 'Bag Sampark', // ✅ Consistent naming
        count: 0,
        iconColor: const Color(0xFF9C27B0), // Purple
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bag Tags - Coming Soon!')),
          );
        },
      ),
      TagItem(
        icon: Icons.business_center_rounded,
        label: 'Business',
        count: tagStats?.summary.businessTags ?? 0,
        iconColor: const Color(0xFF00897B), // Teal
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BusinessTagsListPage()),
          );
        },
      ),
      TagItem(
        icon: Icons.pets_rounded,
        label: 'Lost & Found',
        count: tagStats?.summary.emergencyTags ?? 0,
        iconColor: const Color(0xFFE91E63), // Pink
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LostFoundListPage()),
          );
        },
      ),
      TagItem(
        icon: Icons.meeting_room_rounded,
        label: 'Door Sampark', // ✅ Renamed
        count: tagStats?.summary.doorTags ?? 0,
        iconColor: const Color(0xFF5D4037), // Brown
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DoorTagsListPage()),
          );
        },
      ),
    ];

    // Filter tags with count > 0
    final List<TagItem> availableTags = tags.where((tag) => tag.count > 0).toList();

    if (availableTags.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.paddingLarge,
          horizontal: AppConstants.paddingLarge,
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 50,
                color: AppColors.activeYellow,
              ),
              const SizedBox(height: 12),
              Text(
                'No Tags Yet',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSectionTitle, // ✅ Increased size
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start creating tags to manage them here',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeCardDescription,
                  color: AppColors.textGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: availableTags.length,
      itemBuilder: (context, index) {
        return _TagCard(tag: availableTags[index]);
      },
    );
  }
}

class _TagCard extends StatelessWidget {
  final TagItem tag;

  const _TagCard({required this.tag});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tag.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tag.icon,
                    // ✅ Used Constant (approx 32.0 is good for grid)
                    size: AppConstants.largeIconSizeGrid, 
                    color: tag.iconColor,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      tag.label,
                      textAlign: TextAlign.center,
                      maxLines: 2, // Allow 2 lines if "Sampark" wraps
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        // ✅ Increased from fontSizeCardTitle (12) to fontSizeSectionTitle (14)
                        fontSize: AppConstants.fontSizeSectionTitle, 
                        fontWeight: FontWeight.w700, // Made slightly bolder
                        color: AppColors.black,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TagItem {
  final IconData icon;
  final String label;
  final int count;
  final Color iconColor;
  final VoidCallback? onTap;

  TagItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.iconColor,
    this.onTap,
  });
}