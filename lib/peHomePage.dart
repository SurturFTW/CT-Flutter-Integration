import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';

class PeHomePage extends StatefulWidget {
  const PeHomePage({Key? key}) : super(key: key);

  @override
  State<PeHomePage> createState() => _PeHomePageState();
}

class _PeHomePageState extends State<PeHomePage> {
  // Variables to store config values
  String welcomeMessage = 'Welcome!';
  double dailyLimit = 50000.0;
  bool showPromotion = false;
  double cashbackPercent = 2.0;
  bool showCardOffers = false;
  String cardType = 'Premium';
  double cardCreditLimit = 100000.0;

  // Card carousel variables
  late PageController _pageController;
  int _selectedCardIndex = 0;

  // Card promotion data
  final List<Map<String, dynamic>> _cardPromotions = [
    {
      'title': 'Premium Card Special',
      'description': 'Get 5% cashback on all premium purchases',
      'color': Colors.purple,
      'icon': Icons.diamond,
      'offer': '5% Cashback',
    },
    {
      'title': 'Travel Rewards',
      'description': 'Earn 3x miles on travel bookings',
      'color': Colors.blue,
      'icon': Icons.flight,
      'offer': '3x Miles',
    },
    {
      'title': 'Dining Benefits',
      'description': 'Up to 10% off at partner restaurants',
      'color': Colors.orange,
      'icon': Icons.restaurant,
      'offer': '10% Off',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    initializeProductExperiences();
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Remove the listener when disposing
    // CleverTapPlugin.onVariablesChanged(null);
    super.dispose();
  }

  void initializeProductExperiences() {
    // Step 1: Define your variables with default values
    var variables = {
      'welcome_message': 'Welcome to Your Fintech App!',
      'daily_transaction_limit': 50000.0,
      'show_promotion_banner': false,
      'cashback_percentage': 2.0,
      'enable_feature_x': true,
      'show_card_offers': true,
      'card_type': 'Premium',
      'card_credit_limit': 100000.0,
    };

    CleverTapPlugin.defineVariables(variables);
    print('✓ Variables defined');

    // Step 2: Set up listener for variable changes
    CleverTapPlugin.onVariablesChanged((variables) {
      print('Variables updated from server: $variables');
      // Check if widget is still mounted before updating
      if (mounted) {
        updateUIWithNewValues();
      }
    });

    // Step 3: Sync variables to dashboard (ONLY in debug mode)
    // Uncomment this line ONLY when you want to sync to dashboard
    // CleverTapPlugin.syncVariables();

    // Step 4: Fetch latest values from server
    fetchVariables();
  }

  void fetchVariables() async {
    print('Fetching variables from CleverTap...');

    bool? success = await CleverTapPlugin.fetchVariables();

    if (success == true) {
      print('✓ Variables fetched successfully');
      if (mounted) {
        updateUIWithNewValues();
      }
    } else {
      print('✗ Failed to fetch variables, using defaults');
    }
  }

  void updateUIWithNewValues() async {
    // Get individual variable values
    var welcome = await CleverTapPlugin.getVariable('welcome_message');
    var limit = await CleverTapPlugin.getVariable('daily_transaction_limit');
    var showPromo = await CleverTapPlugin.getVariable('show_promotion_banner');
    var cashback = await CleverTapPlugin.getVariable('cashback_percentage');
    var cardOffers = await CleverTapPlugin.getVariable('show_card_offers');
    var cardTypeVar = await CleverTapPlugin.getVariable('card_type');
    var creditLimit = await CleverTapPlugin.getVariable('card_credit_limit');

    // Only update if widget is still mounted
    if (!mounted) return;

    setState(() {
      welcomeMessage = welcome ?? 'Welcome!';
      dailyLimit = _parseDouble(limit, 50000.0);
      showPromotion = _parseBool(showPromo, false);
      cashbackPercent = _parseDouble(cashback, 2.0);
      showCardOffers = _parseBool(cardOffers, false);
      cardType = cardTypeVar ?? 'Premium';
      cardCreditLimit = _parseDouble(creditLimit, 100000.0);
    });

    print('UI updated with new values');
  }

  // Helper method to safely parse boolean values
  bool _parseBool(dynamic value, bool defaultValue) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value != 0;
    return defaultValue;
  }

  // Helper method to safely parse double values
  double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fintech Cards'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Current Card Type Display
            _buildCurrentCardType(),

            const SizedBox(height: 24),

            // Card Promotions Carousel
            _buildCardPromotionsCarousel(),

            const SizedBox(height: 24),

            // Card Offers Section (controlled by CleverTap)
            if (showCardOffers) _buildCardOffersSection(),

            const SizedBox(height: 32),

            // Refresh Button
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Config'),
                onPressed: fetchVariables,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentCardType() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Current Card',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getCardColors(cardType),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$cardType Card',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      _getCardIcon(cardType),
                      color: Colors.white,
                      size: 36,
                    ),
                  ],
                ),
                const Text(
                  '**** **** **** 1234',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
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
                        const Text(
                          'Credit Limit',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '₹${cardCreditLimit.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cashback Rate',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$cashbackPercent%',
                          style: const TextStyle(
                            color: Colors.white,
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
    );
  }

  Widget _buildCardPromotionsCarousel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Card Promotions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedCardIndex = index;
                });
              },
              itemCount: _cardPromotions.length,
              itemBuilder: (context, index) {
                final promotion = _cardPromotions[index];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        promotion['color'],
                        promotion['color'].withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            promotion['icon'],
                            color: Colors.white,
                            size: 32,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              promotion['offer'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promotion['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            promotion['description'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Promotion indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _cardPromotions.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedCardIndex == index
                      ? Colors.blue[700]
                      : Colors.grey[300],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardOffersSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exclusive Card Offers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getCardIcon(cardType),
                      color: Colors.green[700],
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$cardType Card Benefits',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Get $cashbackPercent% cashback on all card transactions',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Credit Limit: ₹${cardCreditLimit.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getCardColors(String type) {
    switch (type) {
      case 'Premium':
        return [Colors.purple[800]!, Colors.purple[600]!];
      case 'Gold':
        return [Colors.amber[800]!, Colors.amber[600]!];
      case 'Platinum':
        return [Colors.blueGrey[800]!, Colors.blueGrey[600]!];
      default:
        return [Colors.grey[800]!, Colors.grey[600]!];
    }
  }

  IconData _getCardIcon(String type) {
    switch (type) {
      case 'Premium':
        return Icons.diamond;
      case 'Gold':
        return Icons.stars;
      case 'Platinum':
        return Icons.workspace_premium;
      default:
        return Icons.credit_card;
    }
  }
}
