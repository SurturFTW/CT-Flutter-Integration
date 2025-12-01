import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart'; // Add if you want haptic feedback

class TrueMoneyPage extends StatefulWidget {
  const TrueMoneyPage({Key? key}) : super(key: key);

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

  // Add this variable to store the current userId (optional)
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

    // Step 3: Sync variables to dashboard (ONLY in debug mode)
    // Uncomment this line ONLY when you want to sync to dashboard
    CleverTapPlugin.syncVariables();

    // Step 4: Fetch latest values from server
    // fetchVariables();
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
        _textColor =
            _parseColor(appTheme['textColorHex'], const Color(0xFF000000));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildCardSection(),
                const SizedBox(height: 30),
                _buildFirstIconRow(),
                const SizedBox(height: 20),
                _buildSecondIconRow(),
                const SizedBox(height: 30),
                _buildImageCarousel(),
                const SizedBox(height: 35),
                _buildPayNowButton(),
                const SizedBox(height: 30),
                _buildRefreshConfigButton(),
                const SizedBox(height: 20),
                _buildSwitchUserButton(), // <-- Add this line
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_headerGradientTop, _headerGradientBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: -10,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Logo and title
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: 40,
                        color: _iconTintColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Wallet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 180,
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

          // Card content - could be an image or custom design
          Center(
            child: Padding(
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
          ),
        ],
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
        // Add haptic feedback
        HapticFeedback.lightImpact();
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
                color: Colors.white,
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
                color: _iconTintColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _textColor,
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
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No banners available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 200,
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
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
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
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: () {
            print('Pay Now tapped');
            // Add payment logic here
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _buttonColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: _buttonColor.withOpacity(0.4),
          ),
          child: const Text(
            'Pay Credit Card Bill',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshConfigButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: OutlinedButton.icon(
        icon: Icon(Icons.refresh, color: _buttonColor),
        label: Text(
          'Refresh Config from Dashboard',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _buttonColor,
          ),
        ),
        onPressed: () {
          print('Refreshing config from CleverTap Dashboard...');
          fetchVariables();
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: _buttonColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchUserButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
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
            // Call CleverTap onUserLogin
            CleverTapPlugin.onUserLogin({
              'Identity': newUserId,
            });
            print('Switched to user: $newUserId');
            fetchVariables(); // Refresh variables for new user
          }
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: _buttonColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
          title: const Text('Switch User'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Enter User Email/ID',
            ),
            onChanged: (value) => userId = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(userId),
              child: const Text('Switch'),
            ),
          ],
        );
      },
    );
  }
}
