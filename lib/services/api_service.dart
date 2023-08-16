import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:safetouch/models/ad_store_info.dart';
import 'package:safetouch/models/models.dart';

class ApiService {
  final String _hostAddress = '43.201.180.2';
  final String path = '/mobile';

  Future<dynamic> requestSignin(
      String userDiv, String osDiv, String name, String num) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/user/login',
          ),
          body: userDiv == '1'
              ? jsonEncode(<String, String>{
                  'user_div': userDiv,
                  'phone_os_div': osDiv,
                  'store_name': name,
                  'user_pwd': num,
                })
              : jsonEncode(<String, String>{
                  'user_div': userDiv,
                  'phone_os_div': osDiv,
                  'user_name': name,
                  'phone_no': num,
                }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return SessionData.fromJson(body);
        } else if (body['status_code'] == 400) {
          return body;
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  Future<dynamic> requestSignup(String userDiv, String osDiv, String storeCode,
      String storeName, String phoneNum, String pwd) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/user/join',
          ),
          body: userDiv == '1'
              ? jsonEncode(<String, String>{
                  'user_div': userDiv,
                  'phone_os_div': osDiv,
                  'store_code': storeCode,
                  'store_name': storeName,
                  'phone_no': phoneNum,
                  'user_pwd': pwd,
                })
              : jsonEncode(<String, String>{
                  'user_div': userDiv,
                  'phone_os_div': osDiv,
                  'user_name': storeName,
                  'phone_no': phoneNum,
                }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return SessionData.fromJson(body);
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  Future<dynamic> requestSignOut(
      String userDiv, String userId, String userToken) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/user/logout',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return true;
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  Future<dynamic> updateStoreAccount(
      String userDiv,
      String userId,
      String userToken,
      String storeCode,
      String storeName,
      String orgPhoneNo,
      String newPhoneNo,
      String userPwd,
      String unsubscribeFlag) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/user/modify/info',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
            'store_code': storeCode,
            'store_name': storeName,
            'org_phone_no': orgPhoneNo,
            'new_phone_no': newPhoneNo,
            'user_pwd': userPwd,
            'unsubscribe_flag': unsubscribeFlag,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return SessionData(userId: '', userToken: body['user_token']);
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  Future<dynamic> updateCustomerAccount(
      String userDiv,
      String userId,
      String userToken,
      String userName,
      String orgPhoneNo,
      String newPhoneNo,
      String unsubscribeFlag) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/user/modify/info',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
            'user_name': userName,
            'org_phone_no': orgPhoneNo,
            'new_phone_no': newPhoneNo,
            'unsubscribe_flag': unsubscribeFlag,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return SessionData(userId: '', userToken: body['user_token']);
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  Future<dynamic> updatePushToken(
      String userDiv, String userId, String userToken, String pushToken) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/user/modify/push',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
            'push_token': pushToken,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return true;
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  Future<dynamic> getStoreNameByCode(String storeCode) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/store/check/code',
          ),
          body: jsonEncode(<String, String>{
            'store_code': storeCode,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return StoreName.fromJson(body);
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  Future<dynamic> getStoreInfo(
      String userDiv, String userId, String userToken) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/store/check/info',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
          }));
      if (res.statusCode == 200) {
        //final body = json.decode(res.body);
        final body = jsonDecode(utf8.decode(res.bodyBytes));
        if (body['status_code'] == 200) {
          return StoreDetails.fromJson(body);
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  Future<dynamic> postStoreInfo(String userDiv, String userId, String userToken,
      StoreDetails data) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/store/modify/info',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
            'store_id': data.storeId,
            'store_name': data.storeName,
            'week_biz_time': data.bizTime,
            'tel_no': data.telNum,
            'phone_no': data.phoneNum,
            'email_addr': data.emailAddr,
            'store_addr': data.storeAddr,
            'cat_id': data.catId,
            'store_intro': data.storeIntro,
            'menu_list': jsonEncode(
                data.menuList.map((element) => element.toJson()).toList()),
            'store_image_list': jsonEncode(
                data.storeImagePostList!.map((element) => element).toList()),
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return true;
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return 'UNKNOWN_ERROR';
      }
    }
  }

  Future<dynamic> getEventInfo(
      String userDiv, String userId, String userToken) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/event/check/info',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return body['event_list']
              .map((element) => EventInfo.fromJson(element))
              .toList();
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return err.toString();
      }
    }
  }

  Future<dynamic> postEventInfo(String userDiv, String userId, String userToken,
      List<EventInfo> list) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/event/modify/info',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
            'event_list':
                jsonEncode(list.map((element) => element.toJson()).toList())
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return true;
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return err.toString();
      }
    }
  }

  Future<dynamic> deleteEvent(
      String userDiv, String userId, String userToken, String eventId) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/event/delete',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
            'event_id': eventId,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return true;
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return err.toString();
      }
    }
  }

  Future<dynamic> getStoreInfoById(
      String userDiv, String userId, String userToken, String storeId) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/store/info',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
            'store_id': storeId,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          final StoreInfoResv ret = StoreInfoResv.fromJson(body);
          return ret;
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        //return 'UNKNOWN_ERROR';
        return err.toString();
      }
    }
  }

  Future<dynamic> requestVacancy(
      String userDiv,
      String userId,
      String userToken,
      String storeId,
      String userName,
      String phoneNo,
      String visitTime,
      String personCnt,
      String menuName,
      String time) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/store/vacancy/request',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
            'store_id': storeId,
            'user_name': userName,
            'phone_no': phoneNo,
            'visit_time': visitTime,
            'person_cnt': personCnt,
            'menu_name': menuName,
            'request_time': time
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return true;
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return err.toString();
      }
    }
  }

  Future<dynamic> getVacancyList(
      String userDiv, String userId, String userToken) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/store/vacancy/list',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return body['vacancy_list']
              .map<TablingInfo>((element) => TablingInfo.fromJson(element))
              .toList();
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return err.toString();
      }
    }
  }

  Future<dynamic> postReplyVacancy(
      String userDiv,
      String userId,
      String userToken,
      String vacancyId,
      String vacancyDiv,
      String waitMin,
      String etcMsg,
      String time) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/store/vacancy/reply',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
            'vacancy_id': vacancyId,
            'vacancy_div': vacancyDiv,
            'wait_min': waitMin,
            'etc_msg': etcMsg,
            'replied_time': time,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return true;
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return err.toString();
      }
    }
  }

  Future<dynamic> getVacancyReply(
      String userDiv, String userId, String userToken, String vacancyId) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/store/vacancy/check',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
            'vacancy_id': vacancyId,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return TablingReply.fromJson(body['reply_info']);
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return err.toString();
      }
    }
  }

  Future<dynamic> cancelVacancy(
      String userDiv, String userId, String userToken, String vacancyId) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/store/vacancy/cancel',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
            'vacancy_id': vacancyId,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return true;
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return err.toString();
      }
    }
  }

  Future<dynamic> requestReservation(
      String userDiv,
      String userId,
      String userToken,
      String storeId,
      String userName,
      String phoneNo,
      String visitTime,
      String personCnt,
      String menuName,
      String time) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/store/book/request',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
            'store_id': storeId,
            'user_name': userName,
            'phone_no': phoneNo,
            'visit_time': visitTime,
            'person_cnt': personCnt,
            'menu_name': menuName,
            'request_time': time,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return true;
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return err.toString();
      }
    }
  }

  Future<dynamic> getReservationList(
      String userDiv, String userId, String userToken) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/store/book/list',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return body['book_list']
              .map<TablingInfo>((element) => TablingInfo.fromJson(element))
              .toList();
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return err.toString();
      }
    }
  }

  Future<dynamic> postReplyReservation(
      String userDiv,
      String userId,
      String userToken,
      String vacancyId,
      String vacancyDiv,
      String waitMin,
      String etcMsg,
      String time) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/store/book/reply',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
            'book_id': vacancyId,
            'book_div': vacancyDiv,
            'wait_min': waitMin,
            'etc_msg': etcMsg,
            'replied_time': time,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return true;
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return err.toString();
      }
    }
  }

  Future<dynamic> getReservationReply(
      String userDiv, String userId, String userToken, String bookId) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/store/book/check',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
            'book_id': bookId,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return TablingReply.fromJson(body['reply_info']);
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return err.toString();
      }
    }
  }

  Future<dynamic> cancelBook(
      String userDiv, String userId, String userToken, String bookId) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/store/book/cancel',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
            'book_id': bookId,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return true;
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return err.toString();
      }
    }
  }

  Future<dynamic> getAdStoreInfo(
      String userDiv, String userId, String userToken) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/adver/info',
          ),
          body: jsonEncode(<String, String>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return AdStoreInfo.fromJson(body);
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return err.toString();
      }
    }
  }

  Future<dynamic> requestAdInfo(
      String userDiv, String userId, String userToken, AdStoreInfo data) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/adver/reset',
          ),
          body: jsonEncode(<String, dynamic>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
            'adver_set_info': data,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return true;
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return err.toString();
      }
    }
  }

  Future<dynamic> postCustIdea(String userDiv, String userId, String userToken,
      String ideaDetail) async {
    try {
      final res = await http.post(
          Uri(
            scheme: 'http',
            host: _hostAddress,
            path: '$path/user/idea',
          ),
          body: jsonEncode(<String, dynamic>{
            'user_div': userDiv,
            'user_id': userId,
            'user_token': userToken,
            'idea_detail': ideaDetail,
          }));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['status_code'] == 200) {
          return true;
        } else {
          return body['status_message'];
        }
      } else if (res.statusCode == 500) {
        return 'internal server error';
      } else {
        return 'unknown error';
      }
    } catch (err) {
      if (err is SocketException) {
        return 'SOCKET_EXCEPTION';
      } else if (err is TimeoutException) {
        return 'SERVER_TIMEOUT';
      } else {
        return err.toString();
      }
    }
  }

  Future<bool> checkLinkAvailable() async {
    try {
      final res = await http.get(Uri(
        scheme: 'http',
        host: 'itgocorp.com',
        path: 'applink.php',
      ));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        return body['link'] == 'found' ? true : false;
      } else {
        return false;
      }
    } catch (err) {
      return false;
    }
  }
}
