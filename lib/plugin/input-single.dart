import 'package:admin_flutter/utils.dart';
import 'package:flutter/material.dart';

class InputSingle extends StatefulWidget {
  final String placeholder;
  final Function onChanged;
  final Padding contentPadding; // TextField contentPadding
  final value;
  final NumberType type; // int, float
  final int decimal; // type 是 float, 保留的位数
  final String sign; // '-' 表示支持负数, 负整数设置: type=float, decimal=0
  final int maxLines;

  InputSingle({
    this.placeholder,
    @required this.onChanged,
    this.contentPadding,
    this.value = '',
    this.type,
    this.decimal = 2,
    this.sign = '+',
    this.maxLines = 1,
  });

  @override
  _InputSingleState createState() => _InputSingleState();
}

class _InputSingleState extends State<InputSingle> {
  String value = '';

  @override
  void initState() {
    super.initState();
    value = widget.value ?? '';
  }

  @override
  void didUpdateWidget(InputSingle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.maxLines == 1 ? 34.0 : null,
      child: TextField(
        maxLines: widget.maxLines,
        controller: TextEditingController.fromValue(
          TextEditingValue(
            text: '${value ?? ''}',
            selection: TextSelection.fromPosition(
              TextPosition(
                affinity: TextAffinity.downstream,
                offset: '${value ?? ''}'.length,
              ),
            ),
          ),
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: widget.contentPadding ??
              EdgeInsets.only(
                top: widget.maxLines == 1 ? 0 : 10,
                bottom: widget.maxLines == 1 ? 0 : 10,
                left: 10,
                right: 10,
              ),
          hintText: widget.placeholder ?? '',
        ),
        onChanged: (String val) {
          String regVal = val;
          if (widget.type == NumberType.int) {
            regVal = clearNoInt(val);
          } else {
            if (widget.type == NumberType.float) {
              regVal = clearNoNum(val, decimal: widget.decimal, sign: widget.sign);
            }
          }
          setState(() {
            value = regVal;
          });
          widget.onChanged(regVal);
        },
      ),
    );
  }
}
