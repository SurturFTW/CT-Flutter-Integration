import 'dart:io';

import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'config/app_colors.dart';
import 'config/app_theme.dart';
import 'config/app_enums.dart';

import 'native_display_page.dart';
import 'custom_html_page.dart';
import 'rich_push_page.dart';
import 'handleClick.dart';
import 'secondPage.dart';

import 'PE/Fintech/walletPage.dart';
import 'PE/OTT/OTTPage.dart';
import 'PE/Health/onsurity_page.dart';

import 'widgets/premium_dialog.dart';
import 'tabs/profile_tab.dart';
import 'tabs/events_tab.dart';
import 'tabs/tools_tab.dart';
import 'tabs/product_experiences_tab.dart';

// ENTRY POINT
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.midnight,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  CleverTapPlugin.setDebugLevel(3);
  CleverTapPlugin.onKilledStateNotificationClicked(
      _onKilledStateNotificationClickedHandler);

  if (Platform.isAndroid) {
    await Firebase.initializeApp();
  }

  await _requestPermissions();

  runApp(const MyApp());
}

void pushClickedPayloadReceived(Map<String, dynamic> notificationPayload) {
  debugPrint("pushClickedPayloadReceived: $notificationPayload");
  handleNotificationClick(notificationPayload);
}

@pragma('vm:entry-point')
void _onKilledStateNotificationClickedHandler(Map<String, dynamic> map) async {
  debugPrint("Notification Payload received: $map");
  handleNotificationClick(map);
}

Future<void> _requestPermissions() async {
  try {
    var notifStatus = await Permission.notification.status;
    if (!notifStatus.isGranted) await Permission.notification.request();

    var locStatus = await Permission.location.status;
    if (!locStatus.isGranted) await Permission.location.request();
    if (locStatus.isGranted) await _sendLocationToCleverTap();
  } catch (e) {
    debugPrint("Error requesting permissions: $e");
  }
}

