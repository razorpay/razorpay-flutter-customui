class Card {
  final String expiryMonth;
  final String expiryYear;
  final String lastSixDigits;

  Card({
    required this.expiryMonth,
    required this.expiryYear,
    required this.lastSixDigits,
  });

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      expiryMonth: json['expiryMonth'],
      expiryYear: json['expiryYear'],
      lastSixDigits: json['lastSixDigits'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'lastSixDigits': lastSixDigits,
    };
  }
}
