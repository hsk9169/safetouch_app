import 'package:flutter/material.dart';
import 'package:safetouch/consts/sizes.dart';

@immutable
class VoidButton extends StatelessWidget {
  final Function? onPressed;
  final String text;
  final double? textSize;
  final double? boxWidth;
  final Color? borderColor;
  final Color? bgColor;

  const VoidButton({
    Key? key,
    this.onPressed,
    required this.text,
    this.textSize,
    this.boxWidth,
    this.borderColor,
    this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
          fixedSize: boxWidth == null
              ? MaterialStateProperty.all<Size>(
                  Size.fromWidth(context.pWidth - context.hPadding * 3))
              : MaterialStateProperty.all<Size>(Size.fromWidth(boxWidth!)),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              EdgeInsets.only(top: context.vPadding, bottom: context.vPadding)),
          backgroundColor: MaterialStateProperty.all(bgColor ?? Colors.white),
          side: MaterialStateProperty.all<BorderSide>(BorderSide(
            color: borderColor ?? Colors.black,
          )),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.pWidth * 0.01),
            ),
          ),
          overlayColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.grey.withOpacity(0.4);
              }
              return Colors.transparent;
            },
          ),
        ),
        child: Text(text,
            style: TextStyle(
                color: borderColor ?? Colors.black,
                fontSize: textSize ?? context.contentsTextSize * 1.3,
                fontWeight: FontWeight.bold)),
        onPressed: () {
          onPressed != null ? onPressed!() : null;
        });
  }
}
