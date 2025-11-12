import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/material.dart';

class CustomHtmlPage extends StatefulWidget {
  const CustomHtmlPage({super.key});

  @override
  State<CustomHtmlPage> createState() => _CustomHtmlPageState();
}

class _CustomHtmlPageState extends State<CustomHtmlPage> {
  void _triggerEvent(String eventName, String message) {
    try {
      CleverTapPlugin.recordEvent(eventName, {});
      _showSuccessSnackBar(message);
    } catch (e) {
      _showErrorSnackBar("Error: $e");
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildActionCard({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: onPressed != null ? color : Colors.grey,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: onPressed != null ? Colors.black87 : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Custom HTML Page'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Section
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.html,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Custom HTML In-Apps',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Trigger events to show HTML in-app messages',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Grid of Action Cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildActionCard(
                        onPressed: () => _triggerEvent(
                          "Product View Action",
                          "Product View Action triggered",
                        ),
                        icon: Icons.visibility,
                        label: 'NPS Rating',
                        color: Colors.teal,
                      ),
                      _buildActionCard(
                        onPressed: () => _triggerEvent(
                          "Scratch Card",
                          "Scratch Card event triggered",
                        ),
                        icon: Icons.card_giftcard,
                        label: 'Scratch Card',
                        color: Colors.orange,
                      ),
                      _buildActionCard(
                        onPressed: () => _triggerEvent(
                          "Cart View",
                          "Draggable Video event triggered",
                        ),
                        icon: Icons.card_giftcard,
                        label: 'Draggable Video',
                        color: Colors.blue,
                      ),
                      _buildActionCard(
                        onPressed: () => _triggerEvent(
                          "Timer InApp",
                          "Timer InApp event triggered",
                        ),
                        icon: Icons.timer,
                        label: 'Timer InApp',
                        color: Colors.blue,
                      ),
                      _buildActionCard(
                        onPressed: () => _triggerEvent(
                          "In-App Test",
                          "In-App Test event triggered",
                        ),
                        icon: Icons.textsms,
                        label: 'In-App Test',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
