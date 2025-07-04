import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _requestPermissions();

  CleverTapPlugin.onKilledStateNotificationClicked(
      _onKilledStateNotificationClickedHandler);

  runApp(const MyApp());
}

void pushClickedPayloadReceived(Map<String, dynamic> notificationPayload) {
  print("pushClickedPayloadReceived called with notification payload: " +
      notificationPayload.toString());
}

@pragma('vm:entry-point')
void _onKilledStateNotificationClickedHandler(Map<String, dynamic> map) async {
  print("Notification Payload received: " + map.toString());
}

Future<void> _requestPermissions() async {
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
}

Future<void> _sendLocationToCleverTap() async {
  Position position = await Geolocator.getCurrentPosition(
    locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
  );
  CleverTapPlugin.setLocation(position.latitude, position.longitude);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  var stuff = ["bags", "shoes"];
  var profile = {
    'Name': 'BatMan',
    'First Name': 'Bat',
    'Last Name': 'Man',
    'Identity': '200',
    'Email': 'Bat@man.com',
    'Phone': '+91123456789',
  };

  void _login() {
    CleverTapPlugin.onUserLogin(profile);
    print(CleverTapPlugin.getCleverTapID());
  }

  void _pushEvent() {
    CleverTapPlugin.recordEvent("Product Viewed", {});
  }

  void _inAppEvent() {
    CleverTapPlugin.recordEvent("Product Viewed", {});
  }

  void _notificationEvent() {
    CleverTapPlugin.recordEvent("Notification Event", {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: _notificationEvent,
              child: Text("Notification Event"),
            ),
            ElevatedButton(
              onPressed: _pushEvent,
              child: Text("Push Event"),
            ),
            ElevatedButton(
              onPressed: _inAppEvent,
              child: Text("In-App"),
            ),
            ElevatedButton(onPressed: _inbox, child: Text('App Inbox'))
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    print("CleverTapPlugin initState");
    super.initState();

    CleverTapPlugin clevertapPlugin = CleverTapPlugin();

    CleverTapPlugin.setDebugLevel(3);
    CleverTapPlugin.registerForPush();

    clevertapPlugin.setCleverTapPushClickedPayloadReceivedHandler(
        pushClickedPayloadReceived);

    clevertapPlugin.setCleverTapInboxDidInitializeHandler(inboxDidInitialize);
  }

  void _inbox() {
    CleverTapPlugin.recordEvent("App Inbox Event", {});
    CleverTapPlugin.initializeInbox();
  }

  void inboxDidInitialize() {
    setState(() {
      print("inboxDidInitialize called");
      var styleConfig = {
        'noMessageTextColor': '#FF6600',
        'noMessageText': 'No message(s) to show.',
        'navBarTitle': 'App Inbox'
      };
      CleverTapPlugin.showInbox(styleConfig);
    });
  }
}

void NotificationButton({required Icon child}) {
  NotificationButton(child: Icon(Icons.notifications));
}
