import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'ott_content_detail_page.dart';
import 'ott_subscription_page.dart';

import '../../config/app_colors.dart';
import '../../config/app_enums.dart';

class OTTPage extends StatefulWidget {
  const OTTPage({super.key});

  @override
  State<OTTPage> createState() => _OTTPageState();
}

class _OTTPageState extends State<OTTPage> with TickerProviderStateMixin {
  // ── CleverTap-driven theme variables ─────────────────────────────────────
  Color _accentColor = const Color(0xFFE50914); // Netflix red default
  Color _secondaryAccent = const Color(0xFF831010);
  String _platformName = 'StreamMax';
  String _platformTagline = 'Watch Anywhere. Cancel Anytime.';

  // ── CleverTap-driven user/subscription variables ──────────────────────────
  String _userName = 'Guest User';
  String _subscriptionPlan = 'Standard'; // Mobile / Basic / Standard / Premium
  String _profileAvatar = '🎬';
  String _watchlistCount = '12';
  String _continueWatchingCount = '3';

  // ── CleverTap-driven hero banner variables ─────────────────────────────────
  String _heroBannerTitle = 'Stranger Things';
  String _heroBannerSubtitle = 'Season 4 · Now Streaming';
  String _heroBannerGenre = 'Sci-Fi · Horror · Drama';
  String _heroBannerImageUrl = '';
  String _heroBannerBadge = 'NEW SEASON';

  // ── CleverTap-driven content rows ─────────────────────────────────────────
  String _featuredRowTitle = 'Trending Now';
  String _personalizedRowTitle = 'Because You Watched Dark';
  String _exclusiveRowTitle = 'StreamMax Originals';

  // ── Banner carousel ────────────────────────────────────────────────────────
  List<String> _bannerImageUrls = [];
  late PageController _carouselController;
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;

  // ── Hero auto-cycle ────────────────────────────────────────────────────────
  int _currentHeroIndex = 0;
  late PageController _heroController;
  Timer? _heroTimer;

  // ── Animations ────────────────────────────────────────────────────────────
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  // ── User switcher ─────────────────────────────────────────────────────────
  String _currentUserId = 'ott_user_1';

  // ── Static content data (in real app, driven by CT variables) ─────────────
  final List<Map<String, dynamic>> _heroContent = [
    {
      'title': 'Stranger Things',
      'subtitle': 'Season 4 · Now Streaming',
      'genre': 'Sci-Fi · Horror',
      'badge': 'NEW SEASON',
      'rating': 'U/A 16+',
      'color': Color(0xFF8B0000),
    },
    {
      'title': 'The Crown',
      'subtitle': 'Final Season',
      'genre': 'Historical · Drama',
      'badge': 'AWARD WINNER',
      'rating': 'U/A 13+',
      'color': Color(0xFF0D2137),
    },
    {
      'title': 'Wednesday',
      'subtitle': 'Season 2 Coming Soon',
      'genre': 'Comedy · Horror',
      'badge': 'COMING SOON',
      'rating': 'U/A 13+',
      'color': Color(0xFF1A0A2E),
    },
  ];

  final List<Map<String, dynamic>> _trendingContent = [
    {
      'title': 'Oppenheimer',
      'genre': 'Drama',
      'rating': '8.9',
      'isNew': true,
      'color': Color(0xFF1A0E05)
    },
    {
      'title': 'Dark',
      'genre': 'Sci-Fi',
      'rating': '8.8',
      'isNew': false,
      'color': Color(0xFF0A1020)
    },
    {
      'title': 'Squid Game',
      'genre': 'Thriller',
      'rating': '8.0',
      'isNew': false,
      'color': Color(0xFF0A200A)
    },
    {
      'title': 'House of Dragon',
      'genre': 'Fantasy',
      'rating': '8.5',
      'isNew': true,
      'color': Color(0xFF200A0A)
    },
    {
      'title': 'Succession',
      'genre': 'Drama',
      'rating': '8.9',
      'isNew': false,
      'color': Color(0xFF10100A)
    },
    {
      'title': 'The Bear',
      'genre': 'Comedy',
      'rating': '8.7',
      'isNew': true,
      'color': Color(0xFF0A1515)
    },
  ];

