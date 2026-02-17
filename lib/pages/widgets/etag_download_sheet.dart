import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class ETagDownloadSheet extends StatefulWidget {
  final String tagId;
  final String plate;
  final String downloadUrl;
  final String pdfFile;
  final String message;
  final VoidCallback onClose;

  const ETagDownloadSheet({
    super.key,
    required this.tagId,
    required this.plate,
    required this.downloadUrl,
    required this.pdfFile,
    required this.message,
    required this.onClose,
  });

  @override
  State<ETagDownloadSheet> createState() => _ETagDownloadSheetState();
}

class _ETagDownloadSheetState extends State<ETagDownloadSheet> {
  bool _isDownloading = false;

  Future<void> _downloadETag() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final url = Uri.parse(widget.downloadUrl);
      
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('eTag download started'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not open download link'),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppConstants.borderRadius * 2),
                topRight: Radius.circular(AppConstants.borderRadius * 2),
              ),
            ),
            child: Column(
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: AppConstants.spacingMedium),
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingPage,
                        vertical: AppConstants.paddingLarge,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Header with eTag icon
                          _buildHeader(),
                          
                          const SizedBox(height: AppConstants.spacingSection),

                          // 2. Success Message Banner
                          Container(
                            padding: const EdgeInsets.all(AppConstants.cardPaddingMedium),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9), // Soft Green
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: AppConstants.iconSizeLarge,
                                ),
                                const SizedBox(width: AppConstants.spacingMedium),
                                Expanded(
                                  child: Text(
                                    widget.message,
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeCardDescription,
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppConstants.spacingLarge),
                          const Divider(height: 1, color: AppColors.lightGrey),
                          const SizedBox(height: AppConstants.spacingLarge),

                          // 3. Vehicle Plate
                          _buildLabel('Vehicle Plate'),
                          const SizedBox(height: AppConstants.spacingSmall),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: AppConstants.paddingMedium,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
                              border: Border.all(color: AppColors.lightGrey),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                widget.plate,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: AppConstants.spacingSection),

                          // 4. Tag ID
                          _buildLabel('Tag ID'),
                          const SizedBox(height: AppConstants.spacingSmall),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppConstants.paddingMedium),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
                              border: Border.all(color: AppColors.lightGrey),
                            ),
                            child: Text(
                              widget.tagId,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black,
                              ),
                            ),
                          ),

                          const SizedBox(height: AppConstants.spacingSection),

                          // 5. PDF File Info
                          _buildLabel('eTag File'),
                          const SizedBox(height: AppConstants.spacingSmall),
                          Container(
                            padding: const EdgeInsets.all(AppConstants.paddingMedium),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
                              border: Border.all(color: AppColors.lightGrey),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.red,
                                    size: AppConstants.iconSizeLarge,
                                  ),
                                ),
                                const SizedBox(width: AppConstants.spacingMedium),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.pdfFile,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'eTag PDF',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppConstants.spacingSection),

                          // 6. Info Box
                          Container(
                            padding: const EdgeInsets.all(AppConstants.cardPaddingMedium),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue.shade700,
                                  size: AppConstants.iconSizeMedium,
                                ),
                                const SizedBox(width: AppConstants.spacingMedium),
                                Expanded(
                                  child: Text(
                                    'Your eTag has been generated successfully. Download the PDF to get your electronic tag details.',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeSmallText,
                                      color: Colors.blue.shade900,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // 7. Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: AppConstants.buttonHeightMedium,
                                  child: OutlinedButton(
                                    onPressed: _isDownloading
                                        ? null
                                        : () {
                                            Navigator.pop(context);
                                            widget.onClose();
                                          },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.lightGrey,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppConstants.buttonBorderRadius,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Close',
                                      style: TextStyle(
                                        color: AppColors.textGrey,
                                        fontWeight: FontWeight.w600,
                                        fontSize: AppConstants.fontSizeButtonText,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacingMedium),
                              Expanded(
                                child: SizedBox(
                                  height: AppConstants.buttonHeightMedium,
                                  child: ElevatedButton(
                                    onPressed: _isDownloading ? null : _downloadETag,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.activeYellow,
                                      disabledBackgroundColor: AppColors.lightGrey.withOpacity(0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppConstants.buttonBorderRadius,
                                        ),
                                      ),
                                    ),
                                    child: _isDownloading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                AppColors.black,
                                              ),
                                            ),
                                          )
                                        : FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: const [
                                                Icon(
                                                  Icons.download_rounded,
                                                  size: 18,
                                                  color: AppColors.black,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'Download eTag',
                                                  style: TextStyle(
                                                    color: AppColors.black,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: AppConstants.fontSizeButtonText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingLarge),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper widget for Section Labels
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: AppConstants.fontSizeCardTitle,
        fontWeight: FontWeight.w600,
        color: AppColors.textGrey,
      ),
    );
  }

  // Helper widget for Header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryYellow,
            AppColors.darkYellow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_travel,
              color: AppColors.black,
              size: AppConstants.iconSizeGrid,
            ),
          ),
          const SizedBox(width: AppConstants.spacingLarge),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'eTag Generated',
                style: TextStyle(
                  fontSize: AppConstants.fontSizePageTitle,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Ready to download',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSubtitle,
                  color: Color(0xFF424242),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
