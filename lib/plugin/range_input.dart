import 'package:admin_flutter/style.dart';
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
                      child: TextField(
                    style: TextStyle(fontSize: CFFontSize.content),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                        top: 0,
                        bottom: 0,
                        left: 15,
                        right: 15,
                      ),
                    ),
                    onChanged: (String val) {
                      widget.onChangeL(val);
                    },
                  )),
                  Container(
                    width: 20,
                    alignment: Alignment.center,
                    child: Text('-'),
                  ),
                  Expanded(
                    child: TextField(
                      style: TextStyle(fontSize: CFFontSize.content),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.only(
                          top: 0,
                          bottom: 0,
                          left: 15,
                          right: 15,
                        ),
                      ),
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