  final List<Map<String, dynamic>> _continueWatching = [
    {
      'title': 'Dark',
      'episode': 'S2 E5',
      'progress': 0.65,
      'color': Color(0xFF0A1020)
    },
    {
      'title': 'Succession',
      'episode': 'S3 E2',
      'progress': 0.30,
      'color': Color(0xFF10100A)
    },
    {
      'title': 'The Bear',
      'episode': 'S1 E8',
      'progress': 0.88,
      'color': Color(0xFF0A1515)
    },
  ];

  final List<Map<String, dynamic>> _originals = [
    {
      'title': 'Alchemy of Souls',
      'genre': 'K-Drama',
      'badge': 'ORIGINAL',
      'color': Color(0xFF1A0A2E)
    },
    {
      'title': 'Four More Shots',
      'genre': 'Drama',
      'badge': 'ORIGINAL',
      'color': Color(0xFF2E0A1A)
    },
    {
      'title': 'Scam 1992',
      'genre': 'Biopic',
      'badge': 'AWARD WINNER',
      'color': Color(0xFF1A1A0A)
    },
    {
      'title': 'Panchayat',
      'genre': 'Comedy',
      'badge': 'ORIGINAL',
      'color': Color(0xFF0A2E0A)
    },
    {
      'title': 'Mirzapur',
      'genre': 'Crime',
      'badge': 'ORIGINAL',
      'color': Color(0xFF2E1A0A)
    },
  ];

  @override
  void initState() {
    super.initState();
    _carouselController = PageController();
    _heroController = PageController();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _startHeroCycle();
    _initializeProductExperiences();
  }

  @override
  void dispose() {
    _carouselController.dispose();
    _heroController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _carouselTimer?.cancel();
    _heroTimer?.cancel();
    super.dispose();
  }

  // ── CleverTap Integration ──────────────────────────────────────────────────

  void _initializeProductExperiences() {
    final variables = {
      'ott_theme': {
        'accentColorHex': '#E50914',
        'secondaryAccentHex': '#831010',
        'platformName': 'StreamMax',
        'platformTagline': 'Watch Anywhere. Cancel Anytime.',
      },
      'ott_user': {
        'userName': 'Guest User',
        'subscriptionPlan': 'Standard',
        'profileAvatar': '🎬',
        'watchlistCount': '12',
        'continueWatchingCount': '3',
      },
      'ott_hero_banner': {
        'title': 'Stranger Things',
        'subtitle': 'Season 4 · Now Streaming',
        'genre': 'Sci-Fi · Horror · Drama',
        'imageUrl': '',
        'badge': 'NEW SEASON',
      },
      'ott_content_labels': {
        'featuredRowTitle': 'Trending Now',
        'personalizedRowTitle': 'Because You Watched Dark',
        'exclusiveRowTitle': 'StreamMax Originals',
      },
      'ott_banners': {
        'Banner Image 1': '',
        'Banner Image 2': '',
        'Banner Image 3': '',
      },
    };

    CleverTapPlugin.defineVariables(variables);

    CleverTapPlugin.onVariablesChanged((vars) {
      if (mounted) _applyUpdatedVariables();
    });

    _fetchVariables();
  }

  void _fetchVariables() async {
    final success = await CleverTapPlugin.fetchVariables();
    if (success == true && mounted) _applyUpdatedVariables();
  }

