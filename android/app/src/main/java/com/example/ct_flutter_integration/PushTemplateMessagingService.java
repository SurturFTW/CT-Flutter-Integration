package com.example.ct_flutter_integration;

import android.util.Log;

import com.clevertap.android.sdk.pushnotification.fcm.CTFcmMessageHandler;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

public class PushTemplateMessagingService extends FirebaseMessagingService {

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        // Pass FCM payload to CleverTap's Push Template handler
        if (remoteMessage.getData().size() > 0) {
            Log.d("CTPushTemplate", "FCM payload: " + remoteMessage.getData().toString());
            new CTFcmMessageHandler().createNotification(getApplicationContext(), remoteMessage);
        }
    }
}
