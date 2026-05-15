import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';

// Shared color system — mirrors AppColors in main.dart
class _C {
  static const midnight = Color(0xFF080910);
  static const surface = Color(0xFF10111C);
  static const surfaceElevated = Color(0xFF181928);
  static const surfaceHighlight = Color(0xFF1F2035);
  static const borderSubtle = Color(0xFF22243A);
  static const borderDefault = Color(0xFF2E3050);
  static const accent = Color(0xFF6C63FF);

  static const accentSoft = Color(0xFF8B84FF);
  static const success = Color(0xFF10B981);

  static const textPrimary = Color(0xFFF0EFFF);
  static const textSecondary = Color(0xFF9092AE);
  static const textTertiary = Color(0xFF4B4E6B);
}

// ─────────────────────────────────────────────
// NATIVE DISPLAY CAROUSEL SCREEN
// ─────────────────────────────────────────────

class NativeDisplayCarouselScreen extends StatefulWidget {
  final List<Map<String, dynamic>> displayUnits;
  final Function(Map<String, dynamic>, String) onContentClick;
  final Function(String) onUnitViewed;
  final int initialIndex;

  const NativeDisplayCarouselScreen({
    super.key,
    required this.displayUnits,
    required this.onContentClick,
    required this.onUnitViewed,
    this.initialIndex = 0,
  });

  @override
  State<NativeDisplayCarouselScreen> createState() =>
      _NativeDisplayCarouselScreenState();
}

