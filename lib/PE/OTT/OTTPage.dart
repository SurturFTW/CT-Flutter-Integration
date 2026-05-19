import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

import '../../config/app_colors.dart';
import '../../config/app_enums.dart';

class OTTPage extends StatefulWidget {
  const OTTPage({super.key});

  @override
  State<OTTPage> createState() => _OTTPageState();
}

class _OTTPageState extends State<OTTPage> with SingleTickerProviderStateMixin {
  // ── Theme color variables – OTT dark defaults ──────────────────────────────
  Color _headerGradientTop = const Color(0xFF0D0D1A);
  Color _headerGradientBottom = const Color(0xFF1A0A2E);
  Color _cardGradientTop = const Color(0xFFE50914);
  Color _cardGradientBottom = const Color(0xFFB20710);
  Color _iconTintColor = const Color(0xFFE50914);
  Color _buttonColor = const Color(0xFFE50914);
  Color _textColor = Colors.white;

  // ── OTT subscription details ───────────────────────────────────────────────
  String _planName = 'Premium 4K';
  String _renewalDate = '28 Feb 2026';
  String _watchHours = '124 hrs';
  String _profilesCount = '4 Profiles';
  String _subscriptionStatus = 'Active';
  String _primaryCTA = 'Continue Watching';

  // ── Featured content ───────────────────────────────────────────────────────
  String _featuredTitle = 'Stranger Worlds';
  String _featuredSubtitle = 'Continue watching from where you left off';
  String _featuredPosterImage = '';
  String _featuredGenre = 'Sci-Fi Thriller';
  String _featuredDuration = '2h 12m';
  String _featuredRating = '8.7';

  // ── Carousel ───────────────────────────────────────────────────────────────
  late PageController _carouselController;
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;
  List<String> _bannerImageUrls = [];

  // ── User ───────────────────────────────────────────────────────────────────
  String _currentUserId = 'user1@example.com';

  @override
  void initState() {
    super.initState();
    _carouselController = PageController();
    _initializeProductExperiences();
  }

