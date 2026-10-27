import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/visitor.dart';
import '../../../providers/visitor_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/status_chip.dart';
import 'visitor_form_screen.dart';

/// Screen displaying complete details of a visitor, their QR code, and check-in/out actions.
class VisitorDetailsScreen extends ConsumerStatefulWidget {
  final Visitor initialVisitor;

  const VisitorDetailsScreen({
    super.key,
    required this.initialVisitor,
  });

  @override
  ConsumerState<VisitorDetailsScreen> createState() => _VisitorDetailsScreenState();
}

class _VisitorDetailsScreenState extends ConsumerState<VisitorDetailsScreen> {
  late Visitor _visitor;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _visitor = widget.initialVisitor;
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
          content: Text('Cannot check in: Visitor is not in Registered status.'),
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
          content: Text('Cannot check out: Visitor is not currently Checked In.'),
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
            content: Text('Visitor deleted successfully.'),
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

  @override
  Widget build(BuildContext context) {
    // Keep local visitor in sync with provider if updated elsewhere
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
            tooltip: 'Delete',
            onPressed: _isActionLoading ? null : _handleDelete,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshVisitor,
        color: AppColors.primaryNavy,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. QR Code Card
              _buildQrCodeCard(),
              const SizedBox(height: 16),

              // 2. Primary Status & Action Card
              _buildStatusAndActionCard(),
              const SizedBox(height: 16),

              // 3. Visitor Profile Details Card
              _buildProfileDetailsCard(),
              const SizedBox(height: 16),

              // 4. Timestamps Card
              _buildTimestampsCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrCodeCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          children: [
            const Text(
              'Visitor Pass QR Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Scan at security checkpoint to lookup details',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Exact server-assigned ID encoded in QR
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
                size: 180,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
            const SizedBox(height: 14),

            // Server-assigned ID badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tag, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'ID: ${_visitor.id}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusAndActionCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                StatusChip(status: _visitor.status),
              ],
            ),
            const SizedBox(height: 16),

            // Primary Check-In / Check-Out Action Button
            if (_visitor.isRegistered) ...[
              AppButton(
                label: 'Check In Visitor',
                icon: Icons.login,
                onPressed: _handleCheckIn,
                isLoading: _isActionLoading,
                backgroundColor: AppColors.accentTeal,
              ),
            ] else if (_visitor.isCheckedIn) ...[
              AppButton(
                label: 'Check Out Visitor',
                icon: Icons.logout,
                onPressed: _handleCheckOut,
                isLoading: _isActionLoading,
                backgroundColor: AppColors.primaryNavy,
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.statusCheckedOutBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.statusCheckedOutBorder),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 20, color: AppColors.statusCheckedOutText),
                    SizedBox(width: 8),
                    Text(
                      'Visit Completed (Checked Out)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.statusCheckedOutText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailsCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visitor Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.person_outline, 'Name', _visitor.name),
            _buildDetailRow(Icons.phone_outlined, 'Mobile', _visitor.mobile),
            _buildDetailRow(
              Icons.email_outlined,
              'Email',
              _visitor.email ?? 'Not provided',
              isMuted: _visitor.email == null,
            ),
            _buildDetailRow(Icons.badge_outlined, 'Visitor Type', _visitor.visitorType),
            _buildDetailRow(Icons.apartment, 'Project', _visitor.project),
            _buildDetailRow(Icons.notes_outlined, 'Purpose', _visitor.purpose, isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestampsCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visit Activity Timestamps',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.app_registration,
              'Registration Time',
              DateFormatter.formatDateTime(_visitor.createdAt),
            ),
            _buildDetailRow(
              Icons.login,
              'Check-In Time',
              _visitor.checkInTime != null
                  ? DateFormatter.formatDateTime(_visitor.checkInTime)
                  : 'Pending check-in',
              isMuted: _visitor.checkInTime == null,
            ),
            _buildDetailRow(
              Icons.logout,
              'Check-Out Time',
              _visitor.checkOutTime != null
                  ? DateFormatter.formatDateTime(_visitor.checkOutTime)
                  : 'Pending check-out',
              isMuted: _visitor.checkOutTime == null,
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
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
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
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isMuted ? AppColors.textMuted : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
