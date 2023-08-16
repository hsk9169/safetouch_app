import 'dart:io';
import 'package:flutter/material.dart';
import 'package:safetouch/consts/sizes.dart';
import 'package:safetouch/models/models.dart';
import 'package:safetouch/widgets/data_view_form.dart';
import 'package:safetouch/widgets/data_button_form.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:safetouch/widgets/contained_button.dart';

class MenuCard extends StatelessWidget {
  final List<MenuInfo> menuInfo;
  final int index;
  final TextEditingController menuController;
  final TextEditingController priceController;
  final Function onMenuChanged;
  final Function onPriceChanged;
  final Function onTapAddListMenuImage;
  final Function onTapDeleteListMenuImage;
  final Function onTapDeleteMenu;
  final Function onTapChangeRepMenu;

  const MenuCard({
    Key? key,
    required this.menuInfo,
    required this.index,
    required this.menuController,
    required this.priceController,
    required this.onMenuChanged,
    required this.onPriceChanged,
    required this.onTapAddListMenuImage,
    required this.onTapDeleteListMenuImage,
    required this.onTapDeleteMenu,
    required this.onTapChangeRepMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(
          top: context.hPadding * 1.5,
          left: context.hPadding * 1.5,
          right: context.hPadding * 1.5,
        ),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10)),
        child: Container(
            padding: EdgeInsets.only(
              top: context.hPadding * 1.8,
              bottom: context.hPadding,
              left: context.hPadding,
              right: context.hPadding,
            ),
            child: Column(children: [
              Container(
                  width: context.pWidth,
                  height: context.hPadding * 3,
                  margin: EdgeInsets.only(
                    bottom: context.vPadding * 0.4,
                  ),
                  child: Column(children: [
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('메뉴명',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: context.hPadding * 0.8,
                                      fontWeight: FontWeight.bold)),
                            )),
                        Expanded(
                            flex: 3,
                            child: TextField(
                                controller: menuController,
                                onChanged: (value) => onMenuChanged(value),
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.all(context.hPadding * 0.5),
                                  hintText: '메뉴명을 입력해주세요',
                                  hintStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal),
                                  constraints: BoxConstraints(
                                    maxWidth: context.pWidth * 0.5,
                                    maxHeight: context.pHeight * 0.045,
                                  ),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 1),
                                      borderRadius: BorderRadius.circular(
                                          context.pWidth * 0.02)),
                                ),
                                keyboardType: TextInputType.text,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: context.hPadding * 0.7,
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ])),
              Container(
                  width: context.pWidth,
                  height: context.hPadding * 3,
                  margin: EdgeInsets.only(
                    bottom: context.vPadding * 0.4,
                  ),
                  child: Column(children: [
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('가격',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: context.hPadding * 0.8,
                                      fontWeight: FontWeight.bold)),
                            )),
                        Expanded(
                            flex: 3,
                            child: TextField(
                                controller: priceController,
                                onChanged: (value) => onPriceChanged(value),
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.all(context.hPadding * 0.5),
                                  hintText: '숫자만 입력해주세요',
                                  hintStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal),
                                  constraints: BoxConstraints(
                                    maxWidth: context.pWidth * 0.5,
                                    maxHeight: context.pHeight * 0.045,
                                  ),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 1),
                                      borderRadius: BorderRadius.circular(
                                          context.pWidth * 0.02)),
                                ),
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: context.hPadding * 0.7,
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ])),
              DataButtonForm(
                  title: '상품 이미지',
                  isVisible: menuInfo[index].imgName != null
                      ? menuInfo[index].imgName!.isNotEmpty
                          ? false
                          : true
                      : true,
                  input: InkWell(
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
                                      image:
                                          AssetImage('asset/icons/image.png'),
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
                      onTap: () => onTapAddListMenuImage())),
              menuInfo[index].imgName != null
                  ? menuInfo[index].imgName!.isNotEmpty
                      ? Stack(children: [
                          menuInfo[index].imgContent == null
                              ? Container(
                                  margin: EdgeInsets.only(
                                      bottom: context.vPadding * 2),
                                  child: Image.network(
                                    menuInfo[index].imgName!,
                                    width: context.pWidth,
                                  ))
                              : Container(
                                  margin: EdgeInsets.only(
                                      bottom: context.vPadding * 2),
                                  child: Image.file(
                                    File(menuInfo[index].imgPath!),
                                    width: context.pWidth,
                                  )),
                          Container(
                              padding: EdgeInsets.all(context.hPadding * 0.2),
                              alignment: Alignment.topRight,
                              child: InkWell(
                                  onTap: () => onTapDeleteListMenuImage(),
                                  child: Icon(Icons.cancel,
                                      color: Colors.black54)))
                        ])
                      : const SizedBox()
                  : const SizedBox(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ContainedButton(
                  boxWidth: context.pWidth * 0.18,
                  color: Colors.red,
                  text: '삭제',
                  textSize: context.contentsTextSize,
                  onPressed: () => onTapDeleteMenu(),
                ),
                ContainedButton(
                    boxWidth: context.pWidth * 0.52,
                    color: menuInfo[index].repMenuFlag == '1'
                        ? Colors.grey
                        : Colors.green,
                    text: menuInfo[index].repMenuFlag == '1'
                        ? '대표메뉴에서 제외하기'
                        : '대표메뉴로 설정하기',
                    textSize: context.contentsTextSize,
                    prefixImage: Container(
                        margin: EdgeInsets.only(right: context.hPadding * 0.3),
                        child: Image(
                            image: AssetImage('asset/icons/stars.png'),
                            width: context.pWidth * 0.05,
                            height: context.pWidth * 0.05)),
                    onPressed: () => onTapChangeRepMenu()),
              ])
            ])));
  }
}
