class SessionData {
  String userId;
  String userToken;

  SessionData({
    required this.userId,
    required this.userToken,
  });

  factory SessionData.initialize() {
    return SessionData(userId: '', userToken: '');
  }

  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      userId: json['user_id'] ?? '',
      userToken: json['user_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userToken': userToken,
      };
}
