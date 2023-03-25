class MessageModel{
  String msg = "";
  String sender = "";

  MessageModel fromMap(Map map){
    MessageModel model = MessageModel();
    model.msg = map["message"] ?? "";
    model.sender = map["sender"] ?? "";
    return model;
  }

  Map toMapFromMessageModel(MessageModel model){
    Map map = {
      "message": model.msg,
      "sender": "customer"
    };
    return map;
  }
}