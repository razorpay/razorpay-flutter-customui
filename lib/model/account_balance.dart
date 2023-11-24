class AccountBalance {
  final String id;
  final int balance;
  final String currency;

  AccountBalance({
    required this.id,
    required this.balance,
    required this.currency,
  });

  factory AccountBalance.fromJson(Map<String, dynamic> json) {
    return AccountBalance(
      id: json['id'] as String,
      balance: json['balance'] as int,
      currency: json['currency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'balance': balance,
      'currency': currency,
    };
  }
}
