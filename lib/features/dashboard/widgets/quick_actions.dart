import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/section_header.dart';

/// Reusable quick actions section for front-desk staff.
class QuickActions extends StatelessWidget {
  final VoidCallback onRegister;
  final VoidCallback onDirectory;
  final VoidCallback onScan;

  const QuickActions({
    super.key,
    required this.onRegister,
    required this.onDirectory,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Staff Operations',
          subtitle: 'Front desk and security actions',
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            // 1. Primary: Register Visitor
            Expanded(
              flex: 5,
              child: _buildActionCard(
                context,
                title: 'Register Visitor',
                subtitle: 'New visitor pass',
                icon: Icons.person_add_rounded,
                primaryColor: AppColors.primaryNavy,
                accentColor: AppColors.accentTeal,
                onTap: onRegister,
              ),
            ),
            const SizedBox(width: 10),

            // 2. Scan QR Pass
            Expanded(
              flex: 5,
              child: _buildActionCard(
                context,
                title: 'Scan QR Pass',
                subtitle: 'Check-in & lookup',
                icon: Icons.qr_code_scanner_rounded,
                primaryColor: AppColors.accentTealDark,
                accentColor: AppColors.accentTeal,
                onTap: onScan,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color primaryColor,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: primaryColor, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