  void _applyUpdatedVariables() async {
    final theme = await CleverTapPlugin.getVariable('ott_theme');
    final user = await CleverTapPlugin.getVariable('ott_user');
    final hero = await CleverTapPlugin.getVariable('ott_hero_banner');
    final labels = await CleverTapPlugin.getVariable('ott_content_labels');
    final banners = await CleverTapPlugin.getVariable('ott_banners');

    if (!mounted) return;

    setState(() {
      if (theme != null && theme is Map) {
        _accentColor =
            _parseColor(theme['accentColorHex'], const Color(0xFFE50914));
        _secondaryAccent =
            _parseColor(theme['secondaryAccentHex'], const Color(0xFF831010));
        _platformName = theme['platformName']?.toString() ?? 'StreamMax';
        _platformTagline = theme['platformTagline']?.toString() ??
            'Watch Anywhere. Cancel Anytime.';
      }

      if (user != null && user is Map) {
        _userName = user['userName']?.toString() ?? 'Guest User';
        _subscriptionPlan = user['subscriptionPlan']?.toString() ?? 'Standard';
        _profileAvatar = user['profileAvatar']?.toString() ?? '🎬';
        _watchlistCount = user['watchlistCount']?.toString() ?? '12';
        _continueWatchingCount =
            user['continueWatchingCount']?.toString() ?? '3';
      }

      if (hero != null && hero is Map) {
        _heroBannerTitle = hero['title']?.toString() ?? 'Stranger Things';
        _heroBannerSubtitle =
            hero['subtitle']?.toString() ?? 'Season 4 · Now Streaming';
        _heroBannerGenre =
            hero['genre']?.toString() ?? 'Sci-Fi · Horror · Drama';
        _heroBannerImageUrl = hero['imageUrl']?.toString() ?? '';
        _heroBannerBadge = hero['badge']?.toString() ?? 'NEW SEASON';
      }

      if (labels != null && labels is Map) {
        _featuredRowTitle =
            labels['featuredRowTitle']?.toString() ?? 'Trending Now';
        _personalizedRowTitle = labels['personalizedRowTitle']?.toString() ??
            'Because You Watched Dark';
        _exclusiveRowTitle =
            labels['exclusiveRowTitle']?.toString() ?? 'StreamMax Originals';
      }

      if (banners != null && banners is Map) {
        _bannerImageUrls = [
          banners['Banner Image 1'],
          banners['Banner Image 2'],
          banners['Banner Image 3'],
        ]
            .where((url) => url != null && url.toString().isNotEmpty)
            .cast<String>()
            .toList();

        if (_bannerImageUrls.isNotEmpty) _startCarouselTimer();
      }
    });
  }

