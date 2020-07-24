import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:flutter/material.dart';

class ClassModifyAdd extends StatefulWidget {
  final props;

  ClassModifyAdd(this.props);

  @override
  _ClassModifyAddState createState() => _ClassModifyAddState();
}

class _ClassModifyAddState extends State<ClassModifyAdd> {
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
        title: Text(widget.props['item'] == null ? '新增工单分类' : '${widget.props['item']['class_name']} 修改'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Select(
            selectOptions: widget.props['industryClass'],
            selectedValue: param['parent_class_id'] ?? '0',
            label: '上级分类',
            onChanged: (String newValue) {
              setState(() {
                param['parent_class_id'] = newValue;
              });
            },
            labelWidth: 90,
          ),
          Input(
            label: '分类名称',
            require: true,
            onChanged: (val) => param['class_name'] = val,
            value: param['class_name'],
          ),
          Input(
            label: '分类排序',
            require: true,
            onChanged: (val) => param['sort'] = val,
            value: param['sort'],
          ),
          Input(
            label: '默认定价',
            require: true,
            onChanged: (val) => param['class_price'] = val,
            value: param['class_price'],
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 90,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Text('状态'),
                ),
                Expanded(
                  flex: 1,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          setState(() {
                            param['state'] = '1';
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Radio(
                              value: '1',
                              groupValue: param['state'],
                              onChanged: (val) {
                                setState(() {
                                  param['state'] = '1';
                                });
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Text('启用'),
                            )
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            param['state'] = '0';
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Radio(
                              value: '0',
                              groupValue: param['state'],
                              onChanged: (val) {
                                setState(() {
                                  param['state'] = '0';
                                });
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Text('停用'),
                            )
                          ],
                        ),
                      ),
                    ],
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
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      PrimaryButton(
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          print(param);
                        },
                        child: Text('确认提交'),
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