Future<void> _sendLocationToCleverTap() async {
  try {
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    CleverTapPlugin.setLocation(position.latitude, position.longitude);
  } catch (e) {
    debugPrint("Error sending location: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CT Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MyHomePage(title: 'CT Flutter Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin {
  static const platform = MethodChannel('myChannel');

  // Profile data
  final Map<String, dynamic> profile = {
    'Identity': '787',
    'Phone': '+91123456789',
  };

  // State
  bool _isLoggedIn = false;
  String? _cleverTapId;
  List<Map<String, dynamic>> _displayUnits = [];
  bool _hasDisplayUnits = false;

  // Top tab navigation: Profile / Events / Tools / Product Experiences
  late TabController _tabController;

  // Pulsing status dot shown on the Profile tab's identity card
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _setupAnimations();
    _initializeCleverTap();
    _listenToMethodChannelLinks();
    CleverTapPlugin.resumeInAppNotifications();

    Future.delayed(const Duration(seconds: 8), () {
      CleverTapPlugin.recordEvent("Page Viewed", {});
    });
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _listenToMethodChannelLinks() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "handleDeepLink") {
        final deepLink = call.arguments as String?;
        if (deepLink != null) _handleDeepLink(deepLink);
      }
    });
  }

  void _handleDeepLink(String deepLink) {
    debugPrint("Deep link received: $deepLink");
    if (mounted) {
      _showAppSnackBar(
        message: "Deep link: $deepLink",
        type: SnackType.info,
      );
    }
  }

  void _initializeCleverTap() {
    CleverTapPlugin clevertapPlugin = CleverTapPlugin();

    CleverTapPlugin.createNotificationChannel(
        "test", "Test Channel", "Channel for push notifications", 3, true);
    CleverTapPlugin.setDebugLevel(3);

    if (!kIsWeb) CleverTapPlugin.registerForPush();

    clevertapPlugin.setCleverTapPushClickedPayloadReceivedHandler(
        pushClickedPayloadReceived);
    clevertapPlugin.setCleverTapInboxDidInitializeHandler(_inboxDidInitialize);
    clevertapPlugin.setCleverTapInAppNotificationButtonClickedHandler((map) {
      debugPrint("inAppNotificationButtonClicked: ${map.toString()}");
    });
    clevertapPlugin.setCleverTapDisplayUnitsLoadedHandler(onDisplayUnitsLoaded);
  }

  List<Map<String, dynamic>> _convertToMapList(List<dynamic>? data) {
    if (data == null) return [];
    return data.map((item) {
      if (item is Map<String, dynamic>) return item;
      if (item is Map) return Map<String, dynamic>.from(item);
      return <String, dynamic>{};
    }).toList();
  }

  void _login() async {
    try {
      CleverTapPlugin.onUserLogin(profile);
      final ctId = await CleverTapPlugin.getCleverTapID();
      setState(() {
        _isLoggedIn = true;
        _cleverTapId = ctId;
      });
      _showAppSnackBar(
        message: "Logged in — CT ID: ${ctId ?? 'N/A'}",
        type: SnackType.success,
      );
    } catch (e) {
      _showAppSnackBar(message: "Login failed: $e", type: SnackType.error);
    }
  }

  void localAlertPushPrimer() async {
    try {
      bool? enabled =
          await CleverTapPlugin.getPushNotificationPermissionStatus();
      if (enabled == null) return;
      if (!enabled) {
        CleverTapPlugin.promptPushPrimer({
          'inAppType': 'alert',
          'titleText': 'Get Notified',
          'messageText': 'Enable Notification permission',
          'followDeviceOrientation': true,
          'positiveBtnText': 'Allow',
          'negativeBtnText': 'Cancel',
          'fallbackToSettings': true,
        });
        _showAppSnackBar(message: "Push primer shown", type: SnackType.info);
      } else {
        _showAppSnackBar(
            message: "Push already enabled", type: SnackType.success);
      }
    } catch (e) {
      _showAppSnackBar(message: "Error: $e", type: SnackType.error);
    }
  }

  void _getCTID() async {
    final ctId = await CleverTapPlugin.getCleverTapID();
    _showAppSnackBar(
      message: "CleverTap ID: ${ctId ?? 'N/A'}",
      type: SnackType.info,
    );
    debugPrint("CleverTap ID: $ctId");
  }

  void _recordNotificationEvent() {
    try {
      CleverTapPlugin.recordEvent("Notification Event", {});
      _showAppSnackBar(
          message: "Notification event fired", type: SnackType.success);
    } catch (e) {
      _showAppSnackBar(message: "Error: $e", type: SnackType.error);
    }
  }

  void _recordPushEvent() {
    try {
      CleverTapPlugin.recordEvent("Product Viewed", {
        'product_id': 'PROD_123',
        'product_name': 'Premium Plan',
        'category': 'subscription',
      });
      _showAppSnackBar(
          message: "Product Viewed event fired", type: SnackType.success);
    } catch (e) {
      _showAppSnackBar(message: "Error: $e", type: SnackType.error);
    }
  }

  void _recordInAppEvent() {
    try {
      CleverTapPlugin.recordEvent("In-App Event", {});
      _showAppSnackBar(message: "In-App event fired", type: SnackType.success);
    } catch (e) {
      _showAppSnackBar(message: "Error: $e", type: SnackType.error);
    }
  }

  void _recordChargedEvent() {
    try {
      var item1 = {
        'name': 'Premium Subscription',
        'amount': '299',
        'category': 'digital'
      };
      var item2 = {
        'name': 'Extra Features',
        'amount': '199',
        'category': 'addon'
      };
      CleverTapPlugin.recordChargedEvent({
        'total': '498',
        'payment': 'credit_card',
        'currency': 'INR',
        'transaction_id': 'TXN_${DateTime.now().millisecondsSinceEpoch}',
      }, [
        item1,
        item2
      ]);
      _showAppSnackBar(
          message: "Charged ₹498 — event fired", type: SnackType.success);
    } catch (e) {
      _showAppSnackBar(message: "Error: $e", type: SnackType.error);
    }
  }

  void _secondPage() {
    Navigator.of(context).push(_premiumRoute(const DeepLinkPage(
      type: '',
      title: '',
      message: '',
    )));
  }

  void _emailEvent() {
    final hr = 50 + Random().nextInt(51);
    CleverTapPlugin.recordEvent("Health", {"Heart Rate": hr});
    _showAppSnackBar(
        message: "Health event — HR: $hr bpm", type: SnackType.success);
  }

  void _linkedContent() {
    CleverTapPlugin.recordEvent("android Purchase", {});
    _showAppSnackBar(
        message: "Linked content event fired", type: SnackType.success);
  }

  void _richPushEvent() {
    CleverTapPlugin.recordEvent("Rich Push", {});
    _showAppSnackBar(message: "Rich Push event fired", type: SnackType.success);
  }

  void _medicalCondition() {
    CleverTapPlugin.recordEvent("POP Remove Cart", {});
    _showAppSnackBar(message: "POP Remove Cart fired", type: SnackType.success);
  }

  // ── Display ─────────────────────────────────

  void _recordNativeDisplayEvent() {
    try {
      CleverTapPlugin.recordEvent("Native Event", {});
      _showAppSnackBar(
          message: "Native Display event fired", type: SnackType.success);
      _renderNativeDisplay();
    } catch (e) {
      _showAppSnackBar(message: "Error: $e", type: SnackType.error);
    }
  }

  Future<void> _renderNativeDisplay() async {
    try {
      await platform.invokeMethod('renderNativeDisplayUnits');
      _showAppSnackBar(
          message: "Native display rendered", type: SnackType.success);
    } catch (e) {
      _showAppSnackBar(
          message: "Native display error: $e", type: SnackType.error);
    }
  }

  Future<void> _getAllDisplayUnits() async {
    try {
      final units = await CleverTapPlugin.getAllDisplayUnits();
      if (units != null && units.isNotEmpty) {
        setState(() {
          _displayUnits = _convertToMapList(units);
          _hasDisplayUnits = true;
        });
        _showAppSnackBar(
            message: "${units.length} display unit(s) loaded",
            type: SnackType.success);
      } else {
        setState(() {
          _displayUnits = [];
          _hasDisplayUnits = false;
        });
        _showAppSnackBar(
            message: "No display units found", type: SnackType.info);
      }
    } catch (e) {
      _showAppSnackBar(message: "Error: $e", type: SnackType.error);
    }
  }

  void onDisplayUnitsLoaded(List<dynamic>? displayUnits) {
    if (displayUnits != null && displayUnits.isNotEmpty) {
      setState(() {
        _displayUnits.addAll(_convertToMapList(displayUnits));
        _hasDisplayUnits = true;
      });
    }
  }

  void _openInbox() {
    try {
      CleverTapPlugin.showInbox({
        'noMessageTextColor': '#9092AE',
        'noMessageText': 'No messages yet.',
        'navBarTitle': 'Inbox',
        'navBarTitleColor': '#F0EFFF',
        'navBarColor': '#10111C',
        'inboxBackgroundColor': '#080910',
      });
      _showAppSnackBar(message: "Opening inbox…", type: SnackType.info);
    } catch (e) {
      _showAppSnackBar(message: "Error: $e", type: SnackType.error);
    }
  }

  void _inboxDidInitialize() {
    debugPrint("Inbox initialized");
  }

  void _navigateToCustomHTMLPage() {
    Navigator.of(context).push(_premiumRoute(const CustomHtmlPage()));
  }

  void _navigateToRichPushPage() {
    Navigator.of(context).push(_premiumRoute(const RichPushPage()));
  }

  void _navigateToNativeDisplayPage() {
    Navigator.of(context).push(_premiumRoute(NativeDisplayPage(
      displayUnits: _displayUnits,
      onContentClick: _onContentItemClicked,
      onUnitViewed: _markDisplayUnitAsViewed,
    )));
  }

  void _navigateToTrueMoneyPage() {
    Navigator.of(context).push(_premiumRoute(const TrueMoneyPage()));
  }

  void _navigateToOTTPage() {
    Navigator.of(context).push(_premiumRoute(const OTTPage()));
  }

  void _navigateToHealthPage() {
    Navigator.of(context).push(_premiumRoute(const OnsurityPage()));
  }

  void _markDisplayUnitAsViewed(String unitId) {
    CleverTapPlugin.pushDisplayUnitViewedEvent(unitId);
    _showAppSnackBar(message: "Unit viewed: $unitId", type: SnackType.info);
  }

  void _onContentItemClicked(Map<String, dynamic> item, String unitId) {
    CleverTapPlugin.pushDisplayUnitClickedEvent(unitId);
    _showAppSnackBar(message: "Content clicked!", type: SnackType.success);
  }

  PageRoute _premiumRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, __) => page,
      transitionDuration: const Duration(milliseconds: 380),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
    );
  }

  void _showExamplePopup() {
    CleverTapPlugin.suspendInAppNotifications();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) => PremiumDialog(
        title: 'Sample Popup',
        message:
            'This is how a production-grade popup looks in your CleverTap demo app.',
        icon: Icons.auto_awesome_rounded,
        iconColor: AppColors.accent,
        onAction: () {
          _showAppSnackBar(
              message: 'Action triggered!', type: SnackType.success);
          CleverTapPlugin.resumeInAppNotifications();
        },
        actionLabel: 'Got it',
        onDismiss: () => CleverTapPlugin.resumeInAppNotifications(),
      ),
    );
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
                style: TextStyle(
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
        backgroundColor: AppColors.midnight,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'CleverTap SDK Demo',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          indicatorWeight: 3,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textTertiary,
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(
              icon: Icon(Icons.person_outline_rounded, size: 20),
              text: 'Profile',
            ),
            Tab(
              icon: Icon(Icons.bolt_outlined, size: 20),
              text: 'Events',
            ),
            Tab(
              icon: Icon(Icons.build_outlined, size: 20),
              text: 'Tools',
            ),
            Tab(
              icon: Icon(Icons.star_outline_rounded, size: 20),
              text: 'Product',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ProfileTab(
            isLoggedIn: _isLoggedIn,
            cleverTapId: _cleverTapId,
            pulseAnim: _pulseAnim,
            onLogin: _login,
            onPushPrimer: localAlertPushPrimer,
            onGetCtId: _getCTID,
          ),
          EventsTab(
            onNotificationEvent: _recordNotificationEvent,
            onProductViewed: _recordPushEvent,
            onInAppEvent: _recordInAppEvent,
            onChargedEvent: _recordChargedEvent,
            onDeepLink: _secondPage,
          ),
          ToolsTab(
            hasDisplayUnits: _hasDisplayUnits,
            displayUnitsCount: _displayUnits.length,
            onEmailCampaign: _emailEvent,
            onRichPush: _richPushEvent,
            onLinkedContent: _linkedContent,
            onMedicalCondition: _medicalCondition,
            onOpenInbox: _openInbox,
            onNativeDisplayEvent: _recordNativeDisplayEvent,
            onGetDisplayUnits: _getAllDisplayUnits,
            onNavigateNativeDisplayPage: _navigateToNativeDisplayPage,
            onNavigateCustomHtmlPage: _navigateToCustomHTMLPage,
            onNavigateRichPushPage: _navigateToRichPushPage,
            onShowPopup: _showExamplePopup,
          ),
          ProductExperiencesTab(
            onFintech: _navigateToTrueMoneyPage,
            onOtt: _navigateToOTTPage,
            onHealth: _navigateToHealthPage,
            onMore: () {
              _showAppSnackBar(
                message: "More product experience demos coming soon!",
                type: SnackType.info,
              );
            },
          ),
        ],
      ),
    );
  }
}