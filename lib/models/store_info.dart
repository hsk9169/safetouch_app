class StoreInfo {
  final String storeName;
  final String userPwd;

  StoreInfo({
    required this.storeName,
    required this.userPwd,
  });

  factory StoreInfo.initialize() {
    return StoreInfo(storeName: '', userPwd: '');
  }

  Map<String, dynamic> toJson() => {
        'storeName': storeName,
        'userPwd': userPwd,
      };
}
