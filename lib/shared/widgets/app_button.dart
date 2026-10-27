import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Reusable enterprise button with loading indicator and disabled state protection.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 48.0,
  });

  /// Factory for primary action buttons (Deep Navy or Accent Teal)
  factory AppButton.primary({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    Color? backgroundColor,
    double? width,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: backgroundColor ?? AppColors.primaryNavy,
      width: width,
    );
  }

  /// Factory for secondary / outlined action buttons
  factory AppButton.secondary({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    Color? foregroundColor,
    double? width,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      isOutlined: true,
      icon: icon,
      foregroundColor: foregroundColor ?? AppColors.primaryNavy,
      width: width,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget childContent;
    if (isLoading) {
      childContent = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined
                ? (foregroundColor ?? AppColors.primaryNavy)
                : Colors.white,
          ),
        ),
      );
    } else if (icon != null) {
      childContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    } else {
      childContent = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    Widget button;
    if (isOutlined) {
      button = OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? AppColors.primaryNavy,
          minimumSize: Size(width ?? double.infinity, height),
          side: BorderSide(
            color: effectiveOnPressed == null
                ? AppColors.borderLight
                : (foregroundColor ?? AppColors.borderMedium),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: childContent,
      );
    } else {
      button = ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryNavy,
          foregroundColor: foregroundColor ?? Colors.white,
          minimumSize: Size(width ?? double.infinity, height),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: childContent,
      );
    }

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }
}
