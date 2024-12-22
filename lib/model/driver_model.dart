class DriverModel {
  String name = "";
  String phoneNumber = "";
  String vehicleNumber = "";
  String rating = "";
  double latitude = 0.0;
  double longitude = 0.0;
  int otp = 0;
  String id = "";
  int amount = 0;

  DriverModel getDataFromMap(Map map) {
    DriverModel model = DriverModel();
    model.vehicleNumber = map["vehicleNumber"] ?? "";
    model.phoneNumber = map["phoneNumber"] ?? "";
    model.rating = map["rating"] ?? "";
    model.name = map["name"] ?? "";
    model.id = map["id"] ?? "";
    model.longitude = map["long"] ?? 0;
    model.latitude = map["lat"] ?? 0;
    model.otp = map["otp"] ?? 0;
    model.amount = map['amount'] ?? 0;
    return model;
  }
}
