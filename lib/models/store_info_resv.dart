import './store_details.dart';

class StoreInfoResv {
  final String storeId;
  final String storeName;
  final String bizTime;
  final String storePhone;
  final String repImg;
  final List<MenuInfo> menuList;

  StoreInfoResv({
    required this.storeId,
    required this.storeName,
    required this.bizTime,
    required this.storePhone,
    required this.repImg,
    required this.menuList,
  });

  factory StoreInfoResv.initialize() {
    return StoreInfoResv(
        storeId: '',
        storeName: '',
        bizTime: '',
        storePhone: '',
        repImg: '',
        menuList: []);
  }

  factory StoreInfoResv.fromJson(Map<String, dynamic> json) {
    return StoreInfoResv(
      storeId: json['store_id'],
      storeName: json['store_name'],
      bizTime: json['biz_time'] ?? '',
      storePhone: json['tel_no'] ?? '',
      repImg: json['rep_image'] ?? '',
      menuList: json['menu_list']
          .map<MenuInfo>((menu) => MenuInfo.fromJson(menu))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'storeId': storeId,
        'storeName': storeName,
        'bizTime': bizTime,
        'storePhone': storePhone,
        'repImage': repImg,
        'menuList': menuList.map((element) => element.toJson()).toList(),
      };
}
