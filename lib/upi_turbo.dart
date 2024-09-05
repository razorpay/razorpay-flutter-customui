import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:eventify/eventify.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_turbo/model/account_balance.dart';
import 'package:razorpay_turbo/model/empty.dart';
import 'package:razorpay_turbo/razorpay_turbo.dart';
import 'model/Error.dart';
import 'model/Sim.dart';
import 'model/all_banks.dart';
import 'model/bank_account.dart';
import 'model/bank_model.dart';
import 'model/upi_account.dart';
import 'card.dart';
import 'model/prefetch_model.dart';

typedef void OnSuccess<T>(T result);
typedef void OnFailure<T>(T error);

class UpiTurbo {
  // EventEmitter instance used for communication
  late EventEmitter _eventEmitter;
  late MethodChannel _channel;
  final int _CODE_EVENT_SUCCESS = 200;
  final int _CODE_EVENT_ERROR = 201;

  // Turbo UPI
  final _eventChannel = const EventChannel('razorpay_turbo_with_turbo_upi');
  bool _isTurboPluginAvailable = false;

  UpiTurbo(MethodChannel channel, EventEmitter eventEmitter) {
    this._channel = channel;
    this._eventEmitter = eventEmitter;
    _streamFromNative();
    _checkTurboPluginAvailable();
  }

  void _checkTurboPluginAvailable() async {
    final Map<dynamic, dynamic> turboPluginAvailableResponse =
        await _channel.invokeMethod('isTurboPluginAvailable');
    _isTurboPluginAvailable =
        turboPluginAvailableResponse["isTurboPluginAvailable"];
  }

  /*
       Response handle from native Turbo UPI
   */

