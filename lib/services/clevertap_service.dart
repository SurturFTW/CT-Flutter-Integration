import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/foundation.dart';

class CleverTapService {
  static final CleverTapService _instance = CleverTapService._();
  factory CleverTapService() => _instance;
  CleverTapService._();

  final CleverTapPlugin _plugin = CleverTapPlugin();

  void initialize({
    required Function(List<dynamic>) onDisplayUnitsLoaded,
    required VoidCallback onInboxInitialized,
    required Function(Map<String, dynamic>) onPushClicked,
  }) {
    CleverTapPlugin.createNotificationChannel(
        "test", "Test Channel", "Channel for push notifications", 3, true);
    CleverTapPlugin.setDebugLevel(3);
    if (!kIsWeb) CleverTapPlugin.registerForPush();

    _plugin.setCleverTapPushClickedPayloadReceivedHandler(onPushClicked);
    _plugin.setCleverTapInboxDidInitializeHandler(onInboxInitialized);
    _plugin.setCleverTapInAppNotificationButtonClickedHandler((map) {
      debugPrint("inAppNotificationButtonClicked: $map");
    });
    _plugin.setCleverTapDisplayUnitsLoadedHandler((units) {
      if (units != null) onDisplayUnitsLoaded(units);
    });

    initializeInbox();
  }

  Future<String?> login(Map<String, dynamic> profile) async {
    CleverTapPlugin.onUserLogin(profile);
    return CleverTapPlugin.getCleverTapID();
  }

  void profileSet(Map<String, dynamic> profile) {
    CleverTapPlugin.profileSet(profile);
  }

  void profileSetMultiValues(String key, List<String> values) {
    CleverTapPlugin.profileSetMultiValues(key, values);
  }

  void profileAddMultiValue(String key, String value) {
    CleverTapPlugin.profileAddMultiValue(key, value);
  }

  void profileAddMultiValues(String key, List<String> values) {
    CleverTapPlugin.profileAddMultiValues(key, values);
  }

  void profileRemoveMultiValue(String key, String value) {
    CleverTapPlugin.profileRemoveMultiValue(key, value);
  }

  void profileRemoveMultiValues(String key, List<String> values) {
    CleverTapPlugin.profileRemoveMultiValues(key, values);
  }

  void profileRemoveValueForKey(String key) {
    CleverTapPlugin.profileRemoveValueForKey(key);
  }

  void profileIncrementValue(String key, num value) {
    CleverTapPlugin.profileIncrementValue(key, value);
  }

  void profileDecrementValue(String key, num value) {
    CleverTapPlugin.profileDecrementValue(key, value);
  }

  Future<dynamic> profileGetProperty(String key) {
    return CleverTapPlugin.profileGetProperty(key);
  }

  void setLocation(double lat, double lng) {
    CleverTapPlugin.setLocation(lat, lng);
  }

  void recordEvent(String name, [Map<String, dynamic>? props]) {
    CleverTapPlugin.recordEvent(name, props ?? {});
  }

  void recordChargedEvent(
      Map<String, dynamic> details, List<Map<String, dynamic>> items) {
    CleverTapPlugin.recordChargedEvent(details, items);
  }

  Future<Map<dynamic, dynamic>?> getUserEventLog(String eventName) {
    return CleverTapPlugin.getUserEventLog(eventName);
  }

  Future<Map<dynamic, dynamic>?> getUserEventLogHistory() {
    return CleverTapPlugin.getUserEventLogHistory();
  }

  Future<int?> getUserEventLogCount(String eventName) {
    return CleverTapPlugin.getUserEventLogCount(eventName);
  }

  Future<int?> getUserAppLaunchCount() {
    return CleverTapPlugin.getUserAppLaunchCount();
  }

  Future<int?> getUserLastVisitTs() async {
    final val = await CleverTapPlugin.getUserLastVisitTs();
    return val?.toInt();
  }

  Future<int?> sessionGetTimeElapsed() async {
    final val = await CleverTapPlugin.sessionGetTimeElapsed();
    if (val is int?) return val;
    return (val as num?)?.toInt();
  }

