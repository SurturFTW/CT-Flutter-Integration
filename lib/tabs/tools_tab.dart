import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_enums.dart';
import '../services/clevertap_service.dart';
import '../utils/ct_snack.dart';
import '../widgets/action_section.dart';
import '../widgets/ct_input_dialog.dart';
import '../widgets/premium_dialog.dart';

class ToolsTab extends StatefulWidget {
  const ToolsTab({
    super.key,
    required this.hasDisplayUnits,
    required this.displayUnitsCount,
    required this.onNavigateNativeDisplayPage,
    required this.onNavigateCustomHtmlPage,
    required this.onNavigateRichPushPage,
  });

  final bool hasDisplayUnits;
  final int displayUnitsCount;
  final VoidCallback onNavigateNativeDisplayPage;
  final VoidCallback onNavigateCustomHtmlPage;
  final VoidCallback onNavigateRichPushPage;

  @override
  State<ToolsTab> createState() => _ToolsTabState();
}

class _ToolsTabState extends State<ToolsTab> {
  late bool _isOffline;
  late bool _isOptedOut;
  late bool _networkInfoEnabled;
  bool _personalizationEnabled = true;

  @override
  void initState() {
    super.initState();
    _isOffline = CleverTapService().isOffline;
    _isOptedOut = CleverTapService().isOptedOut;
    _networkInfoEnabled = CleverTapService().isNetworkInfoEnabled;
  }

