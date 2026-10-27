import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../models/visitor.dart';
import '../../../providers/visitor_providers.dart';
import '../../../shared/widgets/app_button.dart';
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

    _selectedVisitorType = visitor?.visitorType ?? AppConstants.visitorTypeCustomer;
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
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
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
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          visitorType: _selectedVisitorType,
          project: _selectedProject,
          purpose: _purposeController.text.trim(),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visitor registered successfully!'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Note
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20, color: AppColors.primaryNavy),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _isEditing
                              ? 'Editing profile details preserves current status & timestamps.'
                              : 'All visits require staff registration before check-in.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 1. Visitor Name (Required)
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Visitor Name *',
                    hintText: 'e.g. John Doe',
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
                  ),
                  validator: Validators.validateName,
                  textInputAction: TextInputAction.next,
                  enabled: !_isSubmitting,
                ),
                const SizedBox(height: 16),

                // 2. Mobile Number (Required, exactly 10 digits)
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number *',
                    hintText: '10-digit number',
                    prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textSecondary),
                    helperText: 'Must be exactly 10 numeric digits',
                  ),
                  validator: Validators.validateMobile,
                  textInputAction: TextInputAction.next,
                  enabled: !_isSubmitting,
                ),
                const SizedBox(height: 16),

                // 3. Email (Optional, validate format if provided)
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address (Optional)',
                    hintText: 'name@example.com',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                  ),
                  validator: Validators.validateEmail,
                  textInputAction: TextInputAction.next,
                  enabled: !_isSubmitting,
                ),
                const SizedBox(height: 16),

                // 4. Visitor Type (Customer, Vendor, Other)
                DropdownButtonFormField<String>(
                  initialValue: _selectedVisitorType,
                  decoration: const InputDecoration(
                    labelText: 'Visitor Type *',
                    prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textSecondary),
                  ),
                  items: AppConstants.visitorTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (val) {
                          if (val != null) setState(() => _selectedVisitorType = val);
                        },
                  validator: (val) => Validators.validateRequiredSelection(val, 'visitor type'),
                ),
                const SizedBox(height: 16),

                // 5. Project (Project A, Project B, Project C)
                DropdownButtonFormField<String>(
                  initialValue: _selectedProject,
                  decoration: const InputDecoration(
                    labelText: 'Project *',
                    prefixIcon: Icon(Icons.apartment, color: AppColors.textSecondary),
                  ),
                  items: AppConstants.projects
                      .map((proj) => DropdownMenuItem(
                            value: proj,
                            child: Text(proj),
                          ))
                      .toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (val) {
                          if (val != null) setState(() => _selectedProject = val);
                        },
                  validator: (val) => Validators.validateRequiredSelection(val, 'project'),
                ),
                const SizedBox(height: 16),

                // 6. Purpose of Visit (Required)
                TextFormField(
                  controller: _purposeController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Purpose of Visit *',
                    hintText: 'e.g. Site inspection, vendor delivery, client meeting',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.notes_outlined, color: AppColors.textSecondary),
                    ),
                  ),
                  validator: Validators.validatePurpose,
                  textInputAction: TextInputAction.done,
                  enabled: !_isSubmitting,
                ),
                const SizedBox(height: 28),

                // Submit Button
                AppButton(
                  label: _isEditing ? 'Save Changes' : 'Register & Generate QR',
                  onPressed: _submitForm,
                  isLoading: _isSubmitting,
                  icon: _isEditing ? Icons.check : Icons.qr_code_2,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
