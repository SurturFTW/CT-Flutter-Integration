import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/material.dart';
import 'native_display_carousel_screen.dart';

// Shared color system — mirrors AppColors in main.dart
class _C {
  static const midnight = Color(0xFF080910);
  static const surface = Color(0xFF10111C);
  static const surfaceElevated = Color(0xFF181928);
  static const surfaceHighlight = Color(0xFF1F2035);
  static const borderSubtle = Color(0xFF22243A);

  static const accent = Color(0xFF6C63FF);
  static const accentDim = Color(0x2A6C63FF);

  static const success = Color(0xFF10B981);

  static const teal = Color(0xFF14B8A6);

  static const violet = Color(0xFF8B5CF6);
  static const violetDim = Color(0x1F8B5CF6);

  static const textPrimary = Color(0xFFF0EFFF);
  static const textSecondary = Color(0xFF9092AE);
  static const textTertiary = Color(0xFF4B4E6B);
}

// ─────────────────────────────────────────────
// NATIVE DISPLAY PAGE
// ─────────────────────────────────────────────

class NativeDisplayPage extends StatefulWidget {
  final List<Map<String, dynamic>> displayUnits;
  final Function(Map<String, dynamic>, String) onContentClick;
  final Function(String) onUnitViewed;

  const NativeDisplayPage({
    super.key,
    required this.displayUnits,
    required this.onContentClick,
    required this.onUnitViewed,
  });

  @override
  State<NativeDisplayPage> createState() => _NativeDisplayPageState();
}

