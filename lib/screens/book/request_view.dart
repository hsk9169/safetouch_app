import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safetouch/models/store_info_resv.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:provider/provider.dart';
import 'package:safetouch/providers/platform_provider.dart';
import 'package:safetouch/providers/session_provider.dart';
import 'package:safetouch/consts/sizes.dart';
import 'package:safetouch/widgets/basic_struct.dart';
import 'package:safetouch/widgets/bottom_buttons.dart';
import 'package:safetouch/widgets/title_band.dart';
import 'package:safetouch/widgets/data_input_form.dart';
import 'package:safetouch/widgets/pop_dialog.dart';
import 'package:safetouch/widgets/data_input_form.dart';
import 'package:safetouch/widgets/data_view_form.dart';
import 'package:safetouch/widgets/menu_list.dart';
import 'package:safetouch/models/models.dart';
import 'package:safetouch/services/api_service.dart';
import 'package:safetouch/widgets/void_button.dart';

class BookRequestView extends StatefulWidget {
  final String path;
  BookRequestView({required this.path});
  @override
  State<StatefulWidget> createState() => _BookRequestView();
}

class _BookRequestView extends State<BookRequestView> {
  final _apiService = ApiService();
  bool _isNextEnabled = false;
  String _visitTime = '';
  String _visitNum = '';
  String _menu = '';
  String _storeId = '';
  List<MenuInfo> _menuList = [];

  late TextEditingController _visitTimeController;
  late TextEditingController _visitNumController;
  late TextEditingController _menuController;
  late Future<dynamic> _storeInfoFuture;

