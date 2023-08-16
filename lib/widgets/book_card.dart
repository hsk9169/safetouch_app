import 'package:flutter/material.dart';
import 'package:safetouch/consts/sizes.dart';
import 'package:safetouch/widgets/contained_button.dart';
import 'package:safetouch/widgets/void_button.dart';
import 'package:safetouch/utils/number_handler.dart';

class BookCard extends StatelessWidget {
  final bool isCancelAvailable;
  final bool isConfirmed;
  final bool? isPhoneAvail;
  final Function? onTapPhoneCall;
  final String storeName;
  final String openTime;
  final String phoneNum;
  final String customerName;
  final String visitTime;
  final String visitNum;
  final String? menu;
  final String cancelStr;
  final String confirmStr;
  final String completeStr;
  final Function? onTapButton;
  final Function? onTapCancel;
  final String time;

  const BookCard({
    required this.isCancelAvailable,
    required this.isConfirmed,
    this.isPhoneAvail = false,
    this.onTapPhoneCall,
    required this.storeName,
    required this.openTime,
    required this.phoneNum,
    required this.customerName,
    required this.visitTime,
    required this.visitNum,
    this.menu,
    required this.cancelStr,
    required this.completeStr,
    required this.confirmStr,
    this.onTapButton,
    this.onTapCancel,
    required this.time,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: context.pWidth,
        padding: EdgeInsets.all(context.hPadding * 0.5),
        margin: EdgeInsets.only(
          top: context.vPadding,
          bottom: context.vPadding,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black,
        ),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                      width: context.hPadding * 2,
                      height: context.hPadding * 2,
                      child: Image(
                          image: AssetImage('asset/icons/home.png'),
                          color: Colors.white,
                          width: context.pWidth * 0.2,
                          height: context.pWidth * 0.2)),
                  Padding(padding: EdgeInsets.all(context.hPadding * 0.2)),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(storeName,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: context.hPadding * 0.85,
                                fontWeight: FontWeight.bold)),
                        Padding(
                            padding: EdgeInsets.all(context.hPadding * 0.05)),
                        Text(openTime,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: context.hPadding * 0.6,
                                fontWeight: FontWeight.normal)),
                      ])
                ],
              ),
              isCancelAvailable
                  ? VoidButton(
                      text: cancelStr,
                      textSize: context.contentsTextSize * 0.9,
                      boxWidth: context.pWidth * 0.35,
                      borderColor: Colors.white,
                      bgColor: Colors.black,
                      onPressed: () =>
                          onTapCancel != null ? onTapCancel!() : null,
                    )
                  : SizedBox()
            ]),
            Container(
                width: context.pWidth,
                margin: EdgeInsets.only(top: context.hPadding * 0.5),
                padding: EdgeInsets.all(context.hPadding * 0.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('고객명',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: context.hPadding * 0.7,
                                  fontWeight: FontWeight.normal)),
                          Padding(
                              padding: EdgeInsets.all(context.hPadding * 0.1)),
                          Text(customerName,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: context.hPadding * 0.85,
                                  fontWeight: FontWeight.bold)),
                          Padding(
                              padding: EdgeInsets.all(context.hPadding * 0.8)),
                          Text('방문시간',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: context.hPadding * 0.7,
                                  fontWeight: FontWeight.normal)),
                          Padding(
                              padding: EdgeInsets.all(context.hPadding * 0.1)),
                          Text(visitTime,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: context.hPadding * 0.85,
                                  fontWeight: FontWeight.bold)),
                          menu != null
                              ? menu!.isNotEmpty
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                          Padding(
                                              padding: EdgeInsets.all(
                                                  context.hPadding * 0.8)),
                                          Text('상점메뉴',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize:
                                                      context.hPadding * 0.7,
                                                  fontWeight:
                                                      FontWeight.normal)),
                                          Padding(
                                              padding: EdgeInsets.all(
                                                  context.hPadding * 0.1)),
                                          Text(menu!,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      context.hPadding * 0.85,
                                                  fontWeight: FontWeight.bold))
                                        ])
                                  : const SizedBox()
                              : const SizedBox(),
                        ],
                      )),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('휴대폰 번호',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: context.hPadding * 0.7,
                                  fontWeight: FontWeight.normal)),
                          Padding(
                              padding: EdgeInsets.all(context.hPadding * 0.1)),
                          Text(phoneNum,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: context.hPadding * 0.85,
                                  fontWeight: FontWeight.bold)),
                          Padding(
                              padding: EdgeInsets.all(context.hPadding * 0.8)),
                          Text('방문인원수',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: context.hPadding * 0.7,
                                  fontWeight: FontWeight.normal)),
                          Padding(
                              padding: EdgeInsets.all(context.hPadding * 0.1)),
                          Text('$visitNum명',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: context.hPadding * 0.85,
                                  fontWeight: FontWeight.bold)),
                        ],
                      )),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(context.hPadding * 0.8)),
                  Container(
                      alignment: Alignment.centerLeft,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(onTapCancel != null ? '답변시간' : '요청시간',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: context.hPadding * 0.7,
                                    fontWeight: FontWeight.normal)),
                            Padding(
                                padding:
                                    EdgeInsets.all(context.hPadding * 0.1)),
                            Text(
                                time.isNotEmpty
                                    ? NumberHandler().dateToStr(time)
                                    : '',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: context.hPadding * 0.85,
                                    fontWeight: FontWeight.bold))
                          ])),
                  Padding(padding: EdgeInsets.all(context.hPadding * 0.8)),
                  isPhoneAvail!
                      ? VoidButton(
                          text: '문의하기',
                          textSize: context.contentsTextSize * 1.2,
                          onPressed: () => onTapPhoneCall!(),
                        )
                      : const SizedBox(),
                  isPhoneAvail!
                      ? Padding(padding: EdgeInsets.all(context.hPadding * 0.2))
                      : const SizedBox(),
                  isConfirmed
                      ? ContainedButton(
                          color: Colors.green,
                          text: completeStr,
                          textSize: context.contentsTextSize * 1.2,
                        )
                      : ContainedButton(
                          color: Colors.green,
                          text: confirmStr,
                          textSize: context.contentsTextSize * 1.2,
                          onPressed: () => onTapButton!())
                ]))
          ],
        ));
  }
}
