package com.razorpay.flutter_customui;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import com.razorpay.PaymentData;
import com.razorpay.PaymentResultWithDataListener;
import com.razorpay.Razorpay;
import java.util.Map;
import org.json.JSONObject;

public class RazorpayPaymentActivity
    extends Activity
    implements PaymentResultWithDataListener
{

    private Razorpay razorpay;
    private WebView webview;
    private static final String TAG =
        RazorpayPaymentActivity.class.getSimpleName();
    private JSONObject payload;
    private boolean paymentSubmitted = false;

    private boolean paymentAlreadySubmitted = false;
    public static final int RZP_REQUEST_CODE = 62442;
    public static final int RZP_RESULT_CODE = 62443;
    public static final int RZP_USER_BACK_PRESSED_ERROR_CODE = 5;
    public static final int RZP_UNKNOWN_ERROR_CODE = 6;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d("flutter","onCreate triggered");
        if (savedInstanceState != null) {
            String optionsString = savedInstanceState.getString(
                Constants.OPTIONS
            );
            if (optionsString != null) {
                try {
                    payload = new JSONObject(optionsString);
                } catch (Exception e) {
                    Log.e(TAG, "Error parsing saved state", e);
                }
            }
        }

        if (payload == null) {
            Bundle extras = this.getIntent().getExtras();
            if (extras == null) {
                returnErrorCallback(
                    RZP_UNKNOWN_ERROR_CODE,
                    "Payment options missing.",
                    new PaymentData()
                );
                return;
            }
            String optionsString = extras.getString(Constants.OPTIONS);
            try {
                payload = new JSONObject(optionsString);
            } catch (Exception e) {
                Log.e(TAG, "Error parsing options", e);
                returnErrorCallback(
                    RZP_UNKNOWN_ERROR_CODE,
                    "Invalid payment options.",
                    new PaymentData()
                );
                return;
            }
        }

        initRazorpay();
        createWebView();

        paymentAlreadySubmitted =
            savedInstanceState != null &&
            savedInstanceState.getBoolean("paymentSubmitted", false);
//        boolean intentExtrasMissing = this.getIntent().getExtras() == null;

        // Skip re-submitting if this is a recreation after process death during a UPI intent
        // (paymentAlreadySubmitted=true and intentExtrasMissing=true).
        // Otherwise proceed normally (fresh launch or config change like rotation).
        if (paymentAlreadySubmitted /*&& intentExtrasMissing*/) {
            return;
        }
        sendRequest();

    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        Log.d("flutter","onSaveInstanceState triggered");
        super.onSaveInstanceState(outState);
        if (payload != null) {
            outState.putString(Constants.OPTIONS, payload.toString());
        }
        outState.putBoolean("paymentSubmitted", paymentSubmitted);
    }

    private String getAndRemoveKeyFromOptions(JSONObject payload) {
        try {
            if (payload.has(Constants.KEY_ID)) {
                String key = payload.getString(Constants.KEY_ID);
                payload.remove(Constants.KEY_ID);
                return key;
            }
        } catch (Exception e) {}
        return null;
    }

    private void initRazorpay() {
        String key = getAndRemoveKeyFromOptions(payload);
        if (key == null) {
            razorpay = new Razorpay(this);
        } else {
            razorpay = new Razorpay(this, key);
        }
    }

    private void createWebView() {
        /**
         * Creating webview and adding it to rootview
         */
        ViewGroup rootview = (ViewGroup) this.findViewById(
            android.R.id.content
        );
        webview = new WebView(this);
        webview.setScrollContainer(false);
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
            RelativeLayout.LayoutParams.FILL_PARENT,
            RelativeLayout.LayoutParams.FILL_PARENT
        );
        webview.setLayoutParams(params);
        rootview.addView(webview);
        razorpay.setWebView(webview);
    }

    private void sendRequest() {
        paymentSubmitted = true;
        try {
            razorpay.submit(payload, RazorpayPaymentActivity.this);
        } catch (Exception e) {
            Log.e(TAG, "Failed to submit.", e);
            returnErrorCallback(
                RZP_UNKNOWN_ERROR_CODE,
                "Failed to submit.",
                new PaymentData()
            );
        }
    }

    @Override
    public void onBackPressed() {
        new AlertDialog.Builder(this)
            .setMessage(Constants.BACK_ALERT_MESSAGE)
            .setPositiveButton(
                "No",
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface arg0, int arg1) {}
                }
            )
            .setNegativeButton(
                "Yes",
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface arg0, int arg1) {
                        if (razorpay != null) {
                            razorpay.onBackPressed();
                        } else {
                            returnErrorCallback(
                                RZP_USER_BACK_PRESSED_ERROR_CODE,
                                "User pressed back button",
                                new PaymentData()
                            );
                        }
                    }
                }
            )
            .show();
    }

    /* callback for permission requested from android */
    @Override
    public void onRequestPermissionsResult(
        int requestCode,
        String[] permissions,
        int[] grantResults
    ) {
        if (razorpay != null) {
            razorpay.onRequestPermissionsResult(
                requestCode,
                permissions,
                grantResults
            );
        }
    }

    @Override
    protected void onActivityResult(
        int requestCode,
        int resultCode,
        Intent data
    ) {
        super.onActivityResult(requestCode, resultCode, data);
        if (razorpay != null) {
            if(paymentAlreadySubmitted && data == null){
                razorpay.onActivityResult(requestCode, resultCode, data, true);
            }else{
                razorpay.onActivityResult(requestCode, resultCode, data);
            }

        }
    }

    @Override
    public void onPaymentSuccess(
        String razorpayPaymentId,
        PaymentData paymentData
    ) {
        returnSuccessCallback(razorpayPaymentId, paymentData);
    }

    @Override
    public void onPaymentError(
        int errorCode,
        String errorDescription,
        PaymentData paymentData
    ) {
        returnErrorCallback(errorCode, errorDescription, paymentData);
    }

    private void returnSuccessCallback(
        String razorpayPaymentId,
        PaymentData paymentData
    ) {
        Intent returnIntent = new Intent();
        returnIntent.putExtra(Constants.IS_SUCCESS, true);
        returnIntent.putExtra(Constants.PAYMENT_ID, razorpayPaymentId);
        returnIntent.putExtra(
            Constants.PAYMENT_DATA,
            paymentData.getData().toString()
        );
        this.setResult(RZP_RESULT_CODE, returnIntent);
        this.finish();
    }

    private void returnErrorCallback(
        int errorCode,
        String errorDescription,
        PaymentData paymentData
    ) {
        Intent returnIntent = new Intent();
        returnIntent.putExtra(Constants.IS_SUCCESS, false);
        returnIntent.putExtra(Constants.ERROR_CODE, errorCode);
        returnIntent.putExtra(Constants.ERROR_MESSAGE, errorDescription);
        returnIntent.putExtra(
            Constants.PAYMENT_DATA,
            paymentData.getData().toString()
        );
        this.setResult(RZP_RESULT_CODE, returnIntent);
        this.finish();
    }
}
