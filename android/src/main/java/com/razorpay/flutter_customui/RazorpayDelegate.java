package com.razorpay.flutter_customui;


import android.app.Activity;
import android.content.Intent;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import java.util.ArrayList;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.reflect.TypeToken;
import com.razorpay.ApplicationDetails;
import com.razorpay.PaymentMethodsCallback;
import com.razorpay.Razorpay;
import com.razorpay.RzpUpiSupportedAppsCallback;
import com.razorpay.SubscriptionAmountCallback;
import com.razorpay.UpiTurboLinkAccountListener;
import com.razorpay.UpiTurboLinkAccountResultListener;
import com.razorpay.UpiTurboLinkAction;
import com.razorpay.UpiTurboManageAccountListener;
import com.razorpay.UpiTurboResultListener;
import com.razorpay.UpiTurboTpvLinkAccountListener;
import com.razorpay.UpiTurboTpvLinkAction;
import com.razorpay.ValidateVpaCallback;
import com.razorpay.upi.AccountBalance;
import com.razorpay.upi.AccountCredentials;
import com.razorpay.upi.Atmpin;
import com.razorpay.UpiTurboSetPinResultListener;
import com.razorpay.ValidateVpaCallback;
import com.razorpay.upi.AccountBalance;
import com.razorpay.upi.BankAccount;
import com.razorpay.upi.UpiAccount;
import com.razorpay.upi.Bank;
import com.razorpay.upi.BankAccount;
import com.razorpay.upi.BankAccounts;
import com.razorpay.upi.Card;
import com.razorpay.upi.Empty;
import com.razorpay.upi.Error;
import com.razorpay.upi.Sim;
import com.razorpay.upi.Sms;
import com.razorpay.upi.TPVBankAccount;
import com.razorpay.upi.UpiAccount;
import com.razorpay.upi.Upipin;
import com.razorpay.upi.Vpa;

import org.jetbrains.annotations.Nullable;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Array;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;

import static com.razorpay.flutter_customui.Constants.PAYMENT_DATA;

