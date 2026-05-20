import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/services.dart';

class OTTContentDetailPage extends StatefulWidget {
  final Color accentColor;
  final String contentTitle;
  final String contentGenre;
  final String contentRating;
  final String contentYear;
  final String contentDescription;
  final String thumbnailUrl;

  const OTTContentDetailPage({
    Key? key,
    required this.accentColor,
    required this.contentTitle,
    required this.contentGenre,
    required this.contentRating,
    required this.contentYear,
    required this.contentDescription,
    this.thumbnailUrl = '',
  }) : super(key: key);

  @override
  State<OTTContentDetailPage> createState() => _OTTContentDetailPageState();
}

class _OTTContentDetailPageState extends State<OTTContentDetailPage>
    with SingleTickerProviderStateMixin {
  bool _isInWatchlist = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  late AnimationController _playButtonController;
  late Animation<double> _playButtonScale;

  final List<Map<String, dynamic>> _episodes = [
    {
      'episode': 'E1',
      'title': 'Pilot',
      'duration': '52 min',
      'description': 'The story begins with an unexpected turn of events.',
      'watched': true,
    },
    {
      'episode': 'E2',
      'title': 'The Descent',
      'duration': '48 min',
      'description': 'Characters face their first major challenge.',
      'watched': true,
    },
    {
      'episode': 'E3',
      'title': 'Revelations',
      'duration': '55 min',
      'description': 'A shocking truth comes to light.',
      'watched': false,
    },
    {
      'episode': 'E4',
      'title': 'The Breaking Point',
      'duration': '50 min',
      'description': 'Everything changes in this pivotal episode.',
      'watched': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _playButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _playButtonScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _playButtonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _playButtonController.dispose();
    super.dispose();
  }

  void _startDownload() async {
    setState(() => _isDownloading = true);
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (mounted) setState(() => _downloadProgress = i / 100);
    }
    if (mounted) {
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.contentTitle} downloaded!'),
          backgroundColor: const Color(0xFF1A1A2A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverHero(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetaRow(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                  _buildDescription(),
                  const SizedBox(height: 28),
                  _buildEpisodesList(),
                  const SizedBox(height: 28),
                  _buildMoreLikeThis(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHero() {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: const Color(0xFF0A0A0F),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: const Icon(Icons.arrow_back_ios_rounded,
              size: 16, color: Colors.white),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero image / gradient placeholder
            widget.thumbnailUrl.isNotEmpty
                ? Image.network(widget.thumbnailUrl, fit: BoxFit.cover)
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.accentColor.withOpacity(0.6),
                          const Color(0xFF0A0A0F),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
            // Bottom scrim
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.3, 1.0],
                    colors: [
                      Colors.transparent,
                      const Color(0xFF0A0A0F),
                    ],
                  ),
                ),
              ),
            ),
            // Play button overlay
            Center(
              child: GestureDetector(
                onTapDown: (_) => _playButtonController.forward(),
                onTapUp: (_) {
                  _playButtonController.reverse();
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Starting playback...'),
                      backgroundColor: Color(0xFF1A1A2A),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onTapCancel: () => _playButtonController.reverse(),
                child: ScaleTransition(
                  scale: _playButtonScale,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: widget.accentColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.accentColor.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 36),
                  ),
                ),
              ),
            ),
            // Title at bottom
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contentTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _MetaChip(label: widget.contentYear, color: Colors.white60),
        _MetaChip(
          label: widget.contentRating,
          color: widget.accentColor,
          bordered: true,
        ),
        _MetaChip(label: widget.contentGenre, color: Colors.white60),
        _MetaChip(label: '4 Seasons', color: Colors.white60),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
            (i) => Icon(
              i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
              size: 14,
              color: const Color(0xFFFFC107),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary Play Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.heavyImpact();
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 22),
            label: const Text(
              'Resume  ·  S1 E3',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Secondary row
        Row(
          children: [
            Expanded(
              child: _SecondaryButton(
                icon: _isInWatchlist ? Icons.check_rounded : Icons.add_rounded,
                label: _isInWatchlist ? 'In List' : 'My List',
                accentColor: widget.accentColor,
                onTap: () {
                  setState(() => _isInWatchlist = !_isInWatchlist);
                  HapticFeedback.selectionClick();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SecondaryButton(
                icon: Icons.download_rounded,
                label: _isDownloading
                    ? '${(_downloadProgress * 100).toInt()}%'
                    : 'Download',
                accentColor: widget.accentColor,
                onTap: _isDownloading ? null : _startDownload,
                showProgress: _isDownloading,
                progress: _downloadProgress,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SecondaryButton(
                icon: Icons.share_rounded,
                label: 'Share',
                accentColor: widget.accentColor,
                onTap: () {
                  HapticFeedback.lightImpact();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.contentDescription,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.person_outline_rounded,
                size: 14, color: Colors.white38),
            const SizedBox(width: 6),
            const Text('Cast: ',
                style: TextStyle(color: Colors.white38, fontSize: 12)),
            Text(
              'Starring, Cast Member, Another Star',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEpisodesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Episodes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Text('Season 1',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 14, color: Colors.white38),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ..._episodes.map((ep) => _EpisodeTile(
              episode: ep,
              accentColor: widget.accentColor,
              onTap: () {
                HapticFeedback.selectionClick();
              },
            )),
      ],
    );
  }

  Widget _buildMoreLikeThis() {
    final suggestions = [
      {'title': 'Dark Origins', 'genre': 'Thriller'},
      {'title': 'The Watchers', 'genre': 'Mystery'},
      {'title': 'Echoes', 'genre': 'Drama'},
      {'title': 'Parallels', 'genre': 'Sci-Fi'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'More Like This',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final item = suggestions[index];
              final colors = [
                const Color(0xFF1A0A2E),
                const Color(0xFF0A1A2E),
                const Color(0xFF1A2E0A),
                const Color(0xFF2E1A0A),
              ];
              return Container(
                width: 120,
                margin: EdgeInsets.only(
                    right: index < suggestions.length - 1 ? 12 : 0),
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Icon(Icons.movie_outlined,
                          size: 36, color: Colors.white12),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                          ),
                          Text(
                            item['genre']!,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool bordered;

  const _MetaChip({
    required this.label,
    required this.color,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: bordered
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
          : EdgeInsets.zero,
      decoration: bordered
          ? BoxDecoration(
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: bordered ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback? onTap;
  final bool showProgress;
  final double progress;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.accentColor,
    this.onTap,
    this.showProgress = false,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (showProgress)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        accentColor.withOpacity(0.2)),
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: Colors.white),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  final Map<String, dynamic> episode;
  final Color accentColor;
  final VoidCallback onTap;

  const _EpisodeTile({
    required this.episode,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool watched = episode['watched'] as bool;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF13131F),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: watched
                ? Colors.white.withOpacity(0.06)
                : accentColor.withOpacity(0.3),
            width: watched ? 1 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: watched
                    ? Colors.white.withOpacity(0.06)
                    : accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                watched ? Icons.check_rounded : Icons.play_arrow_rounded,
                color: watched ? Colors.white30 : accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        episode['episode'] as String,
                        style: TextStyle(
                          color: watched ? Colors.white38 : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        episode['title'] as String,
                        style: TextStyle(
                          color: watched ? Colors.white38 : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        episode['duration'] as String,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    episode['description'] as String,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
