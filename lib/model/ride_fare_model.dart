class RideFareModel {
  final double basePrice;
  final double extra;
  final double nightCharge;
  final double rushHour;
  final double surCharges;
  final double waitingCharge;
  final double perKm;

  RideFareModel({
    this.basePrice = 0.0,
    this.extra = 0.0,
    this.nightCharge = 0.0,
    this.rushHour = 0.0,
    this.surCharges = 0.0,
    this.waitingCharge = 0.0,
    this.perKm = 0.0,
  });

  // Factory constructor for creating an instance from JSON
  RideFareModel fromMap(Map json) {
    return RideFareModel(
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      extra: (json['extra'] ?? 0).toDouble(),
      nightCharge: (json['nightCharge'] ?? 0).toDouble(),
      rushHour: (json['rushHour'] ?? 0).toDouble(),
      surCharges: (json['surCharges'] ?? 0).toDouble(),
      waitingCharge: (json['waitingCharge'] ?? 0).toDouble(),
      perKm: (json['per_km'] ?? 0).toDouble(),
    );
  }

  // Convert class instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'basePrice': basePrice,
      'extra': extra,
      'nightCharge': nightCharge,
      'rushHour': rushHour,
      'surCharges': surCharges,
      'waitingCharge': waitingCharge,
    };
  }
}
