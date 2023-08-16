import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:safetouch/models/ad_store_info.dart';
import 'package:safetouch/providers/platform_provider.dart';
import 'package:safetouch/providers/session_provider.dart';
import 'package:safetouch/consts/sizes.dart';
import 'package:safetouch/widgets/basic_struct.dart';
import 'package:safetouch/widgets/bottom_buttons.dart';
import 'package:safetouch/widgets/title_band.dart';
import 'package:safetouch/widgets/pop_dialog.dart';
import 'package:safetouch/models/models.dart';
import 'package:safetouch/services/api_service.dart';

class NotificationSettingView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationSettingView();
}

class _NotificationSettingView extends State<NotificationSettingView> {
  final ApiService _apiService = ApiService();
  //bool _isNotiOpened = false;
  //bool _isAgreeOpened = false;
  ValueNotifier<List<String>> _selCatList = ValueNotifier<List<String>>([]);
  ValueNotifier<String> _selTime = ValueNotifier<String>('');
  ValueNotifier<String> _getMsg = ValueNotifier<String>('');
  ValueNotifier<String> _agreed = ValueNotifier<String>('');
  bool _isEnabled = false;
  bool _onProgress = false;
  late Future<dynamic> _dataFuture;
  final List<String> _timeList = ['', '1시간', '6시간', '12시간', '24시간'];

