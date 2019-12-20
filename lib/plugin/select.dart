import 'package:admin_flutter/style.dart';
import 'package:flutter/material.dart';

class Select extends StatefulWidget {
  final String label;
  final double labelWidth;
  final Function onChanged;
  final Map selectOptions;
  final String selectedValue;
  final bool require;

  Select(
      {@required this.selectOptions,
      @required this.selectedValue,
      @required this.label,
      @required this.onChanged,
      this.labelWidth,
      this.require = false});

  @override
  _SelectState createState() => _SelectState();
}

class _SelectState extends State<Select> {
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
                  style: TextStyle(color: CFColors.danger, fontSize: CFFontSize.content),
                ),
                Text(
                  '${widget.label}',
                  style: TextStyle(fontSize: CFFontSize.content),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(4),),
              ),
              height: 34,
              child: DropdownButton<String>(
                isExpanded: true,
                elevation: 1,
                underline: Container(),
                value: widget.selectedValue,
                onChanged: (String newValue) {
                  widget.onChanged(newValue);
                },
                items: widget.selectOptions.keys.toList().map<DropdownMenuItem<String>>((key) {
                  return DropdownMenuItem(
                    value: '$key',
                    child: Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        '${widget.selectOptions[key]}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: CFFontSize.content),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
