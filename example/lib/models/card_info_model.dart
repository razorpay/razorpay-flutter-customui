class CardInfoModel {
  String? cardNumber;
  String? expiryMonth;
  String? expiryYear;
  String? cvv;
  String? cardHolderName;
  String? mobileNumber;
  String? email;
}

class NetBankingModel {
  String? bankKey;
  String? bankName;

  NetBankingModel({this.bankKey, this.bankName});
}

class WalletModel {
  String? walletName;

  WalletModel({this.walletName});
}
