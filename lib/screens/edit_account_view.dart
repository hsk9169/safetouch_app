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
import 'package:safetouch/widgets/bottom_buttons.dart';
import 'package:safetouch/widgets/pop_dialog.dart';
import 'package:safetouch/models/models.dart';
import 'package:safetouch/services/encrypted_storage_service.dart';

class EditAccountView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditAccountView();
}

class _EditAccountView extends State<EditAccountView> {
  String _storeCode = '';
  String _storeName = '';
  String _storeOrgPhone = '';
  String _storeNewPhone = '';
  String _storePwd = '';
  String _custName = '';
  String _custOrgPhone = '';
  String _custNewPhone = '';
  bool _bSignupEnabled = false;
  bool _cSignupEnabled = false;
  ValueNotifier<bool> _deleteAccount = ValueNotifier<bool>(false);

  ApiService _apiService = ApiService();
  late Future<dynamic> _storeInfoFuture;

  @override
  void initState() {
    super.initState();
    _initData();
    EncryptedStorageService().initStorage();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  void _initData() {
    if (Provider.of<Platform>(context, listen: false).userDiv == '1') {
      _storeInfoFuture = _getStoreInfo();
    }
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
        _storeName = value.storeName;
        _storeOrgPhone = value.phoneNum;
        return value;
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  void _onStoreCodeFilled(String value) {
    setState(() {
      _storeCode = value;
    });

    _checkStoreInputs();
  }

  void _checkStoreInputs() {
    if (_storeNewPhone.isNotEmpty &&
        _storeCode.isNotEmpty &&
        _storeName.isNotEmpty &&
        _storePwd.length > 7 &&
        _storePwd.length < 10) {
      setState(() => _bSignupEnabled = true);
    } else {
      setState(() => _bSignupEnabled = false);
    }
  }

  void _checkCustomerInputs() {
    if (_custName.isNotEmpty && _custNewPhone.isNotEmpty) {
      setState(() => _cSignupEnabled = true);
    } else {
      setState(() => _cSignupEnabled = false);
    }
  }

  void _onStorePhoneChanged(String value) {
    setState(() => _storeNewPhone = value);
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
    setState(() => _custNewPhone = value);
    _checkCustomerInputs();
  }

  void _onDeleteChanged(bool value) {
    _deleteAccount.value = value;
  }

  Future<void> _deleteAccountInfo() async {
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    sessionProvider.sessionData = SessionData.initialize();
    sessionProvider.storeInfo = StoreInfo.initialize();
    sessionProvider.customerInfo = CustomerInfo.initialize();
    platformProvider.userDiv = '';
    await EncryptedStorageService().saveData('auto_login', 'false');
    await EncryptedStorageService().removeData('user_div');
    await EncryptedStorageService().removeData('store_name');
    await EncryptedStorageService().removeData('store_pwd');
    await EncryptedStorageService().removeData('user_name');
    await EncryptedStorageService().removeData('user_phone');
  }

  void _onTapStoreEdit() {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final sessionProvider = Provider.of<Session>(context, listen: false);
    platformProvider.isLoading = true;
    _apiService
        .updateStoreAccount(
            '1',
            sessionProvider.sessionData.userId,
            sessionProvider.sessionData.userToken,
            _storeCode,
            _storeName,
            _storeOrgPhone,
            _storeNewPhone,
            _storePwd,
            _deleteAccount.value ? '1' : '0')
        .then((value) async {
      if (value is String) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value),
            backgroundColor: Colors.black87.withOpacity(0.6),
            duration: const Duration(seconds: 2)));
      } else {
        if (_deleteAccount.value) {
          _deleteAccountInfo().whenComplete(() {
            context.goNamed('signin');
          });
        } else {
          sessionProvider.sessionData.userToken = value.userToken;
          await EncryptedStorageService()
              .saveData('store_pwd', _storePwd)
              .whenComplete(() => _renderDialog('상점 회원정보 수정을 완료했습니다.'));
        }
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  void _onTapCustomerEdit() {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final sessionProvider = Provider.of<Session>(context, listen: false);
    _custOrgPhone = sessionProvider.customerInfo.phoneNum;
    platformProvider.isLoading = true;
    _apiService
        .updateCustomerAccount(
            '2',
            sessionProvider.sessionData.userId,
            sessionProvider.sessionData.userToken,
            _custName,
            _custOrgPhone,
            _custNewPhone,
            _deleteAccount.value ? '1' : '0')
        .then((value) async {
      if (value is String) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value),
            backgroundColor: Colors.black87.withOpacity(0.6),
            duration: const Duration(seconds: 2)));
      } else {
        if (_deleteAccount.value) {
          _deleteAccountInfo().whenComplete(() {
            context.goNamed('signin');
          });
        } else {
          sessionProvider.sessionData.userToken = value.userToken;
          sessionProvider.customerInfo.userName = _custName;
          sessionProvider.customerInfo.phoneNum = _custNewPhone;
          await EncryptedStorageService()
              .saveData('user_name', _custName)
              .whenComplete(() => EncryptedStorageService()
                  .saveData('user_phone', _custNewPhone)
                  .whenComplete(() => _renderDialog('고객 회원정보 수정을 완료했습니다.')));
        }
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
              context.goNamed('main');
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final userDiv = Provider.of<Platform>(context, listen: false).userDiv;
    return BasicStruct(
      isMenuList: true,
      appbarColor: Colors.white,
      childWidget: Container(
          color: Colors.white,
          width: context.pWidth,
          child: Column(
            children: [
              TitleBand(
                  color: userDiv == '1' ? Colors.orange : Colors.yellow,
                  text: userDiv == '1' ? '상점주님 입력해주세요' : '고객님 입력해주세요',
                  textColor: userDiv == '1' ? Colors.white : Colors.black,
                  image: Image(
                      color: userDiv == '1' ? Colors.white : Colors.black,
                      image: AssetImage('asset/icons/smile.png'),
                      width: context.pWidth * 0.2,
                      height: context.pWidth * 0.2)),
              userDiv == '1'
                  ? FutureBuilder(
                      future: _storeInfoFuture,
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.data != null) {
                          return _renderStoreInput(snapshot.data!);
                        } else {
                          return const SizedBox();
                        }
                      })
                  : _renderCustomerInput(),
            ],
          )),
    );
  }

  Widget _renderStoreInput(StoreDetails data) {
    return Column(
      children: [
        Container(
            width: context.pWidth,
            padding: EdgeInsets.all(context.hPadding),
            child: Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('\u2022',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.hPadding * 0.7,
                        fontWeight: FontWeight.bold)),
                Padding(padding: EdgeInsets.all(context.hPadding * 0.1)),
                Container(
                    width: context.pWidth - context.hPadding * 3,
                    child: Text('회원정보 변경시 바로 수정해주세요.',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.hPadding * 0.65,
                            fontWeight: FontWeight.normal)))
              ]),
              Padding(padding: EdgeInsets.all(context.hPadding * 0.1)),
              Row(
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
                      child: Text('상점 비밀번호 분실시 바로 수정해주세요.',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: context.hPadding * 0.65,
                              fontWeight: FontWeight.normal))),
                ],
              )
            ])),
        Container(
            padding: EdgeInsets.only(
              left: context.hPadding * 1.5,
              right: context.hPadding * 1.5,
            ),
            child: Column(children: [
              DataInputForm(
                title: '상점고유번호',
                type: TextInputType.number,
                onCompleted: (value) => _onStoreCodeFilled(value),
                helpWidget: Text('8자리 숫자를 입력해주세요.',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: context.hPadding * 0.6,
                        fontWeight: FontWeight.normal)),
              ),
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
                title: '휴대폰 번호',
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
        Padding(padding: EdgeInsets.all(context.hPadding * 0.5)),
        ValueListenableBuilder(
            valueListenable: _deleteAccount,
            builder: (BuildContext context, bool delete, _) {
              return Container(
                  padding: EdgeInsets.only(
                    left: context.hPadding * 1.5,
                    right: context.hPadding * 1.5,
                  ),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text('회원탈퇴',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.hPadding * 0.8,
                            fontWeight: FontWeight.bold)),
                    Padding(
                      padding: EdgeInsets.all(context.hPadding * 0.3),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: context.vPadding * 0.5),
                        width: context.hPadding * 0.5,
                        height: context.hPadding * 0.5,
                        child: Checkbox(
                            value: delete,
                            onChanged: (val) {
                              _onDeleteChanged(val!);
                            })),
                  ]));
            }),
        BottomButtons(
          btn3Enabled: _bSignupEnabled,
          btn3Text: '저장하기',
          btn3Color: Colors.black,
          btn3Pressed: _bSignupEnabled ? () => _onTapStoreEdit() : null,
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
          Padding(padding: EdgeInsets.all(context.hPadding * 0.5)),
          ValueListenableBuilder(
              valueListenable: _deleteAccount,
              builder: (BuildContext context, bool delete, _) {
                return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('회원탈퇴',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding * 0.8,
                          fontWeight: FontWeight.bold)),
                  Padding(
                    padding: EdgeInsets.all(context.hPadding * 0.3),
                  ),
                  Container(
                      margin: EdgeInsets.only(left: context.vPadding * 0.5),
                      width: context.hPadding * 0.5,
                      height: context.hPadding * 0.5,
                      child: Checkbox(
                          value: delete,
                          onChanged: (val) {
                            _onDeleteChanged(val!);
                          })),
                ]);
              }),
          BottomButtons(
            btn3Enabled: _cSignupEnabled,
            btn3Text: '저장하기',
            btn3Color: Colors.black,
            btn3Pressed: _cSignupEnabled ? () => _onTapCustomerEdit() : null,
          )
        ]));
  }
}
