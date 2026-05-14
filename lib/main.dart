import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart';

import 'native_display_page.dart';
import 'custom_html_page.dart';
import 'PE/walletPage.dart';
import 'rich_push_page.dart';
import 'secondPage.dart';
import 'handleClick.dart';

class AppColors {
  AppColors._();

  // Background layers
  static const midnight = Color(0xFF080910);
  static const surface = Color(0xFF10111C);
  static const surfaceElevated = Color(0xFF181928);
  static const surfaceHighlight = Color(0xFF1F2035);

  // Borders
  static const borderSubtle = Color(0xFF22243A);
  static const borderDefault = Color(0xFF2E3050);
  static const borderFocus = Color(0xFF6C63FF);

  // Accent — electric indigo
  static const accent = Color(0xFF6C63FF);
  static const accentDim = Color(0x2A6C63FF);
  static const accentSoft = Color(0xFF8B84FF);

  // Semantic
  static const success = Color(0xFF10B981);
  static const successDim = Color(0x1F10B981);
  static const warning = Color(0xFFF59E0B);
  static const warningDim = Color(0x1FF59E0B);
  static const error = Color(0xFFEF4444);
  static const errorDim = Color(0x1FEF4444);
  static const info = Color(0xFF38BDF8);
  static const infoDim = Color(0x1F38BDF8);

  // Category palette
  static const violet = Color(0xFF8B5CF6);
  static const violetDim = Color(0x1F8B5CF6);
  static const teal = Color(0xFF14B8A6);
  static const tealDim = Color(0x1F14B8A6);
  static const rose = Color(0xFFF43F5E);
  static const roseDim = Color(0x1FF43F5E);
  static const amber = Color(0xFFF59E0B);
  static const amberDim = Color(0x1FF59E0B);
  static const sky = Color(0xFF0EA5E9);
  static const skyDim = Color(0x1F0EA5E9);
  static const emerald = Color(0xFF10B981);
  static const emeraldDim = Color(0x1F10B981);
  static const coral = Color(0xFFFF7A59);
  static const coralDim = Color(0x1FFF7A59);
  static const pink = Color(0xFFEC4899);
  static const pinkDim = Color(0x1FEC4899);
  static const lime = Color(0xFF84CC16);
  static const limeDim = Color(0x1F84CC16);

  // Text
  static const textPrimary = Color(0xFFF0EFFF);
  static const textSecondary = Color(0xFF9092AE);
  static const textTertiary = Color(0xFF4B4E6B);
  static const textOnAccent = Color(0xFFFFFFFF);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.midnight,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.teal,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        outline: AppColors.borderDefault,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceHighlight,
        contentTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderDefault),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.midnight,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await _requestPermissions();
  runApp(const MyApp());

  CleverTapPlugin.onKilledStateNotificationClicked(
      _onKilledStateNotificationClickedHandler);
  CleverTapPlugin.setDebugLevel(3);
  await Firebase.initializeApp();
}

void pushClickedPayloadReceived(Map<String, dynamic> notificationPayload) {
  debugPrint("pushClickedPayloadReceived: $notificationPayload");
}

