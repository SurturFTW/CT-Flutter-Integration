import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

class SubscriptionNewsPage extends StatefulWidget {
  const SubscriptionNewsPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionNewsPage> createState() => _SubscriptionNewsPageState();
}

class _SubscriptionNewsPageState extends State<SubscriptionNewsPage> {
  // Theme color variables
  Color _primaryColor = const Color(0xFF1E88E5);
  Color _accentColor = const Color(0xFFFF6F00);
  Color _backgroundColor = const Color(0xFFF5F5F5);
  Color _cardColor = Colors.white;
  Color _textPrimaryColor = const Color(0xFF212121);
  Color _textSecondaryColor = const Color(0xFF757575);

  // Subscription details
  String _subscriptionTier = 'Premium';
  String _subscriptionStatus = 'Active';
  String _expiryDate = '31 Dec 2025';
  String _articlesRemaining = '100';
  bool _hasSubscription = true;

  // News categories
  List<String> _categories = [
    'Business',
    'Technology',
    'Politics',
    'Sports',
    'Entertainment'
  ];
  int _selectedCategoryIndex = 0;

  // Banner/Hero images
  List<String> _bannerImages = [];

  // Featured articles
  List<Map<String, dynamic>> _featuredArticles = [
    {
      'title': 'Breaking: Markets hit all-time high',
      'category': 'Business',
      'imageUrl': '',
      'isPremium': false,
    },
    {
      'title': 'AI Revolution in Healthcare',
      'category': 'Technology',
      'imageUrl': '',
      'isPremium': true,
    },
    {
      'title': 'Election Updates: Latest Poll Results',
      'category': 'Politics',
      'imageUrl': '',
      'isPremium': true,
    },
  ];

  // Carousel controller
  late PageController _carouselController;
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;

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
    // Define variables with default values
    var variables = {
      'app_theme': {
        'primaryColorHex': '#1E88E5',
        'accentColorHex': '#FF6F00',
        'backgroundColorHex': '#F5F5F5',
        'cardColorHex': '#FFFFFF',
        'textPrimaryColorHex': '#212121',
        'textSecondaryColorHex': '#757575',
      },
      'subscription_details': {
        'tier': 'Premium',
        'status': 'Active',
        'expiryDate': '31 Dec 2025',
        'articlesRemaining': '100',
        'hasSubscription': true,
      },
      'news_categories': {
        'category1': 'Business',
        'category2': 'Technology',
        'category3': 'Politics',
        'category4': 'Sports',
        'category5': 'Entertainment',
      },
      'banner_images': {
        'banner1': '',
        'banner2': '',
        'banner3': '',
      },
      'featured_articles': {
        'article1_title': 'Breaking: Markets hit all-time high',
        'article1_category': 'Business',
        'article1_image': '',
        'article1_premium': false,
        'article2_title': 'AI Revolution in Healthcare',
        'article2_category': 'Technology',
        'article2_image': '',
        'article2_premium': true,
        'article3_title': 'Election Updates: Latest Poll Results',
        'article3_category': 'Politics',
        'article3_image': '',
        'article3_premium': true,
      },
    };

    CleverTapPlugin.defineVariables(variables);
    print('✓ Subscription News variables defined');

    // Set up listener for variable changes
    CleverTapPlugin.onVariablesChanged((variables) {
      print('Subscription News variables updated: $variables');
      if (mounted) {
        updateUIWithNewValues();
      }
    });

    // Uncomment to sync variables to dashboard (ONLY in debug mode)
    CleverTapPlugin.syncVariables();

