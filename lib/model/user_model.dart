class UserModel{
  String name = "";
  String phoneNumber = "";
  String email = "";
  String profilePic = "";
  String key = "";
  bool referred = false;
  String driverReferred = '';
  UserModel();

  Map<String,dynamic> toMap(UserModel model){
    return {
      "name":model.name,
      "phoneNumber":model.phoneNumber,
      "email":model.email
    };
  }
  UserModel getDataFromMap(Map map){
    UserModel model = UserModel();
    model.phoneNumber = map["phoneNumber"] ?? "";
    model.email = map["email"] ?? "";
    model.name = map["name"] ?? "";
    model.referred = map["referred"] ?? false;
    model.profilePic = map["profile_pic"] ?? "";
    model.driverReferred  = map["driver_referred"] ?? "";
    return model;
  }
}