  @override
  void initState() {
    super.initState();
    _initData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<Platform>(context, listen: false).isLoading = true;
    });
    _visitTimeController = TextEditingController();
    _visitNumController = TextEditingController();
    _menuController = TextEditingController();
    _visitTimeController.addListener(_visitTimeChanged);
    _visitNumController.addListener(_visitNumChanged);
    _menuController.addListener(_menuChanged);
  }

  void _initData() {
    _storeInfoFuture = _getStoreInfo();
  }

  Future<dynamic> _getStoreInfo() {
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    return _apiService
        .getStoreInfoById(
            platformProvider.userDiv,
            sessionProvider.sessionData.userId,
            sessionProvider.sessionData.userToken,
            widget.path)
        //'2400')
        .then((value) {
      if (value is String) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value),
            backgroundColor: Colors.black87.withOpacity(0.6),
            duration: const Duration(seconds: 2)));
        return null;
      } else {
        _storeId = value.storeId;
        _menuList = value.menuList;
        return value as StoreInfoResv;
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  void _visitTimeChanged() {
    _visitTime = _visitTimeController.text;
    _checkInputs();
  }

  void _visitNumChanged() {
    _visitNum = _visitNumController.text;
    _checkInputs();
  }

  void _menuChanged() {
    _menu = _menuController.text;
    _checkInputs();
  }

  void _checkInputs() {
    if (_visitTime.length == 4 && _visitNum.isNotEmpty) {
      _isNextEnabled = true;
    } else {
      _isNextEnabled = false;
    }
  }

  void _onTapRequestVacancy() {
    if (_isNextEnabled) {
      final sessionProvider = Provider.of<Session>(context, listen: false);
      final platformProvider = Provider.of<Platform>(context, listen: false);
      platformProvider.isLoading = true;
      final dateTime = DateTime.now();
      final time = dateTime.year.toString() +
          dateTime.month.toString() +
          dateTime.day.toString() +
          dateTime.hour.toString() +
          dateTime.minute.toString();
      _apiService
          .requestVacancy(
              platformProvider.userDiv,
              sessionProvider.sessionData.userId,
              sessionProvider.sessionData.userToken,
              _storeId,
              sessionProvider.customerInfo.userName,
              sessionProvider.customerInfo.phoneNum,
              _visitTime,
              _visitNum,
              _menu,
              time)
          .then((value) {
        if (value is String) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(value),
              backgroundColor: Colors.black87.withOpacity(0.6),
              duration: const Duration(seconds: 2)));
        } else {
          _renderDialog('빈자리 확인');
        }
      }).whenComplete(() => platformProvider.isLoading = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('입력 형식이 잘못되었습니다.'),
          backgroundColor: Colors.black87.withOpacity(0.6),
          duration: const Duration(seconds: 2)));
    }
  }

  void _onTapRequestReservation() {
    if (_isNextEnabled) {
      final sessionProvider = Provider.of<Session>(context, listen: false);
      final platformProvider = Provider.of<Platform>(context, listen: false);
      platformProvider.isLoading = true;
      final dateTime = DateTime.now();
      final time = dateTime.year.toString() +
          dateTime.month.toString() +
          dateTime.day.toString() +
          dateTime.hour.toString() +
          dateTime.minute.toString();
      _apiService
          .requestReservation(
              platformProvider.userDiv,
              sessionProvider.sessionData.userId,
              sessionProvider.sessionData.userToken,
              _storeId,
              sessionProvider.customerInfo.userName,
              sessionProvider.customerInfo.phoneNum,
              _visitTime,
              _visitNum,
              _menu,
              time)
          .then((value) {
        if (value is String) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(value),
              backgroundColor: Colors.black87.withOpacity(0.6),
              duration: const Duration(seconds: 2)));
        } else {
          _renderDialog('예약');
        }
      }).whenComplete(() => platformProvider.isLoading = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('입력 형식이 잘못되었습니다.'),
          backgroundColor: Colors.black87.withOpacity(0.6),
          duration: const Duration(seconds: 2)));
    }
  }

  void _onTapMenuImage(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              elevation: 0,
              alignment: Alignment.center,
              backgroundColor: Colors.transparent,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(_menuList[index].imgName!,
                        width: context.pWidth),
                    Padding(padding: EdgeInsets.all(context.hPadding * 0.5)),
                    InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                            width: context.pWidth * 0.12,
                            height: context.pWidth * 0.12,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 1),
                                color: Colors.black54),
                            child: Icon(Icons.close,
                                color: Colors.white,
                                size: context.pWidth * 0.08)))
                  ]));
        });
  }

  void _renderDialog(String info) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            image: AssetImage('asset/icons/smile.png'),
            imageColor: Colors.black,
            textWidget: Column(children: [
              Text('$info 신청 완료했습니다.',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.2,
                      fontWeight: FontWeight.bold)),
              Text('$info 내역에서 확인가능합니다.',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.2,
                      fontWeight: FontWeight.bold)),
            ]),
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
          );
        });
  }

  void _onTapCall(String phoneNum) async {
    if (phoneNum.isNotEmpty) {
      UrlLauncher.launchUrl(Uri(scheme: "tel", path: phoneNum));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('매장 전화번호가 미등록 상태입니다.'),
          backgroundColor: Colors.black87.withOpacity(0.6),
          duration: const Duration(seconds: 2)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasicStruct(
        isMenuList: true,
        showPop: false,
        appbarColor: Colors.white,
        childWidget: SingleChildScrollView(
            controller: ScrollController(),
            child: FutureBuilder(
                future: _storeInfoFuture,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.data != null) {
                    return Container(
                        color: Colors.white,
                        width: context.pWidth,
                        child: Column(
                          children: [
                            TitleBand(
                                color: Colors.black12,
                                text: '고객님 입력해주세요',
                                image: Image(
                                    image: AssetImage('asset/icons/smile.png'),
                                    width: context.pWidth * 0.2,
                                    height: context.pWidth * 0.2)),
                            _renderInfo(),
                            TitleBand(
                                color: Colors.yellow,
                                text: '빈자리 확인 / 예약하기',
                                image: Image(
                                    color: Colors.black,
                                    image:
                                        AssetImage('asset/icons/calendar.png'),
                                    width: context.pWidth * 0.2,
                                    height: context.pWidth * 0.2)),
                            _renderInfoInput(snapshot.data),
                            _renderMenuList(snapshot.data.menuList),
                            //_renderRepImage(snapshot.data.repImg),
                            _renderGuide(),
                            _renderButtons(snapshot.data.storePhone),
                          ],
                        ));
                  } else {
                    return const SizedBox();
                  }
                })));
  }

  Widget _renderInfo() {
    return Container(
        width: context.pWidth,
        padding: EdgeInsets.all(context.hPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\u2022',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: context.hPadding * 0.7,
                    fontWeight: FontWeight.bold)),
            Padding(padding: EdgeInsets.all(context.hPadding * 0.1)),
            SizedBox(
                width: context.pWidth - context.hPadding * 3,
                child: Text('스마트사이니지 상점정보에서 방문하고싶은 상점을 보시고 빈자리확인 또는 예약을 해주세요',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.hPadding * 0.65,
                        fontWeight: FontWeight.normal))),
          ],
        ));
  }

  Widget _renderInfoInput(StoreInfoResv data) {
    final String bizTime =
        '${data.bizTime.substring(0, 2)}:${data.bizTime.substring(2, 4)} ~ ${data.bizTime.substring(4, 6)}:${data.bizTime.substring(
      6,
    )}';

    return Container(
        padding: EdgeInsets.only(
          left: context.hPadding * 1.5,
          right: context.hPadding * 1.5,
        ),
        margin: EdgeInsets.only(top: context.vPadding * 2),
        child: Column(children: [
          DataViewForm(
            title: '상점명',
            content: data.storeName,
          ),
          DataViewForm(
            title: '영업시간 표시',
            content: bizTime,
            helpWidget: Text('스마트사이니지에서 선택터치한 상점정보 자동입력',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: context.hPadding * 0.6,
                    fontWeight: FontWeight.normal)),
          ),
          DataViewForm(
            title: '고객명',
            content: Provider.of<Session>(context, listen: false)
                .customerInfo
                .userName,
            helpWidget: Text('로그인시 자동입력',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: context.hPadding * 0.6,
                    fontWeight: FontWeight.normal)),
          ),
          DataViewForm(
            title: '휴대폰 번호',
            content: Provider.of<Session>(context, listen: false)
                .customerInfo
                .phoneNum,
            helpWidget: Text('로그인시 자동입력',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: context.hPadding * 0.6,
                    fontWeight: FontWeight.normal)),
          ),
          DataInputForm(
            title: '방문시간',
            controller: _visitTimeController,
            type: TextInputType.number,
            helpWidget: Text('ex) 2130',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: context.hPadding * 0.6,
                    fontWeight: FontWeight.normal)),
          ),
          DataInputForm(
            title: '방문인원수',
            controller: _visitNumController,
            type: TextInputType.number,
            helpWidget: Text('숫자만 입력해주세요.',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: context.hPadding * 0.6,
                    fontWeight: FontWeight.normal)),
          ),
          DataInputForm(
            title: '상점메뉴',
            controller: _menuController,
            type: TextInputType.text,
            helpWidget: Text('선택사항 입니다.',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: context.hPadding * 0.6,
                    fontWeight: FontWeight.normal)),
          ),
        ]));
  }

  Widget _renderMenuList(List<MenuInfo> list) {
    return Container(
        width: context.pWidth,
        padding: EdgeInsets.only(
          left: context.hPadding * 1.5,
          right: context.hPadding * 1.5,
        ),
        margin: EdgeInsets.only(
          top: context.vPadding,
          bottom: context.vPadding * 2,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('상점메뉴 보기',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.hPadding * 0.8,
                  fontWeight: FontWeight.bold)),
          Padding(
            padding: EdgeInsets.all(context.hPadding * 0.5),
          ),
          MenuList(
            list: list,
            onTapImage: (index) => _onTapMenuImage(index),
          ),
        ]));
  }

  Widget _renderRepImage(String imgLink) {
    return imgLink.isNotEmpty
        ? Container(
            margin: EdgeInsets.only(bottom: context.vPadding * 2),
            child: Image.network(
              imgLink,
              width: context.pWidth,
            ))
        : const SizedBox();
  }

  Widget _renderGuide() {
    return Container(
      width: context.pWidth,
      padding: EdgeInsets.all(context.hPadding * 0.8),
      margin: EdgeInsets.only(
          left: context.hPadding * 1.5,
          right: context.hPadding * 1.5,
          bottom: context.hPadding * 3),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.black87),
      alignment: Alignment.centerLeft,
      child: Text(
          '정보 등록후 원하시는 서비스를 눌러주세요\n상점 예약 확정시 꼭 방문해주시고, 취소 변경을 원하시면 오른쪽 상단 메뉴 고객예약내역에서 확인하세요',
          style: TextStyle(
              color: Colors.white,
              fontSize: context.contentsTextSize,
              fontWeight: FontWeight.normal)),
    );
  }

  Widget _renderButtons(String storePhone) {
    return Container(
        margin: EdgeInsets.only(bottom: context.vPadding * 5),
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          VoidButton(text: '문의하기', onPressed: () => _onTapCall(storePhone)),
          Padding(
            padding: EdgeInsets.all(context.vPadding * 0.5),
          ),
          VoidButton(text: '예약하기', onPressed: () => _onTapRequestReservation()),
          Padding(
            padding: EdgeInsets.all(context.vPadding * 0.5),
          ),
          VoidButton(text: '빈자리 확인하기', onPressed: () => _onTapRequestVacancy())
        ]));
  }
}
