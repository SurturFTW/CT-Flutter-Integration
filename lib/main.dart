import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:math';

// Import your new files
import 'native_display_page.dart';
import 'custom_html_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermissions();

  CleverTapPlugin.onKilledStateNotificationClicked(
      _onKilledStateNotificationClickedHandler);

  runApp(const MyApp());
  await Firebase.initializeApp();
}

void pushClickedPayloadReceived(Map<String, dynamic> notificationPayload) {
  debugPrint(
      "pushClickedPayloadReceived called with notification payload: $notificationPayload");
}

@pragma('vm:entry-point')
void _onKilledStateNotificationClickedHandler(Map<String, dynamic> map) async {
  debugPrint("Notification Payload received: $map");
}

Future<void> _requestPermissions() async {
  try {
    var notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      await Permission.notification.request();
    }

    var locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      await Permission.location.request();
    }
    if (locationStatus.isGranted) {
      await _sendLocationToCleverTap();
    }
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
    debugPrint(
        "Location sent to CleverTap: ${position.latitude}, ${position.longitude}");
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CT Flutter Integration'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Profile data
  final Map<String, dynamic> profile = {
    'Name': 'BatMan',
    // 'First Name': 'Pushkar',
    // 'Last Name': 'Sane',
    'Identity': '200',
    'Email': 'Bat@man.com',
    'Phone': '+91123456789',
  };

  // State variables
  bool _isLoggedIn = false;
  String? _cleverTapId;
  List<Map<String, dynamic>> _displayUnits = [];
  bool _hasDisplayUnits = false;

  @override
  void initState() {
    debugPrint("CleverTapPlugin initState");
    super.initState();
    _initializeCleverTap();
  }

  void _initializeCleverTap() {
    CleverTapPlugin clevertapPlugin = CleverTapPlugin();

    CleverTapPlugin.init("TEST-865-ZRW-7K7Z");
    CleverTapPlugin.setDebugLevel(3);

    if (!kIsWeb) {
      CleverTapPlugin.registerForPush();
    }

    clevertapPlugin.setCleverTapPushClickedPayloadReceivedHandler(
        pushClickedPayloadReceived);
    clevertapPlugin.setCleverTapInboxDidInitializeHandler(_inboxDidInitialize);

    debugPrint("CleverTap basic initialization complete");
  }

  // Helper methods
  List<Map<String, dynamic>> _convertToMapList(List<dynamic>? data) {
    if (data == null) return [];

    return data.map((item) {
      if (item is Map<String, dynamic>) {
        return item;
      } else if (item is Map) {
        return Map<String, dynamic>.from(item);
      } else {
        return <String, dynamic>{};
      }
    }).toList();
  }

  // Login functionality
  void _login() async {
    try {
      CleverTapPlugin.onUserLogin(profile);
      String? ctId = await CleverTapPlugin.getCleverTapID();
      setState(() {
        _isLoggedIn = true;
        _cleverTapId = ctId;
      });
      debugPrint("CT ID is $ctId");
      _showSuccessSnackBar("Login successful! CT ID: ${ctId ?? 'N/A'}");
    } catch (e) {
      _showErrorSnackBar("Login failed: $e");
    }
  }

  // Navigate to Custom HTML Page
  void _navigateToCustomHTMLPage() {
    // This event can trigger a custom HTML in-app from your CleverTap dashboard
    _showSuccessSnackBar("Custom HTML event recorded");

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CustomHtmlPage(),
      ),
    );
  }

  // Event recording methods
  void _recordNotificationEvent() {
    try {
      CleverTapPlugin.recordEvent("Notification Event", {});
      _showSuccessSnackBar("Notification event recorded");
    } catch (e) {
      _showErrorSnackBar("Failed to record notification event: $e");
    }
  }

  void _recordPushEvent() {
    try {
      CleverTapPlugin.recordEvent("Product Viewed", {
        'product_id': 'PROD_123',
        'product_name': 'Premium Plan',
        'category': 'subscription',
      });
      _showSuccessSnackBar("Custom event recorded");
    } catch (e) {
      _showErrorSnackBar("Failed to record Custom event: $e");
    }
  }

  void _recordInAppEvent() {
    try {
      CleverTapPlugin.recordEvent("In-App Event", {});
      // CleverTapPlugin.recordEvent("GFT Remove Cart", {}); // Test for Multi-Instance
      _showSuccessSnackBar("In-App event recorded");
    } catch (e) {
      _showErrorSnackBar("Failed to record in-app event: $e");
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
      var items = [item1, item2];
      var chargeDetails = {
        'total': '498',
        'payment': 'credit_card',
        'currency': 'INR',
        'transaction_id': 'TXN_${DateTime.now().millisecondsSinceEpoch}',
      };
      CleverTapPlugin.recordChargedEvent(chargeDetails, items);
      _showSuccessSnackBar("Charged event recorded: ₹498");
    } catch (e) {
      _showErrorSnackBar("Failed to record charged event: $e");
    }
  }

  // Native Display methods
  void _recordNativeDisplayEvent() {
    try {
      CleverTapPlugin.recordEvent("Native Event", {});
      _showSuccessSnackBar("Native Display event recorded");
      _getAllDisplayUnits();
    } catch (e) {
      _showErrorSnackBar("Failed to record native display event: $e");
    }
  }

  Future<void> _getAllDisplayUnits() async {
    try {
      debugPrint("Getting all display units...");
      final displayUnits = await CleverTapPlugin.getAllDisplayUnits();

      if (displayUnits != null && displayUnits.isNotEmpty) {
        setState(() {
          _displayUnits = _convertToMapList(displayUnits);
          _hasDisplayUnits = true;
        });
        _showSuccessSnackBar("Found ${displayUnits.length} display units");
        debugPrint("Display units loaded: ${displayUnits.length}");
      } else {
        setState(() {
          _displayUnits = [];
          _hasDisplayUnits = false;
        });
        _showSuccessSnackBar("No display units available");
      }
    } catch (e) {
      debugPrint("Error getting display units: $e");
      _showErrorSnackBar("Display units error: $e");
    }
  }

  // Navigate to Native Display Page
  void _navigateToNativeDisplayPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NativeDisplayPage(
          displayUnits: _displayUnits,
          onContentClick: _onContentItemClicked,
          onUnitViewed: _markDisplayUnitAsViewed,
        ),
      ),
    );
  }

  void _markDisplayUnitAsViewed(String unitId) {
    try {
      CleverTapPlugin.recordEvent("Display Unit Viewed", {
        'unit_id': unitId,
        'source': 'manual_trigger',
        'timestamp': DateTime.now().toIso8601String(),
      });
      _showSuccessSnackBar("Display unit viewed: $unitId");
    } catch (e) {
      _showErrorSnackBar("Error marking unit as viewed: $e");
    }
  }

  void _onContentItemClicked(Map<String, dynamic> item, String unitId) {
    try {
      CleverTapPlugin.recordEvent("Native Display Content Clicked", {
        'unit_id': unitId,
        'content_key': item['key']?.toString() ?? '',
        'timestamp': DateTime.now().toIso8601String(),
      });
      _showSuccessSnackBar("Content clicked!");
    } catch (e) {
      _showErrorSnackBar("Error recording click: $e");
    }
  }

  // Inbox methods
  void _openInbox() {
    try {
      CleverTapPlugin.recordEvent("App Inbox Event", {});
      CleverTapPlugin.initializeInbox();
      _showSuccessSnackBar("Opening App Inbox...");
    } catch (e) {
      _showErrorSnackBar("Failed to open inbox: $e");
    }
  }

  void _inboxDidInitialize() {
    setState(() {
      var styleConfig = {
        'noMessageTextColor': '#FF6600',
        'noMessageText': 'No message(s) to show.',
        'navBarTitle': 'App Inbox',
        'navBarTitleColor': '#FFFFFF',
        'navBarColor': '#9C27B0',
        'inboxBackgroundColor': '#F5F5F5',
      };
      CleverTapPlugin.showInbox(styleConfig);
    });
  }

  // UI Helper methods
  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _emailEvent() {
    int randomNumber = 50 + (Random().nextInt(51));
    CleverTapPlugin.recordEvent("Health", {"Heart Rate": randomNumber});
    _showSuccessSnackBar(
        "Email campaign event recorded with HR: $randomNumber");
  }

  void _linkedContent() {
    CleverTapPlugin.recordEvent("android Purchase", {});
    _showSuccessSnackBar("Linked content event recorded");
  }

  Widget _buildActionCard({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Change to min
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24, // Reduced from 32
                color: onPressed != null ? color : Colors.grey,
              ),
              const SizedBox(height: 4), // Reduced from 8
              FittedBox(
                // Wrap text in FittedBox
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11, // Reduced from 12
                    fontWeight: FontWeight.w600,
                    color: onPressed != null ? Colors.black87 : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Section
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'CleverTap Integration Demo',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          if (_isLoggedIn) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Text(
                                'Logged in • ID: ${_cleverTapId ?? 'Loading...'}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Display Units Status
                  if (_hasDisplayUnits) ...[
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.campaign, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Active Display Units: ${_displayUnits.length}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Grid of Action Cards
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildActionCard(
                          onPressed: _login,
                          icon: Icons.login,
                          label: _isLoggedIn ? 'Re-login' : 'Login',
                          color: Colors.blue,
                        ),
                        _buildActionCard(
                          onPressed: _recordNotificationEvent,
                          icon: Icons.notifications_active,
                          label: 'Notification Event',
                          color: Colors.orange,
                        ),
                        _buildActionCard(
                          onPressed: _recordPushEvent,
                          icon: Icons.send,
                          label: 'Push Event',
                          color: Colors.green,
                        ),
                        _buildActionCard(
                          onPressed: _recordChargedEvent,
                          icon: Icons.payment,
                          label: 'Charged Event',
                          color: Colors.amber[700]!,
                        ),
                        _buildActionCard(
                          onPressed: _recordInAppEvent,
                          icon: Icons.phone_iphone,
                          label: 'In-App Event',
                          color: Colors.purple,
                        ),
                        _buildActionCard(
                          onPressed: _linkedContent,
                          icon: Icons.content_copy,
                          label: 'Linked Content',
                          color: Colors.green,
                        ),
                        _buildActionCard(
                          onPressed: _openInbox,
                          icon: Icons.inbox,
                          label: 'App Inbox',
                          color: Colors.teal,
                        ),
                        _buildActionCard(
                          onPressed: _recordNativeDisplayEvent,
                          icon: Icons.display_settings,
                          label: 'Native Display',
                          color: Colors.indigo,
                        ),
                        _buildActionCard(
                          onPressed: _emailEvent,
                          icon: Icons.email,
                          label: "Email Campaign",
                          color: Colors.lightBlue,
                        ),
                        _buildActionCard(
                          onPressed: _getAllDisplayUnits,
                          icon: Icons.view_list,
                          label: 'Get Units',
                          color: Colors.cyan,
                        ),
                        _buildActionCard(
                          onPressed: _navigateToNativeDisplayPage,
                          icon: Icons.open_in_new,
                          label: 'Native Display Page',
                          color: Colors.deepOrange,
                        ),
                        _buildActionCard(
                          onPressed: _navigateToCustomHTMLPage,
                          icon: Icons.web,
                          label: "Custom HTML Page",
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
