import 'package:flutter/material.dart';
import 'app_colors.dart';

enum SnackType {
  success(Icons.check_circle_outline_rounded, AppColors.success),
  error(Icons.error_outline_rounded, AppColors.error),
  info(Icons.info_outline_rounded, AppColors.info),
  warning(Icons.warning_amber_rounded, AppColors.warning);

  const SnackType(this.icon, this.color);
  final IconData icon;
  final Color color;
}
