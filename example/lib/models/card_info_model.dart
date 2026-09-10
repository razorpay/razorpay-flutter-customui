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
  String? logoUrl;

  NetBankingModel({this.bankKey, this.bankName, this.logoUrl});
}

class WalletModel {
  String? walletName;

  WalletModel({this.walletName});
}
