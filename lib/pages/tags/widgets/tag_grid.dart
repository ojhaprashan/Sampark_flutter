import 'package:flutter/material.dart';
import 'package:my_new_app/pages/tags/business/business_tags_list_page.dart';
import 'package:my_new_app/pages/tags/door/door_tags_list_page.dart';
import 'package:my_new_app/pages/tags/lost_found/lost_found_list_page.dart';
import 'package:my_new_app/pages/auth/vehicle_details_page.dart'; // ✅ Import Vehicle Details
import 'package:my_new_app/pages/auth/login_page.dart'; // ✅ Import Login
import 'package:my_new_app/pages/tags/widgets/tag_grid_skeleton.dart'; // ✅ Import Skeleton
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/tags_service.dart';
import '../../../services/auth_service.dart'; // ✅ Import Auth Service
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
      return const TagGridSkeleton(itemCount: 6);
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.paddingLarge,
          horizontal: AppConstants.paddingLarge,
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 40, color: Colors.red.shade400),
            const SizedBox(height: 12),
            Text(
              'Failed to load tags',
              style: TextStyle(
                fontSize: AppConstants.fontSizeSectionTitle,
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

    final List<TagItem> allTags = [
      TagItem(
        icon: Icons.directions_car_rounded,
        label: 'Car Sampark',
        count: tagStats?.summary.carTags ?? 0,
        iconColor: const Color(0xFF2196F3),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CarTagsListPage()),
          );
        },
      ),
      TagItem(
        icon: Icons.two_wheeler_rounded,
        label: 'Bike Sampark',
        count: tagStats?.summary.bikeTags ?? 0,
        iconColor: const Color(0xFFFF6B00),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BikeTagsListPage()),
          );
        },
      ),
      TagItem(
        icon: Icons.business_center_rounded,
        label: 'Business',
        count: tagStats?.summary.businessTags ?? 0,
        iconColor: const Color(0xFF00897B),
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
        iconColor: const Color(0xFFE91E63),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LostFoundListPage()),
          );
        },
      ),
      TagItem(
        icon: Icons.meeting_room_rounded,
        label: 'Door Sampark',
        count: tagStats?.summary.doorTags ?? 0,
        iconColor: const Color(0xFF5D4037),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DoorTagsListPage()),
          );
        },
      ),
      // ✅ ADD VEHICLE BUTTON (With Direct Navigation Logic)
      TagItem(
        icon: Icons.add_circle_outline_rounded,
        label: 'Add Vehicle',
        count: -1, 
        iconColor: AppColors.black,
        isAction: true,
        onTap: () async {
          // 1. Check Login Status
          final isLoggedIn = await AuthService.isLoggedIn();
          
          if (!context.mounted) return;

          if (isLoggedIn) {
            // 2. Go to Vehicle Details
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VehicleDetailsPage()),
            );
          } else {
            // 3. Prompt Login
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Please login to add a vehicle'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        },
      ),
    ];

    // ✅ Filter tags: show only those with count >= 1 or action buttons
    final List<TagItem> tags = allTags
        .where((tag) => tag.isAction || tag.count >= 1)
        .toList();

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
      itemCount: tags.length,
      itemBuilder: (context, index) {
        return _TagCard(tag: tags[index]);
      },
    );
  }
}

class _TagCard extends StatelessWidget {
  final TagItem tag;

  const _TagCard({required this.tag});

  @override
  Widget build(BuildContext context) {
    final isAddButton = tag.isAction;

    return GestureDetector(
      onTap: tag.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isAddButton ? AppColors.activeYellow.withOpacity(0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          border: isAddButton 
              ? Border.all(color: AppColors.activeYellow, width: 2) 
              : null,
          boxShadow: [
            if (!isAddButton)
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
                    size: AppConstants.largeIconSizeGrid, 
                    color: tag.iconColor,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      tag.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSectionTitle, 
                        fontWeight: FontWeight.w700, 
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
  final bool isAction;

  TagItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.iconColor,
    this.onTap,
    this.isAction = false,
  });
}