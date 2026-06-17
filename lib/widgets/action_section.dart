import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Data for a single tappable action row inside an [ActionSection].
class ActionTileData {
  const ActionTileData({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;
}

/// Small uppercase label with a leading icon, used above an [ActionSection].
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
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

/// A titled card containing a list of [ActionTileData] rows, separated by
/// thin dividers. This is the same look every tab used to build inline —
/// now shared so Profile / Events / Tools / Product Experiences all match.
class ActionSection extends StatelessWidget {
  const ActionSection({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.tiles,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final List<ActionTileData> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(label: label, icon: icon, iconColor: iconColor),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int i = 0; i < tiles.length; i++) ...[
                ActionListTile(data: tiles[i]),
                if (i < tiles.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: AppColors.borderSubtle,
                    indent: 56,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class ActionListTile extends StatefulWidget {
  const ActionListTile({super.key, required this.data});
  final ActionTileData data;

  @override
  State<ActionListTile> createState() => _ActionListTileState();
}

class _ActionListTileState extends State<ActionListTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        d.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _pressed ? AppColors.surfaceHighlight : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: d.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                d.icon,
                size: 18,
                color: d.color,
              ),
            ),
            const SizedBox(width: 14),
            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    d.subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (d.trailing != null) ...[
              const SizedBox(width: 8),
              d.trailing!,
            ],
          ],
        ),
      ),
    );
  }
}