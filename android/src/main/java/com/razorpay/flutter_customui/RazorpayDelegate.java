package com.razorpay.flutter_customui;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Build;
import android.util.Log;
import android.view.View;
import android.webkit.WebView;
import android.widget.RelativeLayout;
import android.widget.Toast;


import androidx.annotation.RequiresApi;

import com.google.gson.Gson;
import com.razorpay.ApplicationDetails;
import com.razorpay.PaymentData;
//import com.razorpay.PaymentMethodsCallback;

import com.razorpay.PaymentMethodsCallback;
import com.razorpay.PaymentResultWithDataListener;
import com.razorpay.Razorpay;
import com.razorpay.RazorpayWebViewClient;
import com.razorpay.RzpUpiSupportedAppsCallback;

import com.razorpay.SubscriptionAmountCallback;
import com.razorpay.ValidateVpaCallback;
import com.razorpay.ValidationListener;


import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;

import static com.razorpay.flutter_customui.Constants.PAYMENT_DATA;

public class RazorpayDelegate implements ActivityResultListener {

    private Activity activity;
    private Result pendingResult;
    private Map<Object, Object> pendingReply;
    private Razorpay razorpay;
    private String key;

    private static final int CODE_PAYMENT_SUCCESS = 0;
    private static final int CODE_PAYMENT_ERROR = 1;

    // Payment error codes for communicating with plugin
    private static final int NETWORK_ERROR = 2;
    private static final int INVALID_OPTIONS = 3;
    private static final int PAYMENT_CANCELLED = 0;
    private static final int TLS_ERROR = 6;
    private static final int UNKNOWN_ERROR = 100;


    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    public RazorpayDelegate(Activity activity) {
        this.activity = activity;
    }

    void init(String key, Result result) {
        this.key = key;
        this.pendingResult = result;
        razorpay = new Razorpay(activity,key);
    }

    void submit(final JSONObject payload, Result result) {
        this.pendingResult = result;
        Intent intent = new Intent(activity, RazorpayPaymentActivity.class);
        intent.putExtra(Constants.OPTIONS, payload.toString());
        intent.putExtra("FRAMEWORK", "flutter");
        activity.startActivityForResult(intent, RazorpayPaymentActivity.RZP_REQUEST_CODE);
    }

    void callNativeIntent(String value, Result result) {
        this.pendingResult = result;
        razorpay.callNativeIntent(value);
    }

    void changeApiKey(String value, Result result) {
        this.pendingResult = result;
        razorpay.changeApiKey(value);
    }

    String getBankLogoUrl(String value) {
       return razorpay.getBankLogoUrl(value);
    }

    String getCardNetwork(String value) {
        return razorpay.getCardNetwork(value);
    }

    int getCardNetworkLength(String value) {
        return razorpay.getCardNetworkLength(value);
    }

    void getPaymentMethods(final Result result) {
        pendingResult = result;
        if (razorpay == null) {
            init(this.key,result);
        }
        razorpay.getPaymentMethods(new PaymentMethodsCallback() {
            @Override
            public void onPaymentMethodsReceived(String s) {
                HashMap<String, Object> hMapData = new Gson().fromJson(s, HashMap.class);
                pendingResult.success(hMapData);
            }

            @Override
            public void onError(String s) {
                pendingResult.error(s, "", null);
            }
        });
    }

    void getAppsWhichSupportUpi(Result result) {
        this.pendingResult = result;
        Razorpay.getAppsWhichSupportUpi(activity, new RzpUpiSupportedAppsCallback() {
            @Override
            public void onReceiveUpiSupportedApps(List<ApplicationDetails> list) {
                List< HashMap<String, String>> itemList = new ArrayList<>();

                for (int i=0;i<list.size();i++) {
                    HashMap<String, String> appInfo = new HashMap<>();
                    appInfo.put("appName", list.get(i).getAppName());
                    appInfo.put("appPackageName", list.get(i).getPackageName());
                    appInfo.put("appLogo", list.get(i).getAppLogoUrl());
                    itemList.add(appInfo);
                }
                pendingResult.success(itemList);
            }
        });
    }

    void getSubscriptionAmount(String value, Result result) {
        this.pendingResult = result;
        razorpay.getSubscriptionAmount(value, new SubscriptionAmountCallback() {
            @Override
            public void onSubscriptionAmountReceived(long l) {
                pendingResult.success(l);
            }

            @Override
            public void onError(String s) {
                pendingResult.error(s, "", null);
            }
        });
    }

    void getWalletLogoUrl(String value, Result result) {
        this.pendingResult = result;
        pendingResult.success(razorpay.getWalletLogoUrl(value));
    }

    void isValidCardNumber(String value, Result result) {
        this.pendingResult = result;
        pendingResult.success(razorpay.isValidCardNumber(value));
    }

