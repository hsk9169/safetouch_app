import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safetouch/consts/sizes.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:safetouch/widgets/basic_struct.dart';
import 'package:safetouch/widgets/bottom_buttons.dart';
import 'package:safetouch/widgets/contained_button.dart';
import 'package:safetouch/widgets/title_band.dart';
import 'package:safetouch/widgets/data_input_form.dart';
import 'package:safetouch/widgets/data_view_form.dart';
import 'package:safetouch/widgets/data_button_form.dart';
import 'package:safetouch/models/models.dart';
import 'package:safetouch/widgets/menu_card.dart';

class AddStoreView2 extends StatefulWidget {
  StoreDetails details;
  AddStoreView2({required this.details});
  @override
  State<StatefulWidget> createState() => _AddStoreView2();
}

class _AddStoreView2 extends State<AddStoreView2> {
  StoreDetails _storeDetails = StoreDetails.initialize();
  ValueNotifier<bool> _isNextEnabled = ValueNotifier<bool>(false);
  bool _isLastAdded = false;
  ValueNotifier<Map<String, dynamic>> _menuImage =
      ValueNotifier<Map<String, dynamic>>({});
  List<MenuInfo> _menuList = [];
  final ValueNotifier<String> _introText = ValueNotifier<String>('');
  late TextEditingController _introTextController;
  List<TextEditingController> _priceInputList = [];
  List<TextEditingController> _menuInputList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _storeDetails = widget.details;
      _introText.value = widget.details.storeIntro;
      _checkInputs();
    });
    _initData();
  }

  void _initData() {
    _menuList = widget.details.menuList;
    _introTextController =
        TextEditingController(text: widget.details.storeIntro);
    _introTextController.addListener(_onIntroChanged);
    widget.details.menuList.forEach((menu) {
      _menuInputList.add(TextEditingController(text: menu.name));
      _priceInputList.add(TextEditingController(text: menu.price));
    });
  }

  void _onIntroChanged() {
    if (_introTextController.text.length > 500) {
      _introTextController.text = _introText.value;
    } else {
      _introText.value = _introTextController.text;
    }
    _checkInputs();
  }

  void _onListMenuChanged(int index, String value) {
    _menuList[index].name = value;
    _checkInputs();
  }

  void _onListPriceChanged(int index, String value) {
    _menuList[index].price = value;
    _checkInputs();
  }

  void _onTapAddListMenuImage(int index) async {
    XFile? imgFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (imgFile != null) {
      final String fileName = imgFile.name;
      final String filePath = imgFile.path;
      Uint8List? imgBytes = await imgFile.readAsBytes();
      String imageEncoded = base64.encode(imgBytes);
      setState(() {
        _menuList[index].imgName = fileName;
        _menuList[index].imgContent = imageEncoded;
        _menuList[index].imgPath = filePath;
      });
    }
  }

  void _onTapDeleteListMenuImage(int index) {
    setState(() {
      _menuList[index].imgName = null;
      _menuList[index].imgContent = null;
      _menuList[index].imgName = null;
    });
  }

  void _onTapAddMenu() {
    setState(() {
      _menuList.add(MenuInfo.initialize());
    });
    _menuInputList.add(TextEditingController());
    _priceInputList.add(TextEditingController());
    _checkInputs();
  }

  void _onTapDeleteMenu(int index) {
    _menuInputList.removeAt(index);
    _priceInputList.removeAt(index);
    setState(() => _menuList.removeAt(index));
    _checkInputs();
  }

  void _onTapChangeRepMenu(int index) {
    setState(() {
      if (_menuList[index].repMenuFlag == '1') {
        _menuList[index].repMenuFlag = '0';
      } else {
        _menuList[index].repMenuFlag = '1';
      }
    });
  }

  void _checkInputs() {
    bool checkIntro = _introTextController.text.isNotEmpty;
    bool checkMenuList = true;
    _menuList.asMap().forEach((idx, menu) {
      checkMenuList = checkMenuList &
          _menuInputList[idx].text.isNotEmpty &
          _priceInputList[idx].text.isNotEmpty;
    });
    setState(() => _isNextEnabled.value = checkIntro & checkMenuList);
  }

  void _onTapNext() {
    _storeDetails.storeIntro = _introText.value;
    _storeDetails.menuList = _menuList;
    context.pushNamed('add_store_3', extra: _storeDetails);
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
              child: Column(
                children: [
                  TitleBand(
                      color: Colors.orange,
                      textColor: Colors.white,
                      text: '상점을 소개해주세요',
                      image: Image(
                          color: Colors.white,
                          image: AssetImage('asset/icons/list.png'),
                          width: context.pWidth * 0.2,
                          height: context.pWidth * 0.2)),
                  _renderIntroInput(),
                  TitleBand(
                      color: Colors.orange,
                      textColor: Colors.white,
                      text: '상점내 메뉴를 등록해주세요',
                      image: Image(
                          image: AssetImage('asset/icons/hands.png'),
                          width: context.pWidth * 0.2,
                          height: context.pWidth * 0.2)),
                  _renderMenuList(),
                  Container(
                      padding: EdgeInsets.only(
                        top: context.hPadding,
                        left: context.hPadding * 1.5,
                        right: context.hPadding * 1.5,
                      ),
                      alignment: Alignment.centerRight,
                      child: ContainedButton(
                          color: Colors.black,
                          boxWidth: double.infinity,
                          textSize: context.hPadding * 0.6,
                          text: '메뉴 추가하기',
                          onPressed: () => _onTapAddMenu())),
                  ValueListenableBuilder(
                      valueListenable: _isNextEnabled,
                      builder: (BuildContext context, bool value, _) {
                        return BottomButtons(
                          btn3Enabled: false,
                          btn3Text: '다 음',
                          btn3Color: Colors.black,
                          btn3Pressed: value ? () => _onTapNext() : null,
                        );
                      })
                ],
              ))),
    );
  }

  Widget _renderIntroInput() {
    return ValueListenableBuilder<String>(
      builder: (BuildContext context, String value, Widget? child) {
        return Container(
            width: context.pWidth,
            padding: EdgeInsets.only(
              left: context.hPadding * 1.5,
              right: context.hPadding * 1.5,
            ),
            margin: EdgeInsets.only(
                top: context.vPadding * 2, bottom: context.vPadding * 2),
            child: Column(children: [
              TextField(
                  controller: _introTextController,
                  textAlignVertical: TextAlignVertical.top,
                  maxLines: 10,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: '상점 소개를 입력해주세요',
                    hintStyle: const TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.normal),
                    constraints: BoxConstraints(
                      maxWidth: context.pWidth,
                      maxHeight: context.pHeight * 0.2,
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1),
                        borderRadius:
                            BorderRadius.circular(context.pWidth * 0.02)),
                  ),
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.hPadding * 0.7,
                      fontWeight: FontWeight.bold)),
              Padding(padding: EdgeInsets.all(context.vPadding * 0.5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(value.length.toString(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding * 0.8,
                          fontWeight: FontWeight.bold)),
                  Text(' / 500',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding * 0.6,
                          fontWeight: FontWeight.normal)),
                ],
              )
            ]));
      },
      valueListenable: _introText,
    );
  }

  Widget _renderMenuList() {
    return Column(
        children: List.generate(
            _menuList.length,
            (idx) => MenuCard(
                  menuInfo: _menuList,
                  index: idx,
                  menuController: _menuInputList[idx],
                  priceController: _priceInputList[idx],
                  onMenuChanged: (value) => _onListMenuChanged(idx, value),
                  onPriceChanged: (value) => _onListPriceChanged(idx, value),
                  onTapAddListMenuImage: () => _onTapAddListMenuImage(idx),
                  onTapDeleteListMenuImage: () =>
                      _onTapDeleteListMenuImage(idx),
                  onTapChangeRepMenu: () => _onTapChangeRepMenu(idx),
                  onTapDeleteMenu: () => _onTapDeleteMenu(idx),
                )));
    ;
  }
}
