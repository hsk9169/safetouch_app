import 'package:flutter/material.dart';
import 'package:safetouch/consts/sizes.dart';

@immutable
class DataButtonForm extends StatelessWidget {
  final String title;
  final Widget input;
  final bool isVisible;

  const DataButtonForm({
    Key? key,
    required this.title,
    required this.input,
    required this.isVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: context.pWidth,
        margin: EdgeInsets.only(
          bottom: context.vPadding * 0.8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(title,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding * 0.8,
                          fontWeight: FontWeight.bold)),
                )),
            Expanded(
                flex: 3,
                child: isVisible
                    ? Container(
                        width: context.pWidth * 0.5,
                        alignment: Alignment.centerLeft,
                        child: input)
                    : const SizedBox())
          ],
        ));
  }
}
