import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:safetouch/providers/platform_provider.dart';
import 'package:safetouch/providers/session_provider.dart';
import 'package:safetouch/consts/sizes.dart';
import 'package:safetouch/widgets/basic_struct.dart';
import 'package:safetouch/widgets/bottom_buttons.dart';
import 'package:safetouch/widgets/title_band.dart';
import 'package:safetouch/widgets/data_input_form.dart';
import 'package:safetouch/widgets/pop_dialog.dart';
import 'package:safetouch/widgets/void_button.dart';
import 'package:safetouch/widgets/contained_button.dart';
import 'package:safetouch/models/image_data.dart';
import 'package:safetouch/services/api_service.dart';
import 'package:safetouch/models/models.dart';

class AddEventView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddEventView();
}

class _AddEventView extends State<AddEventView> {
  bool _isNextEnabled = false;
  String _nextButtonStr = '등 록 하 기';
  bool _isEditting = true;
  ValueNotifier<List<List<Map<String, dynamic>>>> _imageList =
      ValueNotifier<List<List<Map<String, dynamic>>>>([]);
  List<TextEditingController> _titleTextControllerList = [];
  List<TextEditingController> _startDateTextControllerList = [];
  List<TextEditingController> _startTimeTextControllerList = [];
  List<TextEditingController> _endDateTextControllerList = [];
  List<TextEditingController> _endTimeTextControllerList = [];
  List<String> _startDateList = [];
  List<String> _startTimeList = [];
  List<String> _endDateList = [];
  List<String> _endTimeList = [];

  ApiService _apiService = ApiService();

  late Future<dynamic> _eventInfoFuture;
  List<EventInfo> _eventList = [];

