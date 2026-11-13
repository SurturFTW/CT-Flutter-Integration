import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/clevertap_service.dart';
import '../widgets/action_section.dart';
import '../widgets/ct_dynamic_props_dialog.dart';
import '../widgets/premium_dialog.dart';
import '../utils/ct_snack.dart';

class ProductExperiencesTab extends StatelessWidget {
  const ProductExperiencesTab({
    super.key,
    required this.onFintech,
    required this.onOtt,
    required this.onMore,
    required this.hasDisplayUnits,
    required this.displayUnitsCount,
    required this.onNavigateNativeDisplayPage,
    required this.onNavigateCustomHtmlPage,
    required this.onNavigateRichPushPage,
  });

  final VoidCallback onFintech;
  final VoidCallback onOtt;
  final VoidCallback onMore;
  final bool hasDisplayUnits;
  final int displayUnitsCount;
  final VoidCallback onNavigateNativeDisplayPage;
  final VoidCallback onNavigateCustomHtmlPage;
  final VoidCallback onNavigateRichPushPage;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        children: [
          ActionSection(
            label: 'Pages',
            icon: Icons.explore_outlined,
            iconColor: AppColors.emerald,
            tiles: [
              ActionTileData(
                label: 'Native Display Page',
                subtitle: hasDisplayUnits
                    ? '$displayUnitsCount unit(s) available'
                    : 'Browse display unit gallery',
                icon: Icons.open_in_new_rounded,
                color: AppColors.coral,
                onTap: onNavigateNativeDisplayPage,
                trailing: _arrow,
              ),
              ActionTileData(
                label: 'Custom HTML Page',
                subtitle: 'WebView with custom markup',
                icon: Icons.code_rounded,
                color: AppColors.rose,
                onTap: onNavigateCustomHtmlPage,
                trailing: _arrow,
              ),
              ActionTileData(
                label: 'Rich Push Templates',
                subtitle: 'Push notifications with media',
                icon: Icons.notifications_active_outlined,
                color: AppColors.rose,
                onTap: onNavigateRichPushPage,
                trailing: _arrow,
              ),
              ActionTileData(
                label: 'Show Popup',
                subtitle: 'Example dialog with actions',
                icon: Icons.auto_awesome_outlined,
                color: AppColors.amber,
                onTap: () {
                  CleverTapService().suspendInAppNotifications();
                  showDialog(
                    context: context,
                    barrierColor: Colors.black.withValues(alpha: 0.7),
                    builder: (ctx) => PremiumDialog(
                      title: 'Sample Popup',
                      message:
                          'This is how a production-grade popup looks in your CleverTap demo app.',
                      icon: Icons.auto_awesome_rounded,
                      iconColor: AppColors.accent,
                      onAction: () {
                        ctSnack(context,
                            message: 'Action triggered!',
                            type: SnackType.success);
                        CleverTapService().resumeInAppNotifications();
                      },
                      actionLabel: 'Got it',
                      onDismiss: () =>
                          CleverTapService().resumeInAppNotifications(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
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
                trailing: _arrow,
              ),
              ActionTileData(
                label: 'OTT PE',
                subtitle: 'OTT product experience demo',
                icon: Icons.movie_outlined,
                color: AppColors.accent,
                onTap: onOtt,
                trailing: _arrow,
              ),
              ActionTileData(
                label: 'More PE Demos',
                subtitle: 'Coming soon',
                icon: Icons.upcoming_outlined,
                color: AppColors.accent,
                onTap: onMore,
                trailing: _arrow,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const _arrow = Icon(
    Icons.arrow_forward_ios_rounded,
    size: 12,
    color: AppColors.textTertiary,
  );
}
