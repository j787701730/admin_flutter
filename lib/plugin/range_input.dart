import 'package:admin_flutter/plugin/input-single.dart';
import 'package:flutter/material.dart';

class RangeInput extends StatefulWidget {
  final String label;
  final double labelWidth;
  final Function onChangeL;
  final Function onChangeR;

  RangeInput({@required this.label, this.labelWidth, @required this.onChangeL, @required this.onChangeR});

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
