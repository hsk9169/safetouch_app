import './store_details.dart';

class AdStoreInfo {
  final List<CategoryInfo>? catList;
  final List<String> catIdList;
  final String rcvTimeDiv;
  final String rcvFlag;
  final String? updatedTime;

  AdStoreInfo({
    this.catList,
    required this.catIdList,
    required this.rcvTimeDiv,
    required this.rcvFlag,
    this.updatedTime,
  });

  factory AdStoreInfo.fromJson(Map<String, dynamic> json) {
    return json['adver_set_info'] != null
        ? AdStoreInfo(
            catList: json['category_list']
                .map<CategoryInfo>((element) => CategoryInfo.fromJson(element))
                .toList(),
            catIdList: json['adver_set_info']['cat_id_list']
                .map<String>((element) => element.toString())
                .toList(),
            rcvTimeDiv: json['adver_set_info']['rcv_time_div'],
            rcvFlag: json['adver_set_info']['rcv_flag'],
            updatedTime: json['adver_set_info']['updated_time'])
        : AdStoreInfo(
            catList: json['category_list']
                .map<CategoryInfo>((element) => CategoryInfo.fromJson(element))
                .toList(),
            catIdList: [],
            rcvTimeDiv: '0',
            rcvFlag: '',
            updatedTime: '');
  }

  Map<String, dynamic> toJson() => {
        'cat_id_list':
            catIdList.map<String>((element) => element.toString()).toList(),
        'rcv_time_div': rcvTimeDiv,
        'rcv_flag': rcvFlag,
      };
}
