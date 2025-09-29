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

        // MethodChannel for Deeplink forwarding
        if let controller = window?.rootViewController as? FlutterViewController {
           channel = FlutterMethodChannel(name: "myChannel", binaryMessenger: controller.binaryMessenger)
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

        // Register default notification category (will be updated dynamically)
        registerDefaultNotificationActions()
    }

    // MARK: - Default Notification Actions
    func registerDefaultNotificationActions() {
        let center = UNUserNotificationCenter.current()
        
        // Default actions if no custom buttons are available
        let defaultAction = UNNotificationAction(identifier: "default_action", title: "View", options: [])
        let defaultCategory = UNNotificationCategory(identifier: "CTNotification",
                                                   actions: [defaultAction],
                                                   intentIdentifiers: [],
                                                   options: [])
        center.setNotificationCategories([defaultCategory])
    }

    // MARK: - Dynamic Notification Actions
    func createDynamicNotificationActions(from payload: [AnyHashable: Any]) {
        let center = UNUserNotificationCenter.current()
        var actions: [UNNotificationAction] = []
        
        // Extract custom KV pairs and create buttons
        if let name = payload["name"] as? String,
           let link = payload["link"] as? String {
            
            // Create action with custom name and store link in identifier
            let customAction = UNNotificationAction(
                identifier: "custom_\(link)", // Store link in identifier for later retrieval
                title: name.capitalized, // Display name as button text
                options: []
            )
            actions.append(customAction)
            
            NSLog("Created dynamic button: %@ -> %@", name, link)
        }
        
        // Add default "View In App" action
        let defaultAction = UNNotificationAction(identifier: "view_in_app", title: "View In App", options: [])
        // actions.append(defaultAction)
        
        // Create category with dynamic actions
        let dynamicCategory = UNNotificationCategory(
            identifier: "CTNotification",
            actions: Array(actions.prefix(4)), // iOS allows max 4 actions
            intentIdentifiers: [],
            options: []
        )
        
        center.setNotificationCategories([dynamicCategory])
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
        
        // Create dynamic actions when notification is received
        createDynamicNotificationActions(from: userInfo)
        
        completionHandler(.noData)
    }

    // MARK: - Foreground Push Notification
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         willPresent notification: UNNotification,
                                         withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        NSLog("Push notification received in foreground: %@", userInfo)
        
        // Create dynamic actions for foreground notifications
        createDynamicNotificationActions(from: userInfo)
        
        CleverTap.sharedInstance()?.recordNotificationViewedEvent(withData: userInfo)
        completionHandler([.alert, .badge, .sound])
    }

    // MARK: - Push Notification Tap
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         didReceive response: UNNotificationResponse,
                                         withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        NSLog("Push notification tapped: %@", userInfo)
        NSLog("Action identifier: %@", response.actionIdentifier)
        
        CleverTap.sharedInstance()?.handleNotification(withData: userInfo)
        
        // Handle dynamic button taps
        handleNotificationAction(actionIdentifier: response.actionIdentifier, userInfo: userInfo)
        
        completionHandler()
    }

    // MARK: - Handle Notification Actions
    func handleNotificationAction(actionIdentifier: String, userInfo: [AnyHashable: Any]) {
        switch actionIdentifier {
        case "view_in_app":
            // Handle default "View In App" action
            if let deepLink = userInfo["wzrk_dl"] as? String {
                NSLog("Opening default deep link: %@", deepLink)
                channel?.invokeMethod("handleDeepLink", arguments: deepLink)
            }
            
        case let identifier where identifier.hasPrefix("custom_"):
            // Extract custom link from identifier
            let customLink = String(identifier.dropFirst("custom_".count))
            NSLog("Opening custom link: %@", customLink)
            channel?.invokeMethod("handleDeepLink", arguments: customLink)
            
        default:
            NSLog("Unknown action identifier: %@", actionIdentifier)
        }
    }

    // Optional: Deep Link / URL Handling
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        NSLog("Open URL: %@", url.absoluteString)
        return true
    }
}

// MARK: - Extension for Multiple Custom Buttons (if needed)
extension AppDelegate {
    
    // Enhanced version to handle multiple custom buttons
    func createMultipleCustomActions(from payload: [AnyHashable: Any]) {
        let center = UNUserNotificationCenter.current()
        var actions: [UNNotificationAction] = []
        
        // Handle multiple custom buttons by checking for arrays or multiple KV pairs
        for i in 1...3 { // Check for up to 3 custom buttons
            if let name = payload["name\(i == 1 ? "" : String(i))"] as? String,
               let link = payload["link\(i == 1 ? "" : String(i))"] as? String {
                
                let action = UNNotificationAction(
                    identifier: "custom_\(link)",
                    title: name.capitalized,
                    options: []
                )
                actions.append(action)
            }
        }
        
        // Add default action if no custom actions
        if actions.isEmpty {
            let defaultAction = UNNotificationAction(identifier: "view_in_app", title: "View In App", options: [])
            actions.append(defaultAction)
        }
        
        // Create category with actions (max 4 for iOS)
        let category = UNNotificationCategory(
            identifier: "CTNotification",
            actions: Array(actions.prefix(4)),
            intentIdentifiers: [],
            options: []
        )
        
        center.setNotificationCategories([category])
    }
}