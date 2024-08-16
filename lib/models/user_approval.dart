import 'dart:convert';

UserApproval userApprovalFromJson(String str) =>
    UserApproval.fromJson(json.decode(str));

String userApprovalToJson(UserApproval data) => json.encode(data.toJson());

class UserApproval {
  UserApproval({
    required this.userId,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.message,
    required this.datetime,
    required this.payload,
  });

  final String userId;
  final String userName;
  final String email;
  final String phoneNumber;
  final Message message;
  final DateTime datetime;
  final Payload payload;

  factory UserApproval.fromJson(Map<String, dynamic> json) => UserApproval(
    userId: json["userId"],
    userName: json["userName"],
    email: json["email"],
    phoneNumber: json["phoneNumber"],
    message: Message.fromJson(json["message"]),
    payload: Payload.fromJson(json["payload"]),
    datetime: DateTime.parse(json["datetime"]),
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "userName": userName,
    "email": email,
    "phoneNumber": phoneNumber,
    "message": message.toJson(),
    "payload": payload.toJson(),
    "datetime": datetime.toIso8601String(),
  };
}
class Message {
  Message({
    required this.message,
    required this.subject,
  });

  final String message;
  final String subject;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    message: json["message"],
    subject: json["subject"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "subject": subject,
  };
}

class Payload {
  Payload({
    required this.userCredentials,
  });

  final UserCredentials userCredentials;

  factory Payload.fromJson(Map<String, dynamic> json) => Payload(
    userCredentials: UserCredentials.fromJson(json["userCredentials"]),
  );

  Map<String, dynamic> toJson() => {
    "userCredentials": userCredentials.toJson(),
  };
}

class UserCredentials {
  UserCredentials({
    required this.disabled,
  });

  final bool disabled;

  factory UserCredentials.fromJson(Map<String, dynamic> json) => UserCredentials(
    disabled: json["disabled"],
  );

  Map<String, dynamic> toJson() => {
    "disabled": disabled,
  };
}

