package com.razorpay.flutter_customui;

import android.app.Activity;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.razorpay.Razorpay;
import com.razorpay.UpiTurboLinkAccountListener;
import com.razorpay.UpiTurboLinkAccountResultListener;
import com.razorpay.UpiTurboLinkAction;
import com.razorpay.UpiTurboManageAccountListener;
import com.razorpay.UpiTurboResultListener;
import com.razorpay.upi.AccountBalance;
import com.razorpay.upi.Bank;
import com.razorpay.upi.Card;
import com.razorpay.upi.Empty;
import com.razorpay.upi.Error;
import com.razorpay.upi.Sim;
import com.razorpay.upi.TPVBankAccount;
import com.razorpay.upi.UpiAccount;

import org.json.JSONObject;

import java.lang.reflect.Type;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class UpiTurbo {

    private UpiTurboLinkAction linkAction;
    private EventChannel.EventSink eventSink;
    private MethodChannel.Result pendingResult;
    private Map<Object, Object> pendingReply;
    private final Razorpay razorpay;
    private Activity activity;
    private static final int CODE_EVENT_SUCCESS = 200;
    private static final int CODE_EVENT_ERROR = 201;

    private static final String LINK_NEW_UPI_ACCOUNT_EVENT = "linkNewUpiAccountEvent";
    Gson gson ;
    private Handler uiThreadHandler = new Handler(Looper.getMainLooper());

    public UpiTurbo(Activity activity, Razorpay razorpay) {
        this.activity = activity;
        this.razorpay = razorpay;
        this.gson = new Gson();
    }

    /*
         OnBoarding Flow Turbo UPI
     */
    void linkNewUpiAccount(String mobileNumber, MethodChannel.Result result, EventChannel.EventSink eventSink){
        this.pendingResult = result;
        this.eventSink = eventSink;
        razorpay.upiTurbo.linkNewUpiAccount(mobileNumber, new UpiTurboLinkAccountListener() {
            @Override
            public void onResponse(@NonNull UpiTurboLinkAction upiTurboLinkAction) {
                onUpiTurboResponse(upiTurboLinkAction);
            }
        });
    }

    void askForPermission(MethodChannel.Result result, EventChannel.EventSink eventSink){
        this.pendingResult = result;
        this.eventSink = eventSink;
        if (linkAction !=null){
            linkAction.requestPermission();
        }
    }

    private void requestPermissionsManually(String[] permissionArray) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            activity.requestPermissions(permissionArray, 4001);
        }
    }

    void register(String simStr, MethodChannel.Result result, EventChannel.EventSink eventSink){
        this.pendingResult = result;
        this.eventSink = eventSink;
        if (this.linkAction !=null){
            this.linkAction.selectedSim(getSim(simStr));
        }
    }

    public void getBankAccounts(String bankStr, MethodChannel.Result result, EventChannel.EventSink eventSink) {
        this.pendingResult = result;
        this.eventSink = eventSink;
        if (linkAction !=null){
            linkAction.selectedBank(getBank(bankStr));
        }
    }

    public void selectedBankAccount(String bankAccountStr , MethodChannel.Result result,
                                    EventChannel.EventSink eventSink){
        this.pendingResult = result;
        this.eventSink = eventSink;
        if (this.linkAction !=null){
            this.linkAction.selectedBankAccount(getBankAccount(bankAccountStr));
        }
    }

    public void setupUpiPin(String cardStr, MethodChannel.Result result, EventChannel.EventSink eventSink){
        this.pendingResult = result;
        this.eventSink = eventSink;
        if (this.linkAction !=null){
            this.linkAction.setupUpiPin(getCard(cardStr));
        }
    }

    private Bank getBank(String bankStr) {
        Type listType = new TypeToken<Bank>() {}.getType();
        return this.gson.fromJson(bankStr, listType);
    }

    public Sim getSim(String simStr){
        Type listType = new TypeToken<Sim>() {}.getType();
        return this.gson.fromJson(simStr, listType);
    }

    public  com.razorpay.upi.BankAccount getBankAccount(String bankAccountStr){
        Type listType = new TypeToken<com.razorpay.upi.BankAccount>() {}.getType();
        return this.gson.fromJson(bankAccountStr, listType);
    }

    private void sendReply(HashMap<Object, Object> data) {
        if (pendingResult != null) {
            pendingResult.success(data);
            pendingReply = null;
        } else {
            pendingReply = data;
        }
    }

    /*
       Non-transactional Flow Turbo UPI
     */

    void getLinkedUpiAccounts(String mobileNumber, MethodChannel.Result result, EventChannel.EventSink eventSink){
        this.pendingResult = result;
        this.eventSink = eventSink;
        HashMap<Object, Object> reply = new HashMap<>();
        razorpay.upiTurbo.getLinkedUpiAccounts(mobileNumber, new UpiTurboResultListener() {
            @Override
            public void onSuccess(@NonNull List<UpiAccount> upiAccounts) {
                if(upiAccounts.isEmpty()){
                    reply.put("data", "");
                }else {
                    reply.put("data", toJsonString(upiAccounts));
                }
                sendReply(reply);
            }

            @Override
            public void onError(@NonNull Error error) {
                pendingResult.error(error.getErrorCode(), error.getErrorDescription() , toJsonString(error));
            }
        });
    }

    public void getBalance(String upiAccountStr , MethodChannel.Result result, EventChannel.EventSink eventSink){
        this.pendingResult = result;
        this.eventSink = eventSink;
        HashMap<Object, Object>  reply = getNonTransactionalReply();
        razorpay.upiTurbo.getBalance(getUpiAccount(upiAccountStr), new com.razorpay.upi.Callback<AccountBalance>() {
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

    public void changeUpiPin(String upiAccountStr, MethodChannel.Result result, EventChannel.EventSink eventSink){
        this.pendingResult = result;
        this.eventSink = eventSink;
        HashMap<Object, Object>  reply = getNonTransactionalReply();
        razorpay.upiTurbo.changeUpiPin(getUpiAccount(upiAccountStr), new com.razorpay.upi.Callback<UpiAccount>() {
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

    public void resetUpiPin(String upiAccount, String card , MethodChannel.Result result, EventChannel.EventSink eventSink){
        this.pendingResult = result;
        this.eventSink = eventSink;
        HashMap<Object, Object>  reply = getNonTransactionalReply();
        razorpay.upiTurbo.resetUpiPin(getCard(card), getUpiAccount(upiAccount), new com.razorpay.upi.Callback<UpiAccount>() {
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

    public void delink(String upiAccountStr , MethodChannel.Result result, EventChannel.EventSink eventSink){
        this.pendingResult = result;
        this.eventSink = eventSink;
        HashMap<Object, Object>  reply = getNonTransactionalReply();
        razorpay.upiTurbo.delink(getUpiAccount(upiAccountStr), new com.razorpay.upi.Callback<Empty>() {
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

    public static UpiAccount getUpiAccount(String upiAccountStr){
        Type listType = new TypeToken<UpiAccount>() {}.getType();
        return new Gson().fromJson(upiAccountStr, listType);
    }

    public Card getCard(String cardStr){
        Type listType = new TypeToken<Card>() {}.getType();
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
                reply.put("data",  toJsonString(upiTurboLinkAction.getData()));
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
                UpiTurbo.this.eventSink.success(reply);
            }
        });
    }

    public void onEventSuccess(HashMap<Object, Object> reply) {
        reply.put("type", CODE_EVENT_SUCCESS);
        sendReplyByEventSink(reply);
    }

    public void onEventError(HashMap<Object, Object> reply , String error) {
        reply.put("type", CODE_EVENT_ERROR);
        reply.put("error", error);
        sendReplyByEventSink(reply);
    }

    private String toJsonString(Object object){
        return this.gson.toJson(object);
    }

    public void handlePermissionResult(int requestCode, String[] permissions, int[] grantResults) {
        razorpay.upiTurbo.onPermissionsRequestResult();
    }

    public  boolean isTurboPluginAvailable(MethodChannel.Result result, EventChannel.EventSink eventSink) {
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

    public void linkNewUpiAccount(String customerMobile, String customerId, String  orderId , String tpvBankAccountStr , MethodChannel.Result result,
                                  EventChannel.EventSink eventSink){
        this.pendingResult = result;
        this.eventSink = eventSink;
        /*razorpay.upiTurbo.getTPV()
                .setOrderId(orderId)
                .setCustomerMobile(customerMobile)
                .setTpvBankAccount(getTPVBankAccount(tpvBankAccountStr))
                .setCustomerId(customerId)
                .linkNewUpiAccount( new UpiTurboLinkAccountListener() {
                    @Override
                    public void onResponse(@NonNull UpiTurboLinkAction upiTurboLinkAction) {
                        onUpiTurboResponse(upiTurboLinkAction);
                    }
                });*/
    }

    public TPVBankAccount getTPVBankAccount(String tPVBankAccountStr){
        if (tPVBankAccountStr == null){
            return  null;
        }
        Type listType = new TypeToken<TPVBankAccount>() {}.getType();
        return new Gson().fromJson(tPVBankAccountStr, listType);
    }

    /*
        UPI Turbo with custom UI (by checkout)
     */
    public void linkNewUpiAccountWithUI(String customerMobile, String color, MethodChannel.Result result, EventChannel.EventSink eventSink){
        this.pendingResult = result;
        this.eventSink = eventSink;
        HashMap<Object, Object> reply = new HashMap<>();
        razorpay.upiTurbo.linkNewUpiAccountWithUI(customerMobile, new UpiTurboLinkAccountResultListener() {
            @Override
            public void onSuccess(@NonNull List<UpiAccount> upiAccounts) {
                if(upiAccounts.isEmpty()){
                    reply.put("data", "");
                }else {
                    reply.put("data", toJsonString(upiAccounts));
                }
                sendReply(reply);
            }

            @Override
            public void onError(@NonNull Error error) {
                pendingResult.error(error.getErrorCode(), error.getErrorDescription(), toJsonString(error));
            }
        },color);
    }

    public void manageUpiAccounts(String customerMobile, MethodChannel.Result result, EventChannel.EventSink eventSink){
        this.pendingResult = result;
        this.eventSink = eventSink;
        razorpay.upiTurbo.manageUpiAccounts(customerMobile, new UpiTurboManageAccountListener() {
            @Override
            public void onError(@NonNull JSONObject jsonObject) {
                pendingResult.error("", jsonObject.toString(), jsonObject.toString());
            }
        } );

    }

}
