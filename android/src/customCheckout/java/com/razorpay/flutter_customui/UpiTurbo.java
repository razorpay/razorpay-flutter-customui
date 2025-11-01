package com.razorpay.flutter_customui;


import android.app.Activity;

import androidx.annotation.NonNull;

import com.razorpay.Razorpay;

import java.util.HashMap;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class UpiTurbo {

    public UpiTurbo(Activity activity, Razorpay razorpay) {
    }

    void linkNewUpiAccount(String mobileNumber, MethodChannel.Result result, EventChannel.EventSink eventSink){

    }

    void askForPermission(MethodChannel.Result result, EventChannel.EventSink eventSink){
    }

    private void requestPermissionsManually(String[] permissionArray) {
    }

    void register(String simStr, MethodChannel.Result result, EventChannel.EventSink eventSink){
    }

    public void getBankAccounts(String bankStr, MethodChannel.Result result, EventChannel.EventSink eventSink) {
    }

    public void selectedBankAccount(String bankAccountStr , MethodChannel.Result result, EventChannel.EventSink eventSink){
    }

    public void setupUpiPin(String cardStr, MethodChannel.Result result, EventChannel.EventSink eventSink){
    }



    void getLinkedUpiAccounts(String mobileNumber, MethodChannel.Result result, EventChannel.EventSink eventSink){

    }

    public void getBalance(String upiAccountStr , MethodChannel.Result result, EventChannel.EventSink eventSink){

    }

    public void changeUpiPin(String upiAccountStr, MethodChannel.Result result, EventChannel.EventSink eventSink){

    }

    public void resetUpiPin(String upiAccount, String card , MethodChannel.Result result, EventChannel.EventSink eventSink){

    }

    public void delink(String upiAccountStr , MethodChannel.Result result, EventChannel.EventSink eventSink){

    }

    public static Object getUpiAccount(String upiAccountStr){
        return null;
    }


    public void onUpiTurboResponse(@NonNull Object upiTurboLinkAction) {

    }

    private void sendReplyByEventSink(HashMap<Object, Object> reply) {
    }

    public void onEventSuccess(HashMap<Object, Object> reply) {

    }

    public void onEventError(HashMap<Object, Object> reply , String error) {

    }

    private String toJsonString(Object object){
        return "";
    }

    public void handlePermissionResult(int requestCode, String[] permissions, int[] grantResults) {
    }

    public  boolean isTurboPluginAvailable(MethodChannel.Result result, EventChannel.EventSink eventSink) {
        return false;
    }

    public void linkNewUpiAccount(String customerMobile, String customerId, String  orderId , String tpvBankAccountStr , MethodChannel.Result result, EventChannel.EventSink eventSink){
    }

    public void linkNewUpiAccountWithUI(String customerMobile, String color, MethodChannel.Result result, EventChannel.EventSink eventSink){
    }

    public void manageUpiAccounts(String customerMobile, MethodChannel.Result result, EventChannel.EventSink eventSink){
    }

}
