package com.example.ct_flutter_integration;

import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.app.NotificationManager;
import android.util.Log;

import io.flutter.embedding.android.FlutterFragmentActivity;

import com.clevertap.android.sdk.ActivityLifecycleCallback;
import com.clevertap.android.sdk.CleverTapAPI;
import com.clevertap.android.pushtemplates.PushTemplateNotificationHandler;
import com.clevertap.android.pushtemplates.PTConstants;

public class MainActivity extends FlutterFragmentActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        ActivityLifecycleCallback.register(this.getApplication());
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void onResume() {
        super.onResume();
        CleverTapAPI.onActivityResumed(this);
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);

        // On Android 12+ forward notification click payload to CleverTap
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            CleverTapAPI cleverTapDefaultInstance = CleverTapAPI.getDefaultInstance(this);
            if (cleverTapDefaultInstance != null && intent.getExtras() != null) {
                cleverTapDefaultInstance.pushNotificationClickedEvent(intent.getExtras());
            }
        }
        
        // Handle notification dismissal
        NotificationUtils.dismissNotification(intent, this);
    }

    public static class NotificationUtils {

        // Require to close notification on action button click
        public static void dismissNotification(Intent intent, Context applicationContext) {
            if (intent == null || intent.getExtras() == null) {
                return;
            }

            Bundle extras = intent.getExtras();
            boolean autoCancel = true;
            int notificationId = -1;

            String actionId = extras.getString("actionId");
            if (actionId != null) {
                Log.d("ACTION_ID", actionId);
                autoCancel = extras.getBoolean("autoCancel", true);
                notificationId = extras.getInt("notificationId", -1);
            }

            /**
             * If using InputBox template, add ptDismissOnClick flag to not dismiss notification
             * if pt_dismiss_on_click is false in InputBox template payload. Alternatively if normal
             * notification is raised then we dismiss notification.
             */
            String ptDismissOnClick = extras.getString(PTConstants.PT_DISMISS_ON_CLICK, "");

            if (autoCancel && notificationId > -1 && (ptDismissOnClick == null || ptDismissOnClick.isEmpty())) {
                NotificationManager notifyMgr = (NotificationManager) applicationContext.getSystemService(Context.NOTIFICATION_SERVICE);
                if (notifyMgr != null) {
                    notifyMgr.cancel(notificationId);
                }
            }
        }
    }
}