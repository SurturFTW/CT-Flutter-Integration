import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/services.dart';

import '../../config/app_colors.dart';

class OnsurityWellnessPage extends StatefulWidget {
  final Color primaryColor;
  final Color accentColor;
  final String wellnessScore;
  final String gymPartners;
  final String teleConsultCount;

  const OnsurityWellnessPage({
    Key? key,
    required this.primaryColor,
    required this.accentColor,
    required this.wellnessScore,
    required this.gymPartners,
    required this.teleConsultCount,
  }) : super(key: key);

  @override
  State<OnsurityWellnessPage> createState() => _OnsurityWellnessPageState();
}

class _OnsurityWellnessPageState extends State<OnsurityWellnessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Tele-consultation',
      'icon': Icons.video_call_outlined,
      'sub': 'Consult doctors online',
      'tag': 'FREE',
    },
    {
      'title': 'Mental Wellness',
      'icon': Icons.psychology_outlined,
      'sub': 'Therapy & counselling',
      'tag': 'NEW',
    },
    {
      'title': 'Gym & Fitness',
      'icon': Icons.fitness_center_outlined,
      'sub': '2,500+ partner gyms',
      'tag': '',
    },
    {
      'title': 'Health Checkup',
      'icon': Icons.biotech_outlined,
      'sub': 'Annual full-body checkup',
      'tag': 'ANNUAL',
    },
    {
      'title': 'Dental Care',
      'icon': Icons.medical_services_outlined,
      'sub': 'Cleaning, X-rays & more',
      'tag': '',
    },
    {
      'title': 'Vision Care',
      'icon': Icons.remove_red_eye_outlined,
      'sub': 'Eye check & glasses',
      'tag': '',
    },
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  double get _scoreValue => (double.tryParse(widget.wellnessScore) ?? 72) / 100;

  String get _scoreLabel {
    final score = double.tryParse(widget.wellnessScore) ?? 72;
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs Attention';
  }

  Color get _scoreColor {
    final score = double.tryParse(widget.wellnessScore) ?? 72;
    if (score >= 80) return AppColors.success;
    if (score >= 60) return widget.accentColor;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        title: Text('Wellness Hub',
            style: TextStyle(
                color: widget.accentColor,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildScoreCard(),
            const SizedBox(height: 20),
            _buildConsultBanner(),
            const SizedBox(height: 20),
            _buildCategoryGrid(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.accentColor.withOpacity(0.2),
              widget.primaryColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.accentColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            // Circular score indicator
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (_, __) => CircularProgressIndicator(
                      value: _scoreValue * _progressController.value,
                      strokeWidth: 8,
                      backgroundColor: AppColors.borderDefault,
                      valueColor: AlwaysStoppedAnimation<Color>(_scoreColor),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      widget.wellnessScore,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text('/100',
                        style: TextStyle(
                            color: AppColors.textTertiary, fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_scoreLabel,
                      style: TextStyle(
                          color: _scoreColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  const Text(
                    'Your team\'s health is on track. Keep encouraging wellness activities.',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.gymPartners} gym partners',
                      style: TextStyle(
                          color: widget.accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
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

  Widget _buildConsultBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Connecting to a doctor...'),
                behavior: SnackBarBehavior.floating),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.primaryColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.4),
                blurRadius: 12,
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.video_call_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Free Tele-consultation',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800)),
                    Text(
                      '${widget.teleConsultCount} consults remaining this month',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Book Now',
                    style: TextStyle(
                        color: widget.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Wellness Benefits',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final cat = _categories[i];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${cat['title']} selected'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(cat['icon'] as IconData,
                              color: widget.accentColor, size: 22),
                          const Spacer(),
                          if ((cat['tag'] as String).isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.accentColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(cat['tag'] as String,
                                  style: TextStyle(
                                      color: widget.accentColor,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3)),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(cat['title'] as String,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      Text(cat['sub'] as String,
                          style: const TextStyle(
                              color: AppColors.textTertiary, fontSize: 10)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
