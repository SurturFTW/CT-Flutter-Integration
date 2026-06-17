import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Small "N active display unit(s) — LIVE" banner shown at the top of the
/// Tools tab whenever display units have been fetched.
class DisplayUnitsBanner extends StatelessWidget {
  const DisplayUnitsBanner({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.tealDim,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.teal.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign_rounded, size: 16, color: AppColors.teal),
          const SizedBox(width: 8),
          Text(
            '$count active display unit${count == 1 ? '' : 's'}',
            style: const TextStyle(
              color: AppColors.teal,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: AppColors.teal,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}