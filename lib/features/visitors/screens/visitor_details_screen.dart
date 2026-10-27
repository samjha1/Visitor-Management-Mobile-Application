import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/visitor.dart';
import '../../../providers/visitor_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/status_chip.dart';
import 'visitor_form_screen.dart';

/// Redesigned Visitor Details Screen showcasing an executive profile,
/// high-contrast QR pass, primary check-in/out transitions, and activity timeline.
class VisitorDetailsScreen extends ConsumerStatefulWidget {
  final Visitor initialVisitor;

  const VisitorDetailsScreen({super.key, required this.initialVisitor});

  @override
  ConsumerState<VisitorDetailsScreen> createState() =>
      _VisitorDetailsScreenState();
}

class _VisitorDetailsScreenState extends ConsumerState<VisitorDetailsScreen> {
  late Visitor _visitor;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _visitor = widget.initialVisitor;
  }

  /// Generate two-letter initials from visitor name
  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'V';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  /// Synchronize with latest state from Riverpod store or refresh from server
  Future<void> _refreshVisitor() async {
    try {
      final updated = await ref
          .read(visitorListProvider.notifier)
          .fetchAndSyncVisitor(_visitor.id);
      if (mounted) {
        setState(() => _visitor = updated);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  /// Handle Check-In action
  Future<void> _handleCheckIn() async {
    if (_isActionLoading) return;

    if (!_visitor.canCheckIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot check in: Visitor is not in Registered status.',
          ),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }

    setState(() => _isActionLoading = true);
    try {
      final updated = await ref
          .read(visitorListProvider.notifier)
          .checkIn(_visitor);

      if (mounted) {
        setState(() => _visitor = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_visitor.name} has checked in successfully.'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check-in failed: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  /// Handle Check-Out action
  Future<void> _handleCheckOut() async {
    if (_isActionLoading) return;

    if (!_visitor.canCheckOut) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot check out: Visitor is not currently Checked In.',
          ),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }

    setState(() => _isActionLoading = true);
    try {
      final updated = await ref
          .read(visitorListProvider.notifier)
          .checkOut(_visitor);

      if (mounted) {
        setState(() => _visitor = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_visitor.name} has checked out successfully.'),
            backgroundColor: AppColors.primaryNavy,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check-out failed: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  /// Open edit form
  Future<void> _handleEdit() async {
    final updated = await Navigator.of(context).push<Visitor>(
      MaterialPageRoute(
        builder: (_) => VisitorFormScreen(visitorToEdit: _visitor),
      ),
    );

    if (updated != null && mounted) {
      setState(() => _visitor = updated);
    }
  }

  /// Delete visitor with confirmation
  Future<void> _handleDelete() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Visitor Record',
      message:
          'Are you sure you want to delete ${_visitor.name}\'s record? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (!confirmed || !mounted) return;

    try {
      await ref.read(visitorListProvider.notifier).deleteVisitor(_visitor.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visitor record deleted successfully.'),
            backgroundColor: AppColors.primaryNavy,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  /// Copy visitor ID to clipboard
  void _copyVisitorId() {
    Clipboard.setData(ClipboardData(text: _visitor.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visitor ID "${_visitor.id}" copied to clipboard.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keep local visitor in sync with provider updates
    ref.listen<AsyncValue<List<Visitor>>>(visitorListProvider, (_, next) {
      next.whenData((list) {
        final found = list.where((v) => v.id == _visitor.id).firstOrNull;
        if (found != null && found != _visitor && mounted) {
          setState(() => _visitor = found);
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: _isActionLoading ? null : _handleEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.errorLight),
            tooltip: 'Delete Record',
            onPressed: _isActionLoading ? null : _handleDelete,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshVisitor,
        color: AppColors.primaryNavy,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTheme.maxContentWidth,
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Profile Header Hero Card
                  _buildProfileHeroCard(),
                  const SizedBox(height: 14),

                  // 2. Primary Action Bar (Check In / Check Out)
                  _buildPrimaryActionBar(),
                  const SizedBox(height: 14),

                  // 3. QR Identification Pass Card
                  _buildQrCodeCard(),
                  const SizedBox(height: 14),

                  // 4. Contact & Visit Information Card
                  _buildInformationCard(),
                  const SizedBox(height: 14),

                  // 5. Activity Timeline Card
                  _buildTimelineCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeroCard() {
    final avatarColor = AppColors.getAvatarColor(_visitor.name);
    final initials = _getInitials(_visitor.name);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            // Initials Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: avatarColor.withValues(alpha: 0.12),
              child: Text(
                initials,
                style: TextStyle(
                  color: avatarColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Name + Status + ID badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _visitor.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      StatusChip(status: _visitor.status, isCompact: true),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _copyVisitorId,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '#${_visitor.id}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.copy_rounded,
                                size: 11,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryActionBar() {
    if (_visitor.isRegistered) {
      return AppButton.primary(
        label: 'Check In Visitor',
        icon: Icons.login_rounded,
        onPressed: _handleCheckIn,
        isLoading: _isActionLoading,
        backgroundColor: AppColors.accentTeal,
      );
    } else if (_visitor.isCheckedIn) {
      return AppButton.primary(
        label: 'Check Out Visitor',
        icon: Icons.logout_rounded,
        onPressed: _handleCheckOut,
        isLoading: _isActionLoading,
        backgroundColor: AppColors.primaryNavy,
      );
    } else {
      // Completed Visit state
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.statusCheckedOutBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.statusCheckedOutBorder),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.done_all_rounded,
              size: 20,
              color: AppColors.statusCheckedOutText,
            ),
            SizedBox(width: 8),
            Text(
              'Visit Completed (Checked Out)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.statusCheckedOutText,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildQrCodeCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        child: Column(
          children: [
            const Text(
              'Visitor Pass QR Code',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'Scan at security checkpoint for identity verification',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // High contrast QR Image
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: QrImageView(
                data: _visitor.id,
                version: QrVersions.auto,
                size: 170,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
            const SizedBox(height: 14),

            // Server-assigned ID chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Text(
                'Visitor ID: ${_visitor.id}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visit & Contact Information',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            _buildDetailRow(
              Icons.phone_outlined,
              'Mobile Number',
              _visitor.mobile,
            ),
            _buildDetailRow(
              Icons.email_outlined,
              'Email Address',
              _visitor.email ?? 'Not provided',
              isMuted: _visitor.email == null,
            ),
            _buildDetailRow(
              Icons.badge_outlined,
              'Visitor Type',
              _visitor.visitorType,
            ),
            _buildDetailRow(
              Icons.apartment_rounded,
              'Assigned Project',
              _visitor.project,
            ),
            _buildDetailRow(
              Icons.notes_rounded,
              'Purpose of Visit',
              _visitor.purpose,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visit Activity Timeline',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            _buildTimelineItem(
              icon: Icons.app_registration_rounded,
              iconColor: AppColors.primaryNavy,
              title: 'Registration Time',
              timestamp: DateFormatter.formatDateTime(_visitor.createdAt),
              isComplete: true,
            ),
            _buildTimelineItem(
              icon: Icons.login_rounded,
              iconColor: AppColors.accentTeal,
              title: 'Check-In Time',
              timestamp: _visitor.checkInTime != null
                  ? DateFormatter.formatDateTime(_visitor.checkInTime)
                  : 'Pending check-in by front desk',
              isComplete: _visitor.checkInTime != null,
            ),
            _buildTimelineItem(
              icon: Icons.logout_rounded,
              iconColor: AppColors.statusCheckedOutText,
              title: 'Check-Out Time',
              timestamp: _visitor.checkOutTime != null
                  ? DateFormatter.formatDateTime(_visitor.checkOutTime)
                  : 'Pending visit completion',
              isComplete: _visitor.checkOutTime != null,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isMuted = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isMuted ? AppColors.textMuted : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String timestamp,
    required bool isComplete,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isComplete
                  ? iconColor.withValues(alpha: 0.1)
                  : AppColors.surfaceMuted,
              shape: BoxShape.circle,
              border: Border.all(
                color: isComplete
                    ? iconColor.withValues(alpha: 0.3)
                    : AppColors.borderLight,
              ),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isComplete ? iconColor : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  timestamp,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isComplete ? FontWeight.w500 : FontWeight.w400,
                    color: isComplete
                        ? AppColors.textSecondary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
