import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:safetouch/providers/platform_provider.dart';
import 'package:safetouch/providers/session_provider.dart';
import 'package:safetouch/consts/sizes.dart';
import 'package:safetouch/widgets/basic_struct.dart';
import 'package:safetouch/widgets/bottom_buttons.dart';
import 'package:safetouch/services/api_service.dart';
import 'package:safetouch/widgets/pop_dialog.dart';
import 'package:safetouch/models/models.dart';

class ReservationStoreAvailabilityAnswerView extends StatefulWidget {
  final String bookId;
  ReservationStoreAvailabilityAnswerView({required this.bookId});
  @override
  State<StatefulWidget> createState() =>
      _ReservationStoreAvailabilityAnswerView();
}

class _ReservationStoreAvailabilityAnswerView
    extends State<ReservationStoreAvailabilityAnswerView> {
  ApiService _apiService = ApiService();
  ValueNotifier<bool> _isEnabled = ValueNotifier<bool>(true);
  int _option = 0;
  String _minute = '';
  ValueNotifier<String> _etc = ValueNotifier<String>('');
  late TextEditingController _timeTextController;
  late TextEditingController _etcTextController;

  @override
  void initState() {
    super.initState();
    _timeTextController = TextEditingController(text: _minute);
    _etcTextController = TextEditingController(text: _etc.value);
    _timeTextController.addListener(_onTimeChanged);
    _etcTextController.addListener(_onEtcChanged);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  void _onTimeChanged() {
    _minute = _timeTextController.text;
    _checkInput();
  }

  void _onEtcChanged() {
    if (_etcTextController.text.length > 30) {
      _etcTextController.text = _etc.value;
    } else {
      _etc.value = _etcTextController.text;
    }
    _checkInput();
  }

  void _onOptionChanged(int value) {
    setState(() => _option = value);
    _checkInput();
  }

  void _checkInput() {
    bool check = true;
    if (_option == 1) {
      if (_minute.isEmpty) {
        check = false;
      }
    } else if (_option == 6) {
      if (_etc.value.isEmpty) {
        check = false;
      }
    }
    _isEnabled.value = check;
  }

  void _onTapPostReply() {
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    platformProvider.isLoading = true;
    String bookDiv = '';
    if (_option < 6) {
      bookDiv = (_option + 1).toString();
    } else if (_option == 6) {
      bookDiv = '9';
    }
    final dateTime = DateTime.now();
    final time = dateTime.year.toString() +
        dateTime.month.toString() +
        dateTime.day.toString() +
        dateTime.hour.toString() +
        dateTime.minute.toString();
    _apiService
        .postReplyReservation(
            platformProvider.userDiv,
            sessionProvider.sessionData.userId,
            sessionProvider.sessionData.userToken,
            widget.bookId,
            bookDiv,
            _minute,
            _etc.value,
            time)
        .then((value) {
      if (value is String) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value),
            backgroundColor: Colors.black87.withOpacity(0.6),
            duration: const Duration(seconds: 2)));
      } else {
        _renderDialog();
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  void _renderDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
              image: AssetImage('asset/icons/smile.png'),
              imageColor: Colors.green,
              textWidget: Column(children: [
                Text('고객님에게 답변을 전송하였습니다.',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.contentsTextSize * 1.2,
                        fontWeight: FontWeight.bold)),
              ]),
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return BasicStruct(
        isMenuList: true,
        appbarColor: Colors.white,
        childWidget: SingleChildScrollView(
            controller: ScrollController(),
            child: Container(
                color: Colors.white,
                width: context.pWidth,
                margin: EdgeInsets.only(
                  top: context.hPadding * 1.5,
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _renderInfo(),
                      _renderOptions(),
                      ValueListenableBuilder(
                          valueListenable: _isEnabled,
                          builder: (BuildContext context, bool value, _) {
                            return BottomButtons(
                              btn3Enabled: true,
                              btn3Text: '답변 전송하기',
                              btn3Color: value ? Colors.green : Colors.grey,
                              btn3Pressed: () =>
                                  value ? _onTapPostReply() : null,
                            );
                          })
                    ]))));
  }

  Widget _renderInfo() {
    return Container(
        width: context.pWidth,
        margin: EdgeInsets.only(
            left: context.hPadding * 1.5, right: context.hPadding * 1.5),
        padding: EdgeInsets.all(context.hPadding * 0.6),
        decoration: BoxDecoration(
            color: Colors.black87, borderRadius: BorderRadius.circular(5)),
        child: Text('상점주님 답변 내용을 선택하시고 답변 전송하기 버튼을 눌러주세요',
            style: TextStyle(
                color: Colors.white, fontSize: context.contentsTextSize)));
  }

  Widget _renderOptions() {
    return Container(
        width: context.pWidth,
        height: context.pHeight * 0.55,
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(
          top: context.hPadding * 2,
          left: context.hPadding * 1.3,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Transform.scale(
                scale: 1.3,
                child: Radio(
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  value: 0,
                  groupValue: _option,
                  onChanged: (value) => _onOptionChanged(value!),
                )),
            Padding(
              padding: EdgeInsets.all(context.hPadding * 0.2),
            ),
            Text(
              '고객님은 현재 이용 가능하십니다.',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.hPadding * 0.85,
                  fontWeight: FontWeight.bold),
            ),
          ]),
          Padding(
            padding: EdgeInsets.all(context.hPadding * 0.4),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Transform.scale(
                scale: 1.3,
                child: Radio(
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  value: 1,
                  groupValue: _option,
                  onChanged: (value) => _onOptionChanged(value!),
                )),
            Padding(
              padding: EdgeInsets.all(context.hPadding * 0.2),
            ),
            Text(
              '고객님은',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.hPadding * 0.85,
                  fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.all(context.hPadding * 0.2),
            ),
            TextField(
                controller: _timeTextController,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(context.hPadding * 0.4),
                  fillColor: Colors.white,
                  filled: true,
                  constraints: BoxConstraints(
                    maxWidth: context.pWidth * 0.15,
                    maxHeight: context.pHeight * 0.036,
                  ),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(5)),
                ),
                keyboardType: TextInputType.text,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: context.hPadding * 0.7,
                    fontWeight: FontWeight.bold)),
            Padding(
              padding: EdgeInsets.all(context.hPadding * 0.2),
            ),
            Text(
              '분 후 이용 가능하십니다.',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.hPadding * 0.85,
                  fontWeight: FontWeight.bold),
            ),
          ]),
          Padding(
            padding: EdgeInsets.all(context.hPadding * 0.4),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Transform.scale(
                scale: 1.3,
                child: Radio(
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  value: 2,
                  groupValue: _option,
                  onChanged: (value) => _onOptionChanged(value!),
                )),
            Padding(
              padding: EdgeInsets.all(context.hPadding * 0.2),
            ),
            Text(
              '고객님 지금 만석입니다.',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.hPadding * 0.85,
                  fontWeight: FontWeight.bold),
            ),
          ]),
          Padding(
            padding: EdgeInsets.all(context.hPadding * 0.4),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Transform.scale(
                scale: 1.3,
                child: Radio(
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  value: 3,
                  groupValue: _option,
                  onChanged: (value) => _onOptionChanged(value!),
                )),
            Padding(
              padding: EdgeInsets.all(context.hPadding * 0.2),
            ),
            Text(
              '고객님 재료소진 되었습니다.',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.hPadding * 0.85,
                  fontWeight: FontWeight.bold),
            ),
          ]),
          Padding(
            padding: EdgeInsets.all(context.hPadding * 0.4),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Transform.scale(
                scale: 1.3,
                child: Radio(
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  value: 4,
                  groupValue: _option,
                  onChanged: (value) => _onOptionChanged(value!),
                )),
            Padding(
              padding: EdgeInsets.all(context.hPadding * 0.2),
            ),
            Text(
              '고객님 영업준비중 입니다.',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.hPadding * 0.85,
                  fontWeight: FontWeight.bold),
            ),
          ]),
          Padding(
            padding: EdgeInsets.all(context.hPadding * 0.4),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Transform.scale(
                scale: 1.3,
                child: Radio(
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  value: 5,
                  groupValue: _option,
                  onChanged: (value) => _onOptionChanged(value!),
                )),
            Padding(
              padding: EdgeInsets.all(context.hPadding * 0.2),
            ),
            Text(
              '고객님 영업종료 입니다.',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.hPadding * 0.85,
                  fontWeight: FontWeight.bold),
            ),
          ]),
          Padding(
            padding: EdgeInsets.all(context.hPadding * 0.4),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Transform.scale(
                scale: 1.3,
                child: Radio(
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  value: 6,
                  groupValue: _option,
                  onChanged: (value) => _onOptionChanged(value!),
                )),
            Padding(
              padding: EdgeInsets.all(context.hPadding * 0.2),
            ),
            Text(
              '기타',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.hPadding * 0.85,
                  fontWeight: FontWeight.bold),
            ),
          ]),
          _renderEtcInput()
        ]));
  }

  Widget _renderEtcInput() {
    return _option == 6
        ? ValueListenableBuilder<String>(
            builder: (BuildContext context, String value, Widget? child) {
              return Container(
                  width: context.pWidth,
                  padding: EdgeInsets.only(
                    right: context.hPadding * 1.5,
                  ),
                  margin: EdgeInsets.only(
                      top: context.vPadding, bottom: context.vPadding),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                            controller: _etcTextController,
                            textAlignVertical: TextAlignVertical.top,
                            maxLines: 1,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(
                                left: context.hPadding * 0.5,
                                right: context.hPadding * 0.5,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              hintText: '기타 답변을 작성해주세요',
                              hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal),
                              constraints: BoxConstraints(
                                maxWidth: context.pWidth,
                              ),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 1),
                                  borderRadius: BorderRadius.circular(
                                      context.pWidth * 0.02)),
                            ),
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: context.hPadding * 0.7,
                                fontWeight: FontWeight.bold)),
                        Padding(
                            padding: EdgeInsets.all(context.vPadding * 0.5)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(value.length.toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: context.hPadding * 0.8,
                                    fontWeight: FontWeight.bold)),
                            Text(' / 30',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: context.hPadding * 0.6,
                                    fontWeight: FontWeight.normal)),
                          ],
                        )
                      ]));
            },
            valueListenable: _etc,
          )
        : Padding(
            padding: EdgeInsets.all(context.hPadding * 3),
          );
  }
}
