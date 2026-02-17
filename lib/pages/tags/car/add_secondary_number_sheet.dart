import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';

class AddSecondaryNumberSheet extends StatefulWidget {
  final String tagId;
  final String? existingSecondaryNumber;  // ✅ Optional existing secondary number

  const AddSecondaryNumberSheet({
    super.key,
    required this.tagId,
    this.existingSecondaryNumber,
  });

  @override
  State<AddSecondaryNumberSheet> createState() => _AddSecondaryNumberSheetState();
}

class _AddSecondaryNumberSheetState extends State<AddSecondaryNumberSheet> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // ✅ Pre-fill with existing secondary number if available
    if (widget.existingSecondaryNumber != null && widget.existingSecondaryNumber!.isNotEmpty) {
      _phoneController.text = widget.existingSecondaryNumber!;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveNumber() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    HapticFeedback.mediumImpact();

    if (mounted) {
      // Return the phone number to parent component
      Navigator.pop(context, _phoneController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.phone,
                          color: Colors.teal.shade600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Secondary Number',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizePageTitle,
                                fontWeight: FontWeight.w800,
                                color: AppColors.black,
                              ),
                            ),
                            Text(
                              'Tag ID: ${widget.tagId}',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeCardDescription,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Info message
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.activeYellow.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.activeYellow.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.black,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This number will receive notifications when your tag is scanned.',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeCardDescription,
                              color: AppColors.black,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Phone number field
                  Text(
                    'Phone Number',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeCardTitle,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    autofocus: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeCardTitle,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter 10-digit number',
                      hintStyle: TextStyle(
                        color: AppColors.textGrey,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(
                        Icons.phone,
                        color: Colors.teal.shade600,
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.lightGrey,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.lightGrey,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.activeYellow,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 1,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      if (value.length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                        return 'Please enter a valid Indian mobile number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveNumber,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.activeYellow,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: AppColors.black,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Save Number',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeButtonPriceText,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Cancel button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeButtonText,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