@pragma('vm:entry-point')
void _onKilledStateNotificationClickedHandler(Map<String, dynamic> map) async {
  debugPrint("Notification Payload received: $map");
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
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

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _pulseController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeCleverTap();
    _listenToMethodChannelLinks();
    CleverTapPlugin.resumeInAppNotifications();

    // Trigger header animation on load
    _headerController.forward();

    Future.delayed(const Duration(seconds: 8), () {
      CleverTapPlugin.recordEvent("Page Viewed", {});
    });
  }

  void _setupAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _headerController.dispose();
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

  void _handleDeepLink(String deepLink, {bool isFromPush = false}) {
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

  void localAlertPushPrimer() {
    setState(() async {
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
    });
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
      builder: (ctx) => _PremiumDialog(
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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_hasDisplayUnits) ...[
                    const SizedBox(height: 8),
                    _DisplayUnitsBanner(count: _displayUnits.length),
                  ],
                  const SizedBox(height: 28),
                  _buildSection(
                    label: 'Authentication',
                    icon: Icons.shield_outlined,
                    iconColor: AppColors.accent,
                    tiles: [
                      _ActionTileData(
                        label: _isLoggedIn ? 'Re-login' : 'Login',
                        subtitle: _isLoggedIn
                            ? 'ID: ${_cleverTapId ?? '…'}'
                            : 'Set identity & profile',
                        icon: Icons.fingerprint_rounded,
                        color: AppColors.accent,
                        onTap: _login,
                      ),
                      _ActionTileData(
                        label: 'Push Primer',
                        subtitle: 'Request notification access',
                        icon: Icons.notifications_outlined,
                        color: AppColors.violet,
                        onTap: localAlertPushPrimer,
                      ),
                      _ActionTileData(
                        label: 'Get CT ID',
                        subtitle: 'Get CleverTap ID for this device',
                        icon: Icons.perm_identity_outlined,
                        color: AppColors.violet,
                        onTap: _getCTID,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    label: 'Events',
                    icon: Icons.bolt_outlined,
                    iconColor: AppColors.amber,
                    tiles: [
                      _ActionTileData(
                        label: 'Notification Event',
                        subtitle: 'Fire a notification trigger',
                        icon: Icons.notifications_active_outlined,
                        color: AppColors.amber,
                        onTap: _recordNotificationEvent,
                      ),
                      _ActionTileData(
                        label: 'Product Viewed',
                        subtitle: 'Premium Plan — PROD_123',
                        icon: Icons.storefront_outlined,
                        color: AppColors.emerald,
                        onTap: _recordPushEvent,
                      ),
                      _ActionTileData(
                        label: 'In-App Event',
                        subtitle: 'Trigger an in-app campaign',
                        icon: Icons.phone_iphone_rounded,
                        color: AppColors.violet,
                        onTap: _recordInAppEvent,
                      ),
                      _ActionTileData(
                        label: 'Charged Event',
                        subtitle: '₹498 — credit card, INR',
                        icon: Icons.receipt_long_outlined,
                        color: AppColors.teal,
                        onTap: _recordChargedEvent,
                      ),
                      _ActionTileData(
                          label: 'Deep Link',
                          subtitle: 'Open deep link page',
                          icon: Icons.link,
                          color: AppColors.pink,
                          onTap: _secondPage)
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    label: 'Campaigns',
                    icon: Icons.campaign_outlined,
                    iconColor: AppColors.sky,
                    tiles: [
                      _ActionTileData(
                        label: 'Email Campaign',
                        subtitle: 'Heart rate health event',
                        icon: Icons.mail_outline_rounded,
                        color: AppColors.sky,
                        onTap: _emailEvent,
                      ),
                      _ActionTileData(
                        label: 'Rich Push',
                        subtitle: 'Media-rich notification',
                        icon: Icons.circle_notifications_outlined,
                        color: AppColors.rose,
                        onTap: _richPushEvent,
                      ),
                      _ActionTileData(
                        label: 'Linked Content',
                        subtitle: 'Dynamic content fetch',
                        icon: Icons.link_rounded,
                        color: AppColors.lime,
                        onTap: _linkedContent,
                      ),
                      _ActionTileData(
                        label: 'Medical Condition',
                        subtitle: 'POP Remove Cart event',
                        icon: Icons.medical_services_outlined,
                        color: AppColors.coral,
                        onTap: _medicalCondition,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    label: 'Display & Inbox',
                    icon: Icons.dashboard_outlined,
                    iconColor: AppColors.pink,
                    tiles: [
                      _ActionTileData(
                        label: 'App Inbox',
                        subtitle: 'Open message center',
                        icon: Icons.inbox_outlined,
                        color: AppColors.teal,
                        onTap: _openInbox,
                      ),
                      _ActionTileData(
                        label: 'Native Display',
                        subtitle: 'Render display units natively',
                        icon: Icons.display_settings_outlined,
                        color: AppColors.violet,
                        onTap: _recordNativeDisplayEvent,
                      ),
                      _ActionTileData(
                        label: 'Get Display Units',
                        subtitle: 'Fetch & cache all units',
                        icon: Icons.view_list_outlined,
                        color: AppColors.pink,
                        onTap: _getAllDisplayUnits,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    label: 'Navigation',
                    icon: Icons.explore_outlined,
                    iconColor: AppColors.emerald,
                    tiles: [
                      _ActionTileData(
                        label: 'Native Display Page',
                        subtitle: 'Browse display unit gallery',
                        icon: Icons.open_in_new_rounded,
                        color: AppColors.coral,
                        onTap: _navigateToNativeDisplayPage,
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      _ActionTileData(
                        label: 'Custom HTML Page',
                        subtitle: 'WebView with custom markup',
                        icon: Icons.code_rounded,
                        color: AppColors.rose,
                        onTap: _navigateToCustomHTMLPage,
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      _ActionTileData(
                        label: 'Rich Push Templates',
                        subtitle: 'Push notifications with media',
                        icon: Icons.notifications_active_outlined,
                        color: AppColors.rose,
                        onTap: _navigateToRichPushPage,
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      _ActionTileData(
                        label: 'FinTech PE',
                        subtitle: 'TrueMoney wallet experience',
                        icon: Icons.account_balance_wallet_outlined,
                        color: AppColors.accent,
                        onTap: _navigateToTrueMoneyPage,
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      _ActionTileData(
                        label: 'Show Popup',
                        subtitle: 'Example dialog with actions',
                        icon: Icons.auto_awesome_outlined,
                        color: AppColors.amber,
                        onTap: _showExamplePopup,
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

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.midnight,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: FadeTransition(
          opacity: _headerFade,
          child: SlideTransition(
            position: _headerSlide,
            child: _HeaderHero(
              isLoggedIn: _isLoggedIn,
              cleverTapId: _cleverTapId,
              pulseAnim: _pulseAnim,
            ),
          ),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      ),
    );
  }

  Widget _buildSection({
    required String label,
    required IconData icon,
    required Color iconColor,
    required List<_ActionTileData> tiles,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(label: label, icon: icon, iconColor: iconColor),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int i = 0; i < tiles.length; i++) ...[
                _ActionListTile(data: tiles[i]),
                if (i < tiles.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: AppColors.borderSubtle,
                    indent: 56,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

enum SnackType {
  success(Icons.check_circle_outline_rounded, AppColors.success),
  error(Icons.error_outline_rounded, AppColors.error),
  info(Icons.info_outline_rounded, AppColors.info),
  warning(Icons.warning_amber_rounded, AppColors.warning);

  const SnackType(this.icon, this.color);
  final IconData icon;
  final Color color;
}

class _HeaderHero extends StatelessWidget {
  const _HeaderHero({
    required this.isLoggedIn,
    required this.cleverTapId,
    required this.pulseAnim,
  });

  final bool isLoggedIn;
  final String? cleverTapId;
  final Animation<double> pulseAnim;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.midnight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              // Logo - from assets
              Image.asset(
                'logo.png',
                width: 44,
                height: 44,
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
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const Text(
                      'Flutter Integration Demo',
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
            const SizedBox(height: 12),
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
                  const Icon(Icons.key_rounded,
                      size: 13, color: AppColors.accentSoft),
                  const SizedBox(width: 6),
                  Text(
                    'CT ID: $cleverTapId',
                    style: const TextStyle(
                      color: AppColors.accentSoft,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                      letterSpacing: 0.4,
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

// ── Section Header ───────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 7),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ── Action Tile Data ─────────────────────────

class _ActionTileData {
  const _ActionTileData({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;
}

class _ActionListTile extends StatefulWidget {
  const _ActionListTile({required this.data});
  final _ActionTileData data;

  @override
  State<_ActionListTile> createState() => _ActionListTileState();
}

class _ActionListTileState extends State<_ActionListTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        d.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _pressed ? AppColors.surfaceHighlight : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: d.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                d.icon,
                size: 18,
                color: d.color,
              ),
            ),
            const SizedBox(width: 14),
            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    d.subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (d.trailing != null) ...[
              const SizedBox(width: 8),
              d.trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

// ── Display Units Banner ─────────────────────

class _DisplayUnitsBanner extends StatelessWidget {
  const _DisplayUnitsBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.tealDim,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.teal.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign_rounded, size: 16, color: AppColors.teal),
          const SizedBox(width: 8),
          Text(
            '$count active display unit${count == 1 ? '' : 's'}',
            style: const TextStyle(
              color: AppColors.teal,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'LIVE',
              style: const TextStyle(
                color: AppColors.teal,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumDialog extends StatelessWidget {
  const _PremiumDialog({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    this.onAction,
    this.actionLabel = 'Confirm',
    this.onDismiss,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onAction;
  final String actionLabel;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.borderDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + close
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    onDismiss?.call();
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      onDismiss?.call();
                    },
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHighlight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: const Text(
                        'Dismiss',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                if (onAction != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        onAction?.call();
                      },
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF8B84FF),
                              Color(0xFF6C63FF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          actionLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
