import 'package:admin_flutter/plugin/input-single.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final String label;
  final double labelWidth;
  final String placeholder;
  final Function onChanged;
  final bool require; // 是否必填 显示*
  final int maxLines;
  final Padding contentPadding; // TextField contentPadding
  final value;
  final double marginTop;
  final NumberType type; // int, float
  final int decimal; // type 是 float, 保留的位数
  final String sign; // '-' 表示支持负数, 负整数设置: type=float, decimal=0

  Input({
    @required this.label,
    this.labelWidth,
    this.placeholder,
    @required this.onChanged,
    this.require = false,
    this.maxLines = 1,
    this.contentPadding,
    this.value = '',
    this.marginTop,
    this.type,
    this.decimal = 2,
    this.sign = '+',
  });

  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<Input> {
  String value = '';

  @override
  void initState() {
    super.initState();
    value = widget.value ?? '';
  }

  @override
  void didUpdateWidget(Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      value = widget.value ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: widget.marginTop == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: widget.labelWidth ?? 80,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(
              right: widget.label == '' ? 0 : 10,
              top: widget.marginTop ?? 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  '${widget.require ? '* ' : ''}',
                  style: TextStyle(color: CFColors.danger),
                ),
                Text('${widget.label}')
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              height: widget.maxLines == 1 ? 34.0 : null,
              child: InputSingle(
                onChanged: (val) {
                  String regVal = val;
                  if (widget.type == NumberType.int) {
                    regVal = clearNoInt(val);
                  } else if (widget.type == NumberType.float) {
                    regVal = clearNoNum(val, decimal: widget.decimal, sign: widget.sign);
                  }
                  setState(() {
                    value = regVal;
                  });
                  widget.onChanged(regVal);
                },
                maxLines: widget.maxLines,
                value: widget.value,
                placeholder: widget.placeholder,
                decimal: widget.decimal,
                sign: widget.sign,
                type: widget.type,
                contentPadding: widget.contentPadding,
              ),
            ),
          )
        ],
      ),
    );
  }
}
