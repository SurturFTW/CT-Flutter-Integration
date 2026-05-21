import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/material.dart';
import 'config/app_colors.dart';
import 'config/app_enums.dart';

class CustomHtmlPage extends StatefulWidget {
  const CustomHtmlPage({super.key});

  @override
  State<CustomHtmlPage> createState() => _CustomHtmlPageState();
}

class _CustomHtmlPageState extends State<CustomHtmlPage> {
  final TextEditingController _eventController = TextEditingController();

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  void _triggerEvent(String eventName, String message) {
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

  void _triggerEventFromText() {
    final eventName = _eventController.text.trim();
    if (eventName.isNotEmpty) {
      _triggerEvent(eventName, "Event '$eventName' triggered");
      _eventController.clear();
    } else {
      _showAppSnackBar(
        message: "Please enter an event name",
        type: SnackType.error,
      );
    }
  }

  Widget _buildActionCard({
    required VoidCallback? onPressed,
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
          'Custom HTML In-Apps',
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
                            Icons.html_rounded,
                            size: 48,
                            color: AppColors.accent,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Custom HTML In-Apps',
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
                            'Trigger events to show HTML in-app messages',
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

                  // Custom Event Input Section
                  _buildSectionHeader(
                    label: 'Custom Event',
                    icon: Icons.edit_outlined,
                    iconColor: AppColors.accent,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _eventController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Enter Event Name',
                            labelStyle: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            prefixIcon: const Icon(
                              Icons.event_outlined,
                              color: AppColors.accent,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.borderDefault,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.borderDefault,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.borderFocus,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.accent,
                                  AppColors.accentSoft,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _triggerEventFromText,
                                borderRadius: BorderRadius.circular(10),
                                child: const Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.send_rounded,
                                        color: AppColors.textOnAccent,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Fire Event',
                                        style: TextStyle(
                                          color: AppColors.textOnAccent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Predefined Events Section
                  _buildSectionHeader(
                    label: 'Predefined Events',
                    icon: Icons.event,
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
                        onPressed: () => _triggerEvent(
                          "NPS Rating",
                          "NPS Rating in-app triggered",
                        ),
                        icon: Icons.star_outline_rounded,
                        label: 'NPS Rating',
                        subtitle: 'Star rating in-app',
                        color: AppColors.teal,
                      ),
                      _buildActionCard(
                        onPressed: () => _triggerEvent(
                          "Scratch Card",
                          "Scratch Card in-app triggered",
                        ),
                        icon: Icons.card_giftcard_rounded,
                        label: 'Scratch Card',
                        subtitle: 'Interactive scratch card',
                        color: AppColors.amber,
                      ),
                      _buildActionCard(
                        onPressed: () => _triggerEvent(
                          "Cart View",
                          "Draggable Video in-app triggered",
                        ),
                        icon: Icons.play_circle_outline_rounded,
                        label: 'Draggable Video',
                        subtitle: 'Video with drag control',
                        color: AppColors.sky,
                      ),
                      _buildActionCard(
                        onPressed: () => _triggerEvent(
                          "Timer InApp",
                          "Timer in-app triggered",
                        ),
                        icon: Icons.timer_outlined,
                        label: 'Timer InApp',
                        subtitle: 'Countdown timer in-app',
                        color: AppColors.coral,
                      ),
                      _buildActionCard(
                        onPressed: () => _triggerEvent(
                          "Native Scratch Card",
                          "Native Scratch Card triggered",
                        ),
                        icon: Icons.screen_search_desktop_rounded,
                        label: 'Native Scratch',
                        subtitle: 'Native scratch card',
                        color: AppColors.violet,
                      ),
                      _buildActionCard(
                        onPressed: () => _triggerEvent(
                          "In-App Test",
                          "Test in-app message triggered",
                        ),
                        icon: Icons.message_outlined,
                        label: 'Test In-App',
                        subtitle: 'Test message template',
                        color: AppColors.emerald,
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
