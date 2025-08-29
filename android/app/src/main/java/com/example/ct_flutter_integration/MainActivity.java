package com.example.ct_flutter_integration;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.app.NotificationManager;

import io.flutter.embedding.android.FlutterFragmentActivity;

import com.clevertap.android.sdk.CleverTapAPI;
import com.clevertap.android.pushtemplates.PushTemplateNotificationHandler;

public class MainActivity extends FlutterFragmentActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Register Push Template Handler once when app starts
        CleverTapAPI.setNotificationHandler(new PushTemplateNotificationHandler());
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
    }
}