  void _streamFromNative() {
    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  void _onEvent(dynamic event) {
    if (event["type"] == _CODE_EVENT_ERROR) {
      event["error"] = _getError(errorResponse: event["error"]);
      _eventEmitter.emit(
          Razorpay.EVENT_UPI_TURBO_LINK_NEW_UPI_ACCOUNT, null, event);
      return;
    }

    if (event["responseEvent"] == "linkNewUpiAccountEvent") {
      if (event["data"] != null) {
        switch (event["action"]) {
          case "SELECT_SIM":
            event["data"] = _getSims(simResponse: event["data"]);
            break;
          case "SELECT_BANK":
            event["data"] = _getAllBank(bankResponse: event["data"]);
            break;
          case "SELECT_BANK_ACCOUNT":
            event["data"] =
                _getBankAccountList(bankAccountResponse: event["data"]);
            break;
        }
        _eventEmitter.emit(
            Razorpay.EVENT_UPI_TURBO_LINK_NEW_UPI_ACCOUNT, null, event);
      }
    } else if (event["responseEvent"] ==
        "prefetchAndLinkNewUpiAccountUIEvent") {
      final dataSnapshot = event['data'];
      Map<String, dynamic> data = json.decode(dataSnapshot);
      final prefetchAccount = _getAllPrefetchAccounts(data);
      event['data'] = prefetchAccount;
      _eventEmitter.emit(
          Razorpay.EVENT_UPI_TURBO_PREFETCH_AND_LINK_NEW_UPI_ACCOUNT,
          null,
          event);
    }
  }

  void _onError(dynamic event) {}

  /*
      OnBoarding Flow Turbo UPI
   */

  void linkNewUpiAccount({required String? customerMobile}) async {
    if (!_isTurboPluginAvailable) {
      _emitError();
      return;
    }
    await _channel.invokeMethod('linkNewUpiAccount', customerMobile);
  }

  void prefetchAndLinkUpiAccountsWithUI(
      {required String? customerMobile, String? color}) async {
    print('prfetch called');
    //final prefetchRequest = {'customerMobile': customerMobile, 'color': color};
    var prefetchRequest = <String, dynamic>{
      "customerMobile": customerMobile,
      "color": color ?? ''
    };
    print(_channel);
    await _channel.invokeMethod(
        'prefetchAndLinkUpiAccountsWithUI', prefetchRequest);
  }

  void register({required Sim sim}) async {
    if (!_isTurboPluginAvailable) {
      _emitError();
      return;
    }
    await _channel.invokeMethod('register', _getSimStr(sim));
  }

  void getBankAccounts({required Bank bank}) async {
    if (!_isTurboPluginAvailable) {
      _emitError();
      return;
    }
    await _channel.invokeMethod('getBankAccount', _getBankStr(bank));
  }

  void selectedBankAccount({required BankAccount bankAccount}) async {
    if (!_isTurboPluginAvailable) {
      _emitError();
      return;
    }
    await _channel.invokeMethod(
        'selectedBankAccount', _getBankAccountStr(bankAccount));
  }

  void setupUpiPin({required Card card}) async {
    if (!_isTurboPluginAvailable) {
      _emitError();
      return;
    }
    await _channel.invokeMethod('setUpUPIPin', _getCardStr(card));
  }

  void askForPermission() async {
    if (!_isTurboPluginAvailable) {
      _emitError();
      return;
    }
    await _channel.invokeMethod('askForPermission');
  }

  /*x
      Non-transactional Flow Turbo UPI
   */
  void getLinkedUpiAccounts(
      {required String? customerMobile,
      required OnSuccess<List<UpiAccount>> onSuccess,
      required OnFailure<Error> onFailure}) async {
    try {
      if (!_isTurboPluginAvailable) {
        _emitFailure(onFailure);
        return;
      }
      final Map<dynamic, dynamic> getLinkedUpiAccountsResponse =
          await _channel.invokeMethod('getLinkedUpiAccounts', customerMobile);
      if (getLinkedUpiAccountsResponse["data"] != "") {
        onSuccess(_getUpiAccounts(getLinkedUpiAccountsResponse["data"]));
      } else {
        onFailure(Error(errorCode: "", errorDescription: "No Account Found"));
      }
    } on PlatformException catch (error) {
      onFailure(Error(errorCode: error.code, errorDescription: error.message!));
    }
  }

  void getBalance(
      {required UpiAccount upiAccount,
      required OnSuccess<AccountBalance> onSuccess,
      required OnFailure<Error> onFailure}) async {
    try {
      if (!_isTurboPluginAvailable) {
        _emitFailure(onFailure);
        return;
      }
      final Map<dynamic, dynamic> getBalanceResponse = await _channel
          .invokeMethod('getBalance', _getUpiAccountStr(upiAccount));
      onSuccess(
          AccountBalance.fromJson(jsonDecode(getBalanceResponse["data"])));
    } on PlatformException catch (error) {
      onFailure(Error(errorCode: error.code, errorDescription: error.message!));
    }
  }

  void changeUpiPin(
      {required UpiAccount upiAccount,
      required OnSuccess<UpiAccount> onSuccess,
      required OnFailure<Error> onFailure}) async {
    try {
      if (!_isTurboPluginAvailable) {
        _emitFailure(onFailure);
        return;
      }
      final Map<dynamic, dynamic> changeUpiPinResponse = await _channel
          .invokeMethod('changeUpiPin', _getUpiAccountStr(upiAccount));
      if (changeUpiPinResponse["data"] != "") {
        onSuccess(_getUpiAccount(changeUpiPinResponse["data"]));
      }
    } on PlatformException catch (error) {
      onFailure(Error(errorCode: error.code, errorDescription: error.message!));
    }
  }

  void resetUpiPin(
      {required UpiAccount upiAccount,
      required Card card,
      required OnSuccess<UpiAccount> onSuccess,
      required OnFailure<Error> onFailure}) async {
    try {
      if (!_isTurboPluginAvailable) {
        _emitFailure(onFailure);
        return;
      }
      var resetUpiPinInput = <String, dynamic>{
        "upiAccount": _getUpiAccountStr(upiAccount),
        "card": _getCardStr(card)
      };

      final Map<dynamic, dynamic> resetUpiPinResponse =
          await _channel.invokeMethod('resetUpiPin', resetUpiPinInput);
      if (resetUpiPinResponse["data"] != "") {
        onSuccess(_getUpiAccount(resetUpiPinResponse["data"]));
      }
    } on PlatformException catch (error) {
      onFailure(Error(errorCode: error.code, errorDescription: error.message!));
    }
  }

  void delink(
      {required UpiAccount upiAccount,
      required OnSuccess<Empty> onSuccess,
      required OnFailure<Error> onFailure}) async {
    try {
      if (!_isTurboPluginAvailable) {
        _emitFailure(onFailure);
        return;
      }
      final Map<dynamic, dynamic> delinkResponse =
          await _channel.invokeMethod('delink', _getUpiAccountStr(upiAccount));
      var empty = Empty();
      onSuccess(empty);
    } on PlatformException catch (error) {
      onFailure(Error(errorCode: error.code, errorDescription: error.message!));
    }
  }

  /*
     UPI Turbo with custom UI
   */

  void linkNewUpiAccountWithUI(
      {required String? customerMobile,
      required String? color,
      required OnSuccess<List<UpiAccount>> onSuccess,
      required OnFailure<Error> onFailure}) async {
    try {
      if (!_isTurboPluginAvailable) {
        _emitFailure(onFailure);
        return;
      }

      var requestLinkNewUpiAccountWithUI = <String, dynamic>{
        "customerMobile": customerMobile,
        "color": color
      };

      final Map<dynamic, dynamic> getLinkedUpiAccountsResponse =
          await _channel.invokeMethod(
              'linkNewUpiAccountWithUI', requestLinkNewUpiAccountWithUI);
      if (getLinkedUpiAccountsResponse["data"] != "") {
        onSuccess(_getUpiAccounts(getLinkedUpiAccountsResponse["data"]));
      } else {
        onFailure(Error(
            errorCode: "NO_ACCOUNT_FOUND",
            errorDescription: "No Account Found"));
      }
    } on PlatformException catch (error) {
      onFailure(Error(errorCode: error.code, errorDescription: error.message!));
    }
  }

  void manageUpiAccounts(
      {required String? customerMobile,
      required OnFailure<Error> onFailure}) async {
    try {
      if (!_isTurboPluginAvailable) {
        _emitFailure(onFailure);
        return;
      }
      await _channel.invokeMethod('manageUpiAccounts', customerMobile);
    } on PlatformException catch (error) {
      onFailure(Error(errorCode: error.code, errorDescription: error.message!));
    }
  }

  void setUpiPinUI(
      {required BankAccount bankAccount,
      required OnSuccess<List<UpiAccount>> onSuccess,
      required OnFailure<Error> onFailure}) async {
    String bankAccountString = bankAccount.toJson().toString();
    String account = await _channel.invokeMethod(
        'setPrefetchUPIPinWithUI', bankAccountString);
    if (account != '') {
      onSuccess(_getUpiAccounts(account));
    } else {
      onFailure(Error(
          errorCode: "NO_ACCOUNT_FOUND", errorDescription: "No Account Found"));
    }
  }

  UpiAccount _getUpiAccount(jsonString) {
    var upiAccountMap = json.decode(jsonString);
    UpiAccount upiAccount = UpiAccount.fromJson(upiAccountMap);
    return upiAccount;
  }

  List<UpiAccount> _getUpiAccounts(jsonString) {
    if (jsonString.toString().isEmpty) {
      return <UpiAccount>[];
    }

    print('decoded form');
    print(json.decode(jsonString));

    List<UpiAccount> upiAccounts = List<UpiAccount>.from(
      json.decode(jsonString).map((x) => UpiAccount.fromJson(x)),
    );
    return upiAccounts;
  }

  String _getUpiAccountStr(UpiAccount upiAccount) {
    return jsonEncode(UpiAccount(
            accountNumber: upiAccount.accountNumber,
            bankLogoUrl: upiAccount.bankLogoUrl,
            bankName: upiAccount.bankName,
            bankPlaceholderUrl: upiAccount.bankPlaceholderUrl,
            ifsc: upiAccount.ifsc,
            pinLength: upiAccount.pinLength,
            vpa: upiAccount.vpa)
        .toJson());
  }

  String _getCardStr(Card card) {
    return jsonEncode(Card(
            expiryMonth: card.expiryMonth,
            expiryYear: card.expiryYear,
            lastSixDigits: card.lastSixDigits)
        .toJson());
  }

  String _getSimStr(Sim sim) {
    return jsonEncode(Sim(
            id: sim.id,
            provider: sim.provider,
            slotNumber: sim.slotNumber,
            number: sim.number)
        .toJson());
  }

  _getBankAccountStr(BankAccount bankAccount) {
    return jsonEncode(bankAccount.toJson());
  }

  _getBankStr(Bank bank) {
    return jsonEncode(bank.toJson());
  }

  _getSims({required String simResponse}) {
    final decodedResponse = json.decode(simResponse);
    final List<dynamic> simListJson = decodedResponse['sims'];
    List<Sim> sims = simListJson.map((json) => Sim.fromJson(json)).toList();
    return sims;
  }

  _getAllBank({required String bankResponse}) {
    final decodedResponse = json.decode(bankResponse);
    final List<dynamic> bankListJson = decodedResponse['banks'];
    AllBanks allBanks = AllBanks();
    if (bankListJson.isNotEmpty) {
      List<Bank> banks =
          bankListJson.map((json) => Bank.fromJson(json)).toList();
      allBanks.banks = banks;
    }
    final List<dynamic> popularBanksJson = decodedResponse['popularBanks'];
    if (popularBanksJson.isNotEmpty) {
      List<Bank> popularBanks =
          bankListJson.map((json) => Bank.fromJson(json)).toList();
      allBanks.banks = popularBanks;
    }

    return allBanks;
  }

  _getBankAccountList({required String bankAccountResponse}) {
    List<BankAccount> bankAccounts = List<BankAccount>.from(
      json
          .decode(bankAccountResponse)
          .map((bankAccount) => BankAccount.fromJson(bankAccount)),
    );
    return bankAccounts;
  }

  _getError({required String errorResponse}) {
    return Error.fromJson(json.decode(errorResponse));
  }

  _emitError() {
    final Map<String, dynamic> response = HashMap();
    response["error"] = Error(
        errorCode: "AXIS_SDK_ERROR", errorDescription: "No Turbo Plugin Found");
    _eventEmitter.emit(
        Razorpay.EVENT_UPI_TURBO_LINK_NEW_UPI_ACCOUNT, null, response);
  }

  void _emitFailure(OnFailure<Error> onFailure) {
    onFailure(Error(
        errorCode: "AXIS_SDK_ERROR",
        errorDescription: "No Turbo Plugin Found"));
  }

  PrefetchAccounts _getAllPrefetchAccounts(Map<String, dynamic> data) {
    return PrefetchAccounts.fromMap(data);
  }
}
