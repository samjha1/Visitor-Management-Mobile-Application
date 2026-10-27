import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Reusable semantic status chip for Registered, Checked In, and Checked Out states.
class StatusChip extends StatelessWidget {
  final String status;
  final bool isCompact;

  const StatusChip({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    Color border;
    IconData icon;

    switch (status) {
      case AppConstants.statusCheckedIn:
        bg = AppColors.statusCheckedInBg;
        text = AppColors.statusCheckedInText;
        border = AppColors.statusCheckedInBorder;
        icon = Icons.check_circle_outline;
        break;
      case AppConstants.statusCheckedOut:
        bg = AppColors.statusCheckedOutBg;
        text = AppColors.statusCheckedOutText;
        border = AppColors.statusCheckedOutBorder;
        icon = Icons.done_all;
        break;
      case AppConstants.statusRegistered:
      default:
        bg = AppColors.statusRegisteredBg;
        text = AppColors.statusRegisteredText;
        border = AppColors.statusRegisteredBorder;
        icon = Icons.how_to_reg_outlined;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 13 : 15, color: text),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: text,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