  Widget _statusDot(bool active) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.success : AppColors.textTertiary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActionSection(
            label: 'In-App Controls',
            icon: Icons.phone_iphone_rounded,
            iconColor: AppColors.violet,
            tiles: [
              ActionTileData(
                label: 'Suspend InApp',
                subtitle: 'Pause in-app notifications',
                icon: Icons.pause_circle_outline_rounded,
                color: AppColors.violet,
                onTap: () {
                  try {
                    CleverTapService().suspendInAppNotifications();
                    ctSnack(context, message: 'InApp notifications suspended', type: SnackType.info);
                  } catch (e) {
                    ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Discard InApp',
                subtitle: 'Discard queued in-app notifications',
                icon: Icons.cancel_outlined,
                color: AppColors.violet,
                onTap: () {
                  try {
                    CleverTapService().discardInAppNotifications();
                    ctSnack(context, message: 'InApp notifications discarded', type: SnackType.info);
                  } catch (e) {
                    ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Discard InApp + Dismiss',
                subtitle: 'Discard and dismiss visible in-app',
                icon: Icons.close_rounded,
                color: AppColors.violet,
                onTap: () {
                  try {
                    CleverTapService().discardInAppNotifications(dismissVisible: true);
                    ctSnack(context, message: 'InApp discarded and dismissed', type: SnackType.info);
                  } catch (e) {
                    ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Resume InApp',
                subtitle: 'Resume in-app notifications',
                icon: Icons.play_circle_outline_rounded,
                color: AppColors.violet,
                onTap: () {
                  try {
                    CleverTapService().resumeInAppNotifications();
                    ctSnack(context, message: 'InApp notifications resumed', type: SnackType.success);
                  } catch (e) {
                    ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Client-Side InApps',
            icon: Icons.download_outlined,
            iconColor: AppColors.sky,
            tiles: [
              ActionTileData(
                label: 'Fetch InApps',
                subtitle: 'Fetch in-app definitions from server',
                icon: Icons.cloud_download_outlined,
                color: AppColors.sky,
                onTap: () async {
                  try {
                    final result = await CleverTapService().fetchInApps();
                    if (mounted) ctSnack(context, message: result == true ? 'InApps fetched' : 'Fetch returned false', type: result == true ? SnackType.success : SnackType.warning);
                  } catch (e) {
                    if (mounted) ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Clear All InApp Resources',
                subtitle: 'Remove all cached in-app assets',
                icon: Icons.delete_sweep_outlined,
                color: AppColors.sky,
                onTap: () {
                  try {
                    CleverTapService().clearInAppResources();
                    ctSnack(context, message: 'All InApp resources cleared', type: SnackType.success);
                  } catch (e) {
                    ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Clear Expired InApp Resources',
                subtitle: 'Remove only expired cached assets',
                icon: Icons.auto_delete_outlined,
                color: AppColors.sky,
                onTap: () {
                  try {
                    CleverTapService().clearInAppResources(expiredOnly: true);
                    ctSnack(context, message: 'Expired InApp resources cleared', type: SnackType.success);
                  } catch (e) {
                    ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'GDPR',
            icon: Icons.privacy_tip_outlined,
            iconColor: AppColors.amber,
            tiles: [
              ActionTileData(
                label: 'Opt Out User',
                subtitle: _isOptedOut ? 'Status: opted out' : 'Status: opted in',
                icon: Icons.block_rounded,
                color: AppColors.amber,
                trailing: _statusDot(_isOptedOut),
                onTap: () {
                  try {
                    CleverTapService().setOptOut(true);
                    setState(() => _isOptedOut = true);
                    ctSnack(context, message: 'User opted out', type: SnackType.warning);
                  } catch (e) {
                    ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Opt In User',
                subtitle: _isOptedOut ? 'Restore data collection' : 'Already opted in',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.amber,
                trailing: _statusDot(!_isOptedOut),
                onTap: () {
                  try {
                    CleverTapService().setOptOut(false);
                    setState(() => _isOptedOut = false);
                    ctSnack(context, message: 'User opted in', type: SnackType.success);
                  } catch (e) {
                    ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Partial Opt Out',
                subtitle: 'Opt out but allow system events',
                icon: Icons.remove_circle_outline_rounded,
                color: AppColors.amber,
                onTap: () {
                  try {
                    CleverTapService().setOptOut(true, true);
                    setState(() => _isOptedOut = true);
                    ctSnack(context, message: 'Partial opt out applied', type: SnackType.warning);
                  } catch (e) {
                    ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Toggle Device Networking Info',
                subtitle: _networkInfoEnabled ? 'Network reporting: ON' : 'Network reporting: OFF',
                icon: Icons.network_check_rounded,
                color: AppColors.amber,
                trailing: _statusDot(_networkInfoEnabled),
                onTap: () {
                  try {
                    final newVal = !_networkInfoEnabled;
                    CleverTapService().enableDeviceNetworkInfoReporting(newVal);
                    setState(() => _networkInfoEnabled = newVal);
                    ctSnack(context, message: 'Network info reporting: ${newVal ? 'ON' : 'OFF'}', type: SnackType.info);
                  } catch (e) {
                    ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Offline Mode',
            icon: Icons.wifi_off_outlined,
            iconColor: AppColors.coral,
            tiles: [
              ActionTileData(
                label: 'Toggle Online/Offline',
                subtitle: _isOffline ? 'Currently: OFFLINE' : 'Currently: ONLINE',
                icon: _isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                color: AppColors.coral,
                trailing: _statusDot(_isOffline),
                onTap: () {
                  try {
                    final newVal = !_isOffline;
                    CleverTapService().setOffline(newVal);
                    setState(() => _isOffline = newVal);
                    ctSnack(context, message: newVal ? 'Offline mode enabled' : 'Online mode restored', type: SnackType.info);
                  } catch (e) {
                    ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Unmute',
                subtitle: 'Unmute CleverTap activity',
                icon: Icons.volume_up_outlined,
                color: AppColors.coral,
                onTap: () {
                  try {
                    CleverTapService().unmute();
                    ctSnack(context, message: 'CleverTap unmuted', type: SnackType.success);
                  } catch (e) {
                    ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Personalization',
            icon: Icons.tune_outlined,
            iconColor: AppColors.teal,
            tiles: [
              ActionTileData(
                label: 'Enable Personalization',
                subtitle: _personalizationEnabled ? 'Status: enabled' : 'Currently disabled',
                icon: Icons.person_pin_outlined,
                color: AppColors.teal,
                trailing: _statusDot(_personalizationEnabled),
                onTap: () {
                  try {
                    CleverTapService().enablePersonalization();
                    setState(() => _personalizationEnabled = true);
                    ctSnack(context, message: 'Personalization enabled', type: SnackType.success);
                  } catch (e) {
                    ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Disable Personalization',
                subtitle: !_personalizationEnabled ? 'Status: disabled' : 'Currently enabled',
                icon: Icons.person_off_outlined,
                color: AppColors.teal,
                trailing: _statusDot(!_personalizationEnabled),
                onTap: () {
                  try {
                    CleverTapService().disablePersonalization();
                    setState(() => _personalizationEnabled = false);
                    ctSnack(context, message: 'Personalization disabled', type: SnackType.warning);
                  } catch (e) {
                    ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Push Primer',
            icon: Icons.notifications_active_outlined,
            iconColor: AppColors.rose,
            tiles: [
              ActionTileData(
                label: 'Alert Push Primer',
                subtitle: 'Show alert-style push primer',
                icon: Icons.notifications_outlined,
                color: AppColors.rose,
                onTap: () async {
                  try {
                    final enabled = await CleverTapService().getPushPermissionStatus();
                    if (enabled == null) return;
                    if (!enabled) {
                      CleverTapService().promptPushPrimer({
                        'inAppType': 'alert',
                        'titleText': 'Get Notified',
                        'messageText': 'Enable Notification permission',
                        'followDeviceOrientation': true,
                        'positiveBtnText': 'Allow',
                        'negativeBtnText': 'Cancel',
                        'fallbackToSettings': true,
                      });
                      if (mounted) ctSnack(context, message: 'Push primer shown', type: SnackType.info);
                    } else {
                      if (mounted) ctSnack(context, message: 'Push already enabled', type: SnackType.success);
                    }
                  } catch (e) {
                    if (mounted) ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Half-Interstitial Primer',
                subtitle: 'Show half-interstitial push primer',
                icon: Icons.open_in_browser_rounded,
                color: AppColors.rose,
                onTap: () {
                  try {
                    CleverTapService().promptPushPrimer({
                      'inAppType': 'half-interstitial',
                      'titleText': 'Stay Updated',
                      'messageText': 'Allow notifications to get real-time updates',
                      'followDeviceOrientation': true,
                      'positiveBtnText': 'Allow',
                      'negativeBtnText': 'Skip',
                      'fallbackToSettings': true,
                    });
                    ctSnack(context, message: 'Half-interstitial primer shown', type: SnackType.info);
                  } catch (e) {
                    ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Prompt for Push',
                subtitle: 'Directly prompt push permission',
                icon: Icons.add_alert_outlined,
                color: AppColors.rose,
                onTap: () {
                  try {
                    CleverTapPlugin.promptForPushNotification(true);
                    ctSnack(context, message: 'Push prompt triggered', type: SnackType.info);
                  } catch (e) {
                    ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Push Tokens',
            icon: Icons.vpn_key_outlined,
            iconColor: AppColors.lime,
            tiles: [
              ActionTileData(
                label: 'Set FCM Token',
                subtitle: 'Register an FCM push token',
                icon: Icons.key_rounded,
                color: AppColors.lime,
                onTap: () async {
                  final result = await CtInputDialog.show(
                    context,
                    title: 'Set FCM Token',
                    subtitle: 'Register a Firebase Cloud Messaging token',
                    submitLabel: 'Set',
                    fields: const [
                      CtInputField(key: 'token', label: 'FCM Token', hint: 'Paste FCM token here'),
                    ],
                  );
                  if (result == null) return;
                  try {
                    CleverTapService().setPushToken(result['token']!);
                    if (mounted) ctSnack(context, message: 'FCM token set', type: SnackType.success);
                  } catch (e) {
                    if (mounted) ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
              ActionTileData(
                label: 'Set HMS Token',
                subtitle: 'Register a Huawei Mobile Services token',
                icon: Icons.vpn_key_outlined,
                color: AppColors.lime,
                onTap: () async {
                  final result = await CtInputDialog.show(
                    context,
                    title: 'Set HMS Token',
                    subtitle: 'Register a Huawei push token',
                    submitLabel: 'Set',
                    fields: const [
                      CtInputField(key: 'token', label: 'HMS Token', hint: 'Paste HMS token here'),
                    ],
                  );
                  if (result == null) return;
                  try {
                    await CleverTapService().pushRegistrationToken(result['token']!, {'type': 'HMS'}).catchError((e) {
                      if (mounted) ctSnack(context, message: 'HMS error: $e', type: SnackType.error);
                    });
                    if (mounted) ctSnack(context, message: 'HMS token set', type: SnackType.success);
                  } catch (e) {
                    if (mounted) ctSnack(context, message: 'Error: $e', type: SnackType.error);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ActionSection(
            label: 'Navigation',
            icon: Icons.explore_outlined,
            iconColor: AppColors.emerald,
            tiles: [
              ActionTileData(
                label: 'Native Display Page',
                subtitle: widget.hasDisplayUnits
                    ? '${widget.displayUnitsCount} unit(s) available'
                    : 'Browse display unit gallery',
                icon: Icons.open_in_new_rounded,
                color: AppColors.coral,
                onTap: widget.onNavigateNativeDisplayPage,
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textTertiary),
              ),
              ActionTileData(
                label: 'Custom HTML Page',
                subtitle: 'WebView with custom markup',
                icon: Icons.code_rounded,
                color: AppColors.rose,
                onTap: widget.onNavigateCustomHtmlPage,
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textTertiary),
              ),
              ActionTileData(
                label: 'Rich Push Templates',
                subtitle: 'Push notifications with media',
                icon: Icons.notifications_active_outlined,
                color: AppColors.rose,
                onTap: widget.onNavigateRichPushPage,
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textTertiary),
              ),
              ActionTileData(
                label: 'Show Popup',
                subtitle: 'Example dialog with actions',
                icon: Icons.auto_awesome_outlined,
                color: AppColors.amber,
                onTap: () {
                  CleverTapService().suspendInAppNotifications();
                  showDialog(
                    context: context,
                    barrierColor: Colors.black.withValues(alpha: 0.7),
                    builder: (ctx) => PremiumDialog(
                      title: 'Sample Popup',
                      message: 'This is how a production-grade popup looks in your CleverTap demo app.',
                      icon: Icons.auto_awesome_rounded,
                      iconColor: AppColors.accent,
                      onAction: () {
                        ctSnack(context, message: 'Action triggered!', type: SnackType.success);
                        CleverTapService().resumeInAppNotifications();
                      },
                      actionLabel: 'Got it',
                      onDismiss: () => CleverTapService().resumeInAppNotifications(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