  Color _parseColor(dynamic value, Color fallback) {
    if (value == null) return fallback;
    try {
      String s = value.toString().replaceFirst('#', '');
      if (s.length == 6) s = 'FF$s';
      return Color(int.parse(s, radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  void _startCarouselTimer() {
    _carouselTimer?.cancel();
    if (_bannerImageUrls.length <= 1) return;
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _currentCarouselIndex =
          (_currentCarouselIndex + 1) % _bannerImageUrls.length;
      _carouselController.animateToPage(
        _currentCarouselIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _startHeroCycle() {
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      _currentHeroIndex = (_currentHeroIndex + 1) % _heroContent.length;
      _heroController.animateToPage(
        _currentHeroIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  // ── Snackbar helper ────────────────────────────────────────────────────────

  void _showSnack(String message, SnackType type) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(type.icon, size: 16, color: type.color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A2A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: type.color.withOpacity(0.3)),
        ),
      ),
    );
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _openContentDetail(Map<String, dynamic> content) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => OTTContentDetailPage(
          accentColor: _accentColor,
          contentTitle: content['title'] as String,
          contentGenre: content['genre'] as String? ?? 'Drama',
          contentRating: content['rating'] as String? ?? 'U/A 13+',
          contentYear: '2023',
          contentDescription:
              'An epic story that unfolds across multiple dimensions of reality, '
              'challenging the limits of human understanding and the nature of existence itself. '
              'Winner of multiple international awards.',
          thumbnailUrl: '',
        ),
        transitionDuration: const Duration(milliseconds: 380),
        transitionsBuilder: (_, a, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  void _openSubscription() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => OTTSubscriptionPage(
          accentColor: _accentColor,
          currentPlan: _subscriptionPlan,
        ),
        transitionDuration: const Duration(milliseconds: 380),
        transitionsBuilder: (_, a, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroBanner(),
              const SizedBox(height: 20),
              _buildContinueWatchingRow(),
              const SizedBox(height: 24),
              _buildStatsStrip(),
              const SizedBox(height: 24),
              _buildContentRow(
                  title: _featuredRowTitle,
                  items: _trendingContent,
                  showRank: true),
              const SizedBox(height: 24),
              _buildImageCarouselBanner(),
              const SizedBox(height: 24),
              _buildContentRow(
                  title: _personalizedRowTitle,
                  items: _trendingContent.reversed.toList()),
              const SizedBox(height: 24),
              _buildSubscriptionCard(),
              const SizedBox(height: 24),
              _buildOriginalsRow(),
              const SizedBox(height: 24),
              _buildGenreQuickAccess(),
              const SizedBox(height: 24),
              _buildRefreshConfigButton(),
              const SizedBox(height: 20),
              _buildQuickUserSwitcher(),
              const SizedBox(height: 16),
              _buildSwitchUserButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: const Icon(Icons.arrow_back_ios_rounded,
              size: 16, color: Colors.white),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _platformName,
            style: TextStyle(
              color: _accentColor,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: () {
            _showSnack('Search coming soon!', SnackType.info);
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child:
                const Icon(Icons.search_rounded, size: 20, color: Colors.white),
          ),
        ),
        GestureDetector(
          onTap: () {
            _showSnack('Profile: $_userName · $_subscriptionPlan Plan',
                SnackType.info);
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _accentColor.withOpacity(0.5)),
            ),
            child: Center(
              child: Text(
                _profileAvatar,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Hero Banner ────────────────────────────────────────────────────────────

  Widget _buildHeroBanner() {
    return SizedBox(
      height: 520,
      child: Stack(
        children: [
          // PageView of hero content
          PageView.builder(
            controller: _heroController,
            onPageChanged: (i) => setState(() => _currentHeroIndex = i),
            itemCount: _heroContent.length,
            itemBuilder: (_, i) {
              final item = _heroContent[i];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (item['color'] as Color),
                      const Color(0xFF0A0A0F),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Subtle grid pattern overlay
                    Positioned.fill(
                      child: CustomPaint(painter: _GridPainter()),
                    ),
                    // Faint show title watermark
                    Positioned(
                      right: -30,
                      top: 80,
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Text(
                          item['title'] as String,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.04),
                            fontSize: 80,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    // Play icon placeholder
                    Positioned(
                      top: 140,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Icon(
                          Icons.play_circle_outline_rounded,
                          size: 90,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Bottom content overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.6, 1.0],
                  colors: [
                    Colors.transparent,
                    Color(0xCC0A0A0F),
                    Color(0xFF0A0A0F)
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _accentColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _heroBannerBadge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    _heroBannerTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _heroBannerSubtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _heroBannerGenre,
                    style: TextStyle(
                      color: _accentColor.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // CTA row
                  Row(
                    children: [
                      SizedBox(
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _openContentDetail({
                              'title': _heroBannerTitle,
                              'genre': _heroBannerGenre,
                            });
                          },
                          icon: const Icon(Icons.play_arrow_rounded, size: 22),
                          label: const Text('Play',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 46,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            _showSnack('$_heroBannerTitle added to My List',
                                SnackType.success);
                          },
                          icon: const Icon(Icons.add_rounded,
                              size: 20, color: Colors.white),
                          label: const Text('My List',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            side: const BorderSide(color: Colors.white38),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          _openContentDetail({
                            'title': _heroBannerTitle,
                            'genre': _heroBannerGenre,
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.info_outline_rounded,
                              size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Hero page dots
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_heroContent.length, (i) {
                final isActive = i == _currentHeroIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: isActive ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isActive ? _accentColor : Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),

          // Category nav row (Netflix-style)
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 4,
            left: 0,
            right: 0,
            child: _buildCategoryNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryNav() {
    final categories = ['Home', 'Series', 'Films', 'New', 'My List'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isActive = cat == 'Home';
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _showSnack('$cat selected', SnackType.info);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: isActive ? Colors.white : Colors.white24),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isActive ? Colors.black : Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Continue Watching ──────────────────────────────────────────────────────

  Widget _buildContinueWatchingRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Continue Watching',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                '$_continueWatchingCount items',
                style: TextStyle(color: _accentColor, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _continueWatching.length,
            itemBuilder: (_, i) {
              final item = _continueWatching[i];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _openContentDetail(item);
                },
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Stack(
                    children: [
                      // Subtle play icon
                      Center(
                        child: Icon(Icons.play_circle_outline_rounded,
                            size: 40, color: Colors.white.withOpacity(0.15)),
                      ),
                      // Title + progress
                      Positioned(
                        left: 10,
                        right: 10,
                        bottom: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700),
                            ),
                            Text(
                              item['episode'] as String,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 11),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: item['progress'] as double,
                                minHeight: 3,
                                backgroundColor: Colors.white24,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(_accentColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Overlay play button
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.more_vert_rounded,
                              size: 14, color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Stats Strip ────────────────────────────────────────────────────────────

  Widget _buildStatsStrip() {
    final plan = _subscriptionPlan;
    final planColor = plan == 'Premium'
        ? const Color(0xFFFFD700)
        : plan == 'Standard'
            ? const Color(0xFF9C27B0)
            : plan == 'Basic'
                ? const Color(0xFF2196F3)
                : const Color(0xFF4CAF50);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF13131F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                icon: Icons.person_outline_rounded,
                label: _userName.split(' ').first,
                color: _accentColor,
              ),
            ),
            _VerticalDivider(),
            Expanded(
              child: GestureDetector(
                onTap: _openSubscription,
                child: _StatItem(
                  icon: Icons.workspace_premium_rounded,
                  label: '$plan Plan',
                  color: planColor,
                  tappable: true,
                ),
              ),
            ),
            _VerticalDivider(),
            Expanded(
              child: _StatItem(
                icon: Icons.bookmark_outline_rounded,
                label: '$_watchlistCount Saved',
                color: const Color(0xFF38BDF8),
              ),
            ),
            _VerticalDivider(),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _showSnack('Downloads: Offline content', SnackType.info);
                },
                child: _StatItem(
                  icon: Icons.download_outlined,
                  label: 'Downloads',
                  color: const Color(0xFF10B981),
                  tappable: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Content Row ────────────────────────────────────────────────────────────

  Widget _buildContentRow({
    required String title,
    required List<Map<String, dynamic>> items,
    bool showRank = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showSnack('See All: $title', SnackType.info);
                },
                child: Text('See All >',
                    style: TextStyle(color: _accentColor, fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: showRank ? 180 : 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();

                  _openContentDetail(item);
                },
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 10),
                  child: Stack(
                    children: [
                      // Card
                      Positioned(
                        top: showRank ? 20 : 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: item['color'] as Color,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.07)),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(Icons.movie_outlined,
                                    size: 32, color: Colors.white10),
                              ),
                              Positioned(
                                left: 8,
                                right: 8,
                                bottom: 8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 2,
                                    ),
                                    if (item['genre'] != null)
                                      Text(
                                        item['genre'] as String,
                                        style: const TextStyle(
                                            color: Colors.white38, fontSize: 9),
                                      ),
                                  ],
                                ),
                              ),
                              if (item['isNew'] == true)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _accentColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: const Text('NEW',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 7,
                                            fontWeight: FontWeight.w800)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Rank number
                      if (showRank)
                        Positioned(
                          top: 0,
                          left: -4,
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              height: 0.9,
                              shadows: [
                                Shadow(
                                    color: Colors.black,
                                    blurRadius: 8,
                                    offset: Offset(2, 2))
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Image Carousel Banner ─────────────────────────────────────────────────

  Widget _buildImageCarouselBanner() {
    if (_bannerImageUrls.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFF13131F),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.campaign_outlined, color: _accentColor, size: 32),
                const SizedBox(height: 8),
                const Text('Personalized banners appear here',
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
                Text('Configure via CleverTap dashboard',
                    style: TextStyle(
                        color: _accentColor.withOpacity(0.6), fontSize: 11)),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 140,
        child: Stack(
          children: [
            PageView.builder(
              controller: _carouselController,
              onPageChanged: (i) => setState(() => _currentCarouselIndex = i),
              itemCount: _bannerImageUrls.length,
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: _bannerImageUrls[i],
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: const Color(0xFF13131F)),
                  errorWidget: (_, __, ___) =>
                      Container(color: const Color(0xFF13131F)),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _bannerImageUrls.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: _currentCarouselIndex == i ? 16 : 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: _currentCarouselIndex == i
                          ? Colors.white
                          : Colors.white30,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Subscription Upsell Card ───────────────────────────────────────────────

  Widget _buildSubscriptionCard() {
    final isPremium = _subscriptionPlan.toLowerCase() == 'premium';
    if (isPremium) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();

          _openSubscription();
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_accentColor.withOpacity(0.8), _secondaryAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _accentColor.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.stars_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upgrade to Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '4K · HDR · Dolby Atmos · 4 screens',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Upgrade',
                  style: TextStyle(
                    color: _accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Originals Row ──────────────────────────────────────────────────────────

  Widget _buildOriginalsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                _platformName,
                style: TextStyle(
                  color: _accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                ' Originals',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _originals.length,
            itemBuilder: (_, i) {
              final item = _originals[i];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _openContentDetail(item);
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _accentColor.withOpacity(0.2)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(Icons.movie_creation_outlined,
                            size: 40, color: Colors.white.withOpacity(0.08)),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _accentColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['badge'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        right: 10,
                        bottom: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 2,
                            ),
                            Text(
                              item['genre'] as String,
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Genre Quick Access ─────────────────────────────────────────────────────

  Widget _buildGenreQuickAccess() {
    final genres = [
      {
        'label': 'Action',
        'icon': Icons.flash_on_rounded,
        'color': Color(0xFFE53935)
      },
      {
        'label': 'Comedy',
        'icon': Icons.sentiment_very_satisfied_rounded,
        'color': Color(0xFFFFA726)
      },
      {
        'label': 'Thriller',
        'icon': Icons.remove_red_eye_outlined,
        'color': Color(0xFF7B1FA2)
      },
      {
        'label': 'Romance',
        'icon': Icons.favorite_rounded,
        'color': Color(0xFFE91E63)
      },
      {
        'label': 'Sci-Fi',
        'icon': Icons.rocket_launch_rounded,
        'color': Color(0xFF0288D1)
      },
      {
        'label': 'Reality',
        'icon': Icons.live_tv_rounded,
        'color': Color(0xFF00897B)
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Browse by Genre',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.4,
            ),
            itemCount: genres.length,
            itemBuilder: (_, i) {
              final genre = genres[i];
              final color = genre['color'] as Color;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _showSnack('${genre['label']} selected', SnackType.info);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(genre['icon'] as IconData, size: 16, color: color),
                      const SizedBox(width: 6),
                      Text(
                        genre['label'] as String,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Refresh Config Button ─────────────────────────────────────────────────

  Widget _buildRefreshConfigButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          icon: Icon(Icons.refresh_rounded, color: _accentColor),
          label: Text(
            'Refresh CleverTap Config',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _accentColor,
            ),
          ),
          onPressed: () {
            _showSnack('Refreshing config from dashboard…', SnackType.info);
            _fetchVariables();
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: _accentColor, width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  // ── User Switcher ─────────────────────────────────────────────────────────

  Widget _buildQuickUserSwitcher() {
    final users = [
      'ott_user_1',
      'ott_user_2',
      'ott_user_3',
      'ott_user_4',
      'ott_user_5'
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Switch:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white38,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: users.map((userId) {
              final isActive = _currentUserId == userId;
              return GestureDetector(
                onTap: () {
                  if (!isActive) {
                    setState(() => _currentUserId = userId);
                    CleverTapPlugin.onUserLogin({'Identity': userId});
                    _showSnack('Switched to: $userId', SnackType.success);
                    _fetchVariables();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive ? _accentColor : const Color(0xFF13131F),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? _accentColor : Colors.white12,
                    ),
                  ),
                  child: Text(
                    userId,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchUserButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          icon: Icon(Icons.person_rounded, color: _accentColor),
          label: Text(
            'Switch User',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _accentColor,
            ),
          ),
          onPressed: () async {
            final newId = await _showUserIdDialog();
            if (newId != null && newId.isNotEmpty) {
              setState(() => _currentUserId = newId);
              CleverTapPlugin.onUserLogin({'Identity': newId});
              _showSnack('Switched to: $newId', SnackType.success);
              _fetchVariables();
            }
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: _accentColor, width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Future<String?> _showUserIdDialog() async {
    String id = '';
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13131F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _accentColor.withOpacity(0.3)),
        ),
        title: const Text('Switch User', style: TextStyle(color: Colors.white)),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Enter User ID / Email',
            labelStyle: const TextStyle(color: Colors.white38),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white12),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _accentColor, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (v) => id = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, id),
            style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
            child: const Text('Switch', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Supporting widgets ─────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool tappable;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.color,
    this.tappable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: tappable ? color : Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 32,
        color: Colors.white12,
      );
}

// ── Custom grid painter for hero background texture ────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
