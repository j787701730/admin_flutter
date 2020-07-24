import 'dart:convert';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:flutter/material.dart';

class WxReplyModify extends StatefulWidget {
  final props;

  WxReplyModify(this.props);

  @override
  _WxReplyModifyState createState() => _WxReplyModifyState();
}

class _WxReplyModifyState extends State<WxReplyModify> {
  Map param = {};
  Map replyType = {
    '1': '自定义函数',
    '2': '文本消息',
    '3': '图文消息',
  };

  @override
  void initState() {
    super.initState();
    if (widget.props == null) {
      param = {'reply_type': '1'};
    } else {
      param = jsonDecode(jsonEncode(widget.props['item']));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.props == null ? '添加回复' : '修改回复'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Input(
            label: '关键字',
            onChanged: (val) => param['keyword'],
            value: param['keyword'],
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Text('平台绑定'),
                ),
                Expanded(
                  flex: 1,
                  child: Wrap(
                    spacing: 15,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          setState(() {
                            param['web_bind'] = '1';
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Radio(
                                value: '1',
                                groupValue: param['web_bind'] ?? '1',
                                onChanged: (val) {
                                  setState(() {
                                    param['web_bind'] = '1';
                                  });
                                }),
                            Text('绑定')
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            param['web_bind'] = '0';
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Radio(
                              value: '0',
                              groupValue: param['web_bind'] ?? '1',
                              onChanged: (val) {
                                setState(() {
                                  param['web_bind'] = '0';
                                });
                              },
                            ),
                            Text('未绑定')
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Select(
            selectOptions: replyType,
            selectedValue: param['reply_type'] ?? '1',
            label: '回复类型',
            onChanged: (String newValue) {
              setState(() {
                param['reply_type'] = newValue;
              });
            },
          ),
          Offstage(
            offstage: param['reply_type'] != '1',
            child: Input(
              label: '函数名称',
              onChanged: (val) => param['reply_content'] = jsonEncode({'function_name': val}),
              value:
                  '${param['reply_content'] == null ? '' : jsonDecode(param['reply_content'])['function_name'] ?? ''}',
            ),
          ),
          Offstage(
            offstage: param['reply_type'] != '2',
            child: Input(
              label: '消息内容',
              onChanged: (val) => param['reply_content'] = jsonEncode({'msg_content': val}),
              value: '${param['reply_content'] == null ? '' : jsonDecode(param['reply_content'])['msg_content'] ?? ''}',
              maxLines: 4,
            ),
          ),
          Offstage(
            offstage: param['reply_type'] != '3',
            child: Column(
              children: <Widget>[
                Input(
                  label: '消息标题',
                  onChanged: (val) {
                    Map temp;
                    if (param['reply_content'] == null) {
                      temp = {'msg_title': val};
                    } else {
                      temp = jsonDecode(param['reply_content']);
                      temp['msg_title'] = val;
                    }
                    setState(() {
                      param['reply_content'] = jsonEncode(temp);
                    });
                  },
                  value:
                      '${param['reply_content'] == null ? '' : jsonDecode(param['reply_content'])['msg_title'] ?? ''}',
                ),
                Input(
                  label: '消息内容',
                  onChanged: (val) {
                    Map temp;
                    if (param['reply_content'] == null) {
                      temp = {'msg_content': val};
                    } else {
                      temp = jsonDecode(param['reply_content']);
                      temp['msg_content'] = val;
                    }
                    setState(() {
                      param['reply_content'] = jsonEncode(temp);
                    });
                  },
                  value:
                      '${param['reply_content'] == null ? '' : jsonDecode(param['reply_content'])['msg_content'] ?? ''}',
                ),
                Input(
                  label: '图片路径',
                  onChanged: (val) {
                    Map temp;
                    if (param['reply_content'] == null) {
                      temp = {'pic_url': val};
                    } else {
                      temp = jsonDecode(param['reply_content']);
                      temp['pic_url'] = val;
                    }
                    setState(() {
                      param['reply_content'] = jsonEncode(temp);
                    });
                  },
                  value: '${param['reply_content'] == null ? '' : jsonDecode(param['reply_content'])['pic_url'] ?? ''}',
                ),
                Input(
                  label: '链接地址',
                  onChanged: (val) {
                    Map temp;
                    if (param['reply_content'] == null) {
                      temp = {'msg_url': val};
                    } else {
                      temp = jsonDecode(param['reply_content']);
                      temp['msg_url'] = val;
                    }
                    setState(() {
                      param['reply_content'] = jsonEncode(temp);
                    });
                  },
                  value: '${param['reply_content'] == null ? '' : jsonDecode(param['reply_content'])['msg_url'] ?? ''}',
                ),
              ],
            ),
          ),
          Input(
            label: '备注',
            onChanged: (val) => param['comments'],
            value: param['comments'],
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                PrimaryButton(
                  onPressed: () {
                    print(param);
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
