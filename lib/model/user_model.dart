class UserModel{
  String name = "";
  String phoneNumber = "";
  String email = "";

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
    return model;
  }
}