class _NativeDisplayCarouselScreenState
    extends State<NativeDisplayCarouselScreen> with TickerProviderStateMixin {
  late PageController _unitPageController;
  late PageController _contentPageController;

  int _currentUnitIndex = 0;
  int _currentContentIndex = 0;

  // Panel animation
  late AnimationController _panelController;
  late Animation<Offset> _panelSlide;
  bool _panelVisible = false;

  @override
  void initState() {
    super.initState();
    _currentUnitIndex = widget.initialIndex;

    _unitPageController = PageController(
        initialPage: widget.initialIndex, viewportFraction: 0.88);
    _contentPageController = PageController(viewportFraction: 1.0);

    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _panelSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeOutCubic,
    ));

    // Make status bar transparent over the immersive view
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _unitPageController.dispose();
    _contentPageController.dispose();
    _panelController.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() => _panelVisible = !_panelVisible);
    if (_panelVisible) {
      _panelController.forward();
    } else {
      _panelController.reverse();
    }
  }

  Color _hexColor(String hex) {
    try {
      final buf = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buf.write('ff');
      buf.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buf.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFF6C63FF);
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

  Map<String, dynamic> get _currentUnit =>
      widget.displayUnits[_currentUnitIndex];

  List<dynamic> get _currentContent =>
      _currentUnit['content'] as List<dynamic>? ?? [];

  String get _currentUnitId => _currentUnit['wzrk_id']?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    if (widget.displayUnits.isEmpty) {
      return _buildEmptyScreen();
    }

    return Scaffold(
      backgroundColor: _C.midnight,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // ── Main scrollable carousel ──────────
          Column(
            children: [
              // Safe area spacer for app bar
              SizedBox(
                  height: MediaQuery.of(context).padding.top + kToolbarHeight),

              // Unit counter + progress
              _buildUnitProgress(),

              const SizedBox(height: 16),

              // Card carousel
              Expanded(
                child: PageView.builder(
                  controller: _unitPageController,
                  onPageChanged: (i) {
                    setState(() {
                      _currentUnitIndex = i;
                      _currentContentIndex = 0;
                      // Reset content page controller
                      _contentPageController =
                          PageController(viewportFraction: 1.0);
                    });
                    if (_currentUnitId.isNotEmpty) {
                      widget.onUnitViewed(_currentUnitId);
                      CleverTapPlugin.pushDisplayUnitViewedEvent(
                          _currentUnitId);
                    }
                  },
                  itemCount: widget.displayUnits.length,
                  itemBuilder: (ctx, unitIdx) {
                    final unit = widget.displayUnits[unitIdx];
                    final content = unit['content'] as List<dynamic>? ?? [];
                    final bg = unit['bg']?.toString() ?? '#6C63FF';

                    return _buildUnitCard(
                      unit: unit,
                      content: content,
                      bg: bg,
                      isActive: unitIdx == _currentUnitIndex,
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Unit dots
              _buildUnitDots(),

              const SizedBox(height: 20),

              // Action bar
              _buildActionBar(),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),

          // ── Slide-up info panel ───────────────
          SlideTransition(
            position: _panelSlide,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _InfoPanel(
                unit: _currentUnit,
                onClose: _togglePanel,
                getNestedValue: _getNestedValue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── App bar ──────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 14,
            color: Colors.white,
          ),
        ),
      ),
      title: const Text(
        'Display Carousel',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _togglePanel,
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 13, color: Colors.white70),
                const SizedBox(width: 5),
                Text(
                  'Details',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Unit progress bar ────────────────────────

  Widget _buildUnitProgress() {
    final total = widget.displayUnits.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            '${_currentUnitIndex + 1} / $total',
            style: const TextStyle(
              color: _C.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: ((_currentUnitIndex + 1) / total),
                backgroundColor: _C.borderSubtle,
                valueColor: const AlwaysStoppedAnimation<Color>(_C.accent),
                minHeight: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card carousel item ──────────────────────

  Widget _buildUnitCard({
    required Map<String, dynamic> unit,
    required List<dynamic> content,
    required String bg,
    required bool isActive,
  }) {
    return AnimatedScale(
      scale: isActive ? 1.0 : 0.94,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: content.isEmpty
            ? _buildEmptyCardState()
            : Column(
                children: [
                  // Content page view
                  Expanded(
                    child: PageView.builder(
                      controller: _contentPageController,
                      onPageChanged: (i) =>
                          setState(() => _currentContentIndex = i),
                      itemCount: content.length,
                      itemBuilder: (ctx, ci) => _ContentCard(
                        contentItem: content[ci],
                        unitId: unit['wzrk_id']?.toString() ?? '',
                        bgColor: _hexColor(bg),
                        onTap: (item) {
                          CleverTapPlugin.pushDisplayUnitClickedEvent(
                              unit['wzrk_id']?.toString() ?? '');
                          widget.onContentClick(
                              item, unit['wzrk_id']?.toString() ?? '');
                        },
                        getNestedValue: _getNestedValue,
                        hexColor: _hexColor,
                      ),
                    ),
                  ),

                  // Content dots
                  if (content.length > 1) ...[
                    const SizedBox(height: 16),
                    _ContentDots(
                      count: content.length,
                      current: _currentContentIndex,
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyCardState() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.borderSubtle),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_not_supported_outlined,
                size: 40, color: _C.textTertiary),
            SizedBox(height: 12),
            Text(
              'No content',
              style: TextStyle(color: _C.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ── Unit navigation dots ─────────────────────

  Widget _buildUnitDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.displayUnits.length, (i) {
        final isActive = i == _currentUnitIndex;
        return GestureDetector(
          onTap: () {
            _unitPageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutCubic,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            width: isActive ? 24 : 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: isActive ? _C.accent : _C.borderDefault,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  // ── Action bar ───────────────────────────────

  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Mark viewed
          Expanded(
            child: _FullButton(
              icon: Icons.visibility_outlined,
              label: 'Mark Viewed',
              color: _C.success,
              onTap: () {
                if (_currentUnitId.isNotEmpty) {
                  widget.onUnitViewed(_currentUnitId);
                  _showToast('Unit marked as viewed');
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          // Learn More / CTA
          Expanded(
            child: _FullButton(
              icon: Icons.open_in_new_rounded,
              label: 'Learn More',
              color: _C.accent,
              filled: true,
              onTap: () {
                if (_currentContent.isNotEmpty) {
                  final item = _currentContent[_currentContentIndex];
                  final mapped = item is Map<String, dynamic>
                      ? item
                      : Map<String, dynamic>.from(item as Map);
                  CleverTapPlugin.pushDisplayUnitClickedEvent(_currentUnitId);
                  widget.onContentClick(mapped, _currentUnitId);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                size: 15, color: _C.success),
            const SizedBox(width: 8),
            Text(message,
                style: const TextStyle(color: _C.textPrimary, fontSize: 13)),
          ],
        ),
        backgroundColor: _C.surfaceHighlight,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _C.success.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Scaffold(
      backgroundColor: _C.midnight,
      appBar: AppBar(
        backgroundColor: _C.midnight,
        title: const Text('Display Carousel',
            style: TextStyle(color: _C.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _C.textSecondary, size: 16),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: Text(
          'No display units available',
          style: TextStyle(color: _C.textSecondary),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CONTENT CARD (immersive full-height card)
// ─────────────────────────────────────────────

class _ContentCard extends StatefulWidget {
  const _ContentCard({
    required this.contentItem,
    required this.unitId,
    required this.bgColor,
    required this.onTap,
    required this.getNestedValue,
    required this.hexColor,
  });

  final dynamic contentItem;
  final String unitId;
  final Color bgColor;
  final Function(Map<String, dynamic>) onTap;
  final String Function(Map<String, dynamic>, List<String>, String)
      getNestedValue;
  final Color Function(String) hexColor;

  @override
  State<_ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<_ContentCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.contentItem is Map<String, dynamic>
        ? widget.contentItem as Map<String, dynamic>
        : Map<String, dynamic>.from(widget.contentItem as Map);

    final title = widget.getNestedValue(item, ['title', 'text'], '');
    final message = widget.getNestedValue(item, ['message', 'text'], '');
    final mediaUrl = widget.getNestedValue(item, ['media', 'url'], '');
    final titleColorHex =
        widget.getNestedValue(item, ['title', 'color'], '#F0EFFF');
    final messageColorHex =
        widget.getNestedValue(item, ['message', 'color'], '#9092AE');

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap(item);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.bgColor.withOpacity(0.25),
                blurRadius: 30,
                offset: const Offset(0, 12),
                spreadRadius: -5,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              if (mediaUrl.isNotEmpty)
                Image.network(
                  mediaUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: widget.bgColor,
                      child: Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                                Colors.white.withOpacity(0.4)),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: widget.bgColor,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 48,
                        color: Colors.white30,
                      ),
                    ),
                  ),
                )
              else
                // Decorative gradient background when no image
                Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topRight,
                      radius: 1.4,
                      colors: [
                        widget.bgColor.withOpacity(0.6),
                        widget.bgColor,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.campaign_outlined,
                      size: 80,
                      color: Colors.white12,
                    ),
                  ),
                ),

              // Gradient scrim (bottom)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.35, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.82),
                      ],
                    ),
                  ),
                ),
              ),

              // Top-left tap indicator
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.touch_app_outlined,
                          size: 11, color: Colors.white54),
                      SizedBox(width: 4),
                      Text(
                        'Tap to open',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Text content
              Positioned(
                left: 24,
                right: 24,
                bottom: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title.isNotEmpty) ...[
                      Text(
                        title,
                        style: TextStyle(
                          color: widget.hexColor(titleColorHex),
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          height: 1.2,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (message.isNotEmpty)
                      Text(
                        message,
                        style: TextStyle(
                          color: widget.hexColor(messageColorHex),
                          fontSize: 15,
                          height: 1.5,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (mediaUrl.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.image_outlined,
                              size: 12, color: Colors.white38),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              mediaUrl.split('/').last,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INFO PANEL (slide-up drawer)
// ─────────────────────────────────────────────

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.unit,
    required this.onClose,
    required this.getNestedValue,
  });

  final Map<String, dynamic> unit;
  final VoidCallback onClose;
  final String Function(Map<String, dynamic>, List<String>, String)
      getNestedValue;

  @override
  Widget build(BuildContext context) {
    final unitId = unit['wzrk_id']?.toString() ?? 'Unknown';
    final unitType = unit['type']?.toString() ?? 'Unknown';
    final bg = unit['bg']?.toString() ?? '#6C63FF';
    final pivot = unit['wzrk_pivot']?.toString() ?? 'N/A';
    final timestamp = unit['ti']?.toString() ?? 'N/A';
    final content = unit['content'] as List<dynamic>? ?? [];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: _C.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.borderDefault),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle + header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: _C.accentSoft),
                const SizedBox(width: 8),
                const Text(
                  'Unit Details',
                  style: TextStyle(
                    color: _C.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _C.surfaceHighlight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _C.borderSubtle),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: _C.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5, color: _C.borderSubtle),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow('Unit ID', unitId, mono: true),
                _InfoRow('Type', unitType),
                _InfoRow('Background', bg),
                _InfoRow('Pivot', pivot),
                _InfoRow('Timestamp', timestamp),
                _InfoRow('Content Items', content.length.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.mono = false});
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                color: _C.textTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: _C.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: mono ? 'monospace' : null,
                letterSpacing: mono ? 0.2 : 0,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED SMALL COMPONENTS
// ─────────────────────────────────────────────

class _ContentDots extends StatelessWidget {
  const _ContentDots({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: isActive ? 18 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _FullButton extends StatefulWidget {
  const _FullButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  @override
  State<_FullButton> createState() => _FullButtonState();
}

class _FullButtonState extends State<_FullButton> {
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
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: widget.filled
                ? const LinearGradient(
                    colors: [Color(0xFF8B84FF), Color(0xFF6C63FF)],
                  )
                : null,
            color: widget.filled
                ? null
                : widget.color.withOpacity(_pressed ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(14),
            border: widget.filled
                ? null
                : Border.all(
                    color: widget.color.withOpacity(_pressed ? 0.4 : 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon,
                  size: 15, color: widget.filled ? Colors.white : widget.color),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.filled ? Colors.white : widget.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
