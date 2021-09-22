package com.razorpay.flutter_customui;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Build;
import android.util.Log;
import android.view.View;
import android.webkit.WebView;
import android.widget.RelativeLayout;


import androidx.annotation.RequiresApi;

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

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;

public class RazorpayDelegate implements ActivityResultListener, PaymentResultWithDataListener {

    private Activity activity;
    private Result pendingResult;
    private Map<String, Object> pendingReply;
    private Razorpay razorpay;
    private String key;

    // Response codes for communicating with plugin
    private static final int CODE_PAYMENT_SUCCESS = 0;
    private static final int CODE_PAYMENT_ERROR = 1;
    private static final int CODE_PAYMENT_EXTERNAL_WALLET = 2;

    // Payment error codes for communicating with plugin
    private static final int NETWORK_ERROR = 0;
    private static final int INVALID_OPTIONS = 1;
    private static final int PAYMENT_CANCELLED = 2;
    private static final int TLS_ERROR = 3;
    private static final int INCOMPATIBLE_PLUGIN = 3;
    private static final int UNKNOWN_ERROR = 100;
    private WebView webview;


    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    public RazorpayDelegate(Activity activity, String key) {
        this.activity = activity;
        this.key = key;
        razorpay = new Razorpay(activity, key);

        final RelativeLayout layout = new RelativeLayout(activity);

        final RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
                activity.getWindowManager().getDefaultDisplay().getWidth(),
                activity.getWindowManager().getDefaultDisplay().getHeight());

        layout.setLayoutParams(params);

        activity.setContentView(layout);
        webview = new WebView(activity);
        webview.getSettings().setJavaScriptEnabled(true);
        RelativeLayout.LayoutParams webViewParams = new RelativeLayout.LayoutParams(
                new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT));
        webViewParams.addRule(RelativeLayout.ABOVE);
    }

    public RazorpayDelegate(Activity activity) {
        razorpay = new Razorpay(activity);
    }

    void submit(JSONObject payload) {
        try {
            razorpay.submit(payload, this);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    void callNativeIntent(String value) {
        razorpay.callNativeIntent(value);
    }

    void changeApiKey(String value) {
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

    void getPaymentMethods() {
        razorpay.getPaymentMethods(new PaymentMethodsCallback() {
            @Override
            public void onPaymentMethodsReceived(String s) {
                pendingResult.success(s);
            }

            @Override
            public void onError(String s) {
                pendingResult.error(s, "", null);
            }
        });
    }

    void getAppsWhichSupportUpi() {
        Razorpay.getAppsWhichSupportUpi(activity, new RzpUpiSupportedAppsCallback() {
            @Override
            public void onReceiveUpiSupportedApps(List<ApplicationDetails> list) {
                pendingResult.success(list);
            }
        });
    }

    void getSubscriptionAmount(String value) {
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

    void getWalletLogoUrl(String value) {
        pendingResult.success(razorpay.getWalletLogoUrl(value));
    }

    void isValidCardNumber(String value) {
        pendingResult.success(razorpay.isValidCardNumber(value));
    }

    void isValidVpa(String value) {
        razorpay.isValidVpa(value, new ValidateVpaCallback() {
            @Override
            public void onResponse(boolean b) {
                pendingResult.success(b);
            }

            @Override
            public void onFailure() {
                pendingResult.error("error", "", null);
            }
        });
    }

    /*void openCheckout(Map<String, Object> arguments, Result result) {

        this.pendingResult = result;

        JSONObject options = new JSONObject(arguments);

        Intent intent = new Intent(activity, CheckoutActivity.class);
        intent.putExtra("OPTIONS", options.toString());
        intent.putExtra("FRAMEWORK", "flutter");

        activity.startActivityForResult(intent, Checkout.RZP_REQUEST_CODE);

    }*/

    private void sendReply(Map<String, Object> data) {
        if (pendingResult != null) {
            pendingResult.success(data);
            pendingReply = null;
        } else {
            pendingReply = data;
        }
    }

    public void validateFields(JSONObject value) {
        razorpay.validateFields(value, new ValidationListener() {
            @Override
            public void onValidationSuccess() {
                webview.setVisibility(View.VISIBLE);
                pendingResult.success("success");
            }

            @Override
            public void onValidationError(Map<String, String> map) {
                pendingResult.error("error","",null);
            }
        });
    }

    public void resync(Result result) {
        result.success(pendingReply);
        pendingReply = null;
    }

    public void setPaymentID(String value) {
        razorpay.setPaymentID(value);
    }

    public void setWebView(WebView value) {
        razorpay.setWebView(value);
    }

    /*private static int translateRzpPaymentError(int errorCode) {
        switch (errorCode) {
            case Checkout.NETWORK_ERROR:
                return NETWORK_ERROR;
            case Checkout.INVALID_OPTIONS:
                return INVALID_OPTIONS;
            case Checkout.PAYMENT_CANCELED:
                return PAYMENT_CANCELLED;
            case Checkout.TLS_ERROR:
                return TLS_ERROR;
            case Checkout.INCOMPATIBLE_PLUGIN:
                return INCOMPATIBLE_PLUGIN;
            default:
                return UNKNOWN_ERROR;
        }
    }*/

    @Override
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
    }

    @Override
    public boolean onActivityResult(int i, int i1, Intent intent) {
        razorpay.onActivityResult(i,i1,intent);
        return false;
    }

    /*@Override
    public void onBackPressed() {
        razorpay.onBackPressed();
        super.onBackPressed();
        //webview.setVisibility(View.GONE);
        //outerBox.setVisibility(View.VISIBLE);
    }*/


    /*@Override
    public void onExternalWalletSelected(String walletName, PaymentData paymentData) {
        Map<String, Object> reply = new HashMap<>();
        reply.put("type", CODE_PAYMENT_EXTERNAL_WALLET);

        Map<String, Object> data = new HashMap<>();
        data.put("external_wallet", walletName);
        reply.put("data", data);

        sendReply(reply);
    }*/

}
