import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../models/visitor.dart';
import '../../../providers/visitor_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dropdown_field.dart';
import '../../../shared/widgets/app_text_field.dart';
import 'visitor_details_screen.dart';

/// Screen for registering a new visitor or editing an existing visitor profile.
class VisitorFormScreen extends ConsumerStatefulWidget {
  final Visitor? visitorToEdit;

  const VisitorFormScreen({super.key, this.visitorToEdit});

  @override
  ConsumerState<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends ConsumerState<VisitorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _purposeController;

  late String _selectedVisitorType;
  late String _selectedProject;

  bool _isSubmitting = false;

  bool get _isEditing => widget.visitorToEdit != null;

  @override
  void initState() {
    super.initState();
    final visitor = widget.visitorToEdit;

    _nameController = TextEditingController(text: visitor?.name ?? '');
    _mobileController = TextEditingController(text: visitor?.mobile ?? '');
    _emailController = TextEditingController(text: visitor?.email ?? '');
    _purposeController = TextEditingController(text: visitor?.purpose ?? '');

    _selectedVisitorType =
        visitor?.visitorType ?? AppConstants.visitorTypeCustomer;
    _selectedProject = visitor?.project ?? AppConstants.projectA;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Prevent repeated submissions while request is in progress
    if (_isSubmitting) return;

    // Validate form inputs
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(visitorListProvider.notifier);

      if (_isEditing) {
        final original = widget.visitorToEdit!;
        final updated = await notifier.updateVisitorProfile(
          id: original.id,
          name: _nameController.text.trim(),
          mobile: _mobileController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          visitorType: _selectedVisitorType,
          project: _selectedProject,
          purpose: _purposeController.text.trim(),
          originalVisitor: original,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visitor profile updated successfully.'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.of(context).pop(updated);
      } else {
        final created = await notifier.registerVisitor(
          name: _nameController.text.trim(),
          mobile: _mobileController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          visitorType: _selectedVisitorType,
          project: _selectedProject,
          purpose: _purposeController.text.trim(),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visitor registered successfully! Pass created.'),
            backgroundColor: AppColors.successGreen,
          ),
        );

        // On successful registration, use returned visitor ID to open details screen with QR code
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => VisitorDetailsScreen(initialVisitor: created),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.errorRed,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Edit Visitor' : 'Register Visitor';
    final subtitle = _isEditing
        ? 'Update profile details (status & timestamps preserved)'
        : 'Generate a new digital pass for check-in';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTheme.maxContentWidth,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Context Information Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: AppColors.primaryNavy,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _isEditing
                                  ? 'Editing visitor profile preserves existing check-in status and timestamps.'
                                  : 'Fields marked with an asterisk (*) are required. A unique QR pass will be created on save.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 1: Contact Details Card
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Visitor Contact Information',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 1. Visitor Name (Required)
                            AppTextField(
                              controller: _nameController,
                              label: 'Visitor Full Name *',
                              hint: 'e.g. John Doe',
                              prefixIcon: Icons.person_outline_rounded,
                              textCapitalization: TextCapitalization.words,
                              validator: Validators.validateName,
                              enabled: !_isSubmitting,
                            ),
                            const SizedBox(height: 14),

                            // 2. Mobile Number (Required, exactly 10 digits)
                            AppTextField(
                              controller: _mobileController,
                              label: 'Mobile Number *',
                              hint: '10-digit number',
                              helperText: 'Must be exactly 10 numeric digits',
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: Validators.validateMobile,
                              enabled: !_isSubmitting,
                            ),
                            const SizedBox(height: 14),

                            // 3. Email Address (Optional)
                            AppTextField(
                              controller: _emailController,
                              label: 'Email Address (Optional)',
                              hint: 'name@example.com',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                              enabled: !_isSubmitting,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Section 2: Visit Destination & Purpose Card
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Visit Destination & Purpose',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 4. Visitor Type (Customer, Vendor, Other)
                            AppDropdownField<String>(
                              value: _selectedVisitorType,
                              label: 'Visitor Type *',
                              prefixIcon: Icons.badge_outlined,
                              items: AppConstants.visitorTypes
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _isSubmitting
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        setState(
                                          () => _selectedVisitorType = val,
                                        );
                                      }
                                    },
                              validator: (val) =>
                                  Validators.validateRequiredSelection(
                                    val,
                                    'visitor type',
                                  ),
                              enabled: !_isSubmitting,
                            ),
                            const SizedBox(height: 14),

                            // 5. Project (Project A, Project B, Project C)
                            AppDropdownField<String>(
                              value: _selectedProject,
                              label: 'Assigned Project *',
                              prefixIcon: Icons.apartment_rounded,
                              items: AppConstants.projects
                                  .map(
                                    (proj) => DropdownMenuItem(
                                      value: proj,
                                      child: Text(proj),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _isSubmitting
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        setState(() => _selectedProject = val);
                                      }
                                    },
                              validator: (val) =>
                                  Validators.validateRequiredSelection(
                                    val,
                                    'project',
                                  ),
                              enabled: !_isSubmitting,
                            ),
                            const SizedBox(height: 14),

                            // 6. Purpose of Visit (Required)
                            AppTextField(
                              controller: _purposeController,
                              label: 'Purpose of Visit *',
                              hint:
                                  'e.g. Site inspection, client meeting, vendor delivery',
                              prefixIcon: Icons.notes_rounded,
                              maxLines: 3,
                              textInputAction: TextInputAction.done,
                              validator: Validators.validatePurpose,
                              enabled: !_isSubmitting,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Actions: Cancel & Save
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: AppButton.secondary(
                            label: 'Cancel',
                            onPressed: _isSubmitting
                                ? null
                                : () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 6,
                          child: AppButton.primary(
                            label: _isEditing
                                ? 'Save Changes'
                                : 'Register & Create Pass',
                            onPressed: _submitForm,
                            isLoading: _isSubmitting,
                            icon: _isEditing
                                ? Icons.check_rounded
                                : Icons.qr_code_2_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
