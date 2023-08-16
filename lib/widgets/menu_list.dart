import 'package:flutter/material.dart';
import 'package:safetouch/consts/sizes.dart';
import 'package:safetouch/models/models.dart';
import 'package:safetouch/utils/number_handler.dart';

class MenuList extends StatelessWidget {
  final List<MenuInfo> list;
  final Function onTapImage;
  const MenuList({required this.list, required this.onTapImage});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: context.pWidth,
        padding: EdgeInsets.all(context.hPadding),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.black87),
        child: Column(
            children: List.generate(
                list.length,
                (index) => Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                              onTap: () => list[index].imgName != null
                                  ? list[index].imgName!.isNotEmpty
                                      ? onTapImage(index)
                                      : null
                                  : null,
                              child: Container(
                                  width: context.pWidth * 0.15,
                                  height: context.pWidth * 0.15,
                                  color: Colors.white,
                                  child: list[index].imgName != null
                                      ? list[index].imgName!.isNotEmpty
                                          ? Stack(
                                              children: [
                                                Image.network(
                                                    list[index].imgName!,
                                                    width:
                                                        context.pWidth * 0.15,
                                                    height:
                                                        context.pWidth * 0.15),
                                                Align(
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: context.pWidth *
                                                            0.15,
                                                        height: context.pWidth *
                                                            0.04,
                                                        padding: EdgeInsets.all(
                                                            context.hPadding *
                                                                0.01),
                                                        color: Colors.black
                                                            .withOpacity(0.8),
                                                        child: Text('크게보기',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: context
                                                                      .hPadding *
                                                                  0.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ))))
                                              ],
                                            )
                                          : Icon(
                                              Icons.fastfood,
                                              color: Colors.black87,
                                              size: context.pWidth * 0.1,
                                            )
                                      : Icon(
                                          Icons.fastfood,
                                          color: Colors.black87,
                                          size: context.pWidth * 0.1,
                                        ))),
                          Container(
                              height: context.pWidth * 0.11,
                              margin: EdgeInsets.only(left: context.hPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(list[index].name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: context.hPadding * 0.8,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  Text(
                                      '${NumberHandler().addComma(list[index].price)}원',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: context.hPadding * 0.8,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ],
                              ))
                        ],
                      ),
                      index < list.length - 1
                          ? Container(
                              width: context.pWidth,
                              margin: EdgeInsets.only(
                                top: context.hPadding * 0.7,
                                bottom: context.hPadding * 0.7,
                              ),
                              child: Divider(
                                  color: Colors.grey,
                                  height: 1,
                                  thickness: 0.5))
                          : const SizedBox()
                    ]))));
  }
}
