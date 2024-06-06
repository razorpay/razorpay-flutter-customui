class AccountBalance {
  final String id;
  final int balance;
  final String currency;
  final double outstanding;

  AccountBalance({
    required this.id,
    required this.balance,
    required this.currency,
    required this.outstanding
  });

  factory AccountBalance.fromJson(Map<String, dynamic> json) {
    return AccountBalance(
      id: json['id'] as String,
      balance: json['balance'] as int,
      currency: json['currency'] as String,
      outstanding: json['outstanding'] as double
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'balance': balance,
      'currency': currency,
      'outstanding': outstanding
    };
  }
}
