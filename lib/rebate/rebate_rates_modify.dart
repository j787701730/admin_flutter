import 'dart:convert';

import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/plugin/user_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:flutter/material.dart';

class RebateRatesModify extends StatefulWidget {
  final props;

  RebateRatesModify(this.props);

  @override
  _RebateRatesModifyState createState() => _RebateRatesModifyState();
}

class _RebateRatesModifyState extends State<RebateRatesModify> {
  Map param = {'user': {}};

  Map rebateType = {
    "1": "商品推荐返利",
    "2": "店铺注册返利",
    "3": "月基本费返利",
    "4": "流量计费返利",
  };

  Map balanceType = {
    "1": "商城现金",
    "2": "商城红包",
    "3": "云端计费",
    "4": "云端计费-赠送",
    "6": "丰收贷",
  };

  @override
  void initState() {
    super.initState();
    if (widget.props != null) {
      param = {
        'user': {
          '${widget.props['user_id']}': {
            'user_id': '${widget.props['user_id']}',
            'login_name': '${widget.props['login_name']}'
          }
        },
        'direct_rate': '${widget.props['direct_rate']}',
        'indirect_rate': '${widget.props['indirect_rate']}',
        'return_rate': '${widget.props['return_rate']}',
        'rebate_type': '${widget.props['rebate_type']}',
        'balance_type': '${widget.props['balance_type']}',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props == null ? '添加返利比例' : '${widget.props['login_name']} 返利修改'}'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  child: Text('用户'),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 1)),
                      height: 34,
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
                    )),
                widget.props == null
                    ? SizedBox(
                        width: 110,
                        height: 30,
                        child: PrimaryButton(
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserPlugin(
                                        userCount: 1,
                                        selectUsersData: jsonDecode(jsonEncode(param['user'])),
                                      )),
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
                    : Container(
                        width: 0,
                      )
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.only(bottom: 10),
              height: 34,
              child: Row(children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  child: Text('直接返利'),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    style: TextStyle(fontSize: CFFontSize.content),
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: '${param['direct_rate'] ?? ''}',
                        selection: TextSelection.fromPosition(
                          TextPosition(
                            affinity: TextAffinity.downstream,
                            offset: '${param['direct_rate'] ?? ''}'.length,
                          ),
                        ),
                      ),
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 15),
                    ),
                    onChanged: (String val) {
                      setState(() {
                        param['direct_rate'] = val;
                      });
                    },
                  ),
                ),
                Text('%')
              ])),
          Container(
              margin: EdgeInsets.only(bottom: 10),
              height: 34,
              child: Row(children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  child: Text('间接返利'),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    style: TextStyle(fontSize: CFFontSize.content),
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: '${param['indirect_rate'] ?? ''}',
                        selection: TextSelection.fromPosition(
                          TextPosition(
                            affinity: TextAffinity.downstream,
                            offset: '${param['indirect_rate'] ?? ''}'.length,
                          ),
                        ),
                      ),
                    ),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 15)),
                    onChanged: (String val) {
                      setState(() {
                        param['indirect_rate'] = val;
                      });
                    },
                  ),
                ),
                Text('%')
              ])),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            height: 34,
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  child: Text('保金返还'),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    style: TextStyle(fontSize: CFFontSize.content),
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: '${param['return_rate'] ?? ''}',
                        selection: TextSelection.fromPosition(
                          TextPosition(
                            affinity: TextAffinity.downstream,
                            offset: '${param['return_rate'] ?? ''}'.length,
                          ),
                        ),
                      ),
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 15),
                    ),
                    onChanged: (String val) {
                      setState(() {
                        param['return_rate'] = val;
                      });
                    },
                  ),
                ),
                Text('%')
              ],
            ),
          ),
          Select(
            selectOptions: rebateType,
            selectedValue: param['rebate_type'] ?? '1',
            label: '返利类型',
            onChanged: (val) {
              setState(() {
                param['rebate_type'] = val;
              });
            },
          ),
          Select(
            selectOptions: balanceType,
            selectedValue: param['balance_type'] ?? '1',
            label: '账本类型',
            onChanged: (val) {
              setState(() {
                param['balance_type'] = val;
              });
            },
          ),
          Container(
            margin: EdgeInsets.only(bottom: 6),
            height: 34,
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  child: Text(''),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      PrimaryButton(
                        onPressed: () {},
                        child: Text('保存'),
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