  @override
  void dispose() {
    _carouselController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  // ── CleverTap Product Experiences ─────────────────────────────────────────

  void _initializeProductExperiences() {
    final variables = {
      'Banner': {
        'Banner Image 1': '',
        'Banner Image 2': '',
        'Banner Image 3': '',
      },
      'app_theme': {
        'headerGradientTopHex': '#0D0D1A',
        'headerGradientBottomHex': '#1A0A2E',
        'cardGradientTopHex': '#E50914',
        'cardGradientBottomHex': '#B20710',
        'iconTintHex': '#E50914',
        'buttonColorHex': '#E50914',
        'textColorHex': '#FFFFFF',
      },
      'ott_subscription_details': {
        'planName': 'Premium 4K',
        'renewalDate': '28 Feb 2026',
        'watchHours': '124 hrs',
        'profilesCount': '4 Profiles',
        'subscriptionStatus': 'Active',
        'primaryCTA': 'Continue Watching',
      },
      'featured_content': {
        'title': 'Stranger Worlds',
        'subtitle': 'Continue watching from where you left off',
        'posterImage': '',
        'genre': 'Sci-Fi Thriller',
        'duration': '2h 12m',
        'rating': '8.7',
      },
    };

    CleverTapPlugin.defineVariables(variables);
    debugPrint('✓ OTT variables defined');

    CleverTapPlugin.onVariablesChanged((vars) {
      debugPrint('OTT variables updated: $vars');
      if (mounted) {
        _updateUIWithNewValues();
      }
    });

    _fetchVariables();
  }

  void _fetchVariables() async {
    debugPrint('Fetching OTT variables from CleverTap…');
    final bool? success = await CleverTapPlugin.fetchVariables();
    if (success == true) {
      debugPrint('✓ OTT variables fetched successfully');
      if (mounted) _updateUIWithNewValues();
    } else {
      debugPrint('✗ Failed to fetch variables, using defaults');
    }
  }

  void _updateUIWithNewValues() async {
    final banner = await CleverTapPlugin.getVariable('Banner');
    final appTheme = await CleverTapPlugin.getVariable('app_theme');
    final subDetails =
        await CleverTapPlugin.getVariable('ott_subscription_details');
    final featuredContent =
        await CleverTapPlugin.getVariable('featured_content');

    if (!mounted) return;

    setState(() {
      // Banner images
      if (banner != null && banner is Map) {
        _bannerImageUrls = [
          banner['Banner Image 1'],
          banner['Banner Image 2'],
          banner['Banner Image 3'],
        ]
            .where((url) => url != null && url.toString().isNotEmpty)
            .cast<String>()
            .toList();

        debugPrint('Banner images loaded: $_bannerImageUrls');
        if (_bannerImageUrls.isNotEmpty) {
          _startCarouselTimer();
        }
      }

      // App theme
      if (appTheme != null && appTheme is Map) {
        _headerGradientTop = _parseColor(
            appTheme['headerGradientTopHex'], const Color(0xFF0D0D1A));
        _headerGradientBottom = _parseColor(
            appTheme['headerGradientBottomHex'], const Color(0xFF1A0A2E));
        _cardGradientTop = _parseColor(
            appTheme['cardGradientTopHex'], const Color(0xFFE50914));
        _cardGradientBottom = _parseColor(
            appTheme['cardGradientBottomHex'], const Color(0xFFB20710));
        _iconTintColor =
            _parseColor(appTheme['iconTintHex'], const Color(0xFFE50914));
        _buttonColor =
            _parseColor(appTheme['buttonColorHex'], const Color(0xFFE50914));
        _textColor =
            _shouldUseLightText(_buttonColor) ? Colors.white : Colors.black87;
        debugPrint('OTT theme applied: $appTheme');
      }

      // Subscription details
      if (subDetails != null && subDetails is Map) {
        _planName = subDetails['planName']?.toString() ?? 'Premium 4K';
        _renewalDate = subDetails['renewalDate']?.toString() ?? '28 Feb 2026';
        _watchHours = subDetails['watchHours']?.toString() ?? '124 hrs';
        _profilesCount =
            subDetails['profilesCount']?.toString() ?? '4 Profiles';
        _subscriptionStatus =
            subDetails['subscriptionStatus']?.toString() ?? 'Active';
        _primaryCTA =
            subDetails['primaryCTA']?.toString() ?? 'Continue Watching';
        debugPrint('OTT subscription updated: $subDetails');
      }

      // Featured content
      if (featuredContent != null && featuredContent is Map) {
        _featuredTitle =
            featuredContent['title']?.toString() ?? 'Stranger Worlds';
        _featuredSubtitle = featuredContent['subtitle']?.toString() ??
            'Continue watching from where you left off';
        _featuredPosterImage = featuredContent['posterImage']?.toString() ?? '';
        _featuredGenre =
            featuredContent['genre']?.toString() ?? 'Sci-Fi Thriller';
        _featuredDuration = featuredContent['duration']?.toString() ?? '2h 12m';
        _featuredRating = featuredContent['rating']?.toString() ?? '8.7';
        debugPrint('OTT featured content updated: $featuredContent');
      }
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Color _parseColor(dynamic colorValue, Color defaultColor) {
    if (colorValue == null) return defaultColor;
    String colorString = colorValue.toString();
    if (colorString.startsWith('#')) colorString = colorString.substring(1);
    try {
      if (colorString.length == 6) colorString = 'FF$colorString';
      return Color(int.parse(colorString, radix: 16));
    } catch (_) {
      debugPrint('Failed to parse color: $colorValue');
      return defaultColor;
    }
  }

  bool _shouldUseLightText(Color color) {
    final luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance < 0.5;
  }

  void _startCarouselTimer() {
    _carouselTimer?.cancel();
    if (_bannerImageUrls.length <= 1) return;

    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _currentCarouselIndex =
          (_currentCarouselIndex + 1) % _bannerImageUrls.length;
      _carouselController.animateToPage(
        _currentCarouselIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
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

  // ── Build ──────────────────────────────────────────────────────────────────

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
          'Product Experience',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildSubscriptionCard(),
            const SizedBox(height: 24),
            _buildFirstIconRow(),
            const SizedBox(height: 20),
            _buildSecondIconRow(),
            const SizedBox(height: 24),
            _buildImageCarousel(),
            const SizedBox(height: 24),
            _buildFeaturedContentCard(),
            const SizedBox(height: 24),
            _buildCTAButton(),
            const SizedBox(height: 16),
            _buildRefreshConfigButton(),
            const SizedBox(height: 24),
            _buildQuickUserSwitcher(),
            const SizedBox(height: 16),
            _buildSwitchUserButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Subscription card ──────────────────────────────────────────────────────

  Widget _buildSubscriptionCard() {
    final isActive = _subscriptionStatus.toLowerCase() == 'active';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_cardGradientTop, _cardGradientBottom],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              left: -30,
              top: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -10,
              top: 30,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Plan name + status badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _planName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white.withOpacity(0.25)
                              : Colors.orange.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive
                                ? Colors.white.withOpacity(0.5)
                                : Colors.orange.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive
                                    ? Colors.greenAccent
                                    : Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _subscriptionStatus,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Play icon row
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 36,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Streaming',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  // Bottom row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _cardStat(label: 'Renews On', value: _renewalDate),
                      _cardStat(label: 'Watch Hours', value: _watchHours),
                      _cardStat(label: 'Profiles', value: _profilesCount),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardStat({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ── Icon rows ──────────────────────────────────────────────────────────────

  Widget _buildFirstIconRow() {
    final icons = [
      {'icon': Icons.bookmark_outline_rounded, 'title': 'Watchlist'},
      {'icon': Icons.download_outlined, 'title': 'Downloads'},
      {'icon': Icons.movie_outlined, 'title': 'Movies'},
      {'icon': Icons.tv_outlined, 'title': 'Series'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: icons
            .map((item) => _buildIconButton(
                  item['icon'] as IconData,
                  item['title'] as String,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSecondIconRow() {
    final icons = [
      {'icon': Icons.sports_soccer_outlined, 'title': 'Sports'},
      {'icon': Icons.child_care_outlined, 'title': 'Kids'},
      {'icon': Icons.live_tv_outlined, 'title': 'Live TV'},
      {'icon': Icons.settings_outlined, 'title': 'Settings'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: icons
            .map((item) => _buildIconButton(
                  item['icon'] as IconData,
                  item['title'] as String,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String title) {
    return InkWell(
      onTap: () {
        debugPrint('✅ $title tapped');
        HapticFeedback.lightImpact();
        _showAppSnackBar(
          message: '$title tapped',
          type: SnackType.info,
        );
      },
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _buttonColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: _textColor, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Banner carousel ────────────────────────────────────────────────────────

  Widget _buildImageCarousel() {
    if (_bannerImageUrls.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_not_supported_outlined,
                  color: AppColors.textSecondary, size: 32),
              SizedBox(height: 8),
              Text(
                'No banners available',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 180,
      child: Stack(
        children: [
          PageView.builder(
            controller: _carouselController,
            onPageChanged: (index) {
              setState(() => _currentCarouselIndex = index);
            },
            itemCount: _bannerImageUrls.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: _bannerImageUrls[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.surfaceElevated,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surfaceElevated,
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
              );
            },
          ),
          // Page indicators
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _bannerImageUrls.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentCarouselIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Featured content card ──────────────────────────────────────────────────

  Widget _buildFeaturedContentCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            SizedBox(
              height: 200,
              width: double.infinity,
              child: _featuredPosterImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: _featuredPosterImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceElevated,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => _posterFallback(),
                    )
                  : _posterFallback(),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Genre + Rating row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _buttonColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border:
                              Border.all(color: _buttonColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          _featuredGenre,
                          style: TextStyle(
                            color: _buttonColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.amberDim,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: AppColors.amber.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 12, color: AppColors.amber),
                            const SizedBox(width: 3),
                            Text(
                              _featuredRating,
                              style: const TextStyle(
                                color: AppColors.amber,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            _featuredDuration,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    _featuredTitle,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Subtitle
                  Text(
                    _featuredSubtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
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

  Widget _posterFallback() {
    return Container(
      color: AppColors.surfaceElevated,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.movie_creation_outlined,
                color: AppColors.textTertiary, size: 48),
            const SizedBox(height: 8),
            const Text(
              'No poster available',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ── CTA button ─────────────────────────────────────────────────────────────

  Widget _buildCTAButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_buttonColor, _buttonColor.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _buttonColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.heavyImpact();
                CleverTapPlugin.recordEvent('OTT CTA Clicked', {
                  'CTA Label': _primaryCTA,
                  'Plan': _planName,
                });
                _showAppSnackBar(
                  message: '$_primaryCTA clicked',
                  type: SnackType.success,
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: _textColor, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      _primaryCTA,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Refresh config button ──────────────────────────────────────────────────

  Widget _buildRefreshConfigButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          icon: Icon(Icons.refresh_rounded, color: _buttonColor),
          label: Text(
            'Refresh Config',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _buttonColor,
            ),
          ),
          onPressed: () {
            _showAppSnackBar(
              message: 'Refreshing config from dashboard…',
              type: SnackType.info,
            );
            _fetchVariables();
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: _buttonColor, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  // ── Quick user switcher ────────────────────────────────────────────────────

  Widget _buildQuickUserSwitcher() {
    final quickUsers = ['1911', '1912', '1913', '1914', '1915'];

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
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickUsers
                .map(
                  (userId) => FilterChip(
                    label: Text(
                      userId,
                      style: TextStyle(
                        color: _currentUserId == userId
                            ? Colors.white
                            : _buttonColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: _currentUserId == userId,
                    onSelected: (selected) {
                      if (selected && _currentUserId != userId) {
                        setState(() => _currentUserId = userId);
                        CleverTapPlugin.onUserLogin({'Identity': userId});
                        _showAppSnackBar(
                          message: 'Switched to user: $userId',
                          type: SnackType.success,
                        );
                        _fetchVariables();
                      }
                    },
                    selectedColor: _buttonColor,
                    checkmarkColor: Colors.white,
                    side: BorderSide(color: _buttonColor),
                    backgroundColor: AppColors.surface,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Switch user button ─────────────────────────────────────────────────────

  Widget _buildSwitchUserButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          icon: Icon(Icons.person_outline_rounded, color: _buttonColor),
          label: Text(
            'Switch User',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _buttonColor,
            ),
          ),
          onPressed: () async {
            final newUserId = await _showUserIdDialog();
            if (newUserId != null && newUserId.isNotEmpty) {
              setState(() => _currentUserId = newUserId);
              CleverTapPlugin.onUserLogin({'Identity': newUserId});
              _showAppSnackBar(
                message: 'Switched to user: $newUserId',
                type: SnackType.success,
              );
              _fetchVariables();
            }
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: _buttonColor, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _showUserIdDialog() async {
    String userId = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Switch User',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: TextField(
            autofocus: true,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Enter User Email/ID',
              labelStyle: const TextStyle(color: AppColors.textSecondary),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.borderDefault),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.accent, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => userId = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
              ),
              onPressed: () => Navigator.of(context).pop(userId),
              child: Text(
                'Switch',
                style: TextStyle(color: _textColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
