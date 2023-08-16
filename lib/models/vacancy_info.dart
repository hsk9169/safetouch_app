class TablingInfo {
  final String id;
  final String storeName;
  final String bizTime;
  final String storePhone;
  final String userName;
  final String userPhone;
  final String visitTime;
  final String personCnt;
  final String menuName;
  final String repliedFlag;
  final String? canceledFlag;
  final String requestTime;
  final String repliedTime;

  TablingInfo({
    required this.id,
    required this.storeName,
    required this.bizTime,
    required this.storePhone,
    required this.userName,
    required this.userPhone,
    required this.visitTime,
    required this.personCnt,
    required this.menuName,
    required this.repliedFlag,
    this.canceledFlag,
    required this.requestTime,
    required this.repliedTime,
  });

  factory TablingInfo.fromJson(Map<String, dynamic> json) {
    return json['vacancy_id'] != null
        ? TablingInfo(
            id: json['vacancy_id'],
            storeName: json['store_name'],
            bizTime: json['biz_time'] ?? '',
            storePhone: json['tel_no'] ?? '',
            userName: json['user_name'],
            userPhone: json['phone_no'] ?? '',
            visitTime: json['visit_time'],
            personCnt: json['person_cnt'],
            menuName: json['menu_name'] ?? '',
            repliedFlag: json['replied_flag'] ?? '',
            canceledFlag: json['canceled_flag'] ?? '',
            requestTime: json['request_time'] ?? '',
            repliedTime: json['replied_time'] ?? '')
        : TablingInfo(
            id: json['book_id'],
            storeName: json['store_name'],
            bizTime: json['biz_time'] ?? '',
            storePhone: json['tel_no'] ?? '',
            userName: json['user_name'],
            userPhone: json['phone_no'] ?? '',
            visitTime: json['visit_time'],
            personCnt: json['person_cnt'],
            menuName: json['menu_name'] ?? '',
            repliedFlag: json['replied_flag'] ?? '',
            canceledFlag: json['canceled_flag'] ?? '',
            requestTime: json['request_time'] ?? '',
            repliedTime: json['replied_time'] ?? '');
  }
}
