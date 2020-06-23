import 'package:admin_flutter/style.dart';
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

  Input({
    @required this.label,
    this.labelWidth,
    this.placeholder,
    @required this.onChanged,
    this.require = false,
    this.maxLines = 1,
    this.contentPadding,
    this.value = '',
  });

  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<Input> {
  String value = '';

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  void didUpdateWidget(Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Container(
            width: widget.labelWidth ?? 80,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(right: 10),
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
            child: widget.maxLines == 1
                ? Container(
                    alignment: Alignment.centerLeft,
                    height: 34.0,
                    child: TextField(
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
                      style: TextStyle(fontSize: CFFontSize.content),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: widget.contentPadding ??
                            EdgeInsets.only(
                              top: 0,
                              bottom: 0,
                              left: 10,
                              right: 10,
                            ),
                        hintText: widget.placeholder ?? '',
                      ),
                      maxLines: widget.maxLines,
                      onChanged: (String val) {
                        setState(() {
                          value = val;
                        });
                        widget.onChanged(val);
                      },
                    ),
                  )
                : TextField(
                    style: TextStyle(fontSize: CFFontSize.content),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: widget.contentPadding ??
                          EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                            left: 10,
                            right: 10,
                          ),
                      hintText: widget.placeholder ?? '',
                    ),
                    maxLines: widget.maxLines,
                    onChanged: (String val) {
                      widget.onChanged(val);
                    },
                  ),
          )
        ],
      ),
    );
  }
}
