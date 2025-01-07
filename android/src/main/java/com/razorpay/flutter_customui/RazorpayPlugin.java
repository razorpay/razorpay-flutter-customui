package com.razorpay.flutter_customui;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import org.json.JSONObject;

import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * RazorpayFlutterCustomuiPlugin
 */

public class RazorpayPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, EventChannel.StreamHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity

    private RazorpayDelegate razorpayDelegate;
    private ActivityPluginBinding pluginBinding;
    private MethodChannel channel;

    private Activity activity;
    private final String TAG = "RazorpayPlugin";

    // Turbo UPI
    private EventChannel.EventSink eventSink;
    private EventChannel eventChannel;
    String upiAccountStr = "";
    String cardStr = "";
    Map<String, Object> _arguments;
    private PluginRegistry.RequestPermissionsResultListener permissionResultListener;
    String customerMobile = "";
    String orderId = "";
    String tpvBankAccount = "";

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    public RazorpayPlugin() {
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "razorpay_turbo");
        channel.setMethodCallHandler(this);
        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "razorpay_turbo_with_turbo_upi");
        eventChannel.setStreamHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {

        switch (call.method) {
            case "initilizeSDK":
                razorpayDelegate.init(call.arguments.toString(), result);
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

            //Turbo UPI
            case "linkNewUpiAccount":
                customerMobile = call.arguments.toString();
                razorpayDelegate.linkNewUpiAccount(customerMobile, result, this.eventSink);
                break;
            case "askForPermission":
                razorpayDelegate.askForPermission(result, this.eventSink);
                break;
            case "register":
                String simStr = call.arguments.toString();
                razorpayDelegate.register(simStr, result, this.eventSink);
                break;
            case "getBankAccount":
                String bankStr = call.arguments.toString();
                razorpayDelegate.getBankAccounts(bankStr, result, this.eventSink);
                break;
            case "getLinkedUpiAccounts":
                razorpayDelegate.getLinkedUpiAccounts(call.arguments.toString(), result, this.eventSink);
                break;
            case "getBalance":
                upiAccountStr = call.arguments.toString();
                razorpayDelegate.getBalance(razorpayDelegate.getUpiAccount(upiAccountStr), result, this.eventSink);
                break;
            case "changeUpiPin":
                upiAccountStr = call.arguments.toString();
                razorpayDelegate.changeUpiPin(razorpayDelegate.getUpiAccount(upiAccountStr), result, this.eventSink);
                break;
            case "resetUpiPin":
                _arguments = call.arguments();
                upiAccountStr = (String) _arguments.get("upiAccount");
                cardStr = (String) _arguments.get("card");
                razorpayDelegate.resetUpiPin(razorpayDelegate.getUpiAccount(upiAccountStr), razorpayDelegate.getCard(cardStr),
                        result, this.eventSink);
                break;
            case "delink":
                upiAccountStr = call.arguments.toString();
                razorpayDelegate.delink(razorpayDelegate.getUpiAccount(upiAccountStr), result, this.eventSink);
                break;
            case "selectedBankAccount":
                String bankAccountStr = call.arguments.toString();
                razorpayDelegate.selectedBankAccount(razorpayDelegate.getBankAccount(bankAccountStr), result, this.eventSink);
                break;
            case "setUpUPIPin":
                cardStr = call.arguments.toString();
                razorpayDelegate.setupUpiPin(razorpayDelegate.getCard(cardStr), result, this.eventSink);
                break;
            case "isTurboPluginAvailable":
                razorpayDelegate.isTurboPluginAvailable(result, this.eventSink);
                break;
        /*
           Turbo TPV
         */
            case "linkNewUpiAccountTPVWithUI":
                _arguments = call.arguments();
                String customerId = (String) _arguments.get("customerId");
                customerMobile = (String) _arguments.get("customerMobile");
                orderId = (String) _arguments.get("orderId");
                tpvBankAccount = (String) _arguments.get("tpvBankAccount");
                razorpayDelegate.linkNewUpiAccount(customerMobile, customerId, orderId, tpvBankAccount, result, this.eventSink);
                break;

            case "linkNewUpiAccountWithUI":
                _arguments = call.arguments();
                customerMobile = (String) _arguments.get("customerMobile");
                String color = (String) _arguments.get("color");
                razorpayDelegate.linkNewUpiAccountWithUI(customerMobile, color, result, this.eventSink);
                break;

            case "manageUpiAccounts":
                customerMobile = call.arguments.toString();
                razorpayDelegate.manageUpiAccounts(customerMobile, result, this.eventSink);
                break;

            case "prefetchAndLinkUpiAccountsWithUI":
                _arguments = call.arguments();
                customerMobile = (String) _arguments.get("customerMobile");
                String colorPrefetch = "#000000";
                try {
                    colorPrefetch = (String) _arguments.get("color");
                    if (colorPrefetch.isEmpty() && colorPrefetch.isBlank()) {
                        colorPrefetch = "#000000";
                    }

                } catch (Exception exception) {
                    colorPrefetch = "#000000";
                }
                razorpayDelegate.prefetchAndLinkNewUpiAccountUI(customerMobile, colorPrefetch, result, this.eventSink);
                break;

            case "setPrefetchUPIPinWithUI":
                bankAccountStr = call.arguments().toString();
                razorpayDelegate.setPrefetchUPIPinWithUI(bankAccountStr, result, eventSink);
                break;

            case "refreshSessionToken":
                String newToken = call.arguments().toString();
                razorpayDelegate.updateToken(newToken);

            default:
                Log.d(TAG, "no method");
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
        this.eventChannel.setStreamHandler(null);
    }

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    public RazorpayPlugin(Registrar registrar) {
        this.activity = registrar.activity();
        this.razorpayDelegate = new RazorpayDelegate(registrar.activity());
        registrar.addActivityResultListener(razorpayDelegate);
    }

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    @Override
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        this.activity = activityPluginBinding.getActivity();
        this.razorpayDelegate = new RazorpayDelegate(activityPluginBinding.getActivity());
        this.pluginBinding = activityPluginBinding;
        activityPluginBinding.addActivityResultListener(razorpayDelegate);
        permissionResultListener = new PluginRegistry.RequestPermissionsResultListener() {
            @Override
            public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
                razorpayDelegate.handlePermissionResult(requestCode, permissions, grantResults);
                return false;
            }
        };
        activityPluginBinding.addRequestPermissionsResultListener(permissionResultListener);

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

    // Turbo UPI

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.eventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        this.eventSink = null;
    }

}
