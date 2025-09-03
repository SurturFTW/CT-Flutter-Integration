package com.example.ct_flutter_integration;

import android.app.Application;
import com.clevertap.android.sdk.CleverTapAPI;
import com.clevertap.android.pushtemplates.PushTemplateNotificationHandler;

public class MainApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        CleverTapAPI.setNotificationHandler(new PushTemplateNotificationHandler());
    }
}