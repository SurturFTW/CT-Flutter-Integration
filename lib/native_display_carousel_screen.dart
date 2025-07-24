import 'package:flutter/material.dart';

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
    extends State<NativeDisplayCarouselScreen> {
  PageController? _unitPageController;
  PageController _contentPageController = PageController();
  int _currentUnitIndex = 0;
  int _currentContentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentUnitIndex = widget.initialIndex;
    _unitPageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _unitPageController?.dispose();
    _contentPageController.dispose();
    super.dispose();
  }

  Color _hexToColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.displayUnits.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Native Display Carousel')),
        body: const Center(
          child: Text('No display units available'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Native Display Carousel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Unit ${_currentUnitIndex + 1}/${widget.displayUnits.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Display Unit Info
          Container(
            padding: const EdgeInsets.all(16),
            child:
                _buildDisplayUnitInfo(widget.displayUnits[_currentUnitIndex]),
          ),

          // Main Carousel
          Expanded(
            child: PageView.builder(
              controller: _unitPageController,
              onPageChanged: (index) {
                setState(() {
                  _currentUnitIndex = index;
                  _currentContentIndex = 0;
                });
                String unitId =
                    widget.displayUnits[index]['wzrk_id']?.toString() ?? '';
                if (unitId.isNotEmpty) {
                  widget.onUnitViewed(unitId);
                }
              },
              itemCount: widget.displayUnits.length,
              itemBuilder: (context, unitIndex) {
                return _buildDisplayUnitCarousel(
                    widget.displayUnits[unitIndex]);
              },
            ),
          ),

          // Bottom Controls
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Unit Navigation Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.displayUnits.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: index == _currentUnitIndex ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: index == _currentUnitIndex
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // CTA Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final currentUnit =
                          widget.displayUnits[_currentUnitIndex];
                      final content =
                          currentUnit['content'] as List<dynamic>? ?? [];
                      if (content.isNotEmpty) {
                        final contentItem = content[_currentContentIndex];
                        widget.onContentClick(
                          contentItem is Map<String, dynamic>
                              ? contentItem
                              : Map<String, dynamic>.from(contentItem as Map),
                          currentUnit['wzrk_id']?.toString() ?? '',
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Learn More',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayUnitInfo(Map<String, dynamic> unit) {
    String unitId = unit['wzrk_id']?.toString() ?? 'Unknown';
    String unitType = unit['type']?.toString() ?? 'Unknown';
    String backgroundColor = unit['bg']?.toString() ?? '#FFFFFF';
    int timestamp = unit['ti'] ?? 0;
    String pivot = unit['wzrk_pivot']?.toString() ?? 'Unknown';

    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Display Unit Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('ID:', unitId),
            _buildInfoRow('Type:', unitType),
            _buildInfoRow('Background:', backgroundColor),
            _buildInfoRow('Pivot:', pivot),
            _buildInfoRow('Timestamp:', timestamp.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayUnitCarousel(Map<String, dynamic> unit) {
    String backgroundColor = unit['bg']?.toString() ?? '#FFFFFF';
    List<dynamic> content = unit['content'] ?? [];

    if (content.isEmpty) {
      return Center(
        child: Text(
          'No content available',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Content Carousel
          Expanded(
            child: PageView.builder(
              controller: _contentPageController,
              onPageChanged: (index) {
                setState(() {
                  _currentContentIndex = index;
                });
              },
              itemCount: content.length,
              itemBuilder: (context, contentIndex) {
                return _buildContentCard(
                  content[contentIndex],
                  unit['wzrk_id']?.toString() ?? '',
                  backgroundColor,
                );
              },
            ),
          ),

          // Content Navigation Dots
          if (content.length > 1) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                content.length,
                (index) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentContentIndex
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContentCard(
      dynamic contentItem, String unitId, String backgroundColor) {
    Map<String, dynamic> item = contentItem is Map<String, dynamic>
        ? contentItem
        : Map<String, dynamic>.from(contentItem as Map);

    String title = _getNestedValue(item, ['title', 'text'], '');
    String message = _getNestedValue(item, ['message', 'text'], '');
    String mediaUrl = _getNestedValue(item, ['media', 'url'], '');
    String contentKey = item['key']?.toString() ?? '';
    String titleColor = _getNestedValue(item, ['title', 'color'], '#FFFFFF');
    String messageColor =
        _getNestedValue(item, ['message', 'color'], '#CCCCCC');
    bool isMediaRecommended = item['isMediaSourceRecommended'] ?? false;
    bool isIconRecommended = item['isIconSourceRecommended'] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: _hexToColor(backgroundColor),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image
            if (mediaUrl.isNotEmpty)
              Positioned.fill(
                child: Image.network(
                  mediaUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: _hexToColor(backgroundColor),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: _hexToColor(backgroundColor),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported,
                              size: 60, color: Colors.white),
                          SizedBox(height: 8),
                          Text(
                            'Image not available',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // Gradient Overlay
            if (mediaUrl.isNotEmpty)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),

            // Content Information Card
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.black.withOpacity(0.7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Content Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildContentInfoRow('Key:', contentKey),
                      _buildContentInfoRow(
                          'Media Recommended:', isMediaRecommended.toString()),
                      _buildContentInfoRow(
                          'Icon Recommended:', isIconRecommended.toString()),
                      _buildContentInfoRow('Title Color:', titleColor),
                      _buildContentInfoRow('Message Color:', messageColor),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title.isNotEmpty) ...[
                      Text(
                        title,
                        style: TextStyle(
                          color: _hexToColor(titleColor),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (message.isNotEmpty) ...[
                      Text(
                        message,
                        style: TextStyle(
                          color: _hexToColor(messageColor),
                          fontSize: 16,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Media URL Display
                    if (mediaUrl.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.link, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Media: ${mediaUrl.split('/').last}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Tap Overlay
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    widget.onContentClick(item, unitId);
                  },
                  child: Container(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getNestedValue(
      Map<String, dynamic> map, List<String> keys, String defaultValue) {
    dynamic current = map;
    for (String key in keys) {
      if (current is Map && current.containsKey(key)) {
        current = current[key];
      } else {
        return defaultValue;
      }
    }
    return current?.toString() ?? defaultValue;
  }
}
