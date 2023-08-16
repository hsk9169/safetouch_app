class StoreDetails {
  String storeId;
  String storeName;
  String bizTime;
  String telNum;
  String phoneNum;
  String emailAddr;
  String storeAddr;
  String catId;
  String storeIntro;
  List<MenuInfo> menuList;
  List<String> storeImageGetList;
  List<StoreImage>? storeImagePostList;
  List<CategoryInfo> catList;

  StoreDetails({
    required this.storeId,
    required this.storeName,
    required this.bizTime,
    required this.telNum,
    required this.phoneNum,
    required this.emailAddr,
    required this.storeAddr,
    required this.catId,
    required this.storeIntro,
    required this.menuList,
    required this.storeImageGetList,
    this.storeImagePostList,
    required this.catList,
  });

  factory StoreDetails.initialize() {
    return StoreDetails(
        storeId: '',
        storeName: '',
        bizTime: '',
        telNum: '',
        phoneNum: '',
        emailAddr: '',
        storeAddr: '',
        catId: '',
        storeIntro: '',
        menuList: [],
        storeImageGetList: [],
        storeImagePostList: [],
        catList: []);
  }

  factory StoreDetails.fromJson(Map<String, dynamic> json) {
    return StoreDetails(
        storeId: json['store_id'] ?? '',
        storeName: json['store_name'] ?? '',
        bizTime: json['week_biz_time'] ?? '',
        telNum: json['tel_no'] ?? '',
        phoneNum: json['phone_no'] ?? '',
        emailAddr: json['email_addr'] ?? '',
        storeAddr: json['store_addr'] ?? '',
        catId: json['cat_id'] ?? '',
        storeIntro: json['store_intro'] ?? '',
        menuList: json['menu_list']
            .map<MenuInfo>((element) => MenuInfo.fromJson(element))
            .toList(),
        storeImageGetList: json['store_image_list']
            .map<String>((element) => element.toString())
            .toList(),
        catList: json['category_list']
            .map<CategoryInfo>((element) => CategoryInfo.fromJson(element))
            .toList());
  }

  Map<String, dynamic> toJson() => {
        'storeId': storeId,
        'storeName': storeName,
        'bizTime': bizTime,
        'telNum': telNum,
        'phoneNum': phoneNum,
        'emailAddr': emailAddr,
        'catId': catId,
        'storeIntro': storeIntro,
        'menuList': menuList.map((element) => element.toJson()).toList(),
        'storeImageList':
            storeImagePostList!.map((element) => element.toJson()).toList(),
      };
}

class CategoryInfo {
  final String id;
  final String name;

  CategoryInfo({
    required this.id,
    required this.name,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(id: json['id'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class MenuInfo {
  String? id;
  String name;
  String price;
  String? imgName;
  String? imgPath;
  String? imgContent;
  String? repMenuFlag;

  MenuInfo({
    this.id,
    required this.name,
    required this.price,
    required this.imgName,
    this.imgPath,
    this.imgContent,
    this.repMenuFlag,
  });

  factory MenuInfo.initialize() {
    return MenuInfo(
        name: '',
        price: '',
        imgName: null,
        imgPath: null,
        imgContent: null,
        repMenuFlag: '0');
  }

  factory MenuInfo.fromJson(Map<String, dynamic> json) {
    return MenuInfo(
        id: json['id'] ?? '',
        name: json['name'],
        price: json['price'],
        imgName: json['menu_image'] ?? '',
        repMenuFlag: json['rep_menu_flag'] ?? '');
  }

  Map<String, dynamic> toJson() => id != null
      ? imgContent != null
          ? {
              'id': id,
              'name': name,
              'price': price,
              'menu_image': imgName,
              'attach_menu_image': imgContent,
              'rep_menu_flag': repMenuFlag,
            }
          : {
              'id': id,
              'name': name,
              'price': price,
              'menu_image': imgName,
              'rep_menu_flag': repMenuFlag,
            }
      : imgContent != null
          ? {
              'name': name,
              'price': price,
              'menu_image': imgName,
              'attach_menu_image': imgContent,
              'rep_menu_flag': repMenuFlag,
            }
          : {
              'name': name,
              'price': price,
              'menu_image': imgName,
              'rep_menu_flag': repMenuFlag,
            };
}

class StoreImage {
  String fileName;
  String? content;

  StoreImage({
    required this.fileName,
    this.content,
  });

  factory StoreImage.fromJson(Map<String, dynamic> json) {
    return StoreImage(fileName: json['store_image']);
  }

  Map<String, dynamic> toJson() => content != null
      ? {
          'store_image': fileName,
          'attach_store_image': content,
        }
      : {
          'store_image': fileName,
        };
}
