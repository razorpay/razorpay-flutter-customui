package com.razorpay.flutter_customui_example;

import com.razorpay.flutter_customui.RazorpayPlugin;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

public class MainActivity extends FlutterActivity {
    private ActivityPluginBinding pluginBinding;
    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        flutterEngine.getPlugins().add(new RazorpayPlugin());
    }
}