  @override
  void initState() {
    super.initState();
    _initData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<Platform>(context, listen: false).isLoading = true;
    });
  }

  void _initData() {
    _dataFuture = _getAdStoreInfo();
  }

  Future<dynamic> _getAdStoreInfo() {
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    return _apiService
        .getAdStoreInfo(
            platformProvider.userDiv,
            sessionProvider.sessionData.userId,
            sessionProvider.sessionData.userToken)
        .then((value) {
      if (value is String) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value),
            backgroundColor: Colors.black87.withOpacity(0.6),
            duration: const Duration(seconds: 2)));
        return null;
      } else {
        _selCatList.value = value.catIdList;
        final String temp = value.rcvTimeDiv as String;
        _selTime.value = _timeList[int.parse(temp)];
        _getMsg.value = value.rcvFlag == '0' ? '아니오' : '예';
        _onProgress = _checkIsOnProgress(value.updatedTime);
        _checkInput();
        return value;
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  bool _checkIsOnProgress(String updatedTime) {
    if (_getMsg.value == '예') {
      if (updatedTime.isEmpty) {
        return false;
      }
      final DateTime thisTime = DateTime.now();
      final int duration = _selTime.value == '1시간'
          ? 1
          : _selTime.value == '6시간'
              ? 6
              : _selTime.value == '12시간'
                  ? 12
                  : _selTime.value == '24시간'
                      ? 24
                      : 0;
      final expiredTime = DateTime(
          int.parse(updatedTime.substring(0, 4)),
          int.parse(updatedTime.substring(4, 6)),
          int.parse(updatedTime.substring(6, 8)),
          int.parse(updatedTime.substring(8, 10)) + duration,
          int.parse(updatedTime.substring(10, 12)));
      return thisTime.isBefore(expiredTime);
    } else {
      return false;
    }
  }

  void _onSelCatListChanged(CategoryInfo cat, bool isSel) {
    setState(() => isSel
        ? _selCatList.value.add(cat.id)
        : _selCatList.value.remove(cat.id));
    _checkInput();
  }

  void _onSelTimeChanged(String time) {
    _selTime.value = time;
    _checkInput();
  }

  void _onGetMsgChanged(String getMsg) {
    _getMsg.value = getMsg;
    _checkInput();
  }

  void _onAgreeChanged(bool agreed) {
    if (agreed) {
      _agreed.value = '예';
    } else {
      _agreed.value = '';
    }
    _checkInput();
  }

  void _checkInput() {
    bool temp = false;
    if (_selCatList.value.isNotEmpty && _selTime.value.isNotEmpty) {
      if (_onProgress) {
        if (_getMsg.value == '예') {
          temp = false;
        } else {
          temp = true;
        }
      } else {
        if (_agreed.value.isNotEmpty) {
          if (_getMsg.value == '예') {
            temp = true;
          } else {
            temp = false;
          }
        }
      }
    } else {
      temp = false;
    }
    setState(() => _isEnabled = temp);
  }

  void _onTapRequest() {
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    platformProvider.isLoading = true;
    _apiService
        .requestAdInfo(
            platformProvider.userDiv,
            sessionProvider.sessionData.userId,
            sessionProvider.sessionData.userToken,
            AdStoreInfo(
                catIdList: _selCatList.value,
                rcvTimeDiv: _timeList.indexOf(_selTime.value).toString(),
                rcvFlag: _getMsg.value == '예' ? '1' : '0'))
        .then((value) {
      if (value is String) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value),
            backgroundColor: Colors.black87.withOpacity(0.6),
            duration: const Duration(seconds: 2)));
      } else {
        _renderDialog();
        _updateAdStoreInfo();
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  void _renderDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            image: AssetImage('asset/icons/smile.png'),
            imageColor: Colors.black,
            textWidget: Column(children: [
              Text(_onProgress ? '정보수신서비스가 취소되었습니다.' : '정보수신서비스가 신청되었습니다.',
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

  void _updateAdStoreInfo() {
    Provider.of<Platform>(context, listen: false).isLoading = true;
    _dataFuture = _getAdStoreInfo();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BasicStruct(
        isMenuList: true,
        appbarColor: Colors.white,
        childWidget: SingleChildScrollView(
            controller: ScrollController(),
            child: FutureBuilder(
                future: _dataFuture,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.data != null) {
                    return Container(
                        color: Colors.white,
                        width: context.pWidth,
                        child: Column(children: [
                          TitleBand(
                              color: Colors.black12,
                              text: '고객님 서비스이용 감사합니다',
                              image: Image(
                                  image: AssetImage('asset/icons/smile.png'),
                                  width: context.pWidth * 0.2,
                                  height: context.pWidth * 0.2)),
                          _renderInfo(),
                          TitleBand(
                              color: Color.fromARGB(255, 109, 143, 206),
                              text: '정보수신서비스',
                              textColor: Colors.white,
                              //tailWidget: _renderToggleNoti(),
                              image: Image(
                                  color: Colors.white,
                                  image: AssetImage('asset/icons/key.png'),
                                  width: context.pWidth * 0.2,
                                  height: context.pWidth * 0.2)),
                          _renderNotiBody(snapshot.data),
                          Padding(
                            padding: EdgeInsets.all(context.hPadding * 0.7),
                          ),
                          TitleBand(
                              color: Color.fromARGB(255, 109, 143, 206),
                              text: '개인정보이용동의',
                              textColor: Colors.white,
                              //tailWidget: _renderToggleAgree(),
                              image: Image(
                                  color: Colors.white,
                                  image: AssetImage('asset/icons/key.png'),
                                  width: context.pWidth * 0.2,
                                  height: context.pWidth * 0.2)),
                          _renderAgreeBody(),
                          _renderAgreeInfo(),
                          BottomButtons(
                              btn3Enabled: _isEnabled,
                              btn3Text:
                                  _onProgress ? '정보수신서비스 취소하기' : '정보수신서비스 신청하기',
                              btn3Color:
                                  _isEnabled ? Colors.black : Colors.grey,
                              btn3Pressed: () =>
                                  _isEnabled ? _onTapRequest() : null)
                        ]));
                  } else {
                    return const SizedBox();
                  }
                })));
  }

  Widget _renderInfo() {
    return Container(
        width: context.pWidth,
        padding: EdgeInsets.all(context.hPadding * 1.2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\u2022',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: context.hPadding * 0.7,
                    fontWeight: FontWeight.bold)),
            Padding(padding: EdgeInsets.all(context.hPadding * 0.1)),
            Container(
                width: context.pWidth - context.hPadding * 3,
                child: Text('스마트사이니지에 다양한 정보 수신을 선택해서 받을 수 있습니다.',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.hPadding * 0.65,
                        fontWeight: FontWeight.normal))),
          ],
        ));
  }

