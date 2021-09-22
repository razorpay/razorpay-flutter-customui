package com.razorpay.flutter_customui;

import android.webkit.WebView;

import androidx.annotation.NonNull;

import com.razorpay.Razorpay;
import org.json.JSONObject;

import java.util.ArrayList;
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
  private Razorpay razorpay;

  public RazorpayPlugin() {
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "razorpay_flutter_customui");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
    if (call.method.equals("openCheckout")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("open")) {
      ArrayList<JSONObject> arguments = (ArrayList<JSONObject>) call.arguments;
      razorpayDelegate.submit(arguments.get(0));
    } else if (call.method.equals("callNativeIntent")) {
      ArrayList<String> arguments = (ArrayList<String>) call.arguments;
      razorpayDelegate.callNativeIntent(arguments.get(0));
    } else if (call.method.equals("changeApiKey")) {
      ArrayList<String> arguments = (ArrayList<String>) call.arguments;
      razorpayDelegate.changeApiKey(arguments.get(0));
    } else if (call.method.equals("getBankLogoUrl")) {
      ArrayList<String> arguments = (ArrayList<String>) call.arguments;
      result.success(razorpayDelegate.getBankLogoUrl(arguments.get(0)));
    } else if (call.method.equals("getCardNetwork")) {
      ArrayList<String> arguments = (ArrayList<String>) call.arguments;
      result.success(razorpayDelegate.getCardNetwork(arguments.get(0)));
    } else if (call.method.equals("getCardNetworkLength")) {
      ArrayList<String> arguments = (ArrayList<String>) call.arguments;
      result.success(String.valueOf(razorpayDelegate.getCardNetworkLength(arguments.get(0))));
    } else if (call.method.equals("getPaymentMethods")) {
      razorpayDelegate.getPaymentMethods();
    } else if (call.method.equals("getAppsWhichSupportUpi")) {
      razorpayDelegate.getAppsWhichSupportUpi();
    } else if (call.method.equals("getSubscriptionAmount")) {
      ArrayList<String> arguments = (ArrayList<String>) call.arguments;
      razorpayDelegate.getSubscriptionAmount(arguments.get(0));
    } else if (call.method.equals("getWalletLogoUrl")) {
      ArrayList<String> arguments = (ArrayList<String>) call.arguments;
      razorpayDelegate.getWalletLogoUrl(arguments.get(0));
    } else if (call.method.equals("isValidCardNumber")) {
      ArrayList<String> arguments = (ArrayList<String>) call.arguments;
      razorpayDelegate.isValidCardNumber(arguments.get(0));
    } else if (call.method.equals("isValidVpa")) {
      ArrayList<String> arguments = (ArrayList<String>) call.arguments;
      razorpayDelegate.isValidVpa(arguments.get(0));
    } else if (call.method.equals("setPaymentId")) {
      ArrayList<String> arguments = (ArrayList<String>) call.arguments;
      razorpayDelegate.setPaymentID(arguments.get(0));
    } else if (call.method.equals("setWebView")) {
      ArrayList<WebView> arguments = (ArrayList<WebView>) call.arguments;
      razorpayDelegate.setWebView(arguments.get(0));
    } else if (call.method.equals("validateFields")) {
      ArrayList<JSONObject> arguments = (ArrayList<JSONObject>) call.arguments;
      razorpayDelegate.validateFields(arguments.get(0));
    }

  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  public RazorpayPlugin(Registrar registrar) {
    this.razorpayDelegate = new RazorpayDelegate(registrar.activity());
    registrar.addActivityResultListener(razorpayDelegate);
  }

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
