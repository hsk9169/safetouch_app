import 'package:flutter/material.dart';
import 'package:safetouch/consts/sizes.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:safetouch/providers/platform_provider.dart';
import 'package:safetouch/providers/session_provider.dart';
import 'package:safetouch/widgets/basic_struct.dart';
import 'package:safetouch/widgets/bottom_buttons.dart';
import 'package:safetouch/widgets/title_band.dart';
import 'package:safetouch/widgets/data_input_form.dart';
import 'package:safetouch/widgets/data_view_form.dart';
import 'package:safetouch/services/api_service.dart';
import 'package:safetouch/models/models.dart';

class AddStoreView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddStoreView();
}

class _AddStoreView extends State<AddStoreView> {
  StoreDetails _storeDetails = StoreDetails.initialize();
  String _openTime = '';
  String _phoneNum = '';
  String _mobileNum = '';
  String _emailAddr = '';
  String _storeAddr = '';
  ValueNotifier<String> _catId = ValueNotifier<String>('');
  bool _isNextEnabled = false;

  ApiService _apiService = ApiService();

  late Future<dynamic> _storeInfoFuture;

  @override
  void initState() {
    super.initState();
    _initData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<Platform>(context, listen: false).isLoading = true;
    });
  }

  void _initData() {
    _storeInfoFuture = _getStoreInfo();
  }

  Future<dynamic> _getStoreInfo() async {
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    return await _apiService
        .getStoreInfo(
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
        _catId.value = value.catId;
        _openTime = value.bizTime;
        _phoneNum = value.telNum;
        _mobileNum = value.phoneNum;
        _emailAddr = value.emailAddr;
        _storeAddr = value.storeAddr;
        _storeDetails = value;
        _checkInputs();
        return value;
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  void _checkInputs() {
    if (_openTime.isNotEmpty && _phoneNum.isNotEmpty && _storeAddr.isNotEmpty) {
      setState(() => _isNextEnabled = true);
    } else {
      setState(() => _isNextEnabled = false);
    }
  }

  void _onOpenTimeChanged(String value) {
    _openTime = value;
    _checkInputs();
  }

  void _onPhoneNumChanged(String value) {
    _phoneNum = value;
    _checkInputs();
  }

  void _onMobileNumChanged(String value) {
    _mobileNum = value;
    _checkInputs();
  }

  void _onEmailAddrChanged(String value) {
    _emailAddr = value;
    _checkInputs();
  }

  void _onStoreAddrChanged(String value) {
    _storeAddr = value;
    _checkInputs();
  }

  void _onStoreTypeChanged(CategoryInfo cat) {
    _catId.value = cat.id;
    _checkInputs();
  }

  void _onTapNext() {
    _storeDetails.bizTime = _openTime;
    _storeDetails.telNum = _phoneNum;
    _storeDetails.phoneNum = _mobileNum;
    _storeDetails.emailAddr = _emailAddr;
    _storeDetails.storeAddr = _storeAddr;
    _storeDetails.catId = _catId.value;
    context.pushNamed('add_store_2', extra: _storeDetails);
  }

  @override
  Widget build(BuildContext context) {
    return BasicStruct(
      isMenuList: true,
      appbarColor: Colors.white,
      childWidget: SingleChildScrollView(
          controller: ScrollController(),
          child: FutureBuilder(
              future: _storeInfoFuture,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.data != null) {
                  return Container(
                      color: Colors.white,
                      width: context.pWidth,
                      child: Column(
                        children: [
                          TitleBand(
                              color: Colors.black12,
                              text: '상점정보 등록하기',
                              image: Image(
                                  image: AssetImage('asset/icons/smile.png'),
                                  width: context.pWidth * 0.2,
                                  height: context.pWidth * 0.2)),
                          _renderInfo(),
                          TitleBand(
                              color: Colors.orange,
                              textColor: Colors.white,
                              text: '상점 정보를 입력해주세요',
                              image: Image(
                                  image: AssetImage('asset/icons/home.png'),
                                  width: context.pWidth * 0.2,
                                  height: context.pWidth * 0.2)),
                          _renderInfoInput(snapshot.data),
                          BottomButtons(
                            btn3Enabled: false,
                            btn3Text: '다 음',
                            btn3Color: Colors.black,
                            btn3Pressed: _isNextEnabled
                                ? () => _onTapNext()
                                //? () => _renderDialog()
                                : null,
                          )
                        ],
                      ));
                } else {
                  return const SizedBox();
                }
              })),
    );
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
            Container(
                width: context.pWidth - context.hPadding * 3,
                child: Text(
                    '스마트사이니지에서 방문고객에게 보여주는 상점소개 정보입니다. 상점정보 변경시 바로 수정해주세요.',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.hPadding * 0.65,
                        fontWeight: FontWeight.normal))),
          ],
        ));
  }

  Widget _renderInfoInput(StoreDetails data) {
    return Container(
        padding: EdgeInsets.only(
          left: context.hPadding * 1.5,
          right: context.hPadding * 1.5,
        ),
        margin: EdgeInsets.only(top: context.vPadding),
        child: Column(children: [
          DataViewForm(
            title: '상점명',
            content: data.storeName,
            helpWidget: Text('로그인시 자동 입력됩니다.',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: context.hPadding * 0.6,
                    fontWeight: FontWeight.normal)),
          ),
          DataInputForm(
            title: '영업시간',
            initData: data.bizTime,
            type: TextInputType.text,
            onChanged: (value) => _onOpenTimeChanged(value),
            helpWidget: Text('ex) 09:00 ~ 24:00',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: context.hPadding * 0.6,
                    fontWeight: FontWeight.normal)),
          ),
          DataInputForm(
            title: '전화번호',
            initData: data.telNum,
            type: TextInputType.number,
            onChanged: (value) => _onPhoneNumChanged(value),
            helpWidget: Text('숫자만 입력해주세요.',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: context.hPadding * 0.6,
                    fontWeight: FontWeight.normal)),
          ),
          DataInputForm(
            title: '휴대폰 번호',
            initData: data.phoneNum,
            type: TextInputType.number,
            onChanged: (value) => _onMobileNumChanged(value),
            helpWidget: Text('숫자만 입력해주세요.',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: context.hPadding * 0.6,
                    fontWeight: FontWeight.normal)),
          ),
          DataInputForm(
            title: '이메일',
            initData: data.emailAddr,
            type: TextInputType.emailAddress,
            onChanged: (value) => _onEmailAddrChanged(value),
            helpWidget: Text('안내문서 발송용입니다.',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: context.hPadding * 0.6,
                    fontWeight: FontWeight.normal)),
          ),
          DataInputForm(
            title: '상점주소',
            initData: data.storeAddr,
            type: TextInputType.text,
            onChanged: (value) => _onStoreAddrChanged(value),
          ),
          Container(
              width: context.pWidth,
              margin: EdgeInsets.only(
                bottom: context.vPadding * 2,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('업종 선택',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.hPadding * 0.8,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(context.vPadding * 0.2),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('최대 1개 선택할 수 있습니다.',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.hPadding * 0.7,
                            fontWeight: FontWeight.normal)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(context.vPadding * 0.2),
                  ),
                  _renderCheckboxList(data)
                ],
              ))
        ]));
  }

  Widget _renderCheckboxList(StoreDetails data) {
    return ValueListenableBuilder(
        valueListenable: _catId,
        builder: (BuildContext context, String value, _) {
          return SizedBox(
              width: context.pWidth,
              child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  children: data.catList.map((CategoryInfo cat) {
                    final bool isCatRight = cat.id == value;
                    return Container(
                        width: context.pWidth * 0.25,
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
                                        _onStoreTypeChanged(cat);
                                      }
                                    })),
                            Padding(
                              padding: EdgeInsets.all(context.hPadding * 0.6),
                            ),
                            Text(cat.name,
                                style: TextStyle(
                                    color: isCatRight
                                        ? Colors.black
                                        : Colors.black54,
                                    fontSize: context.contentsTextSize,
                                    fontWeight: isCatRight
                                        ? FontWeight.bold
                                        : FontWeight.normal))
                          ],
                        ));
                  }).toList()));
        });
  }
}
