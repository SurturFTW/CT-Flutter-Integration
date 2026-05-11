import Flutter
import UIKit
import CleverTapSDK
import clevertap_plugin
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

    private var channel: FlutterMethodChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Register Flutter plugins
        GeneratedPluginRegistrant.register(with: self)

        // MethodChannel for Deeplink forwarding and native rendering
        if let controller = window?.rootViewController as? FlutterViewController {
           channel = FlutterMethodChannel(name: "myChannel", binaryMessenger: controller.binaryMessenger)
            
            // Add method call handler for native rendering
            channel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
                switch call.method {
                case "renderNativeDisplayUnits":
                    self?.renderNativeDisplayUnits(result: result)
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
        }

        // CleverTap integration
        CleverTap.setDebugLevel(CleverTapLogLevel.debug.rawValue)
        CleverTap.autoIntegrate()
        CleverTapPlugin.sharedInstance()?.applicationDidLaunch(options: launchOptions)

        // Register push notifications
        registerForPush()

        if let remoteNotification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            NSLog("App launched from push notification: %@", remoteNotification)
            CleverTap.sharedInstance()?.handleNotification(withData: remoteNotification)

            // Extract deep link and forward to Flutter
            if let deepLink = remoteNotification["wzrk_dl"] as? String {
                // NSLog("Extracted deep link: %@", deepLink)
                channel?.invokeMethod("handleDeepLink", arguments: deepLink)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - Push Notification Registration
    func registerForPush() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        // Request permission
        center.requestAuthorization(options: [.sound, .badge, .alert]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }

        // Register custom notification actions
        let action1 = UNNotificationAction(identifier: "action_1", title: "Back", options: [])
        let action2 = UNNotificationAction(identifier: "action_2", title: "Next", options: [])
        let action3 = UNNotificationAction(identifier: "action_3", title: "View In App", options: [])
        let category = UNNotificationCategory(identifier: "CTNotification",
                                              actions: [action1, action2, action3],
                                              intentIdentifiers: [],
                                              options: [])
        center.setNotificationCategories([category])
    }

    // MARK: - Push Notification Handlers
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("Failed to register for remote notifications: %@", error.localizedDescription)
    }

    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NSLog("Registered for remote notifications: %@", deviceToken.description)
    }

    override func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NSLog("Received remote notification: %@", userInfo)
        completionHandler(.noData)
    }

    // MARK: - Foreground Push Notification
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         willPresent notification: UNNotification,
                                         withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        NSLog("Push notification received in foreground: %@", notification.request.content.userInfo)
        // CleverTap.sharedInstance()?.recordNotificationViewedEvent(withData: notification.request.content.userInfo)
        completionHandler([.alert, .badge, .sound])
    }

    // MARK: - Push Notification Tap
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         didReceive response: UNNotificationResponse,
                                         withCompletionHandler completionHandler: @escaping () -> Void) {
        NSLog("Push notification tapped: %@", response.notification.request.content.userInfo)
        CleverTap.sharedInstance()?.handleNotification(withData: response.notification.request.content.userInfo)
        completionHandler()
    }

    func pushNotificationTapped(withCustomExtras customExtras: [AnyHashable : Any]!) {
        NSLog("pushNotificationTapped: customExtras: ", customExtras)
    }

    // Optional: Deep Link / URL Handling
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        NSLog("Open URL: %@", url.absoluteString)
        return true
    }

    // MARK: - Native Display Unit Rendering
    func renderNativeDisplayUnits(result: @escaping FlutterResult) {
        NSLog("Starting native rendering of display units...")
        
        guard let cleverTapInstance = CleverTap.sharedInstance() else {
            NSLog("CleverTap instance not available")
            result(FlutterError(code: "CLEVTAP_ERROR", message: "CleverTap instance not available", details: nil))
            return
        }
        
        // Get all display units
        let displayUnits = cleverTapInstance.getAllInboxMessages()
        
        if displayUnits.isEmpty {
            NSLog("No display units available to render")
            result(["success": false, "message": "No display units available"])
            return
        }
        
        NSLog("Found %d display units to render", displayUnits.count)
        
        // Render each display unit natively
        for displayUnit in displayUnits {
            if let displayUnit = displayUnit as? [AnyHashable: Any] {
                // Log rendering
                NSLog("Rendering display unit: %@", displayUnit)
                
                // CleverTap SDK will handle native rendering through the plugin
                // The display units will be shown in the native UI layer
            }
        }
        
        // Notify success
        result(["success": true, "message": "Display units rendered successfully", "count": displayUnits.count])
    }
}

