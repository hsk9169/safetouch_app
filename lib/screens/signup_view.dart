import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safetouch/consts/sizes.dart';
import 'package:provider/provider.dart';
import 'package:safetouch/providers/platform_provider.dart';
import 'package:safetouch/providers/session_provider.dart';
import 'package:safetouch/widgets/basic_struct.dart';
import 'package:safetouch/widgets/bottom_buttons.dart';
import 'package:safetouch/widgets/title_band.dart';
import 'package:safetouch/widgets/data_input_form.dart';
import 'package:safetouch/widgets/data_view_form.dart';
import 'package:safetouch/services/api_service.dart';
import 'package:safetouch/widgets/pop_dialog.dart';
import 'package:safetouch/models/models.dart';

class SignupView extends StatefulWidget {
  int user;
  SignupView({required this.user});
  @override
  State<StatefulWidget> createState() => _SignupView();
}

class _SignupView extends State<SignupView> {
  String _storeNumber = '';
  ValueNotifier<String> _storeName = ValueNotifier<String>('');
  String _storePhone = '';
  String _storePwd = '';
  String _custName = '';
  String _custPhone = '';
  bool _bSignupEnabled = false;
  bool _cSignupEnabled = false;

  ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  void _onStoreNumberFilled(String value) async {
    setState(() {
      _storeNumber = value;
    });
    if (value.isEmpty) {
      _storeName.value = '';
    } else {
      final platformProvider = Provider.of<Platform>(context, listen: false);
      platformProvider.isLoading = true;
      await _apiService.getStoreNameByCode(value).then((res) {
        if (res is String) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(res),
              backgroundColor: Colors.black87.withOpacity(0.6),
              duration: const Duration(seconds: 2)));
          _storeName.value = '';
        } else {
          _storeName.value = res.storeName;
        }
      }).whenComplete(() => platformProvider.isLoading = false);
    }
    _checkStoreInputs();
  }

  void _checkStoreInputs() {
    if (_storePhone.isNotEmpty &&
        _storePwd.isNotEmpty &&
        _storeName.value.isNotEmpty &&
        _storeNumber.isNotEmpty) {
      setState(() => _bSignupEnabled = true);
    } else {
      setState(() => _bSignupEnabled = false);
    }
  }

  void _checkCustomerInputs() {
    if (_custName.isNotEmpty && _custPhone.isNotEmpty) {
      setState(() => _cSignupEnabled = true);
    } else {
      setState(() => _cSignupEnabled = false);
    }
  }

  void _onStorePhoneChanged(String value) {
    setState(() => _storePhone = value);
    _checkStoreInputs();
  }

  void _onStorePwdChanged(String value) {
    setState(() => _storePwd = value);
    _checkStoreInputs();
  }

  void _onCustNameChanged(String value) {
    setState(() => _custName = value);
    _checkCustomerInputs();
  }

  void _onCustPhoneChanged(String value) {
    setState(() => _custPhone = value);
    _checkCustomerInputs();
  }

  void _onTapStoreSignup() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final sessionProvider = Provider.of<Session>(context, listen: false);
    platformProvider.isLoading = true;
    await _apiService
        .requestSignup('1', platformProvider.osDiv, _storeNumber,
            _storeName.value, _storePhone, _storePwd)
        .then((value) {
      if (value is String) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value),
            backgroundColor: Colors.black87.withOpacity(0.6),
            duration: const Duration(seconds: 2)));
      } else {
        Provider.of<Session>(context, listen: false).sessionData = value;
        Provider.of<Platform>(context, listen: false).userDiv = '1';
        Provider.of<Session>(context, listen: false).storeInfo =
            StoreInfo(storeName: _storeName.value, userPwd: _storePwd);
        _renderDialog('상점주 등록을 완료했습니다.');
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  void _onTapCustomerSignup() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    platformProvider.isLoading = true;
    await _apiService
        .requestSignup(
            '2', platformProvider.osDiv, '', _custName, _custPhone, '')
        .then((value) {
      if (value is String) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value),
            backgroundColor: Colors.black87.withOpacity(0.6),
            duration: const Duration(seconds: 2)));
      } else {
        Provider.of<Session>(context, listen: false).sessionData = value;
        Provider.of<Platform>(context, listen: false).userDiv = '2';
        Provider.of<Session>(context, listen: false).customerInfo =
            CustomerInfo(userName: _custName, phoneNum: _custPhone);
        _renderDialog('고객 등록을 완료했습니다.');
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  Future<void> _renderDialog(String message) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            image: AssetImage('asset/icons/smile.png'),
            imageColor: Colors.green,
            textWidget: Column(children: [
              Text(message,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.2,
                      fontWeight: FontWeight.bold)),
            ]),
            onPressed: () {
              Navigator.pop(context);
              context.go('/main');
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return BasicStruct(
        isMenuList: false,
        appbarColor: Colors.white,
        childWidget: SingleChildScrollView(
            controller: ScrollController(),
            child: Stack(children: [
              Container(
                  color: Colors.white,
                  width: context.pWidth,
                  child: Column(
                    children: [
                      TitleBand(
                          color:
                              widget.user == 0 ? Colors.orange : Colors.yellow,
                          text: widget.user == 0 ? '상점주님 입력해주세요' : '고객님 입력해주세요',
                          textColor:
                              widget.user == 0 ? Colors.white : Colors.black,
                          image: Image(
                              image: AssetImage('asset/icons/smile.png'),
                              color: widget.user == 0
                                  ? Colors.white
                                  : Colors.black,
                              width: context.pWidth * 0.2,
                              height: context.pWidth * 0.2)),
                      widget.user == 0
                          ? _renderStoreInput()
                          : _renderCustomerInput(),
                    ],
                  )),
            ])));
  }

  Widget _renderStoreInput() {
    return Column(
      children: [
        Container(
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
                    child: Text('상점고유번호 (8자리 숫자)를 입력하시면 상점명이 자동입력되어 확인됩니다.',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.hPadding * 0.65,
                            fontWeight: FontWeight.normal))),
              ],
            )),
        Container(
            padding: EdgeInsets.only(
              left: context.hPadding * 1.5,
              right: context.hPadding * 1.5,
            ),
            child: Column(children: [
              DataInputForm(
                title: '상점고유번호',
                type: TextInputType.number,
                onCompleted: (value) => _onStoreNumberFilled(value),
                helpWidget: Text('8자리 숫자를 입력해주세요.',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: context.hPadding * 0.6,
                        fontWeight: FontWeight.normal)),
              ),
              ValueListenableBuilder(
                  valueListenable: _storeName,
                  builder: (BuildContext context, String value, _) {
                    return DataViewForm(
                      title: '상점명',
                      content: value,
                      helpWidget: Text('상점고유번호 입력시 자동입력',
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: context.hPadding * 0.6,
                              fontWeight: FontWeight.normal)),
                    );
                  }),
              DataInputForm(
                title: '전화번호',
                type: TextInputType.number,
                onChanged: (value) => _onStorePhoneChanged(value),
                helpWidget: Text('숫자만 입력해주세요.',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: context.hPadding * 0.6,
                        fontWeight: FontWeight.normal)),
              ),
              DataInputForm(
                title: '비밀번호',
                type: TextInputType.text,
                onChanged: (value) => _onStorePwdChanged(value),
                isObscure: true,
                helpWidget: Text('8자리 이상 ~ 10자리 미만',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: context.hPadding * 0.6,
                        fontWeight: FontWeight.normal)),
              ),
            ])),
        BottomButtons(
          btn3Enabled: _bSignupEnabled,
          btn3Text: '가입하기',
          btn3Color: Colors.black,
          btn3Pressed: _bSignupEnabled ? () => _onTapStoreSignup() : null,
        )
      ],
    );
  }

  Widget _renderCustomerInput() {
    return Container(
        padding: EdgeInsets.only(
          left: context.hPadding * 1.5,
          right: context.hPadding * 1.5,
        ),
        child: Column(children: [
          Padding(padding: EdgeInsets.all(context.hPadding * 0.5)),
          DataInputForm(
            title: '고객명',
            type: TextInputType.text,
            onChanged: (value) => _onCustNameChanged(value),
            helpWidget: Text('한글로 입력해주세요.',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: context.hPadding * 0.6,
                    fontWeight: FontWeight.normal)),
          ),
          DataInputForm(
            title: '휴대폰 번호',
            type: TextInputType.number,
            onChanged: (value) => _onCustPhoneChanged(value),
            helpWidget: Text('숫자만 입력해주세요.',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: context.hPadding * 0.6,
                    fontWeight: FontWeight.normal)),
          ),
          BottomButtons(
            btn3Enabled: _cSignupEnabled,
            btn3Text: '가입하기',
            btn3Color: Colors.black,
            btn3Pressed: _cSignupEnabled
                //? () => context.pushNamed('add_store_2')
                ? () => _onTapCustomerSignup()
                : null,
          )
        ]));
  }
}
