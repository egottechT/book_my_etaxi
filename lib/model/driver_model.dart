
class DriverModel{
  String name = "";
  String phoneNumber = "";
  String vehicleNumber = "";
  String rating = "";

  DriverModel getDataFromMap(Map map){
    DriverModel model = DriverModel();
    model.vehicleNumber = map["vehicleNumber"] ?? "";
    model.phoneNumber = map["phoneNumber"] ?? "";
    model.rating = map["rating"] ?? "";
    model.name = map["name"] ?? "";
    return model;
  }
}