    // Fetch latest values from server
    // fetchVariables();
  }

  void fetchVariables() async {
    print('Fetching Subscription News variables from CleverTap...');

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
    var appTheme = await CleverTapPlugin.getVariable('app_theme');
    var subscriptionDetails =
        await CleverTapPlugin.getVariable('subscription_details');
    var newsCategories = await CleverTapPlugin.getVariable('news_categories');
    var bannerImages = await CleverTapPlugin.getVariable('banner_images');
    var featuredArticles =
        await CleverTapPlugin.getVariable('featured_articles');

    if (!mounted) return;

    setState(() {
      // Update theme colors
      if (appTheme != null && appTheme is Map) {
        _primaryColor =
            _parseColor(appTheme['primaryColorHex'], const Color(0xFF1E88E5));
        _accentColor =
            _parseColor(appTheme['accentColorHex'], const Color(0xFFFF6F00));
        _backgroundColor = _parseColor(
            appTheme['backgroundColorHex'], const Color(0xFFF5F5F5));
        _cardColor = _parseColor(appTheme['cardColorHex'], Colors.white);
        _textPrimaryColor = _parseColor(
            appTheme['textPrimaryColorHex'], const Color(0xFF212121));
        _textSecondaryColor = _parseColor(
            appTheme['textSecondaryColorHex'], const Color(0xFF757575));
        print('Theme colors updated');
      }

      // Update subscription details
      if (subscriptionDetails != null && subscriptionDetails is Map) {
        _subscriptionTier =
            subscriptionDetails['tier']?.toString() ?? 'Premium';
        _subscriptionStatus =
            subscriptionDetails['status']?.toString() ?? 'Active';
        _expiryDate =
            subscriptionDetails['expiryDate']?.toString() ?? '31 Dec 2025';
        _articlesRemaining =
            subscriptionDetails['articlesRemaining']?.toString() ?? '100';
        _hasSubscription = subscriptionDetails['hasSubscription'] ?? true;
        print('Subscription details updated');
      }

      // Update categories
      if (newsCategories != null && newsCategories is Map) {
        _categories = [
          newsCategories['category1']?.toString() ?? 'Business',
          newsCategories['category2']?.toString() ?? 'Technology',
          newsCategories['category3']?.toString() ?? 'Politics',
          newsCategories['category4']?.toString() ?? 'Sports',
          newsCategories['category5']?.toString() ?? 'Entertainment',
        ];
        print('Categories updated');
      }

      // Update banner images
      if (bannerImages != null && bannerImages is Map) {
        _bannerImages = [
          bannerImages['banner1'],
          bannerImages['banner2'],
          bannerImages['banner3'],
        ]
            .where((url) => url != null && url.toString().isNotEmpty)
            .cast<String>()
            .toList();

        if (_bannerImages.isNotEmpty) {
          _startCarouselTimer();
        }
        print('Banner images updated: $_bannerImages');
      }

      // Update featured articles
      if (featuredArticles != null && featuredArticles is Map) {
        _featuredArticles = [
          {
            'title': featuredArticles['article1_title']?.toString() ??
                'Breaking: Markets hit all-time high',
            'category':
                featuredArticles['article1_category']?.toString() ?? 'Business',
            'imageUrl': featuredArticles['article1_image']?.toString() ?? '',
            'isPremium': featuredArticles['article1_premium'] ?? false,
          },
          {
            'title': featuredArticles['article2_title']?.toString() ??
                'AI Revolution in Healthcare',
            'category': featuredArticles['article2_category']?.toString() ??
                'Technology',
            'imageUrl': featuredArticles['article2_image']?.toString() ?? '',
            'isPremium': featuredArticles['article2_premium'] ?? true,
          },
          {
            'title': featuredArticles['article3_title']?.toString() ??
                'Election Updates: Latest Poll Results',
            'category':
                featuredArticles['article3_category']?.toString() ?? 'Politics',
            'imageUrl': featuredArticles['article3_image']?.toString() ?? '',
            'isPremium': featuredArticles['article3_premium'] ?? true,
          },
        ];
        print('Featured articles updated');
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
    if (_bannerImages.length <= 1) return;

    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      _currentCarouselIndex =
          (_currentCarouselIndex + 1) % _bannerImages.length;

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
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSubscriptionBanner(),
            const SizedBox(height: 16),
            _buildCategoryTabs(),
            const SizedBox(height: 16),
            _buildHeroCarousel(),
            const SizedBox(height: 24),
            _buildFeaturedArticles(),
            const SizedBox(height: 24),
            _buildRefreshButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _primaryColor,
      elevation: 0,
      title: Row(
        children: [
          Icon(Icons.newspaper, color: Colors.white, size: 28),
          const SizedBox(width: 8),
          const Text(
            'NewsHub',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            print('Search tapped');
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            print('Notifications tapped');
          },
        ),
      ],
    );
  }

  Widget _buildSubscriptionBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _hasSubscription ? Icons.verified : Icons.workspace_premium,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_subscriptionTier Plan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Status: $_subscriptionStatus • Expires: $_expiryDate',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_articlesRemaining articles remaining',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!_hasSubscription)
            ElevatedButton(
              onPressed: () {
                print('Upgrade tapped');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Upgrade'),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategoryIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
              HapticFeedback.lightImpact();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? _primaryColor : _cardColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? _primaryColor
                      : _textSecondaryColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : _textPrimaryColor,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCarousel() {
    if (_bannerImages.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 200,
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No featured stories',
            style: TextStyle(color: _textSecondaryColor),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            itemCount: _bannerImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: _bannerImages[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported,
                              size: 50, color: Colors.grey),
                        ),
                      ),
                      Container(
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
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _bannerImages.length,
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

  Widget _buildFeaturedArticles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Articles',
                style: TextStyle(
                  color: _textPrimaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  print('See all tapped');
                },
                child: Text(
                  'See all',
                  style: TextStyle(color: _primaryColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _featuredArticles.length,
          itemBuilder: (context, index) {
            return _buildArticleCard(_featuredArticles[index]);
          },
        ),
      ],
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article) {
    final isPremium = article['isPremium'] ?? false;
    final imageUrl = article['imageUrl']?.toString() ?? '';

    return GestureDetector(
      onTap: () {
        if (isPremium && !_hasSubscription) {
          _showSubscriptionDialog();
        } else {
          print('Article tapped: ${article['title']}');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
                    ),
                    if (isPremium)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _accentColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.star, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Premium',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      article['category'] ?? '',
                      style: TextStyle(
                        color: _primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article['title'] ?? '',
                    style: TextStyle(
                      color: _textPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14, color: _textSecondaryColor),
                      const SizedBox(width: 4),
                      Text(
                        '5 min read',
                        style: TextStyle(
                          color: _textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.bookmark_border,
                          size: 18, color: _textSecondaryColor),
                      const SizedBox(width: 12),
                      Icon(Icons.share_outlined,
                          size: 18, color: _textSecondaryColor),
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

  Widget _buildRefreshButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        icon: Icon(Icons.refresh, color: _primaryColor),
        label: Text(
          'Refresh Content from Dashboard',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _primaryColor,
          ),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          fetchVariables();
        },
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          side: BorderSide(color: _primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.workspace_premium, color: _accentColor),
              const SizedBox(width: 8),
              const Text('Premium Content'),
            ],
          ),
          content: const Text(
            'This is a premium article. Subscribe to read unlimited premium content.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                print('Subscribe tapped');
                // CleverTapPlugin.recordEvent('Subscription Prompt Shown', {
                //   'source': 'premium_article',
                // });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Subscribe Now'),
            ),
          ],
        );
      },
    );
  }
}
