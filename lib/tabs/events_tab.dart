import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../widgets/action_section.dart';

class EventsTab extends StatelessWidget {
  const EventsTab({
    super.key,
    required this.onNotificationEvent,
    required this.onProductViewed,
    required this.onInAppEvent,
    required this.onChargedEvent,
    required this.onDeepLink,
  });

  final VoidCallback onNotificationEvent;
  final VoidCallback onProductViewed;
  final VoidCallback onInAppEvent;
  final VoidCallback onChargedEvent;
  final VoidCallback onDeepLink;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: ActionSection(
        label: 'Events',
        icon: Icons.bolt_outlined,
        iconColor: AppColors.amber,
        tiles: [
          ActionTileData(
            label: 'Notification Event',
            subtitle: 'Fire a notification trigger',
            icon: Icons.notifications_active_outlined,
            color: AppColors.amber,
            onTap: onNotificationEvent,
          ),
          ActionTileData(
            label: 'Product Viewed',
            subtitle: 'Premium Plan — PROD_123',
            icon: Icons.storefront_outlined,
            color: AppColors.emerald,
            onTap: onProductViewed,
          ),
          ActionTileData(
            label: 'In-App Event',
            subtitle: 'Trigger an in-app campaign',
            icon: Icons.phone_iphone_rounded,
            color: AppColors.violet,
            onTap: onInAppEvent,
          ),
          ActionTileData(
            label: 'Charged Event',
            subtitle: '₹498 — credit card, INR',
            icon: Icons.receipt_long_outlined,
            color: AppColors.teal,
            onTap: onChargedEvent,
          ),
          ActionTileData(
            label: 'Deep Link',
            subtitle: 'Open deep link page',
            icon: Icons.link,
            color: AppColors.pink,
            onTap: onDeepLink,
          ),
        ],
      ),
    );
  }
}