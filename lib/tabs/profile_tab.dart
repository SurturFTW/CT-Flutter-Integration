import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../widgets/action_section.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.isLoggedIn,
    required this.cleverTapId,
    required this.pulseAnim,
    required this.onLogin,
    required this.onPushPrimer,
    required this.onGetCtId,
  });

  final bool isLoggedIn;
  final String? cleverTapId;
  final Animation<double> pulseAnim;
  final VoidCallback onLogin;
  final VoidCallback onPushPrimer;
  final VoidCallback onGetCtId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIdentityCard(),
          const SizedBox(height: 28),
          ActionSection(
            label: 'Authentication',
            icon: Icons.shield_outlined,
            iconColor: AppColors.accent,
            tiles: [
              ActionTileData(
                label: isLoggedIn ? 'Re-login' : 'Login',
                subtitle: isLoggedIn
                    ? 'ID: ${cleverTapId ?? '…'}'
                    : 'Set identity & profile',
                icon: Icons.fingerprint_rounded,
                color: AppColors.accent,
                onTap: onLogin,
              ),
              ActionTileData(
                label: 'Push Primer',
                subtitle: 'Request notification access',
                icon: Icons.notifications_outlined,
                color: AppColors.violet,
                onTap: onPushPrimer,
              ),
              ActionTileData(
                label: 'Get CT ID',
                subtitle: 'Get CleverTap ID for this device',
                icon: Icons.perm_identity_outlined,
                color: AppColors.violet,
                onTap: onGetCtId,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Logo - from assets
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.borderSubtle,
                    width: 0.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'logo.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CleverTap SDK',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const Text(
                      'Demo Application',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isLoggedIn
                      ? AppColors.successDim
                      : AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isLoggedIn
                        ? AppColors.success.withOpacity(0.4)
                        : AppColors.borderDefault,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: pulseAnim,
                      builder: (_, __) => Opacity(
                        opacity: isLoggedIn ? pulseAnim.value : 0.5,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isLoggedIn
                                ? AppColors.success
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isLoggedIn ? 'Active' : 'Guest',
                      style: TextStyle(
                        color: isLoggedIn
                            ? AppColors.success
                            : AppColors.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isLoggedIn && cleverTapId != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentDim,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accent.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.key_rounded,
                    size: 13,
                    color: AppColors.accentSoft,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'CT ID: $cleverTapId',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.accentSoft,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
