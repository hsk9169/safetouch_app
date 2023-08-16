import 'package:flutter/material.dart';
import 'package:safetouch/consts/sizes.dart';

@immutable
class TitleBand extends StatelessWidget {
  final Color color;
  final String text;
  final Image image;
  final Color? textColor;
  final Widget? tailWidget;

  const TitleBand({
    Key? key,
    required this.color,
    required this.text,
    required this.image,
    this.textColor,
    this.tailWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(
          left: context.hPadding,
          right: context.hPadding,
          top: context.hPadding * 0.3,
          bottom: context.hPadding * 0.3,
        ),
        color: color,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            SizedBox(
                width: context.hPadding * 2,
                height: context.hPadding * 2,
                child: image),
            Padding(padding: EdgeInsets.all(context.hPadding * 0.2)),
            Text(text,
                style: TextStyle(
                    color: textColor ?? Colors.black,
                    fontSize: context.hPadding * 0.85,
                    fontWeight: FontWeight.bold))
          ]),
          tailWidget ?? SizedBox(),
        ]));
  }
}
