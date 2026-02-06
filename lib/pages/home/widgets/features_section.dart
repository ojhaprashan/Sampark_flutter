import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  Future<void> _shareOnWhatsApp(BuildContext context) async {
    final message = 'Car Sampark tag, really useful for my car, i recomend try it once. https://app.ngf132.com/get-ngf?c=share';
    final whatsappUrl = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('WhatsApp is not installed on this device'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open WhatsApp'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Car Sampark Tag',
            style: TextStyle(
              fontSize: AppConstants.fontSizeSectionTitle,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall * 0.5),
          const Text(
            'Waterproof, durable and smart car & bike parking tag',
            style: TextStyle(
              fontSize: AppConstants.fontSizeCardDescription,
              fontWeight: FontWeight.w400,
              color: AppColors.textGrey,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          _buildFeaturesGrid(),
          const SizedBox(height: AppConstants.spacingSmall),
          _buildWhatsAppButton(context),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    final features = [
      FeatureItem(
        icon: Icons.phone_in_talk,
        label: 'Masked\nAudio Calls',
        color: const Color(0xFF2196F3),
        isWhatsApp: false,
      ),
      FeatureItem(
        icon: Icons.chat_bubble,
        label: 'WhatsApp\nNotifications',
        color: const Color(0xFF25D366),
        isWhatsApp: true,
      ),
      FeatureItem(
        icon: Icons.picture_as_pdf,
        label: 'PDF Tag\n(Offline Access)',
        color: const Color(0xFFE91E63),
        isWhatsApp: false,
      ),
      FeatureItem(
        icon: Icons.videocam,
        label: 'Masked\nVideo Calls',
        color: const Color(0xFF9C27B0),
        isWhatsApp: false,
      ),
      FeatureItem(
        icon: Icons.phone_callback,
        label: 'Call Back\nCaller',
        color: const Color(0xFF00BCD4),
        isWhatsApp: false,
      ),
      FeatureItem(
        icon: Icons.location_on,
        label: 'Check\nLocation',
        color: const Color(0xFF4CAF50),
        isWhatsApp: false,
      ),
      FeatureItem(
        icon: Icons.sms,
        label: 'Offline SMS\nAvailable',
        color: const Color(0xFFFF9800),
        isWhatsApp: false,
      ),
      FeatureItem(
        icon: Icons.headset_mic,
        label: 'Live Support\nAlways',
        color: const Color(0xFFF44336),
        isWhatsApp: false,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: AppConstants.spacingSmall * 0.5,
        mainAxisSpacing: AppConstants.spacingSmall * 0.5,
        childAspectRatio: 0.85,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return _buildFeatureItem(features[index]);
      },
    );
  }

  Widget _buildFeatureItem(FeatureItem feature) {
    const double iconSize = 28.0;
    const double containerSize = 56.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: feature.color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: feature.isWhatsApp
                ? Image.asset(
                    'assets/icons/whatsapp.png',
                    width: iconSize,
                    height: iconSize,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.chat_bubble,
                        size: iconSize,
                        color: feature.color,
                      );
                    },
                  )
                : Icon(
                    feature.icon,
                    size: iconSize,
                    color: feature.color,
                  ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall * 0.5),
        Flexible(
          child: Text(
            feature.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeSmallText,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWhatsAppButton(BuildContext context) {
    const double buttonIconSize = 22.0;

    return GestureDetector(
      onTap: () => _shareOnWhatsApp(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.paddingMedium,
          horizontal: AppConstants.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF25D366),
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius * 2.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/whatsapp.png',
              width: buttonIconSize,
              height: buttonIconSize,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.chat_bubble,
                  size: buttonIconSize,
                  color: Colors.white,
                );
              },
            ),
            const SizedBox(width: AppConstants.spacingSmall * 0.75),
            const Text(
              'Share us on WhatsApp',
              style: TextStyle(
                fontSize: AppConstants.fontSizeCardTitle,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureItem {
  final IconData icon;
  final String label;
  final Color color;
  final bool isWhatsApp;

  FeatureItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.isWhatsApp,
  });
}
