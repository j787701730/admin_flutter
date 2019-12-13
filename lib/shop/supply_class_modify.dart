import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:flutter/material.dart';

class SupplyClassModify extends StatefulWidget {
  final props;

  SupplyClassModify(this.props);

  @override
  _SupplyClassModifyState createState() => _SupplyClassModifyState();
}

class _SupplyClassModifyState extends State<SupplyClassModify> {
  Map param = {};

  @override
  void initState() {
    super.initState();
    if (widget.props['item'] != null) {
      param = widget.props['item'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.props['item'] == null ? '新增供应商分类' : '${widget.props['item']['goods-class-name']} 修改'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Select(selectOptions: widget.props['industryClass'], selectedValue: param['parent-class'] ?? '0',label: '上级分类',onChanged: (String newValue) {
            setState(() {
              param['parent-class'] = newValue;
            });
          },labelWidth: 90,),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 90,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('分类名称')
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: TextEditingController.fromValue(TextEditingValue(
                        text: '${param['goods-class-name'] ?? ''}',
                        selection: TextSelection.fromPosition(TextPosition(
                            affinity: TextAffinity.downstream, offset: '${param['goods-class-name'] ?? ''}'.length)))),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 15)),
                    onChanged: (String val) {
                      setState(() {
                        param['goods-class-name'] = val;
                      });
                    },
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 90,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('分类排序')
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: TextEditingController.fromValue(TextEditingValue(
                        text: '${param['class-sort'] ?? ''}',
                        selection: TextSelection.fromPosition(TextPosition(
                            affinity: TextAffinity.downstream, offset: '${param['class-sort'] ?? ''}'.length)))),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 15)),
                    onChanged: (String val) {
                      setState(() {
                        param['class-sort'] = val;
                      });
                    },
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 90,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Text('备注'),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: TextEditingController.fromValue(TextEditingValue(
                        text: '${param['class-comment'] ?? ''}',
                        selection: TextSelection.fromPosition(TextPosition(
                            affinity: TextAffinity.downstream, offset: '${param['class-comment'] ?? ''}'.length)))),
                    maxLines: 4,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 15)),
                    onChanged: (String val) {
                      setState(() {
                        param['class-comment'] = val;
                      });
                    },
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 90,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Text(''),
                ),
                Expanded(
                  flex: 1,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      SizedBox(
                        height: 30,
                        child: PrimaryButton(
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              print(param);
                            },
                            child: Text('确认提交')),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
