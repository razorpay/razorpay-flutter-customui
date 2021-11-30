package com.razorpay.flutter_customui;

import android.annotation.SuppressLint;
import android.os.Build;
import android.util.Log;
import android.webkit.WebView;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import com.razorpay.Razorpay;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import io.flutter.plugin.common.PluginRegistry.Registrar;

/** RazorpayFlutterCustomuiPlugin */
public class RazorpayPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity

  private RazorpayDelegate razorpayDelegate;
  private ActivityPluginBinding pluginBinding;
  private MethodChannel channel;

  @RequiresApi(api = Build.VERSION_CODES.KITKAT)
  public RazorpayPlugin() {
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "razorpay_flutter_customui");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {

    switch (call.method) {
      case "initilizeSDK":
        razorpayDelegate.init(call.arguments.toString(),result);
        break;

      case "submit":
        razorpayDelegate.submit(new JSONObject((Map<String, JSONObject>) call.arguments), result);
        break;

      case "callNativeIntent":
        razorpayDelegate.callNativeIntent(call.arguments.toString(), result);
        break;

      case "changeApiKey":
        razorpayDelegate.changeApiKey(call.arguments.toString(), result);
        break;

      case "getBankLogoUrl":
        result.success(razorpayDelegate.getBankLogoUrl(call.arguments.toString()));
        break;

      case "getCardNetwork":
        result.success(razorpayDelegate.getCardNetwork(call.arguments.toString()));
        break;

      case "getCardNetworkLength":
        result.success(String.valueOf(razorpayDelegate.getCardNetworkLength(call.arguments.toString())));
        break;

      case "getPaymentMethods":
        razorpayDelegate.getPaymentMethods(result);
        break;

      case "getAppsWhichSupportUpi":
        razorpayDelegate.getAppsWhichSupportUpi(result);
        break;

      case "getSubscriptionAmount":
        razorpayDelegate.getSubscriptionAmount(call.arguments.toString(), result);
        break;

      case "getWalletLogoUrl":
        razorpayDelegate.getWalletLogoUrl(call.arguments.toString(), result);
        break;

      case "isValidCardNumber":
        razorpayDelegate.isValidCardNumber(call.arguments.toString(), result);
        break;

      case "isValidVpa":
        razorpayDelegate.isValidVpa(call.arguments.toString(), result);
        break;

      case "setPaymentId":
        razorpayDelegate.setPaymentID(call.arguments.toString(), result);
        break;

      default:
        Log.d("RAZORPAY_SDK","no method");
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @RequiresApi(api = Build.VERSION_CODES.KITKAT)
  public RazorpayPlugin(Registrar registrar) {
    this.razorpayDelegate = new RazorpayDelegate(registrar.activity());
    registrar.addActivityResultListener(razorpayDelegate);
  }

  @RequiresApi(api = Build.VERSION_CODES.KITKAT)
  @Override
  public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
    this.razorpayDelegate = new RazorpayDelegate(activityPluginBinding.getActivity());
    this.pluginBinding = activityPluginBinding;
    activityPluginBinding.addActivityResultListener(razorpayDelegate);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @SuppressLint("NewApi")
  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
    onAttachedToActivity(activityPluginBinding);
  }

  @Override
  public void onDetachedFromActivity() {
    pluginBinding.removeActivityResultListener(razorpayDelegate);
    pluginBinding = null;
  }
}
