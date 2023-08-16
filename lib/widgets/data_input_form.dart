import 'package:flutter/material.dart';
import 'package:safetouch/consts/sizes.dart';

@immutable
class DataInputForm extends StatefulWidget {
  final String title;
  final String? initData;
  final Widget? helpWidget;
  final TextInputType type;
  final bool? isObscure;
  final Function? onChanged;
  final bool? isDisabled;
  final Function? onCompleted;
  final String? hintText;
  final TextEditingController? controller;

  const DataInputForm({
    Key? key,
    required this.title,
    this.initData,
    this.helpWidget,
    required this.type,
    this.isObscure,
    this.onChanged,
    this.isDisabled,
    this.onCompleted,
    this.hintText,
    this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DataInputForm();
}

class _DataInputForm extends State<DataInputForm> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _textEditingController =
          TextEditingController(text: widget.initData ?? '');
    } else {
      _textEditingController = widget.controller!;
    }
    _textEditingController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final value = _textEditingController.text;
    widget.onChanged != null ? widget.onChanged!(value) : null;
    if (widget.onCompleted != null) {
      if (value.length <= 8) {
        if (value.length == 8) {
          widget.onCompleted!(value);
        } else {
          widget.onCompleted!('');
        }
      } else {
        _textEditingController.text = value.substring(0, 8);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    child: Text(widget.title,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.hPadding * 0.8,
                            fontWeight: FontWeight.bold)),
                  )),
              Expanded(
                  flex: 3,
                  child: TextField(
                      controller: _textEditingController,
                      enabled: widget.isDisabled != null ? false : true,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(context.hPadding * 0.5),
                        hintText: widget.hintText,
                        hintStyle: const TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.normal),
                        fillColor: widget.isDisabled != null
                            ? Colors.black12
                            : Colors.white,
                        filled: true,
                        constraints: BoxConstraints(
                          maxWidth: context.pWidth * 0.5,
                          maxHeight: context.pHeight * 0.045,
                        ),
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1),
                            borderRadius:
                                BorderRadius.circular(context.pWidth * 0.02)),
                      ),
                      keyboardType: widget.type,
                      obscureText: widget.isObscure != null ? true : false,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding * 0.7,
                          fontWeight: FontWeight.bold))),
            ],
          ),
          widget.helpWidget != null
              ? Container(
                  margin: EdgeInsets.only(top: context.vPadding * 0.1),
                  alignment: Alignment.bottomRight,
                  child: widget.helpWidget)
              : SizedBox()
        ]));
  }
}