  @override
  void initState() {
    super.initState();
    _initData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<Platform>(context, listen: false).isLoading = true;
    });
  }

  void _initData() async {
    _eventInfoFuture = _getEventInfo();
  }

  Future<dynamic> _getEventInfo() async {
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    return await _apiService
        .getEventInfo(
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
        value.asMap().forEach((index, event) {
          _imageList.value.add([]);
          if (event.eventImageGetList != null) {
            event.eventImageGetList
                ?.forEach((image) => _imageList.value[index].add({
                      'imgName': image,
                      'imgContent': null,
                      'imgPath': null,
                    }));
          }
          _titleTextControllerList
              .add(TextEditingController(text: event.eventMsg));
          String startDate = '';
          String startTime = '';
          String endDate = '';
          String endTime = '';
          if (event.todayEventFlag == '0') {
            startDate = event.startTime.substring(0, 8);
            startTime = event.startTime.substring(8);
            endDate = event.endTime.substring(0, 8);
            endTime = event.endTime.substring(8);
          }
          _startDateTextControllerList
              .add(TextEditingController(text: startDate));
          _startDateList.add(startDate);

          _startTimeTextControllerList
              .add(TextEditingController(text: startTime));
          _startTimeList.add(startTime);

          _endDateTextControllerList.add(TextEditingController(text: endDate));
          _endDateList.add(endDate);

          _endTimeTextControllerList.add(TextEditingController(text: endTime));
          _endTimeList.add(endTime);
        });
        if (value.isNotEmpty) {
          setState(() {
            _isNextEnabled = true;
            _nextButtonStr = '수 정 하 기';
          });
        }
        return value;
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  void _onTitleChanged(int index, String value) {
    _eventList[index].eventMsg = value;
    _checkInputs();
  }

  void _onStartDateChanged(int idx) {
    _startDateList[idx] = _startDateTextControllerList[idx].text;
    _checkInputs();
  }

  void _onStartTimeChanged(int idx) {
    _startTimeList[idx] = _startTimeTextControllerList[idx].text;
    _checkInputs();
  }

  void _onEndDateChanged(int idx) {
    _endDateList[idx] = _endDateTextControllerList[idx].text;
    _checkInputs();
  }

  void _onEndTimeChanged(int idx) {
    _endTimeList[idx] = _endTimeTextControllerList[idx].text;
    _checkInputs();
  }

  void _onTapTodayEvent(int index) {
    try {
      if (_eventList[index].todayEventFlag == '0') {
        _startDateTextControllerList[index].text = '';
        _startTimeTextControllerList[index].text = '';
        _endDateTextControllerList[index].text = '';
        _endTimeTextControllerList[index].text = '';
        setState(() => _eventList[index].todayEventFlag = '1');
      } else {
        _startDateTextControllerList[index].text = _startDateList[index];
        _startTimeTextControllerList[index].text = _startTimeList[index];
        _endDateTextControllerList[index].text = _endDateList[index];
        _endTimeTextControllerList[index].text = _endTimeList[index];
        setState(() => _eventList[index].todayEventFlag = '0');
      }
      _checkInputs();
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('날짜, 시간을 형식에 맞게 입력해주세요.'),
          backgroundColor: Colors.black87.withOpacity(0.6),
          duration: const Duration(seconds: 2)));
    }
  }

  void _onTapAddImage(int index) async {
    XFile? imgFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (imgFile != null) {
      final String fileName = imgFile.name;
      final String filePath = imgFile.path;
      Uint8List? imgBytes = await imgFile.readAsBytes();
      String imageEncoded = base64.encode(imgBytes);

      setState(() => _imageList.value[index].add({
            'imgName': fileName,
            'imgContent': imageEncoded,
            'imgPath': filePath,
          }));
    }
  }

  void _onTapDeleteImage(int index, int idx) {
    setState(() => _imageList.value[index].removeAt(idx));
  }

  void _checkInputs() {
    bool available = true;
    _eventList.asMap().forEach((idx, el) {
      available = available & _titleTextControllerList[idx].text.isNotEmpty;
      if (el.todayEventFlag == '0') {
        available = available &
            _startDateTextControllerList[idx].text.isNotEmpty &
            _startTimeTextControllerList[idx].text.isNotEmpty &
            _endDateTextControllerList[idx].text.isNotEmpty &
            _endTimeTextControllerList[idx].text.isNotEmpty;
      }
    });
    setState(() => _isNextEnabled = available);
  }

  void _onTapAddEvent() {
    setState(() => _eventList.add(EventInfo.initialize()));
    _imageList.value.add([]);
    _titleTextControllerList.add(TextEditingController());
    _startDateTextControllerList.add(TextEditingController());
    _startTimeTextControllerList.add(TextEditingController());
    _endDateTextControllerList.add(TextEditingController());
    _endTimeTextControllerList.add(TextEditingController());
    _startDateList.add('');
    _startTimeList.add('');
    _endDateList.add('');
    _endTimeList.add('');
    _checkInputs();
  }

  void _onTapDeleteEvent(int index) {
    if (_eventList[index].eventId!.isNotEmpty) {
      final sessionProvider = Provider.of<Session>(context, listen: false);
      final platformProvider = Provider.of<Platform>(context, listen: false);
      platformProvider.isLoading = true;
      _apiService
          .deleteEvent(
              platformProvider.userDiv,
              sessionProvider.sessionData.userId,
              sessionProvider.sessionData.userToken,
              _eventList[index].eventId!)
          .then((value) {
        if (value is String) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(value),
              backgroundColor: Colors.black87.withOpacity(0.6),
              duration: const Duration(seconds: 2)));
        } else {
          _imageList.value.removeAt(index);
          _titleTextControllerList.removeAt(index);
          _startDateTextControllerList.removeAt(index);
          _startTimeTextControllerList.removeAt(index);
          _endDateTextControllerList.removeAt(index);
          _endTimeTextControllerList.removeAt(index);
          _startDateList.removeAt(index);
          _startTimeList.removeAt(index);
          _endDateList.removeAt(index);
          _endTimeList.removeAt(index);
          setState(() => _eventList.removeAt(index));
        }
      }).whenComplete(() => platformProvider.isLoading = false);
    } else {
      _imageList.value.removeAt(index);
      _titleTextControllerList.removeAt(index);
      _startDateTextControllerList.removeAt(index);
      _startTimeTextControllerList.removeAt(index);
      _endDateTextControllerList.removeAt(index);
      _endTimeTextControllerList.removeAt(index);
      _startDateList.removeAt(index);
      _startTimeList.removeAt(index);
      _endDateList.removeAt(index);
      _endTimeList.removeAt(index);
      setState(() => _eventList.removeAt(index));
    }
    _checkInputs();
  }

  bool _makeEventList() {
    bool available = true;
    _eventList.asMap().forEach((idx, event) {
      if (_eventList[idx].todayEventFlag == '0') {
        if (_startDateList[idx].length == 8 &&
            _endDateList[idx].length == 8 &&
            _startTimeList[idx].length == 4 &&
            _endTimeList[idx].length == 4) {
          final startTimeStr = _startDateList[idx] + _startTimeList[idx];
          final endTimeStr = _endDateList[idx] + _endTimeList[idx];
          _eventList[idx] = event.eventId != null
              ? EventInfo(
                  eventId: event.eventId,
                  eventMsg: event.eventMsg,
                  eventImagePostList: event.eventImagePostList,
                  startTime: startTimeStr,
                  endTime: endTimeStr,
                  todayEventFlag: event.todayEventFlag,
                )
              : EventInfo(
                  eventMsg: event.eventMsg,
                  eventImagePostList: event.eventImagePostList,
                  startTime: startTimeStr,
                  endTime: endTimeStr,
                  todayEventFlag: event.todayEventFlag,
                );
        } else {
          available = false;
          return;
        }
      }
      if (!available) {
        return;
      }
    });
    return available;
  }

  void _onTapEventRegister() async {
    if (_makeEventList()) {
      _imageList.value.asMap().forEach((index, element) {
        final List<EventImage> temp = [];
        element.forEach((img) {
          temp.add(img['imgContent'] == null
              ? EventImage(fileName: img['imgName'])
              : EventImage(
                  fileName: img['imgName'], content: img['imgContent']));
        });
        _eventList[index].eventImagePostList = temp;
      });
      final sessionProvider = Provider.of<Session>(context, listen: false);
      final platformProvider = Provider.of<Platform>(context, listen: false);
      platformProvider.isLoading = true;

      await _apiService
          .postEventInfo(
              platformProvider.userDiv,
              sessionProvider.sessionData.userId,
              sessionProvider.sessionData.userToken,
              _eventList)
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('날짜, 시간을 형식에 맞게 입력해주세요.'),
          backgroundColor: Colors.black87.withOpacity(0.6),
          duration: const Duration(seconds: 2)));
    }
  }

  void _renderDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            image: AssetImage('asset/icons/smile.png'),
            imageColor: Colors.green,
            textWidget: Column(children: [
              Text('이벤트 등록을 완료했습니다.',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.2,
                      fontWeight: FontWeight.bold)),
              Text('서비스 업데이트 후 확인해주세요.',
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
    return BasicStruct(
        isMenuList: true,
        appbarColor: Colors.white,
        childWidget: SingleChildScrollView(
            controller: ScrollController(),
            child: FutureBuilder(
                future: _eventInfoFuture,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.data != null) {
                    _eventList = snapshot.data?.cast<EventInfo>();
                    return Container(
                        color: Colors.white,
                        width: context.pWidth,
                        child: Column(
                          children: [
                            TitleBand(
                                color: Colors.black12,
                                text: '상점주님 입력해주세요',
                                image: Image(
                                    image: AssetImage('asset/icons/smile.png'),
                                    width: context.pWidth * 0.2,
                                    height: context.pWidth * 0.2)),
                            _renderInfo(),
                            TitleBand(
                                color: Colors.orange,
                                text: '상점이벤트 글을 작성해주세요',
                                textColor: Colors.white,
                                image: Image(
                                    image: AssetImage('asset/icons/list.png'),
                                    width: context.pWidth * 0.2,
                                    height: context.pWidth * 0.2)),
                            _renderEventList(snapshot.data?.cast<EventInfo>()),
                            Container(
                                margin: EdgeInsets.only(top: context.hPadding),
                                padding: EdgeInsets.only(
                                  left: context.hPadding * 1.5,
                                  right: context.hPadding * 1.5,
                                ),
                                alignment: Alignment.centerRight,
                                child: ContainedButton(
                                    color: Colors.black,
                                    boxWidth: double.infinity,
                                    textSize: context.hPadding * 0.6,
                                    text: '이벤트글 추가하기',
                                    onPressed: () => _onTapAddEvent())),
                            _renderInputInfo(),
                            BottomButtons(
                              btn3Enabled: false,
                              btn3Text: _nextButtonStr,
                              btn3Color: Colors.black,
                              btn3Pressed: _isNextEnabled
                                  ? () => _onTapEventRegister()
                                  : null,
                            )
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
            Container(
                width: context.pWidth - context.hPadding * 3,
                child: Text(
                    '스마트사이니지에서 방문고객에게 보여주는 상점이벤트 정보입니다. 상점이벤트 변경시 바로 수정,삭제해주세요.',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.hPadding * 0.65,
                        fontWeight: FontWeight.normal))),
          ],
        ));
  }

  Widget _renderEventList(List<EventInfo> list) {
    return Column(
        children: List.generate(list.length, (idx) => _eventCard(idx)));
  }

  Widget _eventCard(int idx) {
    return Container(
        width: context.pWidth,
        padding: EdgeInsets.all(context.hPadding),
        margin: EdgeInsets.only(
          left: context.hPadding * 1.5,
          right: context.hPadding * 1.5,
          top: context.vPadding * 2,
        ),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(
              bottom: context.hPadding * 0.5,
            ),
            child: Text(
              '이벤트 글',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.contentsTextSize,
                  fontWeight: FontWeight.bold),
            ),
          ),
          // title
          TextField(
              controller: _titleTextControllerList[idx],
              onChanged: (value) => _onTitleChanged(idx, value),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(context.hPadding * 0.5),
                hintText: '이벤트글을 입력해주세요',
                hintStyle: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.normal),
                fillColor: Colors.white,
                filled: true,
                constraints: BoxConstraints(
                  maxWidth: context.pWidth,
                  maxHeight: context.pHeight * 0.045,
                ),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(context.pWidth * 0.02)),
              ),
              keyboardType: TextInputType.text,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.hPadding * 0.7,
                  fontWeight: FontWeight.bold)),

          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(
              top: context.hPadding,
              bottom: context.hPadding * 0.5,
            ),
            child: Text(
              '이벤트 이미지',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.contentsTextSize,
                  fontWeight: FontWeight.bold),
            ),
          ),
          ValueListenableBuilder(
              valueListenable: _imageList,
              builder: (BuildContext context,
                      List<List<Map<String, dynamic>>> value, _) =>
                  Column(
                      children: List.generate(
                          value[idx].length,
                          (index) => SizedBox(
                                  child: Stack(children: [
                                value[idx][index]['imgPath'] != null
                                    ? Container(
                                        margin: EdgeInsets.only(
                                            bottom: context.vPadding * 2),
                                        child: Image.file(
                                            File(value[idx][index]['imgPath']),
                                            width: context.pWidth))
                                    : Container(
                                        margin: EdgeInsets.only(
                                            bottom: context.vPadding * 2),
                                        child: Image.network(
                                            value[idx][index]['imgName'],
                                            width: context.pWidth)),
                                Container(
                                    padding:
                                        EdgeInsets.all(context.hPadding * 0.2),
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                        onTap: () =>
                                            _onTapDeleteImage(idx, index),
                                        child: Icon(Icons.cancel,
                                            color: Colors.black54)))
                              ]))))),
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(
                bottom: context.hPadding * 0.5,
              ),
              child: InkWell(
                  child: DottedBorder(
                      color: Colors.orange,
                      strokeWidth: 2,
                      dashPattern: [4, 4],
                      borderType: BorderType.RRect,
                      radius: Radius.circular(10),
                      child: Container(
                          padding: EdgeInsets.all(context.hPadding * 0.5),
                          child: Column(
                            children: [
                              Image(
                                  image: AssetImage('asset/icons/image.png'),
                                  width: context.pWidth * 0.05,
                                  height: context.pWidth * 0.05),
                              Text(
                                '이미지',
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: context.contentsTextSize,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '추가하기',
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: context.contentsTextSize,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ))),
                  onTap: () => _onTapAddImage(idx))),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(
              top: context.hPadding,
              bottom: context.hPadding * 0.5,
            ),
            child: Text(
              '이벤트 시작 일시',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.contentsTextSize,
                  fontWeight: FontWeight.bold),
            ),
          ),
          // startDate
          TextField(
              controller: _startDateTextControllerList[idx],
              onChanged: (value) => _onStartDateChanged(idx),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                enabled: _eventList[idx].todayEventFlag == '0',
                contentPadding: EdgeInsets.all(context.hPadding * 0.5),
                hintText: _eventList[idx].todayEventFlag == '1'
                    ? '당일에 한함'
                    : 'YYYYMMDD',
                hintStyle: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.normal),
                fillColor: _eventList[idx].todayEventFlag == '1'
                    ? Colors.black12
                    : Colors.white,
                filled: true,
                constraints: BoxConstraints(
                  maxWidth: context.pWidth,
                  maxHeight: context.pHeight * 0.045,
                ),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(context.pWidth * 0.02)),
              ),
              keyboardType: TextInputType.text,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.hPadding * 0.7,
                  fontWeight: FontWeight.bold)),
          Padding(padding: EdgeInsets.all(context.hPadding * 0.2)),
          // startTime
          TextField(
              controller: _startTimeTextControllerList[idx],
              onChanged: (value) => _onStartTimeChanged(idx),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                enabled: _eventList[idx].todayEventFlag == '0',
                contentPadding: EdgeInsets.all(context.hPadding * 0.5),
                hintText:
                    _eventList[idx].todayEventFlag == '1' ? '당일에 한함' : '2045',
                hintStyle: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.normal),
                fillColor: _eventList[idx].todayEventFlag == '1'
                    ? Colors.black12
                    : Colors.white,
                filled: true,
                constraints: BoxConstraints(
                  maxWidth: context.pWidth,
                  maxHeight: context.pHeight * 0.045,
                ),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(context.pWidth * 0.02)),
              ),
              keyboardType: TextInputType.text,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.hPadding * 0.7,
                  fontWeight: FontWeight.bold)),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(
              top: context.hPadding,
              bottom: context.hPadding * 0.5,
            ),
            child: Text(
              '이벤트 종료 일시',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.contentsTextSize,
                  fontWeight: FontWeight.bold),
            ),
          ),
          // endDate
          TextField(
              controller: _endDateTextControllerList[idx],
              onChanged: (value) => _onEndDateChanged(idx),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                enabled: _eventList[idx].todayEventFlag == '0',
                contentPadding: EdgeInsets.all(context.hPadding * 0.5),
                hintText: _eventList[idx].todayEventFlag == '1'
                    ? '당일에 한함'
                    : 'YYYYMMDD',
                hintStyle: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.normal),
                fillColor: _eventList[idx].todayEventFlag == '1'
                    ? Colors.black12
                    : Colors.white,
                filled: true,
                constraints: BoxConstraints(
                  maxWidth: context.pWidth,
                  maxHeight: context.pHeight * 0.045,
                ),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(context.pWidth * 0.02)),
              ),
              keyboardType: TextInputType.text,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.hPadding * 0.7,
                  fontWeight: FontWeight.bold)),
          Padding(padding: EdgeInsets.all(context.hPadding * 0.2)),
          // endTime
          TextField(
              controller: _endTimeTextControllerList[idx],
              onChanged: (value) => _onEndTimeChanged(idx),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                enabled: _eventList[idx].todayEventFlag == '0',
                contentPadding: EdgeInsets.all(context.hPadding * 0.5),
                hintText:
                    _eventList[idx].todayEventFlag == '1' ? '당일에 한함' : '2045',
                hintStyle: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.normal),
                fillColor: _eventList[idx].todayEventFlag == '1'
                    ? Colors.black12
                    : Colors.white,
                filled: true,
                constraints: BoxConstraints(
                  maxWidth: context.pWidth,
                  maxHeight: context.pHeight * 0.045,
                ),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(context.pWidth * 0.02)),
              ),
              keyboardType: TextInputType.text,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.hPadding * 0.7,
                  fontWeight: FontWeight.bold)),
          Padding(
            padding: EdgeInsets.all(context.hPadding * 0.3),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  width: context.pWidth * 0.3,
                  child: Divider(
                    color: Colors.black54,
                    height: 1,
                    thickness: 1,
                  )),
              Text('또는', style: TextStyle(color: Colors.black54)),
              SizedBox(
                  width: context.pWidth * 0.3,
                  child: Divider(
                    color: Colors.black54,
                    height: 1,
                    thickness: 1,
                  ))
            ],
          ),
          Padding(
            padding: EdgeInsets.all(context.hPadding * 0.3),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            ContainedButton(
              boxWidth: context.pWidth * 0.18,
              color: Colors.red,
              text: '삭제',
              textSize: context.contentsTextSize,
              onPressed: () => _onTapDeleteEvent(idx),
            ),
            ContainedButton(
              boxWidth: context.pWidth * 0.52,
              color: _eventList[idx].todayEventFlag == '1'
                  ? Colors.grey
                  : Colors.purple,
              text: _eventList[idx].todayEventFlag == '1'
                  ? '오늘의 이벤트 해제하기'
                  : '오늘의 이벤트로 설정하기',
              textSize: context.contentsTextSize,
              prefixImage: Container(
                  margin: EdgeInsets.only(right: context.hPadding * 0.3),
                  child: Image(
                      image: AssetImage('asset/icons/crown.png'),
                      color: Colors.white,
                      width: context.pWidth * 0.04,
                      height: context.pWidth * 0.04)),
              onPressed: () => _onTapTodayEvent(idx),
            )
          ])
        ]));
  }

  Widget _renderInputInfo() {
    return Container(
        width: context.pWidth,
        padding: EdgeInsets.all(context.hPadding * 0.5),
        margin: EdgeInsets.only(
          left: context.hPadding * 1.5,
          right: context.hPadding * 1.5,
          top: context.vPadding * 2,
          bottom: context.vPadding * 2,
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 0.5)),
        child: Column(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('\u2022',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.hPadding * 0.7,
                      fontWeight: FontWeight.bold)),
              Padding(padding: EdgeInsets.all(context.hPadding * 0.1)),
              SizedBox(
                  width: context.pWidth - context.hPadding * 5,
                  child: Text(
                      '상점이벤트는 이벤트글 + 이벤트이미지 (사진, 배너, POP, 전단지등) 총 6개 가능합니다.',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding * 0.65,
                          fontWeight: FontWeight.normal))),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(context.hPadding * 0.2),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('\u2022',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.hPadding * 0.7,
                      fontWeight: FontWeight.bold)),
              Padding(padding: EdgeInsets.all(context.hPadding * 0.1)),
              SizedBox(
                  width: context.pWidth - context.hPadding * 5,
                  child: Text('이벤트글 기본 1개 이상 입력한 이후, 이벤트 이미지를 업로드 해주세요.',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding * 0.65,
                          fontWeight: FontWeight.normal))),
            ],
          ),
          Divider(height: 20, thickness: 0.5, color: Colors.white),
          SizedBox(
              width: context.pWidth - context.hPadding * 5,
              child: Text('ex) 이벤트글 1개 + 이벤트 이미지 5개',
                  style: TextStyle(
                      color: Colors.purple,
                      fontSize: context.hPadding * 0.65,
                      fontWeight: FontWeight.bold))),
          SizedBox(
              width: context.pWidth - context.hPadding * 5,
              child: Text('ex) 이벤트글 3개 + 이벤트 이미지 3개',
                  style: TextStyle(
                      color: Colors.purple,
                      fontSize: context.hPadding * 0.65,
                      fontWeight: FontWeight.bold))),
        ]));
  }
}
