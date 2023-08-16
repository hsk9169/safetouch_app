import 'package:flutter/material.dart';
import 'package:safetouch/consts/sizes.dart';

@immutable
class DataViewForm extends StatelessWidget {
  final String title;
  final Widget? helpWidget;
  final String content;
  final Color? color;
  final Color? borderColor;

  const DataViewForm({
    Key? key,
    required this.title,
    this.helpWidget,
    required this.content,
    this.color,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: context.pWidth,
        height: context.hPadding * 3,
        margin: EdgeInsets.only(
          bottom: context.vPadding * 0.8,
        ),
        child: Column(children: [
          Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(title,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.hPadding * 0.8,
                            fontWeight: FontWeight.bold)),
                  )),
              Expanded(
                  flex: 3,
                  child: Container(
                      width: context.pWidth * 0.5,
                      height: context.pHeight * 0.045,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(
                        left: context.hPadding * 0.5,
                        right: context.hPadding * 0.5,
                      ),
                      decoration: BoxDecoration(
                          color: color ?? Colors.black12,
                          border:
                              Border.all(color: borderColor ?? Colors.black12),
                          borderRadius:
                              BorderRadius.circular(context.pWidth * 0.02)),
                      child: Text(content,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: context.hPadding * 0.7,
                              fontWeight: FontWeight.bold))))
            ],
          ),
          Padding(padding: EdgeInsets.all(context.hPadding * 0.1)),
          Align(
              alignment: Alignment.bottomRight, child: helpWidget ?? SizedBox())
        ]));
  }
}