    void isValidVpa(String value, Result result) {
        this.pendingResult = result;
        razorpay.isValidVpa(value, new ValidateVpaCallback() {
            @Override
            public void onResponse(JSONObject jsonObject) {
                HashMap<String, Object> hMapData = new Gson().fromJson(jsonObject.toString(), HashMap.class);
                pendingResult.success(hMapData);
            }

            @Override
            public void onFailure() {
                pendingResult.error("error", "", null);
            }
        });
    }

    private void sendReply(HashMap<Object, Object> data) {
        if (pendingResult != null) {
            pendingResult.success(data);
            pendingReply = null;
        } else {
            pendingReply = data;
        }
    }

    public void resync(Result result) {
        result.success(pendingReply);
        pendingReply = null;
    }

    public void setPaymentID(String value, Result result) {
        this.pendingResult = result;
        razorpay.setPaymentID(value);
    }



    /*@Override
    public void onPaymentError(int code, String message, PaymentData paymentData) {
        Map<String, Object> reply = new HashMap<>();
        reply.put("type", CODE_PAYMENT_ERROR);

        Map<String, Object> data = new HashMap<>();
        //data.put("code", translateRzpPaymentError(code));
        data.put("message", message);

        reply.put("data", data);

        sendReply(reply);
    }

    @Override
    public void onPaymentSuccess(String paymentId, PaymentData paymentData) {
        Map<String, Object> reply = new HashMap<>();
        reply.put("type", CODE_PAYMENT_SUCCESS);

        Map<String, Object> data = new HashMap<>();
        data.put("razorpay_payment_id", paymentData.getPaymentId());
        data.put("razorpay_order_id", paymentData.getOrderId());
        data.put("razorpay_signature", paymentData.getSignature());

        if (paymentData.getData().has("razorpay_subscription_id")) {
            try {
                data.put("razorpay_subscription_id", paymentData.getData().optString("razorpay_subscription_id"));
            } catch (Exception e) {
                e.printStackTrace();
            }
        }


        reply.put("data", data);
        sendReply(reply);
    }*/

    public void onPaymentSuccess(String razorpayPaymentId, JSONObject paymentData) {
        try {
            HashMap<Object, Object> reply = new HashMap<>();
            reply.put("type", CODE_PAYMENT_SUCCESS);

            HashMap<Object, Object> data = new HashMap<>();
            data.put("razorpay_payment_id", razorpayPaymentId);
            if (paymentData.has("razorpay_order_id")) {
                data.put("razorpay_order_id", paymentData.get("razorpay_order_id"));
            }
            if (paymentData.has("razorpay_subscription_id")) {
                data.put("razorpay_signature", paymentData.get("razorpay_subscription_id"));
            }
            if (paymentData.has("razorpay_signature")) {
                data.put("razorpay_signature", paymentData.optString("razorpay_signature"));
            }
            reply.put("data",data);
            sendReply(reply);
        } catch (JSONException e) {

        }
    }


    public void onPaymentError(int code, String description, JSONObject paymentDataJson) {
        HashMap<Object, Object> reply = new HashMap<>();
        reply.put("type", CODE_PAYMENT_ERROR);

        HashMap<Object, Object> data = new HashMap<>();
        data.put("code", translateRzpPaymentError(code));
        data.put("message", description);

        reply.put("data", data);

        sendReply(reply);
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if(requestCode == RazorpayPaymentActivity.RZP_REQUEST_CODE && resultCode == RazorpayPaymentActivity.RZP_RESULT_CODE){
            onLocalActivityResult(requestCode, resultCode, data);
        }
        return true;
    }

    void onLocalActivityResult(int requestCode, int resultCode, Intent data){
        String paymentDataString = data.getStringExtra(PAYMENT_DATA);
        JSONObject paymentData = new JSONObject();
        try{
            paymentData = new JSONObject(paymentDataString);
        } catch(Exception e){
        }
        if(data.getBooleanExtra(Constants.IS_SUCCESS, false)){
            String payment_id = data.getStringExtra(Constants.PAYMENT_ID);
            onPaymentSuccess(payment_id, paymentData);
        } else {
            int errorCode = data.getIntExtra(Constants.ERROR_CODE, 0);
            String errorMessage = data.getStringExtra(Constants.ERROR_MESSAGE);
            onPaymentError(errorCode, errorMessage, paymentData);
        }
    }

    private static int translateRzpPaymentError(int errorCode) {
        switch (errorCode) {
            case Razorpay.NETWORK_ERROR:
                return NETWORK_ERROR;
            case Razorpay.INVALID_OPTIONS:
                return INVALID_OPTIONS;
            case Razorpay.PAYMENT_CANCELED:
                return PAYMENT_CANCELLED;
            case Razorpay.TLS_ERROR:
                return TLS_ERROR;
            default:
                return UNKNOWN_ERROR;
        }
    }

    public void onNewIntent(Intent intent) {}

}
