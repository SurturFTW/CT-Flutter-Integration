import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTTSubscriptionPage extends StatefulWidget {
  final Color accentColor;
  final String currentPlan;

  const OTTSubscriptionPage({
    Key? key,
    required this.accentColor,
    required this.currentPlan,
  }) : super(key: key);

  @override
  State<OTTSubscriptionPage> createState() => _OTTSubscriptionPageState();
}

class _OTTSubscriptionPageState extends State<OTTSubscriptionPage>
    with TickerProviderStateMixin {
  int _selectedPlan = 1; // 0=Mobile, 1=Basic, 2=Standard, 3=Premium
  bool _isAnnual = true;
  late AnimationController _shimmerController;

  final List<Map<String, dynamic>> _plans = [
    {
      'name': 'Mobile',
      'monthlyPrice': '₹149',
      'annualPrice': '₹99',
      'resolution': '480p',
      'screens': '1',
      'downloads': '1',
      'icon': Icons.phone_android_rounded,
      'color': Color(0xFF4CAF50),
      'features': ['Mobile only', 'SD quality', '1 device', 'Ads included'],
    },
    {
      'name': 'Basic',
      'monthlyPrice': '₹299',
      'annualPrice': '₹199',
      'resolution': '720p',
      'screens': '1',
      'downloads': '2',
      'icon': Icons.tv_rounded,
      'color': Color(0xFF2196F3),
      'features': ['All devices', 'HD quality', '1 screen', '2 downloads'],
    },
    {
      'name': 'Standard',
      'monthlyPrice': '₹499',
      'annualPrice': '₹349',
      'resolution': '1080p',
      'screens': '2',
      'downloads': '5',
      'icon': Icons.desktop_windows_rounded,
      'color': Color(0xFF9C27B0),
      'features': ['All devices', 'Full HD', '2 screens', '5 downloads'],
      'popular': true,
    },
    {
      'name': 'Premium',
      'monthlyPrice': '₹799',
      'annualPrice': '₹549',
      'resolution': '4K+HDR',
      'screens': '4',
      'downloads': 'Unlimited',
      'icon': Icons.stars_rounded,
      'color': Color(0xFFFFD700),
      'features': [
        'All devices',
        '4K Ultra HD + HDR',
        '4 screens',
        'Unlimited downloads',
        'Dolby Atmos',
        'Exclusive content',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    // Set default selected plan based on current plan
    _selectedPlan = _plans.indexWhere(
      (p) =>
          (p['name'] as String).toLowerCase() ==
          widget.currentPlan.toLowerCase(),
    );
    if (_selectedPlan < 0) _selectedPlan = 1;
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  String _getPrice(Map<String, dynamic> plan) {
    return _isAnnual
        ? '${plan['annualPrice']}/mo'
        : '${plan['monthlyPrice']}/mo';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: const Icon(Icons.arrow_back_ios_rounded,
                size: 16, color: Colors.white),
          ),
        ),
        title: const Text(
          'Choose Your Plan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildBillingToggle(),
            const SizedBox(height: 8),
            _buildSavingsBanner(),
            const SizedBox(height: 20),
            _buildPlanCards(),
            const SizedBox(height: 24),
            _buildFeatureComparisonTable(),
            const SizedBox(height: 24),
            _buildSubscribeButton(),
            const SizedBox(height: 12),
            _buildLegalText(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF13131F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            _ToggleOption(
              label: 'Monthly',
              isSelected: !_isAnnual,
              accentColor: widget.accentColor,
              onTap: () {
                setState(() => _isAnnual = false);
                HapticFeedback.selectionClick();
              },
            ),
            _ToggleOption(
              label: 'Annual',
              isSelected: _isAnnual,
              accentColor: widget.accentColor,
              onTap: () {
                setState(() => _isAnnual = true);
                HapticFeedback.selectionClick();
              },
              suffix: Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'SAVE 33%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsBanner() {
    if (!_isAnnual) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.savings_outlined,
                size: 16, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            const Text(
              'You\'re saving up to ₹3,000/year with Annual billing!',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCards() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _plans.length,
        itemBuilder: (context, index) {
          final plan = _plans[index];
          final isSelected = _selectedPlan == index;
          final planColor = plan['color'] as Color;
          final isPopular = plan['popular'] == true;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedPlan = index);
              HapticFeedback.selectionClick();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? planColor.withOpacity(0.15)
                    : const Color(0xFF13131F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? planColor : Colors.white12,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: planColor.withOpacity(0.2),
                          blurRadius: 16,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  if (isPopular)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: planColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'MOST POPULAR',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding:
                        EdgeInsets.fromLTRB(14, isPopular ? 30 : 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          plan['icon'] as IconData,
                          size: 28,
                          color: isSelected ? planColor : Colors.white38,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          plan['name'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          plan['resolution'] as String,
                          style: TextStyle(
                            color: isSelected ? planColor : Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _getPrice(plan),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white54,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          '${plan['screens']} screen · ${plan['downloads']} DL',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: isPopular ? 36 : 12,
                      right: 12,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: planColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureComparisonTable() {
    final selectedPlanFeatures =
        _plans[_selectedPlan]['features'] as List<String>;

    final allFeatures = [
      'Mobile viewing',
      'TV & Desktop',
      'SD quality',
      'HD quality',
      'Full HD (1080p)',
      '4K Ultra HD + HDR',
      'Dolby Atmos',
      'Offline downloads',
      'Simultaneous screens',
      'Exclusive originals',
    ];

    final planFeatureMap = {
      'Mobile viewing': [true, true, true, true],
      'TV & Desktop': [false, true, true, true],
      'SD quality': [true, false, false, false],
      'HD quality': [false, true, false, false],
      'Full HD (1080p)': [false, false, true, true],
      '4K Ultra HD + HDR': [false, false, false, true],
      'Dolby Atmos': [false, false, false, true],
      'Offline downloads': [true, true, true, true],
      'Simultaneous screens': ['1', '1', '2', '4'],
      'Exclusive originals': [true, true, true, true],
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s Included',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF13131F),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: allFeatures.asMap().entries.map((e) {
                final feature = e.value;
                final featureData = planFeatureMap[feature];
                final planValue = featureData?[_selectedPlan];
                final bool isAvailable =
                    planValue == true || (planValue is String);
                final String displayValue =
                    planValue is String ? planValue : (isAvailable ? '' : '');
                final isLast = e.key == allFeatures.length - 1;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            isAvailable
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            size: 18,
                            color: isAvailable
                                ? (_plans[_selectedPlan]['color'] as Color)
                                : Colors.white12,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                color: isAvailable
                                    ? Colors.white70
                                    : Colors.white24,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          if (displayValue.isNotEmpty)
                            Text(
                              displayValue,
                              style: TextStyle(
                                color: _plans[_selectedPlan]['color'] as Color,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                          height: 1, thickness: 0.5, color: Colors.white12),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton() {
    final plan = _plans[_selectedPlan];
    final planColor = plan['color'] as Color;
    final isCurrentPlan = (plan['name'] as String).toLowerCase() ==
        widget.currentPlan.toLowerCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isCurrentPlan
              ? null
              : () {
                  HapticFeedback.heavyImpact();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF13131F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: planColor.withOpacity(0.3)),
                      ),
                      title: Text(
                        '${plan['name']} Plan',
                        style: const TextStyle(color: Colors.white),
                      ),
                      content: Text(
                        'Upgrade to ${plan['name']} for ${_getPrice(plan)} billed ${_isAnnual ? 'annually' : 'monthly'}.',
                        style: const TextStyle(color: Colors.white60),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.white38)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: planColor),
                          child: const Text('Confirm',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: isCurrentPlan ? Colors.white12 : planColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.white12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            isCurrentPlan
                ? 'Current Plan'
                : 'Get ${plan['name']}  ·  ${_getPrice(plan)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegalText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        'Cancel anytime. No hidden charges. Prices include taxes.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white24,
          fontSize: 11,
          height: 1.5,
        ),
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;
  final Widget? suffix;

  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white38,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (suffix != null) suffix!,
            ],
          ),
        ),
      ),
    );
  }
}
