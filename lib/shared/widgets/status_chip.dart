import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Modern semantic status chip with subtle icon/dot and high-contrast typography.
class StatusChip extends StatelessWidget {
  final String status;
  final bool isCompact;

  const StatusChip({super.key, required this.status, this.isCompact = false});

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
        icon = Icons.check_circle_rounded;
        break;
      case AppConstants.statusCheckedOut:
        bg = AppColors.statusCheckedOutBg;
        text = AppColors.statusCheckedOutText;
        border = AppColors.statusCheckedOutBorder;
        icon = Icons.done_all_rounded;
        break;
      case AppConstants.statusRegistered:
      default:
        bg = AppColors.statusRegisteredBg;
        text = AppColors.statusRegisteredText;
        border = AppColors.statusRegisteredBorder;
        icon = Icons.schedule_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 12 : 14, color: text),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: text,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
