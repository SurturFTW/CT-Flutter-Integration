import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/services.dart';

class RewardsPage extends StatefulWidget {
  final Color buttonColor;
  final Color textColor;
  final String rewardPoints;

  const RewardsPage({
    Key? key,
    required this.buttonColor,
    required this.textColor,
    required this.rewardPoints,
  }) : super(key: key);

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  int _currentPoints = 0;
  final int _nextTierPoints = 20000;

  final List<Map<String, dynamic>> _tiers = [
    {'name': 'Bronze', 'points': 5000, 'color': Colors.brown},
    {'name': 'Silver', 'points': 10000, 'color': Colors.grey},
    {'name': 'Gold', 'points': 20000, 'color': Colors.amber},
    {'name': 'Platinum', 'points': 50000, 'color': Colors.blueGrey},
  ];

  @override
  void initState() {
    super.initState();
    _currentPoints = int.parse(widget.rewardPoints.replaceAll(',', ''));
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
        backgroundColor: widget.buttonColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPointsCard(),
            const SizedBox(height: 24),
            _buildProgressSection(),
            const SizedBox(height: 24),
            _buildTiersList(),
            const SizedBox(height: 24),
            _buildRedeemOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.buttonColor, widget.buttonColor.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.buttonColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.stars, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Your Reward Points',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            widget.rewardPoints,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final progress = _currentPoints / _nextTierPoints;
    final pointsNeeded = _nextTierPoints - _currentPoints;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress to Gold Tier',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.textColor,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.buttonColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress * _progressController.value,
                  minHeight: 20,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(widget.buttonColor),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            '$pointsNeeded points to reach Gold tier',
            style: TextStyle(
              fontSize: 14,
              color: widget.textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTiersList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Membership Tiers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.textColor,
            ),
          ),
          const SizedBox(height: 12),
          ..._tiers.map((tier) {
            final isUnlocked = _currentPoints >= tier['points'];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? (tier['color'] as Color).withOpacity(0.1)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isUnlocked ? (tier['color'] as Color) : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isUnlocked ? Icons.check_circle : Icons.lock,
                    color: isUnlocked
                        ? (tier['color'] as Color)
                        : Colors.grey[600],
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tier['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.textColor,
                          ),
                        ),
                        Text(
                          '${tier['points']} points',
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.textColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUnlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: tier['color'] as Color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'UNLOCKED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRedeemOptions() {
    final options = [
      {'title': 'Cashback', 'points': 1000, 'icon': Icons.payments},
      {'title': 'Gift Voucher', 'points': 2000, 'icon': Icons.card_giftcard},
      {'title': 'Flight Upgrade', 'points': 5000, 'icon': Icons.flight},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Redeem Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.textColor,
            ),
          ),
          const SizedBox(height: 12),
          ...options.map((option) {
            final canRedeem = _currentPoints >= (option['points'] as int);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  option['icon'] as IconData,
                  color: widget.buttonColor,
                  size: 32,
                ),
                title: Text(option['title'] as String),
                subtitle: Text('${option['points']} points'),
                trailing: ElevatedButton(
                  onPressed: canRedeem
                      ? () {
                          HapticFeedback.heavyImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${option['title']} redeemed!'),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.buttonColor,
                  ),
                  child: const Text('Redeem'),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
