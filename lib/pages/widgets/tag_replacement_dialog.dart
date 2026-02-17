import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';


class TagReplacementDialog {
  /// Show the Tag Replacement Dialog
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.cardPaddingLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Close Button
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),


                  // Membership Badge
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        size: 24,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Membership*',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSectionTitle,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),


                  // Title
                  Text(
                    'Tag Replacement.',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizePageTitle,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),


                  // Main Description
                  Text(
                    'We offer our premium subscribers, Free tag replacement. ',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeCardDescription,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'We do charge for Shipping and Manufacturing the tags.',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeCardDescription,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This helps us startup functional.',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeCardDescription,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),


                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You can ask for a new tag incase your old ones are broken, damaged or if you have our very old tags.',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeCardDescription,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We have NGF132 V2 Tags available now.',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeCardDescription,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),


                  // Price Section
                  Text(
                    'Pay Rs 201',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizePageTitle,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please do connect with Akanksha now.',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeCardDescription,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLarge),


                  // WhatsApp Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _openWhatsApp(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366), // WhatsApp green
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.buttonPaddingVertical,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.buttonBorderRadius,
                          ),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/whatsapp.png',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Order Tag Replacement.',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeCardTitle,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  /// Open WhatsApp conversation with Akanksha
  static Future<void> _openWhatsApp(BuildContext context) async {
    try {
      const phoneNumber = '+919876543210'; // Replace with actual Akanksha's number
      const message = 'Hi, I want to order a tag replacement (NGF132 V2)';


      final whatsappUrl =
          'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';


      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback: Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('WhatsApp is not installed'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening WhatsApp: $e');
    }
  }
}