class _NativeDisplayPageState extends State<NativeDisplayPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _displayUnits = [];
  bool _isLoading = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _displayUnits = widget.displayUnits;
    if (_displayUnits.isEmpty) _loadDisplayUnits();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadDisplayUnits() async {
    setState(() => _isLoading = true);
    try {
      final units = await CleverTapPlugin.getAllDisplayUnits();
      if (units != null && units.isNotEmpty) {
        setState(() {
          _displayUnits = units.map((item) {
            if (item is Map<String, dynamic>) return item;
            if (item is Map) return Map<String, dynamic>.from(item);
            return <String, dynamic>{};
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Error loading display units: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.midnight,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _C.midnight,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.borderSubtle),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 14,
            color: _C.textSecondary,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Display Units',
            style: TextStyle(
              color: _C.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          if (_displayUnits.isNotEmpty)
            Text(
              '${_displayUnits.length} unit${_displayUnits.length == 1 ? '' : 's'} loaded',
              style: const TextStyle(
                color: _C.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
      actions: [
        if (_displayUnits.isNotEmpty)
          _AppBarButton(
            icon: Icons.view_carousel_outlined,
            label: 'Carousel',
            onTap: _showCarouselView,
            color: _C.accent,
          ),
        const SizedBox(width: 6),
        _AppBarButton(
          icon: Icons.refresh_rounded,
          onTap: _loadDisplayUnits,
          color: _C.textSecondary,
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildSkeletonLoader();
    if (_displayUnits.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: _loadDisplayUnits,
      color: _C.accent,
      backgroundColor: _C.surface,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        itemCount: _displayUnits.length,
        itemBuilder: (ctx, i) => _DisplayUnitCard(
          unit: _displayUnits[i],
          index: i,
          onUnitViewed: widget.onUnitViewed,
          onContentClick: widget.onContentClick,
          onViewFull: () => _showUnitInCarousel(i),
        ),
      ),
    );
  }

  // ── Skeleton loading ───────────────────────

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      itemCount: 4,
      itemBuilder: (_, i) => AnimatedBuilder(
        animation: _shimmerController,
        builder: (_, __) => _ShimmerCard(
          animation: _shimmerController,
          delay: i * 0.12,
        ),
      ),
    );
  }

  // ── Empty state ────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _C.violetDim,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _C.violet.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.campaign_outlined,
                size: 36,
                color: _C.violet,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Display Units',
              style: TextStyle(
                color: _C.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Load display units from the home screen first, or pull to refresh.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _C.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            _PrimaryButton(
              label: 'Try Loading Again',
              icon: Icons.refresh_rounded,
              onTap: _loadDisplayUnits,
            ),
          ],
        ),
      ),
    );
  }

  void _showCarouselView() => _pushCarousel(0);
  void _showUnitInCarousel(int index) => _pushCarousel(index);

  void _pushCarousel(int index) {
    Navigator.of(context).push(_slideRoute(NativeDisplayCarouselScreen(
      displayUnits: _displayUnits,
      onContentClick: widget.onContentClick,
      onUnitViewed: widget.onUnitViewed,
      initialIndex: index,
    )));
  }

  PageRoute _slideRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, a, __) => page,
        transitionDuration: const Duration(milliseconds: 360),
        transitionsBuilder: (_, a, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// DISPLAY UNIT CARD
// ─────────────────────────────────────────────

class _DisplayUnitCard extends StatefulWidget {
  const _DisplayUnitCard({
    required this.unit,
    required this.index,
    required this.onUnitViewed,
    required this.onContentClick,
    required this.onViewFull,
  });

  final Map<String, dynamic> unit;
  final int index;
  final Function(String) onUnitViewed;
  final Function(Map<String, dynamic>, String) onContentClick;
  final VoidCallback onViewFull;

  @override
  State<_DisplayUnitCard> createState() => _DisplayUnitCardState();
}

class _DisplayUnitCardState extends State<_DisplayUnitCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnim = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  Color _hexColor(String hex) {
    try {
      final buf = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buf.write('ff');
      buf.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buf.toString(), radix: 16));
    } catch (_) {
      return _C.surface;
    }
  }

  String _getNestedValue(
      Map<String, dynamic> map, List<String> keys, String fallback) {
    dynamic cur = map;
    for (final k in keys) {
      if (cur is Map && cur.containsKey(k)) {
        cur = cur[k];
      } else {
        return fallback;
      }
    }
    return cur?.toString() ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final unitId = widget.unit['wzrk_id']?.toString() ?? 'Unknown';
    final unitType = widget.unit['type']?.toString() ?? 'Unknown';
    final bg = widget.unit['bg']?.toString() ?? '#6C63FF';
    final content = widget.unit['content'] as List<dynamic>? ?? [];
    final bgColor = _hexColor(bg);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header row ───────────────────────
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Color swatch + index
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: bgColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: bgColor.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: TextStyle(
                          color: bgColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Display Unit ${widget.index + 1}',
                          style: const TextStyle(
                            color: _C.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            _MetaBadge(
                              label: unitType.toUpperCase(),
                              color: _C.violet,
                            ),
                            const SizedBox(width: 6),
                            _MetaBadge(
                              label:
                                  '${content.length} item${content.length == 1 ? '' : 's'}',
                              color: _C.teal,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _C.textTertiary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable body ──────────────────
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Column(
              children: [
                const Divider(
                  height: 1,
                  thickness: 0.5,
                  color: _C.borderSubtle,
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metadata block
                      _MetaBlock(
                        rows: [
                          _MetaRow('Unit ID', unitId, mono: true),
                          _MetaRow('Background', bg),
                          _MetaRow('Timestamp',
                              widget.unit['ti']?.toString() ?? 'N/A'),
                          _MetaRow('Pivot',
                              widget.unit['wzrk_pivot']?.toString() ?? 'N/A'),
                        ],
                      ),

                      // Content items
                      if (content.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const _SectionLabel('Content Items'),
                        const SizedBox(height: 8),
                        ...content.asMap().entries.map((e) {
                          final item = e.value is Map<String, dynamic>
                              ? e.value as Map<String, dynamic>
                              : Map<String, dynamic>.from(e.value as Map);
                          return _ContentItemTile(
                            item: item,
                            unitId: unitId,
                            getNestedValue: _getNestedValue,
                            onTap: () => widget.onContentClick(item, unitId),
                          );
                        }),
                      ],

                      const SizedBox(height: 14),

                      // CTA row
                      Row(
                        children: [
                          Expanded(
                            child: _OutlineButton(
                              icon: Icons.visibility_outlined,
                              label: 'Mark Viewed',
                              onTap: () => widget.onUnitViewed(unitId),
                              color: _C.success,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _OutlineButton(
                              icon: Icons.fullscreen_rounded,
                              label: 'View Full',
                              onTap: widget.onViewFull,
                              color: _C.accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE SUB-COMPONENTS
// ─────────────────────────────────────────────

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _MetaRow {
  const _MetaRow(this.label, this.value, {this.mono = false});
  final String label;
  final String value;
  final bool mono;
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({required this.rows});
  final List<_MetaRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _C.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.borderSubtle),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final isLast = e.key == rows.length - 1;
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      e.value.label,
                      style: const TextStyle(
                        color: _C.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.value.value,
                      style: TextStyle(
                        color: _C.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        fontFamily: e.value.mono ? 'monospace' : null,
                        letterSpacing: e.value.mono ? 0.3 : 0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 6),
                const Divider(
                    height: 1, thickness: 0.5, color: _C.borderSubtle),
                const SizedBox(height: 6),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: _C.textTertiary,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _ContentItemTile extends StatefulWidget {
  const _ContentItemTile({
    required this.item,
    required this.unitId,
    required this.getNestedValue,
    required this.onTap,
  });

  final Map<String, dynamic> item;
  final String unitId;
  final String Function(Map<String, dynamic>, List<String>, String)
      getNestedValue;
  final VoidCallback onTap;

  @override
  State<_ContentItemTile> createState() => _ContentItemTileState();
}

class _ContentItemTileState extends State<_ContentItemTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.getNestedValue(widget.item, ['title', 'text'], '');
    final message = widget.getNestedValue(widget.item, ['message', 'text'], '');
    final mediaUrl = widget.getNestedValue(widget.item, ['media', 'url'], '');
    final contentKey = widget.item['key']?.toString() ?? '';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _pressed ? _C.surfaceHighlight : _C.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _C.borderSubtle),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _C.accentDim,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: mediaUrl.isNotEmpty
                  ? Image.network(
                      mediaUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        size: 20,
                        color: _C.textTertiary,
                      ),
                    )
                  : const Icon(
                      Icons.image_outlined,
                      size: 20,
                      color: _C.textTertiary,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: const TextStyle(
                        color: _C.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (message.isNotEmpty)
                    Text(
                      message,
                      style: const TextStyle(
                        color: _C.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (contentKey.isNotEmpty)
                    Text(
                      'key: $contentKey',
                      style: const TextStyle(
                        color: _C.textTertiary,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 11,
              color: _C.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlineButton extends StatefulWidget {
  const _OutlineButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 40,
        decoration: BoxDecoration(
          color: _pressed
              ? widget.color.withOpacity(0.15)
              : widget.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.color.withOpacity(_pressed ? 0.4 : 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 14, color: widget.color),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B84FF), Color(0xFF6C63FF)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBarButton extends StatelessWidget {
  const _AppBarButton({
    required this.icon,
    required this.onTap,
    required this.color,
    this.label,
  });

  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: EdgeInsets.symmetric(
          horizontal: label != null ? 12 : 10,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            if (label != null) ...[
              const SizedBox(width: 5),
              Text(
                label!,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Shimmer skeleton card ─────────────────────

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({
    required this.animation,
    required this.delay,
  });

  final AnimationController animation;
  final double delay;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final shimmerValue = ((animation.value - delay).clamp(0.0, 1.0));
        final shimmerColor = Color.lerp(
          _C.surfaceElevated,
          _C.surfaceHighlight,
          shimmerValue,
        )!;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 13,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 90,
                      height: 10,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
