import 'dart:convert';

import 'package:admin_flutter/plugin/user_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:flutter/material.dart';

class BoardCutUserGrantModify extends StatefulWidget {
  final props;

  BoardCutUserGrantModify(this.props);

  @override
  _BoardCutUserGrantModifyState createState() => _BoardCutUserGrantModifyState();
}

class _BoardCutUserGrantModifyState extends State<BoardCutUserGrantModify> {
  Map param = {'user': {}, 'group_rights': []};
  Map chargeConfig = {
    "6": {
      "config_id": "6",
      "config_name": "标签配置89",
      "type_id": "2",
      "type_ch_name": "标签配置",
      "brand": "豪迈",
      "version": "3.2.14"
    },
    "7": {
      "config_id": "7",
      "config_name": "样式配置2",
      "type_id": "3",
      "type_ch_name": "样式配置",
      "brand": "豪迈",
      "version": "3.2.14"
    },
    "29": {
      "config_id": "29",
      "config_name": "测试配置",
      "type_id": "1",
      "type_ch_name": "机台配置",
      "brand": "test",
      "version": "1.22"
    }
  };

  @override
  void initState() {
    super.initState();
    if (widget.props != null) {
      param['user'][widget.props['user_id']] = {
        'user_id': '${widget.props['user_id']}',
        'login_name': '${widget.props['login_name']}',
      };
      param['group_rights'] = jsonDecode(widget.props['group_rights']);
    }
  }

  check() {
    for (var key in chargeConfig.keys.toList()) {
      if (!param['group_rights'].contains(key)) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.props == null ? '新增用户收费开料配置' : '用户收费开料配置修改'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 50,
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
                    padding: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
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
                              widget.props == null
                                  ? Positioned(
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
                                  : Container(),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                widget.props == null
                    ? PrimaryButton(
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
                        child: Text('选择'),
                      )
                    : Container()
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 50,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('授权')
                    ],
                  ),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey),
                        right: BorderSide(color: Colors.grey),
                        top: BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 34,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey),
                            ),
                            color: Color(0xffeeeeee),
                          ),
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Checkbox(
                                  value: check(),
                                  onChanged: (val) {
                                    setState(() {
                                      if (val) {
                                        param['group_rights'] = chargeConfig.keys.toList();
                                      } else {
                                        param['group_rights'] = [];
                                      }
                                    });
                                  },
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text('配置名称'),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text('配置类型'),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text('品牌'),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text('规格'),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: chargeConfig.keys.toList().map<Widget>(
                            (key) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey),
                                  ),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      child: Checkbox(
                                        value: param['group_rights'].contains(key),
                                        onChanged: (val) {
                                          setState(() {
                                            if (param['group_rights'].contains(key)) {
                                              param['group_rights'].remove(key);
                                            } else {
                                              param['group_rights'].add(key);
                                            }
                                          });
                                        },
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text('${chargeConfig[key]['config_name']}'),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text('${chargeConfig[key]['type_ch_name']}'),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text('${chargeConfig[key]['brand']}'),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text('${chargeConfig[key]['version']}'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ).toList(),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 50,
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        height: 34,
                        child: PrimaryButton(
                          onPressed: () {},
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
