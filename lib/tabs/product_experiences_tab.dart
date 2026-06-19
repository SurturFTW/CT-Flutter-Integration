import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../widgets/action_section.dart';

class ProductExperiencesTab extends StatelessWidget {
  const ProductExperiencesTab({
    super.key,
    required this.onFintech,
    required this.onOtt,
    required this.onHealth,
    required this.onMore,
  });

  final VoidCallback onFintech;
  final VoidCallback onOtt;
  final VoidCallback onHealth;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: ActionSection(
        label: 'Product Experiences',
        icon: Icons.star_outline_rounded,
        iconColor: AppColors.emerald,
        tiles: [
          ActionTileData(
            label: 'FinTech PE',
            subtitle: 'Fintech product experience demo',
            icon: Icons.account_balance_wallet_outlined,
            color: AppColors.accent,
            onTap: onFintech,
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: AppColors.textTertiary,
            ),
          ),
          ActionTileData(
            label: 'OTT PE',
            subtitle: 'OTT product experience demo',
            icon: Icons.movie_outlined,
            color: AppColors.accent,
            onTap: onOtt,
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: AppColors.textTertiary,
            ),
          ),
          ActionTileData(
            label: 'Health PE',
            subtitle: 'Health product experience demo',
            icon: Icons.health_and_safety_outlined,
            color: AppColors.accent,
            onTap: onHealth,
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: AppColors.textTertiary,
            ),
          ),
          ActionTileData(
            label: 'More PE Demos',
            subtitle: 'Coming soon',
            icon: Icons.upcoming_outlined,
            color: AppColors.accent,
            onTap: onMore,
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}