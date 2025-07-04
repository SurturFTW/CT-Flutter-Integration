package com.example.ct_flutter_integration;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;

import com.clevertap.android.sdk.CleverTapAPI;

import io.flutter.embedding.android.FlutterFragmentActivity;

public class MainActivity extends FlutterFragmentActivity {

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);

        // On Android 12 and above, inform the notification click to get the pushClickedPayloadReceived callback on Dart side.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            CleverTapAPI cleverTapDefaultInstance = CleverTapAPI.getDefaultInstance(this);
            if (cleverTapDefaultInstance != null && intent.getExtras() != null) {
                cleverTapDefaultInstance.pushNotificationClickedEvent(intent.getExtras());
            }
        }
    }
}