  Future<int?> sessionGetScreenCount() {
    return CleverTapPlugin.sessionGetScreenCount();
  }

  Future<Map<dynamic, dynamic>?> sessionGetUTMDetails() {
    return CleverTapPlugin.sessionGetUTMDetails();
  }

  Future<String?> getCleverTapId() => CleverTapPlugin.getCleverTapID();

  Future<bool?> getPushPermissionStatus() =>
      CleverTapPlugin.getPushNotificationPermissionStatus();

  void promptPushPrimer(Map<String, dynamic> config) {
    CleverTapPlugin.promptPushPrimer(config);
  }

  void showInbox(Map<String, dynamic> styleConfig) {
    CleverTapPlugin.showInbox(styleConfig);
  }

  void initializeInbox() {
    CleverTapPlugin.initializeInbox();
  }

  Future<List?> getAllInboxMessages() {
    return CleverTapPlugin.getAllInboxMessages();
  }

  Future<List?> getUnreadInboxMessages() {
    return CleverTapPlugin.getUnreadInboxMessages();
  }

  Future<Map?> getInboxMessageForId(String id) {
    return CleverTapPlugin.getInboxMessageForId(id);
  }

  Future<void> markReadInboxMessageForId(String id) {
    return CleverTapPlugin.markReadInboxMessageForId(id);
  }

  Future<void> deleteInboxMessageForId(String id) {
    return CleverTapPlugin.deleteInboxMessageForId(id);
  }

  void fetchInbox() {
    CleverTapPlugin.initializeInbox();
  }

  Future<bool?> fetchInboxWithCallback() async {
    await CleverTapPlugin.initializeInbox();
    return true;
  }

  Future<void> pushInboxNotificationClickedEventForId(String id) {
    return CleverTapPlugin.pushInboxNotificationClickedEventForId(id);
  }

  Future<void> pushInboxNotificationViewedEventForId(String id) {
    return CleverTapPlugin.pushInboxNotificationViewedEventForId(id);
  }

  void dismissInbox() {
    CleverTapPlugin.dismissInbox();
  }

  void suspendInAppNotifications() {
    CleverTapPlugin.suspendInAppNotifications();
  }

  void discardInAppNotifications({bool dismissVisible = false}) {
    CleverTapPlugin.discardInAppNotifications(dismissInAppIfVisible: dismissVisible);
  }

  void resumeInAppNotifications() {
    CleverTapPlugin.resumeInAppNotifications();
  }

  Future<bool?> fetchInApps() {
    return CleverTapPlugin.fetchInApps();
  }

  void clearInAppResources({bool expiredOnly = false}) {
    CleverTapPlugin.clearInAppResources(expiredOnly);
  }

  // Persisted toggle states so UI survives tab switches
  bool isOptedOut = false;
  bool isOffline = false;
  bool isNetworkInfoEnabled = false;

  void setOptOut(bool optOut, [bool? allowSystemEvents]) {
    isOptedOut = optOut;
    CleverTapPlugin.setOptOut(optOut, allowSystemEvents);
  }

  void setOffline(bool offline) {
    isOffline = offline;
    CleverTapPlugin.setOffline(offline);
  }

  void unmute() {
    CleverTapPlugin.unmute();
  }

  void enableDeviceNetworkInfoReporting(bool enable) {
    isNetworkInfoEnabled = enable;
    CleverTapPlugin.enableDeviceNetworkInfoReporting(enable);
  }

  void enablePersonalization() {
    CleverTapPlugin.enablePersonalization();
  }

  void disablePersonalization() {
    CleverTapPlugin.disablePersonalization();
  }

  void setPushToken(String token) {
    CleverTapPlugin.setPushToken(token);
  }

  Future<void> pushRegistrationToken(String token, Map<String, dynamic> config) {
    final stringConfig = config.map((k, v) => MapEntry(k, v.toString()));
    return CleverTapPlugin.pushRegistrationToken(token, stringConfig);
  }
}
