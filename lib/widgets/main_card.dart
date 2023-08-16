import 'package:flutter/material.dart';
import 'package:safetouch/consts/sizes.dart';

class MainCard extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final String content;
  final Image image;
  final Color color;
  final Function? onPressed;

  const MainCard({
    required this.title,
    this.titleColor,
    required this.content,
    required this.image,
    required this.color,
    this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onPressed != null ? onPressed!() : null,
        child: Container(
            width: context.pWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: Offset(1, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                    width: context.pWidth,
                    height: context.pHeight * 0.05,
                    padding: EdgeInsets.only(
                      left: context.hPadding * 0.6,
                      right: context.hPadding * 0.6,
                    ),
                    decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5))),
                    alignment: Alignment.centerLeft,
                    child: Text(title,
                        style: TextStyle(
                            color: titleColor ?? Colors.white,
                            fontSize: context.vPadding * 1.2,
                            fontWeight: FontWeight.bold))),
                Container(
                    width: context.pWidth,
                    padding: EdgeInsets.only(
                      left: context.hPadding * 0.6,
                      top: context.hPadding * 0.6,
                    ),
                    color: Colors.white,
                    child: Text(content,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.vPadding * 1.1,
                            fontWeight: FontWeight.normal))),
                Container(
                    width: context.pWidth,
                    padding: EdgeInsets.only(
                      right: context.hPadding,
                      bottom: context.hPadding,
                    ),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5))),
                    child: SizedBox(
                        width: context.vPadding * 4,
                        height: context.vPadding * 4,
                        child: image))
              ],
            )));
  }
}
