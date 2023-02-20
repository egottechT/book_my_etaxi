class UserModel{
  String name = "";
  String phoneNumber = "";
  String email = "";

  UserModel();

  UserModel getDataFromMap(Map map){
    UserModel model = UserModel();
    model.phoneNumber = map["phoneNumber"] ?? "";
    model.email = map["email"] ?? "";
    model.name = map["name"] ?? "";
    return model;
  }
}