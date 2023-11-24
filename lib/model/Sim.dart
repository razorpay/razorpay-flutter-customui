class Sim {
  String? id;
  String? provider;
  int? slotNumber;
  String number;

  Sim({
    this.id,
    this.provider,
    this.slotNumber,
    this.number = "",
  });

  factory Sim.fromJson(Map<String, dynamic> json) {
    return Sim(
      id: json['id'],
      provider: json['provider'],
      slotNumber: json['slotNumber'],
      number: json['number'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider,
      'slotNumber': slotNumber,
      'number': number,
    };
  }
}