import 'dart:collection';
import 'package:flutter/src/services/platform_channel.dart';
import 'package:razorpay_turbo/razorpay_turbo.dart';
import 'model/tpv_bank_account.dart';
import 'dart:convert';
import 'model/Error.dart';
import 'package:eventify/eventify.dart';
import 'package:flutter/services.dart';

class Tpv {
  String? orderId;
  String? customerId;
  String? customerMobile;
  TPVBankAccount? tpvBankAccount;
  MethodChannel? _channel;
  late EventEmitter _eventEmitter;
  bool _isTurboPluginAvailable = false;


  Tpv(MethodChannel channel, EventEmitter eventEmitter){
    this._channel = channel;
    this._eventEmitter = eventEmitter;
    _checkTurboPluginAvailable();
  }

  void _checkTurboPluginAvailable() async {
    final Map<dynamic, dynamic> turboPluginAvailableResponse = await _channel?.invokeMethod('isTurboPluginAvailable');
    _isTurboPluginAvailable = turboPluginAvailableResponse["isTurboPluginAvailable"];
  }


  Tpv setOrderId(String? orderId) {
    this.orderId = orderId;
    return this;
  }

  Tpv setCustomerId(String? customerId) {
    this.customerId = customerId;
    return this;
  }

  Tpv setCustomerMobile(String customerMobile) {
    this.customerMobile = customerMobile;
    return this;

  }

  Tpv setTpvBankAccount(TPVBankAccount? tpvBankAccount) {
    this.tpvBankAccount = tpvBankAccount;
    return this;
  }

  void linkNewUpiAccount() async {
    if(!_isTurboPluginAvailable){
      _emitError();
      return;
    }
      var linkNewUpiAccountTPVInput =  <String, dynamic>{
        "customerId": this.customerId,
        "orderId":  this.orderId,
        "customerMobile" : this.customerMobile,
        "tpvBankAccount": _getTpvBankAccountStr(this.tpvBankAccount)
      };

      await this._channel?.invokeMethod('linkNewUpiAccountTPV' , linkNewUpiAccountTPVInput);
  }

   _getTpvBankAccountStr(TPVBankAccount? tPVBankAccount) {
    if(tPVBankAccount==null)
      return null;
    return jsonEncode(tPVBankAccount.toJson());
  }

  _emitError(){
    final Map<String, dynamic> response = HashMap();
    response["error"] = Error(errorCode: "AXIS_SDK_ERROR", errorDescription: "No Turbo Plugin Found");
    _eventEmitter.emit(Razorpay.EVENT_UPI_TURBO_LINK_NEW_UPI_ACCOUNT, null, response);
  }

}