import 'package:admin_flutter/plugin/input-single.dart';
import 'package:flutter/material.dart';
import 'package:admin_flutter/utils.dart';

class RangeInput extends StatefulWidget {
  final String label;
  final double labelWidth;
  final Function onChangeL;
  final Function onChangeR;
  final NumberType type; // int, float
  final int decimal; // type 是 float, 保留的位数
  final String sign; // '-' 表示支持负数, 负整数设置: type=float, decimal=0

  RangeInput({
    @required this.label,
    this.labelWidth,
    @required this.onChangeL,
    @required this.onChangeR,
    this.type,
    this.decimal = 2,
    this.sign = '+',
  });

  @override
  _RangeInputState createState() => _RangeInputState();
}

class _RangeInputState extends State<RangeInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            alignment: Alignment.topRight,
            child: Text('${widget.label}'),
            width: widget.labelWidth ?? 80,
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 34,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: InputSingle(
                      onChanged: (String val) {
                        widget.onChangeL(val);
                      },
                      decimal: widget.decimal,
                      sign: widget.sign,
                      type: widget.type,
                    ),
                  ),
                  Container(
                    width: 20,
                    alignment: Alignment.center,
                    child: Text('-'),
                  ),
                  Expanded(
                    child: InputSingle(
                      onChanged: (String val) {
                        widget.onChangeR(val);
                      },
                      decimal: widget.decimal,
                      sign: widget.sign,
                      type: widget.type,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