import com.razorpay.UpiTurboPrefetchLinkAccountsResultListener;
import com.razorpay.upi.AllAccounts;

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

    final String TAG = "com.razorpay.flutter_customui.RazorpayDelegate";

    // Turbo UPI

    private UpiTurboLinkAction linkAction;
    private EventChannel.EventSink eventSink;

    private static final int CODE_EVENT_SUCCESS = 200;
    private static final int CODE_EVENT_ERROR = 201;

    private static final String LINK_NEW_UPI_ACCOUNT_EVENT = "linkNewUpiAccountEvent";
    private static final String LINK_NEW_UPI_ACCOUNT_TPV = "linkNewUpiAccountTPVWithUIEvent";
    private static final String LINK_PREFETCH_UPI_ACCOUNT_EVENT = "prefetchAndLinkNewUpiAccountUIEvent";
    private Handler uiThreadHandler = new Handler(Looper.getMainLooper());
    Gson gson ;

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    public RazorpayDelegate(Activity activity) {
        this.activity = activity;
        this.gson = new Gson();
    }

    void init(String key, Result result) {
        this.key = key;
        this.pendingResult = result;
        razorpay = new Razorpay(activity, key);
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
            init(this.key, result);
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
                HashMap<Object, Object> hMap = new HashMap<>();
                for (int i = 0; i < list.size(); i++) {
                    hMap.put(list.get(i).getPackageName(), list.get(i).getAppName());
                }
                pendingResult.success(hMap);
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
            reply.put("data", data);
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
        if (requestCode == RazorpayPaymentActivity.RZP_REQUEST_CODE && resultCode == RazorpayPaymentActivity.RZP_RESULT_CODE) {
            onLocalActivityResult(requestCode, resultCode, data);
        }
        return true;
    }

    void onLocalActivityResult(int requestCode, int resultCode, Intent data) {
        String paymentDataString = data.getStringExtra(PAYMENT_DATA);
        JSONObject paymentData = new JSONObject();
        try {
            paymentData = new JSONObject(paymentDataString);
        } catch (Exception e) {
        }
        if (data.getBooleanExtra(Constants.IS_SUCCESS, false)) {
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


    // Turbo Custom Flutter Wrapper Integrations
    /*
         OnBoarding Flow Turbo UPI
     */
    void linkNewUpiAccount(String mobileNumber, Result result, EventChannel.EventSink eventSink) {
        this.pendingResult = result;
        this.eventSink = eventSink;
        razorpay.upiTurbo.linkNewUpiAccount(mobileNumber, new UpiTurboLinkAccountListener() {
            @Override
            public void onResponse(@NonNull UpiTurboLinkAction upiTurboLinkAction) {
                onUpiTurboResponse(upiTurboLinkAction);
            }
        });
    }

    void askForPermission(Result result, EventChannel.EventSink eventSink) {
        this.pendingResult = result;
        this.eventSink = eventSink;
        if (linkAction != null) {
            linkAction.requestPermission();
        }
    }

    private void requestPermissionsManually(String[] permissionArray) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            activity.requestPermissions(permissionArray, 4001);
        }
    }

    void register(String simStr, Result result, EventChannel.EventSink eventSink) {
        this.pendingResult = result;
        this.eventSink = eventSink;
        if (this.linkAction != null) {
            this.linkAction.selectedSim(getSim(simStr));
        }
    }

    public void getBankAccounts(String bankStr, Result result, EventChannel.EventSink eventSink) {
        this.pendingResult = result;
        this.eventSink = eventSink;
        if (linkAction != null) {
            linkAction.selectedBank(getBank(bankStr));
        }
    }

    public void selectedBankAccount(com.razorpay.upi.BankAccount bankAccount, Result result,
                                    EventChannel.EventSink eventSink) {
        this.pendingResult = result;
        this.eventSink = eventSink;
        if (this.linkAction != null) {
            this.linkAction.selectedBankAccount(bankAccount);
        }
    }

    public void setupUpiPin(Card card, Result result, EventChannel.EventSink eventSink) {
        this.pendingResult = result;
        this.eventSink = eventSink;
        if (this.linkAction != null) {
            this.linkAction.setupUpiPin(card);
        }
    }

    private Bank getBank(String bankStr) {
        Type listType = new TypeToken<Bank>() {
        }.getType();
        return this.gson.fromJson(bankStr, listType);
    }

    public Sim getSim(String simStr) {
        Type listType = new TypeToken<Sim>() {
        }.getType();
        return this.gson.fromJson(simStr, listType);
    }

    public com.razorpay.upi.BankAccount getBankAccount(String bankAccountStr) {
        Type listType = new TypeToken<com.razorpay.upi.BankAccount>() {
        }.getType();
        return this.gson.fromJson(bankAccountStr, listType);
    }

    /*
       Non-transactional Flow Turbo UPI
     */

    void getLinkedUpiAccounts(String mobileNumber, Result result, EventChannel.EventSink eventSink) {
        this.pendingResult = result;
        this.eventSink = eventSink;
        HashMap<Object, Object> reply = new HashMap<>();
        razorpay.upiTurbo.getLinkedUpiAccounts(mobileNumber, new UpiTurboResultListener() {
            @Override
            public void onSuccess(@NonNull List<UpiAccount> upiAccounts) {
                if (upiAccounts.isEmpty()) {
                    reply.put("data", "");
                } else {
                    reply.put("data", toJsonString(upiAccounts));
                }
                sendReply(reply);
            }

            @Override
            public void onError(@NonNull Error error) {
                pendingResult.error(error.getErrorCode(), error.getErrorDescription(), toJsonString(error));
            }
        });


    }

    public void getBalance(UpiAccount upiAccount, Result result, EventChannel.EventSink eventSink) {
        this.pendingResult = result;
        this.eventSink = eventSink;
        HashMap<Object, Object> reply = getNonTransactionalReply();
        razorpay.upiTurbo.getBalance(upiAccount, new com.razorpay.upi.Callback<AccountBalance>() {
            @Override
            public void onSuccess(AccountBalance accountBalance) {
                reply.put("data", toJsonString(accountBalance));
                sendReply(reply);
            }

            @Override
            public void onFailure(@NonNull Error error) {
                pendingResult.error(error.getErrorCode(), error.getErrorDescription(), toJsonString(error));
            }
        });
    }

    public void changeUpiPin(UpiAccount upiAccount, Result result, EventChannel.EventSink eventSink) {
        this.pendingResult = result;
        this.eventSink = eventSink;
        HashMap<Object, Object> reply = getNonTransactionalReply();
        razorpay.upiTurbo.changeUpiPin(upiAccount, new com.razorpay.upi.Callback<UpiAccount>() {
            @Override
            public void onSuccess(UpiAccount upiAccount) {
                reply.put("data", toJsonString(upiAccount));
                sendReply(reply);
            }

            @Override
            public void onFailure(@NonNull Error error) {
                pendingResult.error(error.getErrorCode(), error.getErrorDescription(), toJsonString(error));
            }
        });
    }

    public void resetUpiPin(UpiAccount upiAccount, Card card, Result result, EventChannel.EventSink eventSink) {
        this.pendingResult = result;
        this.eventSink = eventSink;
        HashMap<Object, Object> reply = getNonTransactionalReply();
        razorpay.upiTurbo.resetUpiPin(card, upiAccount, new com.razorpay.upi.Callback<UpiAccount>() {
            @Override
            public void onSuccess(UpiAccount upiAccount) {
                reply.put("data", toJsonString(upiAccount));
                sendReply(reply);
            }

            @Override
            public void onFailure(@NonNull Error error) {
                pendingResult.error(error.getErrorCode(), error.getErrorDescription(), toJsonString(error));
            }
        });
    }

    public void delink(UpiAccount upiAccount, Result result, EventChannel.EventSink eventSink) {
        this.pendingResult = result;
        this.eventSink = eventSink;
        HashMap<Object, Object> reply = getNonTransactionalReply();
        razorpay.upiTurbo.delink(upiAccount, new com.razorpay.upi.Callback<Empty>() {
            @Override
            public void onSuccess(Empty empty) {
                reply.put("data", "Successfully delink your account");
                sendReply(reply);
            }

            @Override
            public void onFailure(@NonNull Error error) {
                pendingResult.error(error.getErrorCode(), error.getErrorDescription(), toJsonString(error));
            }
        });
    }

    public static UpiAccount getUpiAccount(String upiAccountStr) {
        Type listType = new TypeToken<UpiAccount>() {
        }.getType();
        return new Gson().fromJson(upiAccountStr, listType);
    }

    public Card getCard(String cardStr) {
        Type listType = new TypeToken<Card>() {
        }.getType();
        return this.gson.fromJson(cardStr, listType);
    }

    public static HashMap<Object, Object> getNonTransactionalReply() {
        HashMap<Object, Object> reply = new HashMap<>();
        return reply;
    }

    public void onUpiTurboResponse(@NonNull UpiTurboLinkAction upiTurboLinkAction) {
        HashMap<Object, Object> reply = new HashMap<>();
        this.linkAction = upiTurboLinkAction;
        reply.put("responseEvent", LINK_NEW_UPI_ACCOUNT_EVENT);
        reply.put("action", upiTurboLinkAction.name());
        if (upiTurboLinkAction.getError() != null) {
            onEventError(reply, this.gson.toJson(upiTurboLinkAction.getError()));
            return;
        }
        switch (upiTurboLinkAction) {
            case ASK_FOR_PERMISSION:
                /*
                   Callback is not coming from upiTurboLinkAction.requestPermission(); .
                   Created manual function for ask permission adn handle it by PluginRegistry.RequestPermissionsResultListener()
                */
                reply.put("data", "");
                onEventSuccess(reply);
                break;
            case SHOW_PERMISSION_ERROR:
                break;
            case SELECT_SIM:
                reply.put("data", toJsonString(upiTurboLinkAction.getData()));
                onEventSuccess(reply);
                break;
            case SELECT_BANK:
                reply.put("data", toJsonString(upiTurboLinkAction.getData()));
                onEventSuccess(reply);
                break;
            case SELECT_BANK_ACCOUNT:
                reply.put("data", toJsonString(upiTurboLinkAction.getData()));
                onEventSuccess(reply);
                break;
            case SETUP_UPI_PIN:
                reply.put("data", "SETUP_UPI_PIN");
                onEventSuccess(reply);
                break;
            case STATUS:
                reply.put("data", toJsonString(upiTurboLinkAction.getData()));
                onEventSuccess(reply);
                break;
            case LOADER_DATA:
                reply.put("data", "");
                onEventSuccess(reply);
                break;
        }
    }

    private void sendReplyByEventSink(HashMap<Object, Object> reply) {
        uiThreadHandler.post(new Runnable() {
            @Override
            public void run() {
                RazorpayDelegate.this.eventSink.success(reply);
            }
        });
    }

    public void onEventSuccess(HashMap<Object, Object> reply) {
        reply.put("type", CODE_EVENT_SUCCESS);
        Log.e("Reply data", "Reply " + reply);
        sendReplyByEventSink(reply);
    }

    public void onEventError(HashMap<Object, Object> reply, String error) {
        reply.put("type", CODE_EVENT_ERROR);
        reply.put("error", error);
        sendReplyByEventSink(reply);
    }

    private String toJsonString(Object object) {
        return this.gson.toJson(object);
    }

    public JSONObject toJSONObject(Object object) {
        try {
            return new JSONObject(toJsonString(object));
        } catch (Exception exception) {
            return new JSONObject();
        }
    }

    public void handlePermissionResult(int requestCode, String[] permissions, int[] grantResults) {
        razorpay.upiTurbo.onPermissionsRequestResult();
    }

    public boolean isTurboPluginAvailable(Result result, EventChannel.EventSink eventSink) {
        this.pendingResult = result;
        this.eventSink = eventSink;
        HashMap<Object, Object> reply = new HashMap<>();
        try {
            Class.forName("com.razorpay.RzpTurboExternalPlugin");
            Class.forName("com.razorpay.UpiTurboLinkAccountListener");
            reply.put("isTurboPluginAvailable", true);
            sendReply(reply);
            return true;
        } catch (ClassNotFoundException e) {
            // Class not found, so it doesn't exist
            reply.put("isTurboPluginAvailable", false);
            sendReply(reply);
            return false;
        }
    }

    /*
         HeadLess TPV
     */

    public void linkNewUpiAccount(String customerMobile, String customerId, String orderId, String tpvBankAccountStr, Result result,
                                  EventChannel.EventSink eventSink) {
        this.pendingResult = result;
        this.eventSink = eventSink;
        razorpay.upiTurbo.getTPV();

       razorpay.upiTurbo.getTPV()
               .setOrderId(orderId)
               .setCustomerMobile(customerMobile)
               .setTpvBankAccount(getTPVBankAccount(tpvBankAccountStr))
               .setCustomerId(customerId)
               .linkNewUpiAccount(new UpiTurboLinkAccountResultListener(){
                   @Override
                   public void onSuccess(@NonNull List<UpiAccount> list) {
                       HashMap<Object, Object> reply = new HashMap<>();
                       reply.put("responseEvent", LINK_NEW_UPI_ACCOUNT_TPV);
                       reply.put("data", toJsonString(list));
                       onEventSuccess(reply);
                   }

                   @Override
                   public void onError(@NonNull Error error) {
                       HashMap<Object, Object> reply = new HashMap<>();
                       reply.put("responseEvent", LINK_NEW_UPI_ACCOUNT_TPV);
                       onEventError(reply, new Gson().toJson(error));
                   }
               });


    }

    public TPVBankAccount getTPVBankAccount(String tPVBankAccountStr) {
        if (tPVBankAccountStr == null) {
            return null;
        }
        Type listType = new TypeToken<TPVBankAccount>() {
        }.getType();
        return new Gson().fromJson(tPVBankAccountStr, listType);
    }

    /*
        UPI Turbo with custom UI (by checkout)
     */
    public void linkNewUpiAccountWithUI(String customerMobile, String color, Result result, EventChannel.EventSink eventSink) {
        this.pendingResult = result;
        this.eventSink = eventSink;
        HashMap<Object, Object> reply = new HashMap<>();
        razorpay.upiTurbo.linkNewUpiAccountWithUI(customerMobile, new UpiTurboLinkAccountResultListener() {
            @Override
            public void onSuccess(List<UpiAccount> upiAccounts) {
                if (upiAccounts.isEmpty()) {
                    reply.put("data", "");
                } else {
                    reply.put("data", toJsonString(upiAccounts));
                }
                sendReply(reply);
            }

            @Override
            public void onError(@NonNull Error error) {
                pendingResult.error(error.getErrorCode(), error.getErrorDescription(), toJsonString(error));
            }
        }, color);
    }

    public void prefetchAndLinkNewUpiAccountUI(String customerMobile, String color, Result result, EventChannel.EventSink eventSink) {
        try {
            this.pendingResult = result;
            this.eventSink = eventSink;
            razorpay.upiTurbo
                    .setCustomerMobile(customerMobile)
                    .setColor(color)
                    .prefetchAndLinkUpiAccountsWithUI(new UpiTurboPrefetchLinkAccountsResultListener() {
                        @Override
                        public void onResponse(AllAccounts allAccounts) {
                            List<BankAccount> pinNotSetArr = new ArrayList<>();
                            List<Object> pinSetArr = new ArrayList<>();

                            if (allAccounts.getAccountsWithPinNotSet() != null) {
                                for (BankAccount account : allAccounts.getAccountsWithPinNotSet()) {
                                    pinNotSetArr.add(account);
                                }
                            }

                            if (allAccounts.getAccountsWithPinSet() != null) {
                                try {
                                    pinSetArr.addAll(allAccounts.getAccountsWithPinSet());
                                } catch (Exception e) {
                                    Log.e("Exception Occurred", "Pin-set account parsing Exception");
                                }
                            }


                            Map<String, Object> finalDict = new HashMap<>();
                            finalDict.put("accountsWithPinNotSet", pinNotSetArr);
                            finalDict.put("accountsWithPinSet", pinSetArr);

                            String finalDictStr = new Gson().toJson(finalDict);
                            if (finalDictStr != null) {
                                HashMap<Object, Object> reply = new HashMap<>();
                                reply.put("responseEvent", LINK_PREFETCH_UPI_ACCOUNT_EVENT);
                                reply.put("data", finalDictStr);
                                onEventSuccess(reply);
                            }
                        }

                        public void onError(Error error) {
                            HashMap<Object, Object> reply = new HashMap<>();
                            reply.put("responseEvent", LINK_PREFETCH_UPI_ACCOUNT_EVENT);
                            onEventError(reply, new Gson().toJson(error));

                        }
                    });
        } catch (Exception exception) {
            pendingResult.error(exception.toString(), exception.toString(), exception);
        }
    }

    public void setPrefetchUPIPinWithUI(String bankAccountString, Result result, EventChannel.EventSink eventSink) {
        this.pendingResult = result;
        this.eventSink = eventSink;
        BankAccount bankAccount = getBankAccount(bankAccountString);
        if (bankAccount != null) {
            razorpay
                    .upiTurbo
                    .setUpiPinWithUI(bankAccount, new UpiTurboSetPinResultListener() {
                        @Override
                        public void onSuccess(@NonNull UpiAccount upiAccount) {
                            HashMap<Object, Object> reply = new HashMap<>();
                            reply.put("responseEvent", LINK_PREFETCH_UPI_ACCOUNT_EVENT);
                            if (upiAccount != null) {
                                List<UpiAccount> upiAccounts = new ArrayList();
                                upiAccounts.add(upiAccount);
                                reply.put("data", toJsonString(upiAccounts));
                            } else {
                                reply.put("data", "");
                            }
                            sendReply(reply);

                        }

                        @Override
                        public void onError(@NonNull Error error) {
                            HashMap<Object, Object> reply = new HashMap<>();
                            reply.put("responseEvent", LINK_PREFETCH_UPI_ACCOUNT_EVENT);
                            onEventError(reply, new Gson().toJson(error));
                        }
                    });
        }

    }


    public void manageUpiAccounts(String customerMobile, Result result, EventChannel.EventSink eventSink) {
        this.pendingResult = result;
        this.eventSink = eventSink;
        razorpay.upiTurbo.manageUpiAccounts(customerMobile, new UpiTurboManageAccountListener() {
            @Override
            public void onError(@NonNull JSONObject jsonObject) {
                pendingResult.error("", jsonObject.toString(), jsonObject.toString());
            }
        });

    }
}
