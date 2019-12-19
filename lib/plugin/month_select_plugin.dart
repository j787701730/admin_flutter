import 'package:admin_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

/// 月份选择插件
class MonthSelectPlugin extends StatefulWidget {
  final String min;
  final String max;
  final double labelWidth;
  final Function onChanged;
  final bool require; // 是否必填 显示*
  final String label;
  final bool operaNull; // 是否要处理取消时null

  MonthSelectPlugin({
    @required this.onChanged,
    @required this.label,
    this.min,
    this.max,
    this.labelWidth,
    this.require = false,
    this.operaNull = false,
  });

  @override
  _MonthSelectPluginState createState() => _MonthSelectPluginState();
}

class _MonthSelectPluginState extends State<MonthSelectPlugin> {
  DateTime min;
  DateTime max;

  @override
  void initState() {
    super.initState();
    if (widget.min != null) {
      min = DateTime.tryParse(widget.min);
    }
    if (widget.max != null) {
      max = DateTime.tryParse(widget.max);
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
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      showMonthPicker(
                        context: context,
                        firstDate: DateTime.tryParse('1970-01-01 00:00:00'),
                        lastDate: DateTime.tryParse('2099-12-31 23:59:59'),
                        initialDate: min ?? DateTime.now(),
                      ).then((val) {
                        setState(() {
                          if (!widget.operaNull || val != null) {
                            min = val;
                          }
                          widget.onChanged({'min': min, 'max': max});
                        });
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(4))),
                      height: 34,
                      padding: EdgeInsets.only(left: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(min == null ? '' : min.toString().substring(0, 7)),
                    ),
                  ),
                ),
                Container(
                  width: 20,
                  child: Center(
                    child: Text('-'),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        showMonthPicker(
                          context: context,
                          firstDate: DateTime.tryParse('1970-01-01 00:00:00'),
                          lastDate: DateTime.tryParse('2099-12-31 23:59:59'),
                          initialDate: max ?? DateTime.now(),
                        ).then((val) {
                          setState(() {
                            if (!widget.operaNull || val != null) {
                              max = val;
                            }
                            widget.onChanged({'min': min, 'max': max});
                          });
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(4))),
                        height: 34,
                        padding: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        child: Text(max == null ? '' : max.toString().substring(0, 7)),
                      ),
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
