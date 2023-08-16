import 'package:flutter/material.dart';
import 'package:safetouch/consts/sizes.dart';
import 'package:safetouch/widgets/void_button.dart';
import 'package:safetouch/widgets/contained_button.dart';

class BottomButtons extends StatelessWidget {
  final Color? btn3Color;
  final Color? btn3TextColor;
  final String? btn1Text;
  final String? btn2Text;
  final String? btn3Text;
  final Function? btn1Pressed;
  final Function? btn2Pressed;
  final Function? btn3Pressed;
  final bool btn3Enabled;

  const BottomButtons({
    this.btn3Color,
    this.btn3TextColor,
    this.btn1Text,
    this.btn2Text,
    this.btn3Text,
    this.btn1Pressed,
    this.btn2Pressed,
    this.btn3Pressed,
    required this.btn3Enabled,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            margin: EdgeInsets.only(bottom: context.vPadding * 5),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              btn1Text != null
                  ? VoidButton(text: btn1Text!, onPressed: btn1Pressed)
                  : const SizedBox(),
              Padding(
                padding: EdgeInsets.all(context.vPadding * 0.5),
              ),
              btn2Text != null
                  ? VoidButton(text: btn2Text!, onPressed: btn2Pressed)
                  : const SizedBox(),
              Padding(
                padding: EdgeInsets.all(context.vPadding * 0.5),
              ),
              btn3Text != null
                  ? ContainedButton(
                      color: btn3Color!,
                      text: btn3Text!,
                      textColor:
                          btn3TextColor == null ? Colors.white : btn3TextColor!,
                      onPressed: btn3Pressed)
                  : const SizedBox()
            ])));
  }
}
