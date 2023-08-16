import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:safetouch/providers/platform_provider.dart';
import 'package:safetouch/providers/session_provider.dart';
import 'package:safetouch/consts/sizes.dart';
import 'package:safetouch/widgets/basic_struct.dart';
import 'package:safetouch/widgets/bottom_buttons.dart';
import 'package:safetouch/widgets/contained_button.dart';
import 'package:safetouch/widgets/title_band.dart';
import 'package:safetouch/widgets/pop_dialog.dart';
import 'package:safetouch/models/models.dart';
import 'package:safetouch/services/api_service.dart';

class AddStoreView3 extends StatefulWidget {
  StoreDetails details;
  AddStoreView3({required this.details});
  @override
  State<StatefulWidget> createState() => _AddStoreView3();
}

class _AddStoreView3 extends State<AddStoreView3> {
  StoreDetails _storeDetails = StoreDetails.initialize();
  ApiService _apiService = ApiService();
  ValueNotifier<List<Map<String, dynamic>>> _imageList =
      ValueNotifier<List<Map<String, dynamic>>>([]);
  bool _isPostDataMade = false;

  @override
  void initState() {
    super.initState();
    _initData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _storeDetails = widget.details;
    });
  }

  void _initData() {
    widget.details.storeImageGetList.forEach((element) => _imageList.value.add({
          'imgName': element,
          'imgContent': null,
          'imgPath': null,
        }));
  }

  void _onTapAddImage() async {
    if (_imageList.value.length < 10) {
      XFile? imgFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (imgFile != null) {
        final String fileName = imgFile.name;
        final String filePath = imgFile.path;
        Uint8List? imgBytes = await imgFile.readAsBytes();
        String imageEncoded = base64.encode(imgBytes);
        setState(() => _imageList.value.add({
              'imgName': fileName,
              'imgContent': imageEncoded,
              'imgPath': filePath,
            }));
      }
    }
  }

  void _onTapDeleteImage(int index) {
    setState(() {
      _imageList.value.removeAt(index);
    });
  }

  void _onTapStoreRegister() async {
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final List<StoreImage> temp = [];
    if (!_isPostDataMade) {
      _imageList.value.forEach((element) {
        temp.add(element['imgContent'] == null
            ? StoreImage(fileName: element['imgName'])
            : StoreImage(
                fileName: element['imgName'], content: element['imgContent']));
      });
      _storeDetails.storeImagePostList = temp;
      _isPostDataMade = true;
    }

    platformProvider.isLoading = true;
    await _apiService
        .postStoreInfo(
            platformProvider.userDiv,
            sessionProvider.sessionData.userId,
            sessionProvider.sessionData.userToken,
            _storeDetails)
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

  void _renderDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            image: AssetImage('asset/icons/hands.png'),
            imageColor: Colors.black,
            textWidget: Column(children: [
              Text('상점 등록이 완료되었습니다.',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize * 1.2,
                      fontWeight: FontWeight.bold)),
              Text('이벤트 이미지 업로드 해주세요.',
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
          child: Container(
              color: Colors.white,
              width: context.pWidth,
              margin: EdgeInsets.only(
                bottom: context.vPadding * 2,
              ),
              child: Column(children: [
                ValueListenableBuilder(
                    valueListenable: _imageList,
                    builder: (BuildContext context,
                        List<Map<String, dynamic>> value, _) {
                      return TitleBand(
                          color: Colors.orange,
                          textColor: Colors.white,
                          text: '상점사진을 등록해주세요',
                          tailWidget: Row(
                            children: [
                              Text(value.length.toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.hPadding * 0.85,
                                      fontWeight: FontWeight.bold)),
                              Padding(
                                padding: EdgeInsets.all(context.hPadding * 0.1),
                              ),
                              Text(' / 10',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.hPadding * 0.8,
                                      fontWeight: FontWeight.normal))
                            ],
                          ),
                          image: Image(
                              color: Colors.white,
                              image: AssetImage('asset/icons/picture.png'),
                              width: context.pWidth * 0.2,
                              height: context.pWidth * 0.2));
                    }),
                _renderInfo(),
                Container(
                    padding: EdgeInsets.only(
                      left: context.hPadding * 1.5,
                      right: context.hPadding * 1.5,
                    ),
                    alignment: Alignment.centerRight,
                    child: ContainedButton(
                        color: Colors.black,
                        boxWidth: double.infinity,
                        textSize: context.hPadding * 0.65,
                        text: '사진 추가하기',
                        onPressed: () => _onTapAddImage())),
                _renderImageList(),
                BottomButtons(
                  btn3Enabled: false,
                  btn3Text: '등 록 하 기',
                  btn3Color: Colors.black,
                  btn3Pressed: () => _onTapStoreRegister(),
                )
              ]))),
    );
  }

  Widget _renderInfo() {
    return Container(
        width: context.pWidth,
        margin: EdgeInsets.all(context.hPadding * 1.5),
        padding: EdgeInsets.all(context.hPadding),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('매장사진, 대표메뉴는 ',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.contentsTextSize,
                        fontWeight: FontWeight.normal)),
                Text('최대 9장 ',
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: context.contentsTextSize,
                        fontWeight: FontWeight.bold)),
                Text('업로드 가능하며,',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.contentsTextSize,
                        fontWeight: FontWeight.normal)),
              ],
            ),
            Padding(padding: EdgeInsets.all(context.vPadding * 0.1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('메뉴판은 ',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.contentsTextSize,
                        fontWeight: FontWeight.normal)),
                Text('최대 1장 ',
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: context.contentsTextSize,
                        fontWeight: FontWeight.bold)),
                Text('업로드 가능합니다.',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.contentsTextSize,
                        fontWeight: FontWeight.normal)),
              ],
            ),
          ],
        ));
  }

  Widget _renderImageList() {
    return Container(
        width: context.pWidth,
        margin: EdgeInsets.only(top: context.vPadding * 2),
        padding: EdgeInsets.only(
          left: context.hPadding * 1.5,
          right: context.hPadding * 1.5,
        ),
        child: ValueListenableBuilder(
            valueListenable: _imageList,
            builder: (BuildContext context, List<Map<String, dynamic>> value,
                Widget? child) {
              final width = context.pWidth - context.hPadding * 3;
              return Column(
                  children: List.generate(
                      value.length,
                      (index) => Container(
                          margin: EdgeInsets.only(bottom: context.vPadding * 2),
                          child: Stack(children: [
                            value[index]['imgPath'] != null
                                ? Container(
                                    margin: EdgeInsets.only(
                                        bottom: context.vPadding * 2),
                                    child: Image.file(
                                      File(value[index]['imgPath']),
                                      width: context.pWidth,
                                    ))
                                : Container(
                                    margin: EdgeInsets.only(
                                        bottom: context.vPadding * 2),
                                    child: Image.network(
                                      value[index]['imgName'],
                                      width: context.pWidth,
                                    )),
                            Container(
                                padding: EdgeInsets.all(context.hPadding * 0.3),
                                alignment: Alignment.topRight,
                                child: InkWell(
                                    onTap: () => _onTapDeleteImage(index),
                                    child: Icon(Icons.cancel,
                                        color: Colors.black54)))
                          ]))));
            }));
  }
}
