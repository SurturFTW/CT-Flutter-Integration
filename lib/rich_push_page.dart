import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class RichPushPage extends StatefulWidget {
  const RichPushPage({super.key});

  @override
  State<RichPushPage> createState() => _RichPushPageState();
}

class _RichPushPageState extends State<RichPushPage> {
  void _triggerRichPushEvent(String eventName, String message) {
    try {
      CleverTapPlugin.recordEvent(eventName, {});
      _showAppSnackBar(message: message, type: SnackType.success);
    } catch (e) {
      _showAppSnackBar(message: "Error: $e", type: SnackType.error);
    }
  }

  void _showAppSnackBar({
    required String message,
    required SnackType type,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(type.icon, size: 16, color: type.color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceHighlight,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: type.color.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceHighlight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Rich Push Templates',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.midnight,
              AppColors.midnight.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Card(
                    elevation: 0,
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_active_outlined,
                            size: 48,
                            color: AppColors.rose,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Push Notification Templates',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Trigger rich media push notifications with various templates',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Basic Templates Section
                  _buildSectionHeader(
                    label: 'Basic Templates',
                    icon: Icons.layers_outlined,
                    iconColor: AppColors.info,
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildActionCard(
                        onPressed: () => _triggerRichPushEvent(
                          "Rich Push",
                          "Basic push notification triggered",
                        ),
                        icon: Icons.message_outlined,
                        label: 'Basic',
                        subtitle: 'Simple text notification',
                        color: AppColors.info,
                      ),
                      _buildActionCard(
                        onPressed: () => _triggerRichPushEvent(
                          "Zero Bezel Push",
                          "Zero Bezel push triggered",
                        ),
                        icon: Icons.crop_square_rounded,
                        label: 'Zero Bezel',
                        subtitle: 'Full-width image notification',
                        color: AppColors.sky,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Carousel Section
                  _buildSectionHeader(
                    label: 'Carousel Templates',
                    icon: Icons.image_outlined,
                    iconColor: AppColors.teal,
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildActionCard(
                        onPressed: () => _triggerRichPushEvent(
                          "Manual Carousel Push",
                          "Manual Carousel push triggered",
                        ),
                        icon: Icons.swipe_rounded,
                        label: 'Manual Carousel',
                        subtitle: 'User-controlled carousel',
                        color: AppColors.teal,
                      ),
                      _buildActionCard(
                        onPressed: () => _triggerRichPushEvent(
                          "Auto Carousel Push",
                          "Auto Carousel push triggered",
                        ),
                        icon: Icons.autorenew_rounded,
                        label: 'Auto Carousel',
                        subtitle: 'Auto-scrolling images',
                        color: AppColors.emerald,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Timer Templates Section
                  _buildSectionHeader(
                    label: 'Timer Templates',
                    icon: Icons.timer_outlined,
                    iconColor: AppColors.amber,
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildActionCard(
                        onPressed: () => _triggerRichPushEvent(
                          "Timer Dynamic Countdown",
                          "Dynamic countdown timer triggered",
                        ),
                        icon: Icons.hourglass_bottom_rounded,
                        label: 'Timer (Countdown)',
                        subtitle: 'Dynamic countdown timer',
                        color: AppColors.amber,
                      ),
                      _buildActionCard(
                        onPressed: () => _triggerRichPushEvent(
                          "Timer Until Time",
                          "Timer until specified time triggered",
                        ),
                        icon: Icons.schedule_rounded,
                        label: 'Timer (Until Time)',
                        subtitle: 'Until mentioned time in seconds',
                        color: AppColors.coral,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Interactive Templates Section
                  _buildSectionHeader(
                    label: 'Interactive Templates',
                    icon: Icons.touch_app_outlined,
                    iconColor: AppColors.violet,
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildActionCard(
                        onPressed: () => _triggerRichPushEvent(
                          "Five Icons Push",
                          "Five-action push triggered",
                        ),
                        icon: Icons.widgets_outlined,
                        label: 'Five Icons',
                        subtitle: 'Multiple action buttons',
                        color: AppColors.violet,
                      ),
                      _buildActionCard(
                        onPressed: () => _triggerRichPushEvent(
                          "Rating Push",
                          "Star rating push triggered",
                        ),
                        icon: Icons.star_outline_rounded,
                        label: 'Rating',
                        subtitle: 'Star rating in-push interaction',
                        color: AppColors.pink,
                      ),
                      _buildActionCard(
                        onPressed: () => _triggerRichPushEvent(
                          "Input Push",
                          "Input field push triggered",
                        ),
                        icon: Icons.input_rounded,
                        label: 'Input',
                        subtitle: 'User text input field',
                        color: AppColors.sky,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Product Templates Section
                  _buildSectionHeader(
                    label: 'Product Templates',
                    icon: Icons.shopping_bag_outlined,
                    iconColor: AppColors.lime,
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildActionCard(
                        onPressed: () => _triggerRichPushEvent(
                          "Product Display Push",
                          "Product display push triggered",
                        ),
                        icon: Icons.local_offer_rounded,
                        label: 'Product Display',
                        subtitle: 'Product showcase template',
                        color: AppColors.lime,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String label,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 7),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
