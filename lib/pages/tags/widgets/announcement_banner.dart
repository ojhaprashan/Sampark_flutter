import 'package:flutter/material.dart';
import 'package:my_new_app/pages/membership/membership_page.dart';
import '../../../utils/colors.dart';

class MembershipAnnouncement extends StatefulWidget {
  final VoidCallback? onDismiss;

  const MembershipAnnouncement({
    super.key,
    this.onDismiss,
  });

  @override
  State<MembershipAnnouncement> createState() => _MembershipAnnouncementState();
}

class _MembershipAnnouncementState extends State<MembershipAnnouncement> {
  bool _isDismissed = false;

  void _handleDismiss() {
    setState(() {
      _isDismissed = true;
    });
    widget.onDismiss?.call();
  }

  // ✅ Navigate to Membership Page
  void _openMembershipPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MembershipPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryYellow,
            AppColors.activeYellow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.activeYellow.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Glossy overlay effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Premium Crown Icon with gradient background
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.35),
                        Colors.white.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.black,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title with better styling
                      Text(
                        'Premium Membership',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                          letterSpacing: -0.2,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Description with better contrast
                      Text(
                        'Unlimited tags & priority support.',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black.withOpacity(0.7),
                          height: 1.3,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // ✅ Premium Get Membership Button - Clickable
                      GestureDetector(
                        onTap: _openMembershipPage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: AppColors.primaryYellow,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Get Membership',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryYellow,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Premium close button
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: _handleDismiss,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.black.withOpacity(0.8),
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
