import 'package:flutter/material.dart';
import 'package:safetouch/consts/sizes.dart';

@immutable
class ContainedButton extends StatelessWidget {
  final Function? onPressed;
  final Color color;
  final String text;
  final double? boxWidth;
  final double? textSize;
  final Color? textColor;
  final Widget? prefixImage;
  final Widget? suffixImage;

  const ContainedButton(
      {Key? key,
      this.onPressed,
      required this.color,
      required this.text,
      this.boxWidth,
      this.textSize,
      this.textColor,
      this.prefixImage,
      this.suffixImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
          fixedSize: boxWidth == null
              ? MaterialStateProperty.all<Size>(
                  Size.fromWidth(context.pWidth - context.hPadding * 3))
              : MaterialStateProperty.all<Size>(Size.fromWidth(boxWidth!)),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              EdgeInsets.all(context.vPadding)),
          backgroundColor: onPressed != null
              ? MaterialStateProperty.all(color)
              : MaterialStateProperty.all(Colors.grey),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.pWidth * 0.01),
            ),
          ),
          overlayColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.grey.withOpacity(0.5);
              }
              return Colors.transparent;
            },
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          prefixImage ?? const SizedBox(),
          Text(text,
              style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: textSize ?? context.contentsTextSize * 1.3,
                  fontWeight: FontWeight.bold)),
          suffixImage ?? const SizedBox(),
        ]),
        onPressed: () => onPressed != null ? onPressed!() : null);
  }
}
