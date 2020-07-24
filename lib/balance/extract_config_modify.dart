import 'dart:convert';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/user_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:flutter/material.dart';

class ExtractConfigModify extends StatefulWidget {
  final props;

  ExtractConfigModify(this.props);

  @override
  _ExtractConfigModifyState createState() => _ExtractConfigModifyState();
}

class _ExtractConfigModifyState extends State<ExtractConfigModify> {
  Map param = {'user': {}};

  @override
  void initState() {
    super.initState();
    if (widget.props != null) {
      param = {
        'extract_limit': '${widget.props['extract_limit']}',
        'extract_rate': '${widget.props['extract_rate']}',
        'comments': '${widget.props['comments'] ?? ''}',
        'user': {
          '${widget.props['user_id']}': {
            'user_id': '${widget.props['user_id']}',
            'login_name': '${widget.props['login_name']}'
          },
        }
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props == null ? '添加提现配置' : '${widget.props['login_name']} 提现配置修改'}'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          widget.props == null
              ? Container(
                  margin: EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 140,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '* ',
                              style: TextStyle(color: CFColors.danger),
                            ),
                            Text('用户')
                          ],
                        ),
                        margin: EdgeInsets.only(right: 10),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                          height: 30,
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            children: param['user'].keys.toList().map<Widget>((key) {
                              return Container(
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(right: 20),
                                      child: Text(
                                        '${param['user'][key]['login_name']}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        color: Color(0xffeeeeee),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              param['user'].remove(key);
                                            });
                                          },
                                          child: Icon(
                                            Icons.clear,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 110,
                        child: PrimaryButton(
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserPlugin(
                                  userCount: 1,
                                  selectUsersData: jsonDecode(
                                    jsonEncode(param['user']),
                                  ),
                                ),
                              ),
                            ).then((val) {
                              if (val != null) {
                                setState(() {
                                  param['user'] = jsonDecode(jsonEncode(val));
                                });
                              }
                            });
                          },
                          child: Text('选择用户'),
                        ),
                      )
                    ],
                  ),
                )
              : Container(),
          Input(
            label: '月免手续费额度',
            onChanged: (val) {
              param['extract_limit'] = val;
            },
            labelWidth: 140,
            require: true,
            value: param['extract_limit'] ?? '',
            type: 'float',
          ),
          Input(
            label: '费率占比',
            onChanged: (val) {
              param['extract_rate'] = val;
            },
            labelWidth: 140,
            require: true,
            value: param['extract_rate'] ?? '',
            type: 'float',
          ),
          Container(
            margin: EdgeInsets.only(right: 150),
            child: Text(
              '提现超过免费额度时候，提现的手续费占比',
              style: TextStyle(
                color: Color(0xff999999),
              ),
            ),
          ),
          Input(
            label: '备注',
            onChanged: (String val) {
              setState(() {
                param['comments'] = val;
              });
            },
            value: param['comments'] ?? '',
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 140,
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: PrimaryButton(
                          onPressed: () {
                            print(param);
                          },
                          child: Text('保存'),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
