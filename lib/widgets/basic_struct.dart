import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:safetouch/widgets/contained_button.dart';
import 'package:safetouch/widgets/void_button.dart';
import '../firebase_options.dart';
import 'package:go_router/go_router.dart';
import 'package:safetouch/consts/sizes.dart';
import 'package:safetouch/models/models.dart';
import 'package:safetouch/providers/platform_provider.dart';
import 'package:safetouch/providers/session_provider.dart';
import 'package:safetouch/services/api_service.dart';
import 'package:safetouch/services/encrypted_storage_service.dart';
import 'package:safetouch/widgets/pop_dialog.dart';

class BasicStruct extends StatefulWidget {
  final bool isMenuList;
  final Widget childWidget;
  final Color appbarColor;
  final bool? showPop;

  const BasicStruct({
    required this.isMenuList,
    required this.childWidget,
    required this.appbarColor,
    this.showPop = true,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BasicStruct();
}

class _BasicStruct extends State<BasicStruct> {
  bool _isMenuOpened = false;
  ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    EncryptedStorageService().initStorage();
  }

  Future<bool> _onWillPop() async {
    if (GoRouter.of(context).location == '/main' ||
        GoRouter.of(context).location == '/' ||
        GoRouter.of(context).location == '/signup') {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.white,
                child: Container(
                    padding: EdgeInsets.only(
                      left: context.hPadding,
                      right: context.hPadding,
                      top: context.hPadding * 1.2,
                      bottom: context.hPadding * 1.2,
                    ),
                    width: context.pWidth * 0.75,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('알림',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: context.contentsTextSize * 2,
                              fontWeight: FontWeight.bold)),
                      Padding(
                        padding: EdgeInsets.all(context.hPadding * 0.5),
                      ),
                      Text('세이프터치 앱을 종료하시겠습니까?',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: context.contentsTextSize * 1.1,
                              fontWeight: FontWeight.bold)),
                      Padding(
                        padding: EdgeInsets.all(context.hPadding * 0.8),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ContainedButton(
                              onPressed: () => Navigator.pop(context, false),
                              text: '취소',
                              boxWidth: context.pWidth * 0.29,
                              color: Colors.grey[300]!,
                              textSize: context.contentsTextSize,
                              textColor: Colors.black54,
                            ),
                            ContainedButton(
                                onPressed: () => Navigator.pop(context, true),
                                color: Colors.black,
                                text: '확인',
                                boxWidth: context.pWidth * 0.29,
                                textSize: context.contentsTextSize),
                          ])
                    ])));
          }).then((value) {
        return value;
      });
    } else {
      context.goNamed('main');
      return false;
    }
  }

  void _renderDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            image: AssetImage('asset/icons/document.png'),
            imageColor: Colors.black,
            textWidget: Column(children: [
              Padding(padding: EdgeInsets.all(context.hPadding * 0.2)),
              Text('이용안내',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.6,
                      fontWeight: FontWeight.bold)),
              Padding(padding: EdgeInsets.all(context.hPadding * 0.2)),
              Text('스마트사이니지 세이프터치 기기에서',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.2,
                      fontWeight: FontWeight.bold)),
              Text('QR스캔으로 이용하는 앱입니다.',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.2,
                      fontWeight: FontWeight.bold)),
              Padding(padding: EdgeInsets.all(context.hPadding * 0.2)),
              Text('주변 스마트사이니지 세이프터치',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.1,
                      fontWeight: FontWeight.normal)),
              Text('상점정보에서 방문하고싶은 상점을 터치!',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.1,
                      fontWeight: FontWeight.normal)),
              Text('QR스캔하면 빈자리확인, 예약, 문의',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.1,
                      fontWeight: FontWeight.normal)),
              Text('화면으로 자동연결후 앱설치하고',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.1,
                      fontWeight: FontWeight.normal)),
              Text('이용하세요',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.1,
                      fontWeight: FontWeight.normal)),
            ]),
            onPressed: () {
              Navigator.pop(context);
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading =
        Provider.of<Platform>(context, listen: true).isLoading;
    return WillPopScope(
      child: SafeArea(
          top: true,
          bottom: false,
          child: Stack(children: [
            Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.white,
                appBar: PreferredSize(
                  preferredSize: Size(context.pWidth, context.pHeight * 0.09),
                  child: _renderAppBar(),
                ),
                body: widget.childWidget),
            _isMenuOpened ? renderMenu() : const SizedBox(),
            isLoading ? renderLoading() : const SizedBox()
          ])),
      onWillPop: () => _onWillPop(),
    );
  }

  void _onTapSignout() async {
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    platformProvider.isLoading = true;
    await _apiService
        .requestSignOut(
            platformProvider.userDiv,
            sessionProvider.sessionData.userId,
            sessionProvider.sessionData.userToken)
        .then((value) async {
      if (value is String) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value),
            backgroundColor: Colors.black87.withOpacity(0.6),
            duration: const Duration(seconds: 2)));
      } else {
        sessionProvider.sessionData = SessionData.initialize();
        sessionProvider.storeInfo = StoreInfo.initialize();
        sessionProvider.customerInfo = CustomerInfo.initialize();
        platformProvider.userDiv = '';
        await EncryptedStorageService().saveData('auto_login', 'false');
        await EncryptedStorageService().removeData('user_div');
        await EncryptedStorageService().removeData('store_name');
        await EncryptedStorageService().removeData('store_pwd');
        await EncryptedStorageService().removeData('user_name');
        await EncryptedStorageService()
            .removeData('user_phone')
            .whenComplete(() {
          setState(() => _isMenuOpened = false);
          context.goNamed('signin');
        });
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  Widget _renderAppBar() {
    return Container(
        color: widget.appbarColor,
        alignment: Alignment.center,
        child: Stack(alignment: Alignment.center, children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('스마트사이니지',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.vPadding * 1.6,
                        fontWeight: FontWeight.bold)),
                Padding(
                  padding: EdgeInsets.all(context.vPadding * 0.1),
                ),
                Text('세이프터치',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.vPadding * 1.6,
                        fontWeight: FontWeight.bold)),
              ]),
          context.canPop() &&
                  widget.showPop! &&
                  GoRouter.of(context).location != '/main' &&
                  GoRouter.of(context).location != '/'
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                      onTap: () => context.pop(),
                      child: Container(
                          padding: EdgeInsets.all(context.hPadding),
                          child: Icon(Icons.arrow_back_ios,
                              color: Colors.black,
                              size: context.pWidth * 0.06))))
              : const SizedBox(),
          widget.isMenuList
              ? Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                      onTap: () => setState(() => _isMenuOpened = true),
                      child: Container(
                          color: Colors.black87,
                          width: context.pWidth * 0.2,
                          height: context.pWidth * 0.2,
                          child: Icon(Icons.list,
                              color: Colors.white,
                              size: context.pWidth * 0.12))))
              : const SizedBox()
        ]));
  }

  Widget renderLoading() {
    return Material(
        type: MaterialType.transparency,
        child: Container(
            width: context.pWidth,
            height: context.pHeight,
            color: Colors.black.withOpacity(0.4),
            child: Center(
                child: CupertinoActivityIndicator(
              animating: true,
              radius: context.pWidth * 0.05,
            ))));
  }

  Widget renderMenu() {
    final userDiv = Provider.of<Platform>(context, listen: false).userDiv;
    return Material(
        type: MaterialType.transparency,
        child: ClipRect(
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                    width: context.pWidth,
                    height: context.pHeight,
                    padding: EdgeInsets.only(
                      top: context.vPadding * 2,
                      bottom: context.vPadding * 2,
                      left: context.hPadding,
                      right: context.hPadding,
                    ),
                    color: Colors.black.withOpacity(0.7),
                    child: userDiv == '1'
                        ?
                        // Store
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Column(
                                  children: [
                                    InkWell(
                                        onTap: () => setState(
                                            () => _isMenuOpened = false),
                                        child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Icon(
                                              Icons.close,
                                              size: context.pWidth * 0.12,
                                              color: Colors.white,
                                            ))),
                                    Padding(
                                      padding:
                                          EdgeInsets.all(context.vPadding * 2),
                                    ),
                                    InkWell(
                                        onTap: () => context.goNamed('main'),
                                        child: Text('메인 페이지',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    context.contentsTextSize *
                                                        1.5,
                                                fontWeight: FontWeight.bold))),
                                    Padding(
                                      padding:
                                          EdgeInsets.all(context.vPadding * 2),
                                    ),
                                    InkWell(
                                        onTap: () =>
                                            context.goNamed('add_store'),
                                        child: Text('상점정보 등록',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    context.contentsTextSize *
                                                        1.5,
                                                fontWeight: FontWeight.bold))),
                                    Padding(
                                      padding:
                                          EdgeInsets.all(context.vPadding * 2),
                                    ),
                                    InkWell(
                                        onTap: () =>
                                            context.goNamed('add_event'),
                                        child: Text('상점 이벤트 등록',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    context.contentsTextSize *
                                                        1.5,
                                                fontWeight: FontWeight.bold))),
                                    Padding(
                                      padding:
                                          EdgeInsets.all(context.vPadding * 2),
                                    ),
                                    InkWell(
                                        onTap: () => context
                                            .goNamed('table_store_avail'),
                                        child: Text('상점 빈자리 확인 내역',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    context.contentsTextSize *
                                                        1.5,
                                                fontWeight: FontWeight.bold))),
                                    Padding(
                                      padding:
                                          EdgeInsets.all(context.vPadding * 2),
                                    ),
                                    InkWell(
                                        onTap: () => context
                                            .goNamed('reserv_store_avail'),
                                        child: Text('상점 예약 내역',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    context.contentsTextSize *
                                                        1.5,
                                                fontWeight: FontWeight.bold))),
                                    Padding(
                                      padding:
                                          EdgeInsets.all(context.vPadding * 2),
                                    ),
                                    InkWell(
                                        onTap: () =>
                                            context.goNamed('app_review_view'),
                                        child: Text('설문조사 / 이벤트 / 아이디어',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    context.contentsTextSize *
                                                        1.5,
                                                fontWeight: FontWeight.bold))),
                                  ],
                                ),
                                Column(children: [
                                  ContainedButton(
                                    onPressed: () {
                                      context.goNamed('edit_account');
                                    },
                                    color: Colors.orange,
                                    text: '회원정보 수정하기',
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.all(context.hPadding * 0.4),
                                  ),
                                  Container(
                                      width: context.pWidth,
                                      child: InkWell(
                                          onTap: () => _onTapSignout(),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text('로그아웃',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize:
                                                          context.pWidth * 0.05,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Padding(
                                                  padding: EdgeInsets.all(
                                                      context.hPadding * 0.2)),
                                              Image(
                                                  image: AssetImage(
                                                      'asset/icons/logout.png'),
                                                  color: Colors.grey,
                                                  width: context.pWidth * 0.05,
                                                  height:
                                                      context.pWidth * 0.05),
                                            ],
                                          )))
                                ])
                              ])
                        // Customer
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Column(
                                  children: [
                                    InkWell(
                                        onTap: () => setState(
                                            () => _isMenuOpened = false),
                                        child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Icon(
                                              Icons.close,
                                              size: context.pWidth * 0.12,
                                              color: Colors.white,
                                            ))),
                                    Padding(
                                      padding:
                                          EdgeInsets.all(context.vPadding * 2),
                                    ),
                                    InkWell(
                                        onTap: () => context.goNamed('main'),
                                        child: Text('메인 페이지',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    context.contentsTextSize *
                                                        1.5,
                                                fontWeight: FontWeight.bold))),
                                    Padding(
                                      padding:
                                          EdgeInsets.all(context.vPadding * 2),
                                    ),
                                    InkWell(
                                        onTap: () => _renderDialog(),
                                        child: Text('예약 / 상점 빈자리확인 / 문의',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    context.contentsTextSize *
                                                        1.5,
                                                fontWeight: FontWeight.bold))),
                                    Padding(
                                      padding:
                                          EdgeInsets.all(context.vPadding * 2),
                                    ),
                                    InkWell(
                                        onTap: () =>
                                            context.goNamed('table_cust_avail'),
                                        child: Text('고객 빈자리확인 내역',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    context.contentsTextSize *
                                                        1.5,
                                                fontWeight: FontWeight.bold))),
                                    Padding(
                                      padding:
                                          EdgeInsets.all(context.vPadding * 2),
                                    ),
                                    InkWell(
                                        onTap: () => context
                                            .goNamed('reserv_cust_avail'),
                                        child: Text('고객 예약 내역',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    context.contentsTextSize *
                                                        1.5,
                                                fontWeight: FontWeight.bold))),
                                    Padding(
                                      padding:
                                          EdgeInsets.all(context.vPadding * 2),
                                    ),
                                    InkWell(
                                        onTap: () => context
                                            .goNamed('noti_setting_view'),
                                        child: Text('정보수신서비스',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    context.contentsTextSize *
                                                        1.5,
                                                fontWeight: FontWeight.bold))),
                                    Padding(
                                      padding:
                                          EdgeInsets.all(context.vPadding * 2),
                                    ),
                                    InkWell(
                                        onTap: () =>
                                            context.goNamed('app_review_view'),
                                        child: Text('설문조사 / 이벤트 / 아이디어',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    context.contentsTextSize *
                                                        1.5,
                                                fontWeight: FontWeight.bold))),
                                  ],
                                ),
                                Column(children: [
                                  ContainedButton(
                                    onPressed: () {
                                      context.goNamed('edit_account');
                                    },
                                    color: Colors.yellow,
                                    text: '회원정보 수정하기',
                                    textColor: Colors.black,
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.all(context.hPadding * 0.4),
                                  ),
                                  Container(
                                      width: context.pWidth,
                                      child: Column(children: [
                                        InkWell(
                                            onTap: () => _onTapSignout(),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text('로그아웃',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize:
                                                            context.pWidth *
                                                                0.05,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Padding(
                                                    padding: EdgeInsets.all(
                                                        context.hPadding *
                                                            0.2)),
                                                Image(
                                                    image: AssetImage(
                                                        'asset/icons/logout.png'),
                                                    color: Colors.grey,
                                                    width:
                                                        context.pWidth * 0.05,
                                                    height:
                                                        context.pWidth * 0.05),
                                              ],
                                            ))
                                      ]))
                                ])
                              ])))));
  }
}
