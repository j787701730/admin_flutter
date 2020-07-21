import 'dart:convert';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AttributeAddModify extends StatefulWidget {
  final props;

  AttributeAddModify(this.props);

  @override
  _AttributeAddModifyState createState() => _AttributeAddModifyState();
}

class _AttributeAddModifyState extends State<AttributeAddModify> {
  Map param = {'param_enums': [], 'param_name': ''};

  @override
  void initState() {
    super.initState();
    if (widget.props != null) {
      param['param_name'] = widget.props['param_name'];
      param['param_enums'] = jsonDecode(widget.props['param_enums']);
      param['param_id'] = widget.props['param_id'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.props == null ? '新增属性' : '${widget.props['param_name']} 属性修改'),
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: <Widget>[
          Input(
            label: '属性名称',
            require: true,
            onChanged: (val) {
              param['param_name'] = val;
            },
            value: param['param_name'] ?? '',
          ),
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(
                    right: 10,
                    top: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('属性枚举')
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: param['param_enums'].isEmpty
                      ? Container()
                      : Container(
                          child: Column(
                            children: param['param_enums'].map<Widget>((enums) {
                              int index = param['param_enums'].indexOf(enums);
                              return Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Input(
                                        label: '',
                                        labelWidth: 0,
                                        onChanged: (val) {
                                          param['param_enums'][index] = val;
                                        },
                                        value: enums,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            param['param_enums'].removeAt(index);
                                          });
                                        },
                                        child: Icon(
                                          Icons.restore_from_trash,
                                          color: CFColors.danger,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 90),
            child: Row(
              children: <Widget>[
                PrimaryButton(
                  onPressed: () {
                    setState(() {
                      param['param_enums'].add('');
                    });
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: Text('添加枚举'),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 90, top: 15),
            child: Row(
              children: <Widget>[
                PrimaryButton(
                  onPressed: () {
                    print(param);
                    FocusScope.of(context).requestFocus(FocusNode());
                    bool flag = true;
                    List msg = [];
                    if (param['param_name'] == null || '${param['param_name']}'.trim() == '') {
                      flag = false;
                      msg.add('属性名称');
                    }
                    List arr = [];
                    if (param['param_enums'].isNotEmpty) {
                      for (var o in param['param_enums']) {
                        if (o != null && '$o'.trim() != '') {
                          print(o);
                          arr.add(o);
                        }
                      }
                    }
                    if (arr.isEmpty) {
                      flag = false;
                      msg.add('属性枚举');
                    }
                    param['param_enums'] = arr;
                    setState(() {});

                    if (flag) {
                      ajax(
                          param['param_id'] != null
                              ? 'Adminrelas-RenderSoftware-editParams'
                              : 'Adminrelas-RenderSoftware-addParams',
                          {'data': jsonEncode(param)},
                          true, (res) {
                        Navigator.of(context).pop(true);
                      }, () {}, context);
                    } else {
                      Fluttertoast.showToast(
                        msg: '请填写 ${msg.join(', ')}',
                        gravity: ToastGravity.CENTER,
                      );
                    }
                  },
                  child: Text('确认保存'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
