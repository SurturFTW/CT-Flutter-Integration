import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../widgets/action_section.dart';
import '../widgets/display_units_banner.dart';

/// Combines what used to be three separate sections on the home page —
/// Campaigns, Display & Inbox, and Navigation — into a single "Tools" tab.
class ToolsTab extends StatelessWidget {
  const ToolsTab({
    super.key,
    required this.hasDisplayUnits,
    required this.displayUnitsCount,
    required this.onEmailCampaign,
    required this.onRichPush,
    required this.onLinkedContent,
    required this.onMedicalCondition,
    required this.onOpenInbox,
    required this.onNativeDisplayEvent,
    required this.onGetDisplayUnits,
    required this.onNavigateNativeDisplayPage,
    required this.onNavigateCustomHtmlPage,
    required this.onNavigateRichPushPage,
    required this.onShowPopup,
  });

  final bool hasDisplayUnits;
  final int displayUnitsCount;
  final VoidCallback onEmailCampaign;
  final VoidCallback onRichPush;
  final VoidCallback onLinkedContent;
  final VoidCallback onMedicalCondition;
  final VoidCallback onOpenInbox;
  final VoidCallback onNativeDisplayEvent;
  final VoidCallback onGetDisplayUnits;
  final VoidCallback onNavigateNativeDisplayPage;
  final VoidCallback onNavigateCustomHtmlPage;
  final VoidCallback onNavigateRichPushPage;
  final VoidCallback onShowPopup;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasDisplayUnits) ...[
            DisplayUnitsBanner(count: displayUnitsCount),
            const SizedBox(height: 20),
          ],
          ActionSection(
            label: 'Campaigns',
            icon: Icons.campaign_outlined,
            iconColor: AppColors.sky,
            tiles: [
              ActionTileData(
                label: 'Email Campaign',
                subtitle: 'Heart rate health event',
                icon: Icons.mail_outline_rounded,
                color: AppColors.sky,
                onTap: onEmailCampaign,
              ),
              ActionTileData(
                label: 'Rich Push',
                subtitle: 'Media-rich notification',
                icon: Icons.circle_notifications_outlined,
                color: AppColors.rose,
                onTap: onRichPush,
              ),
              ActionTileData(
                label: 'Linked Content',
                subtitle: 'Dynamic content fetch',
                icon: Icons.link_rounded,
                color: AppColors.lime,
                onTap: onLinkedContent,
              ),
              ActionTileData(
                label: 'Medical Condition',
                subtitle: 'POP Remove Cart event',
                icon: Icons.medical_services_outlined,
                color: AppColors.coral,
                onTap: onMedicalCondition,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Display & Inbox',
            icon: Icons.dashboard_outlined,
            iconColor: AppColors.pink,
            tiles: [
              ActionTileData(
                label: 'App Inbox',
                subtitle: 'Open message center',
                icon: Icons.inbox_outlined,
                color: AppColors.teal,
                onTap: onOpenInbox,
              ),
              ActionTileData(
                label: 'Native Display',
                subtitle: 'Render display units natively',
                icon: Icons.display_settings_outlined,
                color: AppColors.violet,
                onTap: onNativeDisplayEvent,
              ),
              ActionTileData(
                label: 'Get Display Units',
                subtitle: 'Fetch & cache all units',
                icon: Icons.view_list_outlined,
                color: AppColors.pink,
                onTap: onGetDisplayUnits,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Navigation',
            icon: Icons.explore_outlined,
            iconColor: AppColors.emerald,
            tiles: [
              ActionTileData(
                label: 'Native Display Page',
                subtitle: 'Browse display unit gallery',
                icon: Icons.open_in_new_rounded,
                color: AppColors.coral,
                onTap: onNavigateNativeDisplayPage,
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              ActionTileData(
                label: 'Custom HTML Page',
                subtitle: 'WebView with custom markup',
                icon: Icons.code_rounded,
                color: AppColors.rose,
                onTap: onNavigateCustomHtmlPage,
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              ActionTileData(
                label: 'Rich Push Templates',
                subtitle: 'Push notifications with media',
                icon: Icons.notifications_active_outlined,
                color: AppColors.rose,
                onTap: onNavigateRichPushPage,
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              ActionTileData(
                label: 'Show Popup',
                subtitle: 'Example dialog with actions',
                icon: Icons.auto_awesome_outlined,
                color: AppColors.amber,
                onTap: onShowPopup,
              ),
            ],
          ),
        ],
      ),
    );
  }
}