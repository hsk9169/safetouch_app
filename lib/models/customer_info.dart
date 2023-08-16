class CustomerInfo {
  String userName;
  String phoneNum;

  CustomerInfo({
    required this.userName,
    required this.phoneNum,
  });

  factory CustomerInfo.initialize() {
    return CustomerInfo(userName: '', phoneNum: '');
  }

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'phoneNum': phoneNum,
      };
}