/*
  Widget _renderToggleNoti() {
    return InkWell(
        onTap: () => setState(() => _isNotiOpened = !_isNotiOpened),
        child: Container(
            padding: EdgeInsets.only(
              top: context.hPadding * 0.1,
              bottom: context.hPadding * 0.1,
              left: context.hPadding * 0.6,
              right: context.hPadding * 0.2,
            ),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(5),
                color: Colors.transparent),
            child: Row(
              children: [
                Text('내용보기',
                    style: TextStyle(
                        fontSize: context.contentsTextSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Icon(
                    _isNotiOpened
                        ? Icons.arrow_drop_up_outlined
                        : Icons.arrow_drop_down_outlined,
                    color: Colors.white,
                    size: context.contentsIconSize)
              ],
            )));
  }

  Widget _renderToggleAgree() {
    return InkWell(
        onTap: () => setState(() => _isAgreeOpened = !_isAgreeOpened),
        child: Container(
            padding: EdgeInsets.only(
              top: context.hPadding * 0.1,
              bottom: context.hPadding * 0.1,
              left: context.hPadding * 0.6,
              right: context.hPadding * 0.2,
            ),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(5),
                color: Colors.transparent),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('내용보기',
                    style: TextStyle(
                        fontSize: context.contentsTextSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Icon(
                    _isAgreeOpened
                        ? Icons.arrow_drop_up_outlined
                        : Icons.arrow_drop_down_outlined,
                    color: Colors.white,
                    size: context.contentsIconSize)
              ],
            )));
  }
*/
  Widget _renderNotiBody(AdStoreInfo data) {
    return
        //_isNotiOpened        ?
        Container(
            width: context.pWidth,
            color: const Color.fromARGB(255, 235, 237, 253),
            padding: EdgeInsets.only(
              top: context.hPadding,
              bottom: context.hPadding,
              left: context.hPadding * 1.2,
              right: context.hPadding * 1.2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('이벤트 & 쿠폰정보를 받고싶은 업종을 선택해주세요',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.contentsTextSize,
                        fontWeight: FontWeight.bold)),
                Padding(
                  padding: EdgeInsets.all(context.hPadding * 0.3),
                ),
                ValueListenableBuilder(
                    valueListenable: _selCatList,
                    builder: (BuildContext context, List<String> list, _) {
                      return SizedBox(
                          width: context.pWidth,
                          child: Wrap(
                              alignment: WrapAlignment.start,
                              children: data.catList!.map((CategoryInfo cat) {
                                final bool isCatRight = list.contains(cat.id);
                                return Container(
                                    width: context.pWidth * 0.26,
                                    margin: EdgeInsets.all(
                                      context.vPadding * 0.5,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                            margin: EdgeInsets.zero,
                                            width: context.hPadding * 0.5,
                                            height: context.hPadding * 0.5,
                                            child: Checkbox(
                                                value: isCatRight,
                                                onChanged: (val) {
                                                  _onSelCatListChanged(
                                                      cat, val!);
                                                })),
                                        Padding(
                                          padding: EdgeInsets.all(
                                              context.hPadding * 0.6),
                                        ),
                                        Text(cat.name,
                                            style: TextStyle(
                                                color: isCatRight
                                                    ? Colors.black
                                                    : Colors.black54,
                                                fontSize:
                                                    context.contentsTextSize,
                                                fontWeight: isCatRight
                                                    ? FontWeight.bold
                                                    : FontWeight.normal))
                                      ],
                                    ));
                              }).toList()));
                    }),
                Padding(
                  padding: EdgeInsets.all(context.hPadding * 0.5),
                ),
                Text('정보 수신 시간을 선택해주세요',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.contentsTextSize,
                        fontWeight: FontWeight.bold)),
                Padding(
                  padding: EdgeInsets.all(context.hPadding * 0.3),
                ),
                ValueListenableBuilder(
                    valueListenable: _selTime,
                    builder: (BuildContext context, String selTime, _) {
                      return SizedBox(
                          width: context.pWidth,
                          child: Wrap(
                              alignment: WrapAlignment.start,
                              children: _timeList.map((String time) {
                                if (time.isNotEmpty) {
                                  final bool isCatRight = selTime == time;
                                  return Container(
                                      width: context.pWidth * 0.26,
                                      margin: EdgeInsets.all(
                                        context.vPadding * 0.5,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                              margin: EdgeInsets.zero,
                                              width: context.hPadding * 0.5,
                                              height: context.hPadding * 0.5,
                                              child: Checkbox(
                                                  value: isCatRight,
                                                  onChanged: (val) {
                                                    if (val!) {
                                                      _onSelTimeChanged(time);
                                                    }
                                                  })),
                                          Padding(
                                            padding: EdgeInsets.all(
                                                context.hPadding * 0.6),
                                          ),
                                          Text(time,
                                              style: TextStyle(
                                                  color: isCatRight
                                                      ? Colors.black
                                                      : Colors.black54,
                                                  fontSize:
                                                      context.contentsTextSize,
                                                  fontWeight: isCatRight
                                                      ? FontWeight.bold
                                                      : FontWeight.normal))
                                        ],
                                      ));
                                } else {
                                  return const SizedBox();
                                }
                              }).toList()));
                    }),
                Padding(
                  padding: EdgeInsets.all(context.hPadding * 0.5),
                ),
                Text('선택하신 내용으로 정보수신을 받으시겠습니까?',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.contentsTextSize,
                        fontWeight: FontWeight.bold)),
                Padding(
                  padding: EdgeInsets.all(context.hPadding * 0.3),
                ),
                ValueListenableBuilder(
                    valueListenable: _getMsg,
                    builder: (BuildContext context, String getMsg, _) {
                      return SizedBox(
                          width: context.pWidth,
                          child:
                              Wrap(alignment: WrapAlignment.start, children: [
                            Container(
                                width: context.pWidth * 0.26,
                                margin: EdgeInsets.all(
                                  context.vPadding * 0.5,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                        margin: EdgeInsets.zero,
                                        width: context.hPadding * 0.5,
                                        height: context.hPadding * 0.5,
                                        child: Checkbox(
                                            value: getMsg == '예',
                                            onChanged: (val) {
                                              if (val!) {
                                                _onGetMsgChanged('예');
                                              }
                                            })),
                                    Padding(
                                      padding: EdgeInsets.all(
                                          context.hPadding * 0.6),
                                    ),
                                    Text('예',
                                        style: TextStyle(
                                            color: getMsg == '예'
                                                ? Colors.black
                                                : Colors.black54,
                                            fontSize: context.contentsTextSize,
                                            fontWeight: getMsg == '예'
                                                ? FontWeight.bold
                                                : FontWeight.normal))
                                  ],
                                )),
                            Container(
                                width: context.pWidth * 0.26,
                                margin: EdgeInsets.all(
                                  context.vPadding * 0.5,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                        margin: EdgeInsets.zero,
                                        width: context.hPadding * 0.5,
                                        height: context.hPadding * 0.5,
                                        child: Checkbox(
                                            value: getMsg == '아니오',
                                            onChanged: (val) {
                                              if (val!) {
                                                _onGetMsgChanged('아니오');
                                              }
                                            })),
                                    Padding(
                                      padding: EdgeInsets.all(
                                          context.hPadding * 0.6),
                                    ),
                                    Text('아니오',
                                        style: TextStyle(
                                            color: getMsg == '아니오'
                                                ? Colors.black
                                                : Colors.black54,
                                            fontSize: context.contentsTextSize,
                                            fontWeight: getMsg == '아니오'
                                                ? FontWeight.bold
                                                : FontWeight.normal))
                                  ],
                                ))
                          ]));
                    }),
              ],
            ))
        //: const SizedBox()
        ;
  }

  Widget _renderAgreeBody() {
    return
        //_isAgreeOpened        ?
        Container(
            width: context.pWidth,
            color: const Color.fromARGB(255, 235, 237, 253),
            padding: EdgeInsets.only(
              top: context.hPadding,
              bottom: context.hPadding,
              left: context.hPadding * 1.2,
              right: context.hPadding * 1.2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('개인정보이용동의',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.contentsTextSize,
                        fontWeight: FontWeight.bold)),
                Padding(
                  padding: EdgeInsets.all(context.hPadding * 0.3),
                ),
                ValueListenableBuilder(
                    valueListenable: _agreed,
                    builder: (BuildContext context, String agreed, _) {
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                margin: EdgeInsets.only(
                                    left: context.vPadding * 0.5),
                                width: context.hPadding * 0.5,
                                height: context.hPadding * 0.5,
                                child: Checkbox(
                                    value: agreed == '예',
                                    onChanged: (val) {
                                      _onAgreeChanged(val!);
                                    })),
                            Padding(
                              padding: EdgeInsets.all(context.hPadding * 0.6),
                            ),
                            Text('예',
                                style: TextStyle(
                                    color: agreed == '예'
                                        ? Colors.black
                                        : Colors.black54,
                                    fontSize: context.contentsTextSize,
                                    fontWeight: agreed == '예'
                                        ? FontWeight.bold
                                        : FontWeight.normal))
                          ]);
                    }),
                Container(
                    margin: EdgeInsets.only(
                      top: context.hPadding,
                      bottom: context.hPadding,
                    ),
                    child: Divider(
                      color: Colors.black12,
                      height: 1,
                      thickness: 3,
                    )),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('개인정보 수집 업체명: 아이티고 (주)',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.contentsTextSize,
                            fontWeight: FontWeight.normal)),
                    Padding(
                      padding: EdgeInsets.all(context.hPadding * 0.2),
                    ),
                    Text('개인정보 수집 목적: 정보수신서비스 제공',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.contentsTextSize,
                            fontWeight: FontWeight.normal)),
                    Padding(
                      padding: EdgeInsets.all(context.hPadding * 0.2),
                    ),
                    Text('개인정보 수집 항목: 이름, 휴대폰번호',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.contentsTextSize,
                            fontWeight: FontWeight.normal)),
                    Padding(
                      padding: EdgeInsets.all(context.hPadding * 0.2),
                    ),
                    Text('개인정보 보유기간: 정보수신서비스 선택시간, 최대 24시간',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.contentsTextSize,
                            fontWeight: FontWeight.normal)),
                    Padding(
                      padding: EdgeInsets.all(context.hPadding * 0.6),
                    ),
                    Container(
                        width: context.pWidth,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('\u2022',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: context.hPadding * 0.7,
                                    fontWeight: FontWeight.bold)),
                            Padding(
                                padding:
                                    EdgeInsets.all(context.hPadding * 0.1)),
                            Container(
                                width: context.pWidth - context.hPadding * 3,
                                child: Text(
                                    '위의 개인정보 제공에 대한 동의를 거부할 권리가 있으며 미동의시 정보수신서비스는 제공되지 않습니다.',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: context.hPadding * 0.65,
                                        fontWeight: FontWeight.normal))),
                          ],
                        ))
                  ],
                )
              ],
            ))
        //: const SizedBox()
        ;
  }

  Widget _renderAgreeInfo() {
    return Container(
        width: context.pWidth,
        color: Colors.white,
        padding: EdgeInsets.only(
          top: context.hPadding * 1.2,
          left: context.hPadding * 1.2,
          right: context.hPadding * 1.2,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              margin: EdgeInsets.only(bottom: context.hPadding * 1.2),
              width: context.pWidth,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\u2022',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding * 0.7,
                          fontWeight: FontWeight.bold)),
                  Padding(padding: EdgeInsets.all(context.hPadding * 0.1)),
                  Container(
                      width: context.pWidth - context.hPadding * 3,
                      child: Text('정보수신서비스는 1일 24시간 동안 제공되는 서비스입니다.',
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: context.hPadding * 0.75,
                              fontWeight: FontWeight.normal))),
                ],
              )),
          Container(
              margin: EdgeInsets.only(bottom: context.hPadding * 1.2),
              width: context.pWidth,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\u2022',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding * 0.7,
                          fontWeight: FontWeight.bold)),
                  Padding(padding: EdgeInsets.all(context.hPadding * 0.1)),
                  Container(
                      width: context.pWidth - context.hPadding * 3,
                      child: Text(
                          '정보수신서비스는 선택항목이고 개인정보이용동의는 정보수신서비스 이용시 필수선택항목 입니다.',
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: context.hPadding * 0.75,
                              fontWeight: FontWeight.normal))),
                ],
              )),
          Container(
              margin: EdgeInsets.only(bottom: context.hPadding * 1.2),
              width: context.pWidth,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\u2022',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding * 0.7,
                          fontWeight: FontWeight.bold)),
                  Padding(padding: EdgeInsets.all(context.hPadding * 0.1)),
                  Container(
                      width: context.pWidth - context.hPadding * 3,
                      child: Text('정보수신서비스 선택시간 종료시 자동종료되고 알림드립니다.',
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: context.hPadding * 0.75,
                              fontWeight: FontWeight.normal))),
                ],
              ))
        ]));
  }
}
