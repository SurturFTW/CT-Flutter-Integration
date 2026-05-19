import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'bill_payment_page.dart';
import 'rewards_page.dart';
import '../../main.dart';

class TrueMoneyPage extends StatefulWidget {
  const TrueMoneyPage({super.key});

  @override
  State<TrueMoneyPage> createState() => _TrueMoneyPageState();
}

class _TrueMoneyPageState extends State<TrueMoneyPage>
    with SingleTickerProviderStateMixin {
  // Theme color variables - Credit Card themed
  Color _headerGradientTop = const Color(0xFF1A1A2E);
  Color _headerGradientBottom = const Color(0xFF16213E);
  Color _cardGradientTop = const Color(0xFFFFD700);
  Color _cardGradientBottom = const Color(0xFFFFB800);
  Color _iconTintColor = const Color(0xFFFFD700);
  Color _textColor = Colors.black87;
  Color _buttonColor = const Color(0xFFFFD700);

  // Credit Card specific variables
  String _cardType = 'Premium Gold';
  String _cardNumber = '**** **** **** 5678';
  String _creditLimit = '₹5,00,000';
  String _availableCredit = '₹3,75,000';
  String _rewardPoints = '12,450';

  // Carousel variables
  late PageController _carouselController;
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;

  // Banner image URLs from CleverTap
  List<String> _bannerImageUrls = [];

  // variable to store the current userId
  String _currentUserId = 'user1@example.com';

  @override
  void initState() {
    super.initState();
    _carouselController = PageController();
    initializeProductExperiences();
  }

  @override
  void dispose() {
    _carouselController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  void initializeProductExperiences() {
    // Define variables with default values for Credit Card App
    var variables = {
      'Banner': {
        'Banner Image 1': '',
        'Banner Image 2': '',
        'Banner Image 3': '',
      },
      'app_theme': {
        'headerGradientTopHex': '#1A1A2E',
        'headerGradientBottomHex': '#16213E',
        'cardGradientTopHex': '#FFD700',
        'cardGradientBottomHex': '#FFB800',
        'iconTintHex': '#FFD700',
        'buttonColorHex': '#FFD700',
        'textColorHex': '#000000',
      },
      'credit_card_details': {
        'cardType': 'Premium Gold',
        'cardNumber': '**** **** **** 5678',
        'creditLimit': '₹5,00,000',
        'availableCredit': '₹3,75,000',
        'rewardPoints': '12,450',
      },
    };

    CleverTapPlugin.defineVariables(variables);
    print('✓ Credit Card variables defined');

    // Set up listener for variable changes
    CleverTapPlugin.onVariablesChanged((variables) {
      print('Credit Card variables updated: $variables');
      if (mounted) {
        updateUIWithNewValues();
      }
    });

    fetchVariables();
  }

  void fetchVariables() async {
    print('Fetching Credit Card variables from CleverTap...');

    bool? success = await CleverTapPlugin.fetchVariables();

    if (success == true) {
      print('✓ Credit Card variables fetched successfully');
      if (mounted) {
        updateUIWithNewValues();
      }
    } else {
      print('✗ Failed to fetch variables, using defaults');
    }
  }

  void updateUIWithNewValues() async {
    // Get Banner images
    var banner = await CleverTapPlugin.getVariable('Banner');

    // Get App Theme
    var appTheme = await CleverTapPlugin.getVariable('app_theme');

    // Get Credit Card Details
    var cardDetails = await CleverTapPlugin.getVariable('credit_card_details');

    if (!mounted) return;

    setState(() {
      // Update banner images
      if (banner != null && banner is Map) {
        _bannerImageUrls = [
          banner['Banner Image 1'],
          banner['Banner Image 2'],
          banner['Banner Image 3'],
        ]
            .where((url) => url != null && url.toString().isNotEmpty)
            .cast<String>()
            .toList();

        print('Banner images loaded: $_bannerImageUrls');

        if (_bannerImageUrls.isNotEmpty) {
          _startCarouselTimer();
        }
      }

      // Update theme colors
      if (appTheme != null && appTheme is Map) {
        _headerGradientTop = _parseColor(
            appTheme['headerGradientTopHex'], const Color(0xFF1A1A2E));
        _headerGradientBottom = _parseColor(
            appTheme['headerGradientBottomHex'], const Color(0xFF16213E));
        _cardGradientTop = _parseColor(
            appTheme['cardGradientTopHex'], const Color(0xFFFFD700));
        _cardGradientBottom = _parseColor(
            appTheme['cardGradientBottomHex'], const Color(0xFFFFB800));
        _iconTintColor =
            _parseColor(appTheme['iconTintHex'], const Color(0xFFFFD700));
        _buttonColor =
            _parseColor(appTheme['buttonColorHex'], const Color(0xFFFFD700));
        // Use light text for dark backgrounds, dark text for light backgrounds
        _textColor =
            _shouldUseLightText(_buttonColor) ? Colors.white : Colors.black87;

        print('Theme applied: $appTheme');
      }

      // Update credit card details
      if (cardDetails != null && cardDetails is Map) {
        _cardType = cardDetails['cardType']?.toString() ?? 'Premium Gold';
        _cardNumber =
            cardDetails['cardNumber']?.toString() ?? '**** **** **** 5678';
        _creditLimit = cardDetails['creditLimit']?.toString() ?? '₹5,00,000';
        _availableCredit =
            cardDetails['availableCredit']?.toString() ?? '₹3,75,000';
        _rewardPoints = cardDetails['rewardPoints']?.toString() ?? '12,450';

        print('Credit card details updated: $cardDetails');
      }
    });
  }

  Color _parseColor(dynamic colorValue, Color defaultColor) {
    if (colorValue == null) return defaultColor;

    String colorString = colorValue.toString();
    if (colorString.startsWith('#')) {
      colorString = colorString.substring(1);
    }

    try {
      if (colorString.length == 6) {
        colorString = 'FF' + colorString;
      }
      return Color(int.parse(colorString, radix: 16));
    } catch (e) {
      print('Failed to parse color: $colorValue');
      return defaultColor;
    }
  }

  bool _shouldUseLightText(Color color) {
    // Calculate luminance to determine if text should be light or dark
    double luminance =
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
            _buildCardSection(),
            const SizedBox(height: 24),
            _buildFirstIconRow(),
            const SizedBox(height: 20),
            _buildSecondIconRow(),
            const SizedBox(height: 24),
            _buildImageCarousel(),
            const SizedBox(height: 24),
            _buildCreditLimitSection(),
            const SizedBox(height: 24),
            _buildPayNowButton(),
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

  Widget _buildCreditLimitSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Credit Limit',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.textTertiary,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _creditLimit,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.75,
                minHeight: 8,
                backgroundColor: AppColors.borderDefault,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _buttonColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Used: ₹1,25,000',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'Available: $_availableCredit',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _cardType,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.contactless,
                        color: Colors.black87,
                        size: 32,
                      ),
                    ],
                  ),
                  Text(
                    _cardNumber,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available Credit',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _availableCredit,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Reward Points',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _rewardPoints,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  Widget _buildFirstIconRow() {
    final icons = [
      {'icon': Icons.payment, 'title': 'Pay Bills'},
      {'icon': Icons.receipt_long, 'title': 'Transaction'},
      {'icon': Icons.stars, 'title': 'Rewards'},
      {'icon': Icons.shopping_bag, 'title': 'Shop'},
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
      {'icon': Icons.swap_horiz, 'title': 'Transfer'},
      {'icon': Icons.account_balance, 'title': 'EMI'},
      {'icon': Icons.card_giftcard, 'title': 'Offers'},
      {'icon': Icons.support_agent, 'title': 'Support'},
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
        print('✅ $title tapped');
        HapticFeedback.lightImpact();

        if (title == 'Pay Bills') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BillPaymentPage(
                buttonColor: _buttonColor,
                textColor: _textColor,
                availableCredit: _availableCredit,
              ),
            ),
          );
        } else if (title == 'Rewards') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RewardsPage(
                buttonColor: _buttonColor,
                textColor: _textColor,
                rewardPoints: _rewardPoints,
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
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
              child: Icon(
                icon,
                color: _textColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
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
          child: Text(
            'No banners available',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
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
              setState(() {
                _currentCarouselIndex = index;
              });
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
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
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

  Widget _buildPayNowButton() {
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
                _showAppSnackBar(
                  message: 'Pay Credit Card Bill initiated',
                  type: SnackType.success,
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Text(
                  'Pay Credit Card Bill',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshConfigButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          icon: Icon(Icons.refresh, color: _buttonColor),
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
              message: 'Refreshing config from dashboard...',
              type: SnackType.info,
            );
            fetchVariables();
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
                        setState(() {
                          _currentUserId = userId;
                        });
                        CleverTapPlugin.onUserLogin({
                          'Identity': userId,
                        });
                        _showAppSnackBar(
                          message: 'Switched to user: $userId',
                          type: SnackType.success,
                        );
                        fetchVariables();
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

  Widget _buildSwitchUserButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          icon: Icon(Icons.person, color: _buttonColor),
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
              setState(() {
                _currentUserId = newUserId;
              });
              CleverTapPlugin.onUserLogin({
                'Identity': newUserId,
              });
              _showAppSnackBar(
                message: 'Switched to user: $newUserId',
                type: SnackType.success,
              );
              fetchVariables();
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
              child: const Text(
                'Switch',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        );
      },
    );
  }
}
