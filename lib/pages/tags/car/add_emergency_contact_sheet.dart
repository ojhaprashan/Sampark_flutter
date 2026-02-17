import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/emergency_service.dart';
import '../../../services/auth_service.dart';

class AddEmergencyContactSheet extends StatefulWidget {
  final String tagId;
  final String? existingPrimaryPhone;  // ✅ Optional existing primary phone
  final String? existingSecondaryPhone;  // ✅ Optional existing secondary phone
  final String? existingBloodGroup;  // ✅ Optional existing blood group
  final String? existingInsurance;  // ✅ Optional existing insurance
  final String? existingNote;  // ✅ Optional existing note

  const AddEmergencyContactSheet({
    super.key,
    required this.tagId,
    this.existingPrimaryPhone,
    this.existingSecondaryPhone,
    this.existingBloodGroup,
    this.existingInsurance,
    this.existingNote,
  });

  @override
  State<AddEmergencyContactSheet> createState() => _AddEmergencyContactSheetState();
}

class _AddEmergencyContactSheetState extends State<AddEmergencyContactSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _phone1Controller = TextEditingController();
  final TextEditingController _phone2Controller = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _insuranceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _status = 'Active';
  bool _isLoading = false;

  final List<String> _statusOptions = ['Active', 'Inactive'];
  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void initState() {
    super.initState();
    // ✅ Pre-fill with existing emergency contact data if available
    if (widget.existingPrimaryPhone != null && widget.existingPrimaryPhone!.isNotEmpty) {
      _phone1Controller.text = widget.existingPrimaryPhone!;
    }
    if (widget.existingSecondaryPhone != null && widget.existingSecondaryPhone!.isNotEmpty) {
      _phone2Controller.text = widget.existingSecondaryPhone!;
    }
    if (widget.existingBloodGroup != null && widget.existingBloodGroup!.isNotEmpty) {
      _bloodGroupController.text = widget.existingBloodGroup!;
    }
    if (widget.existingInsurance != null && widget.existingInsurance!.isNotEmpty) {
      _insuranceController.text = widget.existingInsurance!;
    }
    if (widget.existingNote != null && widget.existingNote!.isNotEmpty) {
      _noteController.text = widget.existingNote!;
    }
  }

  @override
  void dispose() {
    _vehicleController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _bloodGroupController.dispose();
    _insuranceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveEmergencyContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ✅ If status is Inactive, clear all fields
    if (_status == 'Inactive') {
      _phone1Controller.clear();
      _phone2Controller.clear();
      _bloodGroupController.clear();
      _insuranceController.clear();
      _noteController.clear();
    }

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.mediumImpact();

    try {
      // ✅ Get user data for phone
      final userData = await AuthService.getUserData();
      final userPhone = userData['phone'] ?? '';
      final countryCode = userData['countryCode'] ?? '+91';
      final phoneWithCountryCode = countryCode.replaceFirst('+', '') + userPhone;

      // ✅ Parse tagId to int
      final tagIdInt = int.tryParse(widget.tagId) ?? 0;

      // ✅ Call Emergency API to save
      await EmergencyService.updateEmergencyInfo(
        tagId: tagIdInt,
        phone: phoneWithCountryCode,
        phone1: _status == 'Active' ? _phone1Controller.text : null,
        phone2: _status == 'Active' ? _phone2Controller.text : null,
        bloodGroup: _status == 'Active' ? _bloodGroupController.text : null,
        insurance: _status == 'Active' ? _insuranceController.text : null,
        note: _status == 'Active' ? _noteController.text : null,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        Navigator.pop(context);
        _showSuccessMessage();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Emergency contact saved successfully!',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.contact_emergency,
                        color: Colors.purple.shade600,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency Details',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizePageTitle,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                          ),
                          Text(
                            'Add emergency contact information',
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
              ),

              const Divider(height: 1),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 180),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Status'),
                        _buildDropdown(
                          value: _status,
                          items: _statusOptions,
                          onChanged: (value) => setState(() => _status = value!),
                          icon: Icons.info_outline,
                          iconColor: Colors.blue.shade600,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Vehicle Number'),
                        _buildTextField(
                          controller: _vehicleController,
                          hintText: 'e.g., DL8CZ1342',
                          icon: Icons.directions_car,
                          iconColor: Colors.orange.shade600,
                          textCapitalization: TextCapitalization.characters,
                          enabled: _status == 'Active',
                          validator: (value) {
                            if (_status == 'Inactive') return null;
                            return value?.isEmpty ?? true ? 'Required' : null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Emergency Phone 1*'),
                        _buildTextField(
                          controller: _phone1Controller,
                          hintText: 'Enter 10-digit number',
                          icon: Icons.phone,
                          iconColor: Colors.red.shade600,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          enabled: _status == 'Active',
                          validator: (value) {
                            if (_status == 'Inactive') return null;
                            if (value?.isEmpty ?? true) return 'Required';
                            if (value!.length != 10) return 'Must be 10 digits';
                            if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) return 'Invalid number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Emergency Phone 2'),
                        _buildTextField(
                          controller: _phone2Controller,
                          hintText: 'Enter 10-digit number (optional)',
                          icon: Icons.phone,
                          iconColor: Colors.red.shade400,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          enabled: _status == 'Active',
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Your Blood Group'),
                        _buildDropdownTextField(
                          controller: _bloodGroupController,
                          hintText: 'Select blood group',
                          items: _bloodGroups,
                          icon: Icons.bloodtype,
                          iconColor: Colors.red.shade700,
                          enabled: _status == 'Active',
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Health Insurance Company'),
                        _buildTextField(
                          controller: _insuranceController,
                          hintText: 'e.g., ICICI Lombard',
                          icon: Icons.health_and_safety,
                          iconColor: Colors.green.shade600,
                          enabled: _status == 'Active',
                          validator: (value) {
                            if (_status == 'Inactive') return null;
                            return value?.isEmpty ?? true ? 'Required' : null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Your Note'),
                        _buildTextField(
                          controller: _noteController,
                          hintText: 'e.g., Call mom.',
                          icon: Icons.note_outlined,
                          iconColor: Colors.amber.shade700,
                          maxLines: 3,
                          enabled: _status == 'Active',
                        ),
                        const SizedBox(height: 16),

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
                              Icon(Icons.info_outline, color: AppColors.black, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'This information will be visible to people who scan your tag in case of emergency.',
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
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Floating Bottom Buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: AppColors.lightGrey.withOpacity(0.3), width: 1),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveEmergencyContact,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.activeYellow,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          disabledBackgroundColor: AppColors.lightGrey,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, size: 20, color: AppColors.black),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Save Emergency Contact',
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
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
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
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppConstants.fontSizeCardTitle,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color iconColor,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      inputFormatters: keyboardType == TextInputType.phone
          ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]
          : null,
      style: TextStyle(
        fontSize: AppConstants.fontSizeCardTitle,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: iconColor),
        filled: true,
        fillColor: AppColors.white,
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.activeYellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey, width: 1),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: iconColor),
          border: InputBorder.none,
        ),
        style: TextStyle(
          fontSize: AppConstants.fontSizeCardTitle,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildDropdownTextField({
    required TextEditingController controller,
    required String hintText,
    required List<String> items,
    required IconData icon,
    required Color iconColor,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? () => _showBloodGroupPicker(controller, items) : null,
      child: AbsorbPointer(
        absorbing: !enabled,
        child: TextFormField(
          controller: controller,
          enabled: enabled,
          style: TextStyle(
            fontSize: AppConstants.fontSizeCardTitle,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w500),
            prefixIcon: Icon(icon, color: iconColor),
            suffixIcon: Icon(Icons.keyboard_arrow_down, color: AppColors.textGrey),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.lightGrey, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.lightGrey, width: 1),
            ),
          ),
        ),
      ),
    );
  }

  void _showBloodGroupPicker(TextEditingController controller, List<String> items) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Blood Group',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSectionTitle,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      items[index],
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeCardTitle,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    onTap: () {
                      controller.text = items[index];
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
