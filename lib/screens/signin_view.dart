import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:safetouch/providers/platform_provider.dart';
import 'package:safetouch/providers/session_provider.dart';
import 'package:safetouch/consts/sizes.dart';
import 'package:safetouch/widgets/basic_struct.dart';
import 'package:safetouch/widgets/bottom_buttons.dart';
import 'package:safetouch/widgets/void_button.dart';
import 'package:safetouch/services/api_service.dart';
import 'package:safetouch/models/models.dart';
import 'package:safetouch/services/encrypted_storage_service.dart';
import 'package:safetouch/widgets/pop_dialog.dart';

class SigninView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SigninView();
}

class _SigninView extends State<SigninView> with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _bStoreNameController;
  late TextEditingController _bStorePwdController;
  late TextEditingController _cUserNameController;
  late TextEditingController _cPhoneNumController;
  bool isLoading = false;
  int _tabSel = 0;
  bool _bAutologin = false;
  bool _cAutologin = false;

  ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initData() async {
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
    _bStoreNameController = TextEditingController(text: '');
    _bStorePwdController = TextEditingController(text: '');
    _cUserNameController = TextEditingController(text: '');
    _cPhoneNumController = TextEditingController(text: '');
    //_initDaegyo();
    await EncryptedStorageService().initStorage();
    await _getSecureStorageData();
  }

  void _initDaegyo() {
    _bStoreNameController.text = '㈜대교통신';
    _bStorePwdController.text = 'Password';
    _cUserNameController.text = '테스트';
    _cPhoneNumController.text = '01011111111';
    //_cUserNameController.text = '정재원';
    //_cPhoneNumController.text = '01027713958';
  }

  Future<void> _getSecureStorageData() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    await EncryptedStorageService().readData('auto_login').then((value) async {
      if (value == 'true') {
        final userDiv = await EncryptedStorageService().readData('user_div');
        if (userDiv == '1') {
          final storeName =
              await EncryptedStorageService().readData('store_name');
          final storePwd =
              await EncryptedStorageService().readData('store_pwd');
          platformProvider.isLoading = true;
          await _apiService
              .requestSignin(
                  userDiv, platformProvider.osDiv, storeName, storePwd)
              .then((value) {
            if (value is String) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(value),
                  backgroundColor: Colors.black87.withOpacity(0.6),
                  duration: const Duration(seconds: 2)));
            } else {
              Provider.of<Session>(context, listen: false).sessionData = value;
              Provider.of<Platform>(context, listen: false).userDiv = userDiv;
              Provider.of<Session>(context, listen: false).storeInfo =
                  StoreInfo(storeName: storeName, userPwd: storePwd);
              _updateFcmToken();
            }
          }).whenComplete(() {
            Provider.of<Platform>(context, listen: false).isLoading = false;
          });
        } else if (userDiv == '2') {
          final userName =
              await EncryptedStorageService().readData('user_name');
          final userPhone =
              await EncryptedStorageService().readData('user_phone');
          platformProvider.isLoading = true;
          await _apiService
              .requestSignin(
                  userDiv, platformProvider.osDiv, userName, userPhone)
              .then((value) {
            if (value is String) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(value),
                  backgroundColor: Colors.black87.withOpacity(0.6),
                  duration: const Duration(seconds: 2)));
            } else {
              Provider.of<Session>(context, listen: false).sessionData = value;
              Provider.of<Platform>(context, listen: false).userDiv = userDiv;
              Provider.of<Session>(context, listen: false).customerInfo =
                  CustomerInfo(userName: userName, phoneNum: userPhone);
              _updateFcmToken();
            }
          }).whenComplete(() {
            Provider.of<Platform>(context, listen: false).isLoading = false;
          });
        }
      }
    });
  }

  void _onTapSignin(String userDiv) {
    if (userDiv == 'store') {
      _storeSignin().then((value) {
        if (value) {
          _updateFcmToken();
        }
      });
    } else if (userDiv == 'cust') {
      _custSignin().then((value) {
        if (value) {
          _updateFcmToken();
        }
      });
    }
  }

  Future<bool> _storeSignin() {
    Provider.of<Platform>(context, listen: false).isLoading = true;
    return _apiService
        .requestSignin(
            (_tabSel + 1).toString(),
            Provider.of<Platform>(context, listen: false).osDiv,
            _bStoreNameController.text,
            _bStorePwdController.text)
        .then((value) async {
      if (value is String) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value),
            backgroundColor: Colors.black87.withOpacity(0.6),
            duration: const Duration(seconds: 2)));
        return false;
      } else if (value is Map<String, dynamic>) {
        _renderDialog(value['status_message']);
        return false;
      } else {
        Provider.of<Session>(context, listen: false).sessionData = value;
        Provider.of<Platform>(context, listen: false).userDiv = '1';
        Provider.of<Session>(context, listen: false).storeInfo = StoreInfo(
            storeName: _bStoreNameController.text,
            userPwd: _bStorePwdController.text);
        await EncryptedStorageService()
            .saveData('auto_login', _bAutologin ? 'true' : 'false');
        if (_bAutologin) {
          await EncryptedStorageService()
              .saveData('user_div', (_tabSel + 1).toString());
          await EncryptedStorageService()
              .saveData('store_name', _bStoreNameController.text);
          await EncryptedStorageService()
              .saveData('store_pwd', _bStorePwdController.text);
        } else {
          await EncryptedStorageService().removeData('user_div');
          await EncryptedStorageService().removeData('store_name');
          await EncryptedStorageService().removeData('store_pwd');
        }
        return true;
      }
    }).whenComplete(() {
      Provider.of<Platform>(context, listen: false).isLoading = false;
    });
  }

  Future<bool> _custSignin() {
    Provider.of<Platform>(context, listen: false).isLoading = true;
    return _apiService
        .requestSignin(
            (_tabSel + 1).toString(),
            Provider.of<Platform>(context, listen: false).osDiv,
            _cUserNameController.text,
            _cPhoneNumController.text)
        .then((value) async {
      if (value is String) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value),
            backgroundColor: Colors.black87.withOpacity(0.6),
            duration: const Duration(seconds: 2)));
        return false;
      } else if (value is Map<String, dynamic>) {
        _renderDialog(value['status_message']);
        return false;
      } else {
        Provider.of<Session>(context, listen: false).sessionData = value;
        Provider.of<Platform>(context, listen: false).userDiv = '2';
        Provider.of<Session>(context, listen: false).customerInfo =
            CustomerInfo(
                userName: _cUserNameController.text,
                phoneNum: _cPhoneNumController.text);

        await EncryptedStorageService()
            .saveData('auto_login', _cAutologin ? 'true' : 'false');
        if (_cAutologin) {
          await EncryptedStorageService()
              .saveData('user_div', (_tabSel + 1).toString());
          await EncryptedStorageService()
              .saveData('user_name', _cUserNameController.text);
          await EncryptedStorageService()
              .saveData('user_phone', _cPhoneNumController.text);
        } else {
          await EncryptedStorageService().removeData('user_div');
          await EncryptedStorageService().removeData('user_name');
          await EncryptedStorageService().removeData('user_phone');
        }
        return true;
      }
    }).whenComplete(() {
      Provider.of<Platform>(context, listen: false).isLoading = false;
    });
  }

  void _updateFcmToken() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final sessionProvider = Provider.of<Session>(context, listen: false);
    await FirebaseMessaging.instance.getToken().then((value) {
      print(value);
      Provider.of<Platform>(context, listen: false).fcmToken = value!;
    });
    platformProvider.isLoading = true;
    _apiService
        .updatePushToken(
            platformProvider.userDiv,
            sessionProvider.sessionData.userId,
            sessionProvider.sessionData.userToken,
            platformProvider.fcmToken)
        .then((value) {
      if (value is String) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value),
            backgroundColor: Colors.black87.withOpacity(0.6),
            duration: const Duration(seconds: 2)));
      } else {
        context.goNamed('main');
      }
    }).whenComplete(() =>
            Provider.of<Platform>(context, listen: false).isLoading = false);
  }

  void _pressedSignUp() {
    context.pushNamed('signup', extra: _tabSel);
  }

  void _onToggleBAutoLogin(bool? val) {
    setState(() => _bAutologin = val!);
  }

  void _onToggleCAutoLogin(bool? val) {
    setState(() => _cAutologin = val!);
  }

  void _renderDialog(String msg) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            image: AssetImage('asset/icons/smile.png'),
            imageColor: Colors.black,
            textWidget: Column(children: [
              Text(msg,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.2,
                      fontWeight: FontWeight.bold)),
            ]),
            onPressed: () {
              Navigator.pop(context);
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return BasicStruct(
        isMenuList: false,
        appbarColor: _tabSel == 0 ? Colors.orange : Colors.yellow,
        childWidget: Stack(children: [
          Container(
              color: Colors.white,
              width: context.pWidth,
              height: context.pHeight,
              alignment: Alignment.center,
              child: Column(children: [
                renderTabBar(),
                Expanded(
                    child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [renderBusinessSignin(), renderCustomerSignin()],
                ))
              ])),
          BottomButtons(
            btn3Enabled: true,
            btn3Text: '회원가입',
            btn3Color: Colors.black,
            btn3Pressed: () => _pressedSignUp(),
          )
        ]));
  }

  Widget renderTabBar() {
    return Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 1))),
        child: TabBar(
          controller: _tabController,
          onTap: (value) => setState(() => _tabSel = value),
          tabs: [
            Tab(
                child: Text('상점주',
                    style: TextStyle(
                        color: _tabSel == 0 ? Colors.black : Colors.grey,
                        fontSize: context.contentsTextSize * 1.2,
                        fontWeight: FontWeight.bold))),
            Tab(
                child: Text('고객님',
                    style: TextStyle(
                        color: _tabSel == 1 ? Colors.black : Colors.grey,
                        fontSize: context.contentsTextSize * 1.2,
                        fontWeight: FontWeight.bold))),
          ],
        ));
  }

  Widget renderBusinessSignin() {
    return Container(
        width: context.pWidth,
        padding: EdgeInsets.only(
          left: context.pWidth * 0.1,
          right: context.pWidth * 0.1,
        ),
        alignment: Alignment.topCenter,
        child: SizedBox(
            width: context.pWidth,
            height: context.pHeight * 0.4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('상점명',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.contentsTextSize * 1.2,
                            fontWeight: FontWeight.bold)),
                    TextField(
                        controller: _bStoreNameController,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                            constraints: BoxConstraints(
                              maxWidth: context.pWidth * 0.55,
                              maxHeight: context.pHeight * 0.05,
                            ),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1),
                                borderRadius: BorderRadius.circular(
                                    context.pWidth * 0.02))))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('비밀번호',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.contentsTextSize * 1.2,
                            fontWeight: FontWeight.bold)),
                    TextField(
                      controller: _bStorePwdController,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                          constraints: BoxConstraints(
                            maxWidth: context.pWidth * 0.55,
                            maxHeight: context.pHeight * 0.05,
                          ),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(
                                  context.pWidth * 0.02))),
                      obscureText: true,
                    )
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Row(children: [
                    SizedBox(
                        width: context.pWidth * 0.05,
                        height: context.pWidth * 0.05,
                        child: Checkbox(
                            side: BorderSide(color: Colors.grey),
                            value: _bAutologin,
                            onChanged: (val) => _onToggleBAutoLogin(val))),
                    Padding(
                        padding:
                            EdgeInsets.only(right: context.hPadding * 0.5)),
                    Text('로그인 유지',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: context.contentsTextSize,
                            fontWeight: FontWeight.normal)),
                  ])
                ]),
                VoidButton(
                  text: '로그인',
                  onPressed: () => _onTapSignin('store'),
                )
              ],
            )));
  }

  Widget renderCustomerSignin() {
    return Container(
        width: context.pWidth,
        padding: EdgeInsets.only(
          left: context.pWidth * 0.1,
          right: context.pWidth * 0.1,
        ),
        alignment: Alignment.topCenter,
        child: SizedBox(
            width: context.pWidth,
            height: context.pHeight * 0.4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('고객명',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.contentsTextSize * 1.2,
                            fontWeight: FontWeight.bold)),
                    TextField(
                        controller: _cUserNameController,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                            constraints: BoxConstraints(
                              maxWidth: context.pWidth * 0.55,
                              maxHeight: context.pHeight * 0.05,
                            ),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1),
                                borderRadius: BorderRadius.circular(
                                    context.pWidth * 0.02))))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('휴대폰번호',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.contentsTextSize * 1.2,
                            fontWeight: FontWeight.bold)),
                    TextField(
                      controller: _cPhoneNumController,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                          constraints: BoxConstraints(
                            maxWidth: context.pWidth * 0.55,
                            maxHeight: context.pHeight * 0.05,
                          ),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(
                                  context.pWidth * 0.02))),
                      keyboardType: TextInputType.number,
                    )
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Row(children: [
                    SizedBox(
                        width: context.pWidth * 0.05,
                        height: context.pWidth * 0.05,
                        child: Checkbox(
                            side: BorderSide(color: Colors.grey),
                            value: _cAutologin,
                            onChanged: (val) => _onToggleCAutoLogin(val))),
                    Padding(
                        padding:
                            EdgeInsets.only(right: context.hPadding * 0.5)),
                    Text('로그인 유지',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: context.contentsTextSize,
                            fontWeight: FontWeight.normal)),
                  ])
                ]),
                VoidButton(
                  text: '로그인',
                  onPressed: () => _onTapSignin('cust'),
                )
              ],
            )));
  }
}
