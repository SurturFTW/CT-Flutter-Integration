import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

import '../../config/app_colors.dart';
import '../../config/app_enums.dart';
import 'onsurity_claim_page.dart';
import 'onsurity_wellness_page.dart';

// ─── Banner model with expiry support ───────────────────────────────────────

class BannerItem {
  final String imageUrl;
  final DateTime? expiryDate; // null = never expires
  final String label; // e.g. "Offer ends 31 Dec"

  const BannerItem({
    required this.imageUrl,
    this.expiryDate,
    this.label = '',
  });

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  String get expiryLabel {
    if (expiryDate == null) return '';
    if (isExpired) return 'Expired';
    final diff = expiryDate!.difference(DateTime.now());
    if (diff.inDays > 1) return 'Ends in ${diff.inDays}d';
    if (diff.inHours > 0) return 'Ends in ${diff.inHours}h';
    return 'Ends soon';
  }
}

// ─── Main Page ───────────────────────────────────────────────────────────────

class OnsurityPage extends StatefulWidget {
  const OnsurityPage({super.key});

  @override
  State<OnsurityPage> createState() => _OnsurityPageState();
}

class _OnsurityPageState extends State<OnsurityPage>
    with SingleTickerProviderStateMixin {
  // ── CleverTap-driven theme ──────────────────────────────────────────────
  Color _primaryColor = const Color(0xFF1B4FD8); // Onsurity blue
  Color _accentColor = const Color(0xFF00C896); // health green
  String _companyName = 'Onsurity';
  String _planName = 'Essential Care';

  // ── CleverTap-driven user/policy variables ─────────────────────────────
  String _userName = 'Rahul Sharma';
  String _employeeCount = '24';
  String _policyStatus = 'Active'; // Active / Expiring / Expired
  String _policyExpiry = '31 Dec 2025';
  String _sumInsured = '₹3,00,000';
  String _claimsUsed = '₹45,000';
  String _claimsTotal = '₹3,00,000';
  String _memberCount = '68';
  String _pendingClaims = '2';

  // ── CleverTap-driven health metrics ────────────────────────────────────
  String _wellnessScore = '72';
  String _gymPartners = '2,500+';
  String _teleConsultCount = '3';

  // ── Banner carousel with expiry ─────────────────────────────────────────
  List<BannerItem> _banners = [];
  late PageController _carouselController;
  int _currentBannerIndex = 0;
  Timer? _carouselTimer;
  Timer? _expiryCheckTimer;

  // ── Animations ──────────────────────────────────────────────────────────
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  // ── User switcher ────────────────────────────────────────────────────────
  String _currentUserId = 'onsurity_user_1';

  @override
  void initState() {
    super.initState();
    _carouselController = PageController();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    _initializeProductExperiences();

    // Re-check banner expiry every minute
    _expiryCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {}); // triggers rebuild → expired banners hidden
    });
  }

  @override
  void dispose() {
    _carouselController.dispose();
    _carouselTimer?.cancel();
    _expiryCheckTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  // ── CleverTap Integration ────────────────────────────────────────────────

  void _initializeProductExperiences() {
    final variables = {
      'onsurity_theme': {
        'primaryColorHex': '#1B4FD8',
        'accentColorHex': '#00C896',
        'companyName': 'Onsurity',
        'planName': 'Essential Care',
      },
      'onsurity_user': {
        'userName': 'Rahul Sharma',
        'employeeCount': '24',
        'policyStatus': 'Active',
        'policyExpiry': '31 Dec 2025',
        'sumInsured': '₹3,00,000',
        'claimsUsed': '₹45,000',
        'claimsTotal': '₹3,00,000',
        'memberCount': '68',
        'pendingClaims': '2',
      },
      'onsurity_wellness': {
        'wellnessScore': '72',
        'gymPartners': '2,500+',
        'teleConsultCount': '3',
      },
      // Banner slots with expiry metadata
      // Format: imageUrl|expiryEpochMs   (empty expiryEpochMs = never expires)
      'onsurity_banners': {
        'Banner Image 1':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQgGnfCNoOtVu6GrvpEaDJadIwsFma1DmBdiA&s',
        'Banner Expiry 1': '',
        'Banner Label 1': 'Free OPD Cover',
        'Banner Image 2':
            'https://images.unsplash.com/photo-1631217314830-4d536837e2b0?w=800',
        'Banner Expiry 2': '',
        'Banner Label 2': 'Annual Health Checkup',
        'Banner Image 3':
            'https://images.unsplash.com/photo-1631217314830-4d536837e2b0?w=800',
        'Banner Expiry 3': '',
        'Banner Label 3': 'Mental Wellness Sessions',
      },
    };

    CleverTapPlugin.defineVariables(variables);

    _syncVariables();

    CleverTapPlugin.onVariablesChanged((vars) {
      if (mounted) _applyUpdatedVariables();
    });

    _fetchVariables();
  }

  void _fetchVariables() async {
    final success = await CleverTapPlugin.fetchVariables();
    if (success == true && mounted) _applyUpdatedVariables();
  }

  void _syncVariables() async {
    await CleverTapPlugin.syncVariables();
    debugPrint("Variables sync completed");
  }

  void _applyUpdatedVariables() async {
    final theme = await CleverTapPlugin.getVariable('onsurity_theme');
    final user = await CleverTapPlugin.getVariable('onsurity_user');
    final wellness = await CleverTapPlugin.getVariable('onsurity_wellness');
    final banners = await CleverTapPlugin.getVariable('onsurity_banners');

    if (!mounted) return;

    setState(() {
      if (theme != null && theme is Map) {
        _primaryColor =
            _parseColor(theme['primaryColorHex'], const Color(0xFF1B4FD8));
        _accentColor =
            _parseColor(theme['accentColorHex'], const Color(0xFF00C896));
        _companyName = theme['companyName']?.toString() ?? 'Onsurity';
        _planName = theme['planName']?.toString() ?? 'Essential Care';
      }

      if (user != null && user is Map) {
        _userName = user['userName']?.toString() ?? 'Rahul Sharma';
        _employeeCount = user['employeeCount']?.toString() ?? '24';
        _policyStatus = user['policyStatus']?.toString() ?? 'Active';
        _policyExpiry = user['policyExpiry']?.toString() ?? '31 Dec 2025';
        _sumInsured = user['sumInsured']?.toString() ?? '₹3,00,000';
        _claimsUsed = user['claimsUsed']?.toString() ?? '₹45,000';
        _claimsTotal = user['claimsTotal']?.toString() ?? '₹3,00,000';
        _memberCount = user['memberCount']?.toString() ?? '68';
        _pendingClaims = user['pendingClaims']?.toString() ?? '2';
      }

      if (wellness != null && wellness is Map) {
        _wellnessScore = wellness['wellnessScore']?.toString() ?? '72';
        _gymPartners = wellness['gymPartners']?.toString() ?? '2,500+';
        _teleConsultCount = wellness['teleConsultCount']?.toString() ?? '3';
      }

      if (banners != null && banners is Map) {
        _banners = _parseBanners(banners);
        if (_banners.isNotEmpty) _startCarouselTimer();
      }
    });
  }

  /// Parses banner map from CleverTap into [BannerItem] list,
  /// filtering out already-expired banners immediately.
  List<BannerItem> _parseBanners(Map banners) {
    final result = <BannerItem>[];
    for (int i = 1; i <= 3; i++) {
      final url = banners['Banner Image $i']?.toString() ?? '';
      final expStr = banners['Banner Expiry $i']?.toString() ?? '';
      final label = banners['Banner Label $i']?.toString() ?? '';

      if (url.isEmpty) continue; // skip empty slots

      DateTime? expiry;
      if (expStr.isNotEmpty) {
        final ms = int.tryParse(expStr);
        if (ms != null) expiry = DateTime.fromMillisecondsSinceEpoch(ms);
      }

      final item = BannerItem(imageUrl: url, expiryDate: expiry, label: label);
      if (!item.isExpired) result.add(item); // skip already-expired banners
      debugPrint(
          'Parsed Banner $i: ${item.imageUrl} | Expiry: ${item.expiryLabel}');
    }
    debugPrint('Total live banners: ${result.length}');

    return result;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

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
    // Only live (non-expired) banners cycle
    final liveBanners = _banners.where((b) => !b.isExpired).toList();
    if (liveBanners.length <= 1) return;

    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final live = _banners.where((b) => !b.isExpired).toList();
      if (live.isEmpty) return;
      _currentBannerIndex = (_currentBannerIndex + 1) % live.length;
      _carouselController.animateToPage(
        _currentBannerIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  Color get _statusColor {
    switch (_policyStatus) {
      case 'Active':
        return AppColors.success;
      case 'Expiring':
        return AppColors.warning;
      case 'Expired':
        return AppColors.error;
      default:
        return AppColors.success;
    }
  }

  double get _claimsProgress {
    final used =
        double.tryParse(_claimsUsed.replaceAll(RegExp(r'[₹,]'), '')) ?? 45000;
    final total =
        double.tryParse(_claimsTotal.replaceAll(RegExp(r'[₹,]'), '')) ?? 300000;
    if (total == 0) return 0;
    return (used / total).clamp(0.0, 1.0);
  }

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
        backgroundColor: AppColors.surfaceHighlight,
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPolicyHeroCard(),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 20),
              _buildClaimsSection(),
              const SizedBox(height: 20),
              _buildBannerCarousel(),
              const SizedBox(height: 20),
              _buildWellnessStrip(),
              const SizedBox(height: 20),
              _buildTeamHealthSection(),
              const SizedBox(height: 20),
              _buildBenefitsSection(),
              const SizedBox(height: 20),
              _buildRefreshConfigButton(),
              const SizedBox(height: 16),
              _buildQuickUserSwitcher(),
              const SizedBox(height: 12),
              _buildSwitchUserButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

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
            color: AppColors.surfaceHighlight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: const Icon(Icons.arrow_back_ios_rounded,
              size: 16, color: AppColors.textPrimary),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.health_and_safety_rounded,
                size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            _companyName,
            style: TextStyle(
              color: _primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: () =>
              _showSnack('Notifications for $_userName', SnackType.info),
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceHighlight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined,
                    size: 20, color: AppColors.textPrimary),
                if (int.tryParse(_pendingClaims) != null &&
                    int.parse(_pendingClaims) > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.midnight, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          _pendingClaims,
                          style: const TextStyle(
                              fontSize: 7,
                              color: Colors.white,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Policy Hero Card ──────────────────────────────────────────────────────

  Widget _buildPolicyHeroCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryColor, _primaryColor.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -30,
              top: -20,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, ${_userName.split(' ').first} 👋',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _planName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _StatusBadge(
                        label: _policyStatus,
                        color: _statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Sum insured + employees
                  Row(
                    children: [
                      _HeroStat(
                          label: 'Sum Insured',
                          value: _sumInsured,
                          icon: Icons.shield_outlined),
                      const SizedBox(width: 24),
                      _HeroStat(
                          label: 'Members',
                          value: _memberCount,
                          icon: Icons.people_outline_rounded),
                      const SizedBox(width: 24),
                      _HeroStat(
                          label: 'Employees',
                          value: _employeeCount,
                          icon: Icons.business_outlined),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Expiry row
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 13, color: Colors.white60),
                      const SizedBox(width: 6),
                      Text(
                        'Policy valid till: $_policyExpiry',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
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

  // ── Quick Actions ─────────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.add_circle_outline_rounded,
        'label': 'File Claim',
        'color': _primaryColor,
      },
      {
        'icon': Icons.video_call_outlined,
        'label': 'Tele-consult',
        'color': _accentColor,
      },
      {
        'icon': Icons.card_membership_outlined,
        'label': 'E-Card',
        'color': AppColors.amber,
      },
      {
        'icon': Icons.local_hospital_outlined,
        'label': 'Hospitals',
        'color': AppColors.rose,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((a) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (a['label'] == 'File Claim') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OnsurityClaimPage(
                      primaryColor: _primaryColor,
                      accentColor: _accentColor,
                      planName: _planName,
                    ),
                  ),
                );
              } else if (a['label'] == 'Tele-consult') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OnsurityWellnessPage(
                      primaryColor: _primaryColor,
                      accentColor: _accentColor,
                      wellnessScore: _wellnessScore,
                      gymPartners: _gymPartners,
                      teleConsultCount: _teleConsultCount,
                    ),
                  ),
                );
              } else {
                _showSnack('${a['label']} tapped', SnackType.info);
              }
            },
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: (a['color'] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: (a['color'] as Color).withOpacity(0.25)),
                  ),
                  child: Icon(a['icon'] as IconData,
                      color: a['color'] as Color, size: 26),
                ),
                const SizedBox(height: 6),
                Text(
                  a['label'] as String,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Claims Section ────────────────────────────────────────────────────────

  Widget _buildClaimsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    size: 16, color: _primaryColor),
                const SizedBox(width: 8),
                const Text('Claims Overview',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                if (int.tryParse(_pendingClaims) != null &&
                    int.parse(_pendingClaims) > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.warningDim,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_pendingClaims Pending',
                      style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Used: $_claimsUsed',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                Text('Total: $_claimsTotal',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _claimsProgress,
                minHeight: 10,
                backgroundColor: AppColors.borderDefault,
                valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_claimsProgress * 100).toInt()}% of cover used',
              style:
                  const TextStyle(color: AppColors.textTertiary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // ── Banner Carousel with Expiry ───────────────────────────────────────────

  Widget _buildBannerCarousel() {
    // Only show live (non-expired) banners
    final liveBanners = _banners.where((b) => !b.isExpired).toList();

    if (liveBanners.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.campaign_outlined, color: _primaryColor, size: 30),
                const SizedBox(height: 8),
                const Text('Personalised offers appear here',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                Text('Configure in CleverTap dashboard',
                    style: TextStyle(
                        color: _primaryColor.withOpacity(0.6), fontSize: 11)),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 150,
        child: Stack(
          children: [
            PageView.builder(
              controller: _carouselController,
              onPageChanged: (i) => setState(() => _currentBannerIndex = i),
              itemCount: liveBanners.length,
              itemBuilder: (_, i) {
                final banner = liveBanners[i];
                return _BannerSlide(
                  banner: banner,
                  primaryColor: _primaryColor,
                  accentColor: _accentColor,
                );
              },
            ),
            // Page dots
            if (liveBanners.length > 1)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(liveBanners.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: _currentBannerIndex == i ? 18 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: _currentBannerIndex == i
                            ? Colors.white
                            : Colors.white38,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Wellness Strip ────────────────────────────────────────────────────────

  Widget _buildWellnessStrip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OnsurityWellnessPage(
                primaryColor: _primaryColor,
                accentColor: _accentColor,
                wellnessScore: _wellnessScore,
                gymPartners: _gymPartners,
                teleConsultCount: _teleConsultCount,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _accentColor.withOpacity(0.15),
                _primaryColor.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _accentColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _accentColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.favorite_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Wellness Score',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text('$_wellnessScore / 100',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      '$_gymPartners gym partners • $_teleConsultCount consults left',
                      style: TextStyle(color: _accentColor, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: _accentColor),
            ],
          ),
        ),
      ),
    );
  }

  // ── Team Health Section ───────────────────────────────────────────────────

  Widget _buildTeamHealthSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text('Team Health Snapshot',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3)),
          ),
          Row(
            children: [
              Expanded(
                child: _HealthStatCard(
                  icon: Icons.people_outline_rounded,
                  label: 'Covered Members',
                  value: _memberCount,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HealthStatCard(
                  icon: Icons.receipt_long_outlined,
                  label: 'Pending Claims',
                  value: _pendingClaims,
                  color: int.parse(_pendingClaims) > 0
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Benefits Section ──────────────────────────────────────────────────────

  Widget _buildBenefitsSection() {
    final benefits = [
      {
        'icon': Icons.local_hospital_outlined,
        'title': 'Cashless Hospitalisation',
        'sub': '5,000+ network hospitals',
        'color': _primaryColor,
      },
      {
        'icon': Icons.medication_outlined,
        'title': 'OPD & Medicines',
        'sub': 'Cover for outpatient treatment',
        'color': _accentColor,
      },
      {
        'icon': Icons.psychology_outlined,
        'title': 'Mental Wellness',
        'sub': 'Therapy & counselling sessions',
        'color': AppColors.violet,
      },
      {
        'icon': Icons.airline_seat_flat_outlined,
        'title': 'Pre & Post Hospitalisation',
        'sub': '30 / 60 days coverage',
        'color': AppColors.amber,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text('Plan Benefits',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3)),
          ),
          ...benefits.map((b) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (b['color'] as Color).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(b['icon'] as IconData,
                        color: b['color'] as Color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b['title'] as String,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        Text(b['sub'] as String,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded,
                      size: 18, color: AppColors.success),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Refresh & User Switcher ───────────────────────────────────────────────

  Widget _buildRefreshConfigButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          icon: Icon(Icons.refresh_rounded, color: _primaryColor),
          label: Text('Refresh Config',
              style: TextStyle(
                  color: _primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          onPressed: () {
            _showSnack('Refreshing from CleverTap…', SnackType.info);
            _fetchVariables();
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: _primaryColor, width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickUserSwitcher() {
    final users = [
      'onsurity_user_1',
      'onsurity_user_2',
      'onsurity_user_3',
      'onsurity_user_4',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Switch:',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: users.map((uid) {
              final isActive = _currentUserId == uid;
              return GestureDetector(
                onTap: () {
                  if (!isActive) {
                    setState(() => _currentUserId = uid);
                    CleverTapPlugin.onUserLogin({'Identity': uid});
                    _showSnack('Switched to: $uid', SnackType.success);
                    _fetchVariables();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive ? _primaryColor : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color:
                            isActive ? _primaryColor : AppColors.borderDefault),
                  ),
                  child: Text(uid,
                      style: TextStyle(
                          color:
                              isActive ? Colors.white : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          icon: Icon(Icons.person_rounded, color: _primaryColor),
          label: Text('Switch User',
              style: TextStyle(
                  color: _primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
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
            side: BorderSide(color: _primaryColor, width: 1.5),
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _primaryColor.withOpacity(0.3)),
        ),
        title: const Text('Switch User',
            style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Enter User ID / Email',
            labelStyle: const TextStyle(color: AppColors.textSecondary),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.borderDefault),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _primaryColor, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (v) => id = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, id),
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            child: const Text('Switch', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Banner Slide Widget (handles expiry display) ─────────────────────────────

class _BannerSlide extends StatelessWidget {
  final BannerItem banner;
  final Color primaryColor;
  final Color accentColor;

  const _BannerSlide({
    required this.banner,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background — image or gradient fallback
            banner.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: banner.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: primaryColor.withOpacity(0.15)),
                    errorWidget: (_, __, ___) => _fallbackBg(primaryColor),
                  )
                : _fallbackBg(primaryColor),

            // Dark scrim at bottom
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
              ),
            ),

            // Label at bottom-left
            if (banner.label.isNotEmpty)
              Positioned(
                left: 12,
                bottom: 22,
                child: Text(
                  banner.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ),

            // Expiry badge — top-right corner
            if (banner.expiryDate != null)
              Positioned(
                top: 10,
                right: 10,
                child: _ExpiryBadge(banner: banner),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackBg(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.health_and_safety_outlined,
            size: 48, color: Colors.white24),
      ),
    );
  }
}

// ─── Expiry Badge ─────────────────────────────────────────────────────────────

class _ExpiryBadge extends StatelessWidget {
  final BannerItem banner;
  const _ExpiryBadge({required this.banner});

  @override
  Widget build(BuildContext context) {
    final isExpiringSoon = !banner.isExpired &&
        banner.expiryDate != null &&
        banner.expiryDate!.difference(DateTime.now()).inDays <= 3;

    final bg = banner.isExpired
        ? Colors.red.shade700
        : isExpiringSoon
            ? Colors.orange.shade700
            : Colors.black54;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            banner.isExpired ? Icons.block_rounded : Icons.timer_outlined,
            size: 10,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            banner.expiryLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Supporting small widgets ─────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _HeroStat(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 11, color: Colors.white60),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _HealthStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _HealthStatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
