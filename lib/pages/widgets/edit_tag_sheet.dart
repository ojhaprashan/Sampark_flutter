import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../services/tags_service.dart';
import '../../pages/tags/tags_page.dart';

class EditTagSheet extends StatefulWidget {
  final String vehicleNumber;
  final String tagId;
  final String phone;
  final VoidCallback? onConfirm;

  const EditTagSheet({
    super.key,
    required this.vehicleNumber,
    required this.tagId,
    required this.phone,
    this.onConfirm,
  });

  static void show(
    BuildContext context, {
    required String vehicleNumber,
    required String tagId,
    required String phone,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => EditTagSheet(
        vehicleNumber: vehicleNumber,
        tagId: tagId,
        phone: phone,
      ),
    );
  }

  @override
  State<EditTagSheet> createState() => _EditTagSheetState();
}

class _EditTagSheetState extends State<EditTagSheet> {
  bool _isLoading = false;

  void _handleEdit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get auth values
      const String smValue = '67s87s6yys66';
      const String dgValue = 'testYU78dII8iiUIPSISJ';

      print('🗑️ Attempting to delete tag...');
      print('📊 Tag ID: ${widget.tagId}, Phone: ${widget.phone}');

      // Call the delete tag API
      final response = await TagsService.deleteTag(
        tagId: widget.tagId,
        phone: widget.phone,
        smValue: smValue,
        dgValue: dgValue,
      );

      print('✅ Delete Tag Response: $response');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Close the bottom sheet
        Navigator.pop(context);

        // Navigate directly to TagsPage and remove all previous routes
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const TagsPage()),
              (route) => false, // Remove all routes
            );

            // Show success message after navigation
            Future.delayed(const Duration(milliseconds: 300), () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✅ Tag reset successfully. Please scan to reactivate.'),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ),
              );
            });
          }
        });
      }
    } catch (e) {
      print('❌ Error deleting tag: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Error'),
            content: Text('Failed to delete tag: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle Number
                  Text(
                    '#${widget.vehicleNumber}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  const Text(
                    'Edit and Make the Tag Empty?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    'You can scan the tag again and fillup new information, Please note once you click the button below you will need to enter all info again to activate it.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleEdit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'Edit and re-write tag',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}