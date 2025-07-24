import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/material.dart';
import 'native_display_carousel_screen.dart';

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

class _NativeDisplayPageState extends State<NativeDisplayPage> {
  List<Map<String, dynamic>> _displayUnits = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _displayUnits = widget.displayUnits;
    if (_displayUnits.isEmpty) {
      _loadDisplayUnits();
    }
  }

  Future<void> _loadDisplayUnits() async {
    setState(() => _isLoading = true);

    try {
      final displayUnits = await CleverTapPlugin.getAllDisplayUnits();
      if (displayUnits != null && displayUnits.isNotEmpty) {
        setState(() {
          _displayUnits = displayUnits.map((item) {
            if (item is Map<String, dynamic>) {
              return item;
            } else if (item is Map) {
              return Map<String, dynamic>.from(item);
            } else {
              return <String, dynamic>{};
            }
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Error loading display units: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Native Display Units',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadDisplayUnits,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Display Units',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.9),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading Display Units...'),
                  ],
                ),
              )
            : _displayUnits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Display Units Available',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Load display units from the home page first',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadDisplayUnits,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Loading Again'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Header with count
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.campaign,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Active Display Units',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        '${_displayUnits.length} units loaded',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => _showCarouselView(),
                                  child: const Text('View Carousel'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Display Units List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _displayUnits.length,
                          itemBuilder: (context, index) {
                            return _buildDisplayUnitCard(
                                _displayUnits[index], index);
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildDisplayUnitCard(Map<String, dynamic> unit, int index) {
    String unitId = unit['wzrk_id']?.toString() ?? 'Unknown';
    String unitType = unit['type']?.toString() ?? 'Unknown';
    String backgroundColor = unit['bg']?.toString() ?? '#FFFFFF';
    List<dynamic> content = unit['content'] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _hexToColor(backgroundColor),
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          'Display Unit ${index + 1}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: $unitType'),
            Text('ID: $unitId'),
            Text('Content Items: ${content.length}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unit Details
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unit Details',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Background: $backgroundColor'),
                      Text('Timestamp: ${unit['ti'] ?? 'N/A'}'),
                      Text('Pivot: ${unit['wzrk_pivot'] ?? 'N/A'}'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Content Items
                if (content.isNotEmpty) ...[
                  const Text(
                    'Content Items:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...content.asMap().entries.map((entry) {
                    int contentIndex = entry.key;
                    var contentItem = entry.value;
                    Map<String, dynamic> item =
                        contentItem is Map<String, dynamic>
                            ? contentItem
                            : Map<String, dynamic>.from(contentItem as Map);

                    return _buildContentItemCard(item, contentIndex, unitId);
                  }).toList(),
                ],

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => widget.onUnitViewed(unitId),
                        icon: const Icon(Icons.visibility),
                        label: const Text('Mark Viewed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showUnitInCarousel(index),
                        icon: const Icon(Icons.fullscreen),
                        label: const Text('View Full'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentItemCard(
      Map<String, dynamic> item, int index, String unitId) {
    String title = _getNestedValue(item, ['title', 'text'], 'No Title');
    String message = _getNestedValue(item, ['message', 'text'], 'No Message');
    String mediaUrl = _getNestedValue(item, ['media', 'url'], '');
    String contentKey = item['key']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => widget.onContentClick(item, unitId),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child: mediaUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          mediaUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported);
                          },
                        ),
                      )
                    : Icon(Icons.image, color: Colors.grey[600]),
              ),

              const SizedBox(width: 12),

              // Content Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title.isNotEmpty && title != 'No Title')
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (message.isNotEmpty && message != 'No Message')
                      Text(
                        message,
                        style: TextStyle(color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (contentKey.isNotEmpty)
                      Text(
                        'Key: $contentKey',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showCarouselView() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NativeDisplayCarouselScreen(
          displayUnits: _displayUnits,
          onContentClick: widget.onContentClick,
          onUnitViewed: widget.onUnitViewed,
        ),
      ),
    );
  }

  void _showUnitInCarousel(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NativeDisplayCarouselScreen(
          displayUnits: _displayUnits,
          onContentClick: widget.onContentClick,
          onUnitViewed: widget.onUnitViewed,
          initialIndex: index,
        ),
      ),
    );
  }

  Color _hexToColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey;
    }
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
