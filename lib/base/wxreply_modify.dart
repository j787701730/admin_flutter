import 'dart:convert';

import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
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
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Text('关键字'),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    style: TextStyle(fontSize: CFFontSize.content),
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: '${param['keyword'] ?? ''}',
                        selection: TextSelection.fromPosition(
                          TextPosition(
                            affinity: TextAffinity.downstream,
                            offset: '${param['keyword']}'.length,
                          ),
                        ),
                      ),
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                        top: 6,
                        bottom: 6,
                        left: 15,
                        right: 15,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        param['keyword'] = val;
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
            child: Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 80,
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(right: 10),
                    child: Text('函数名称'),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      style: TextStyle(fontSize: CFFontSize.content),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text:
                              '${param['reply_content'] == null ? '' : jsonDecode(param['reply_content'])['function_name'] ?? ''}',
                          selection: TextSelection.fromPosition(
                            TextPosition(
                              affinity: TextAffinity.downstream,
                              offset:
                                  '${param['reply_content'] == null ? '' : jsonDecode(param['reply_content'])['function_name'] ?? ''}'
                                      .length,
                            ),
                          ),
                        ),
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.only(
                          top: 6,
                          bottom: 6,
                          left: 15,
                          right: 15,
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          param['reply_content'] = jsonEncode({'function_name': val});
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          Offstage(
            offstage: param['reply_type'] != '2',
            child: Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 80,
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(right: 10),
                    child: Text('消息内容'),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      style: TextStyle(fontSize: CFFontSize.content),
                      maxLines: 4,
                      controller: TextEditingController.fromValue(TextEditingValue(
                        text:
                            '${param['reply_content'] == null ? '' : jsonDecode(param['reply_content'])['msg_content'] ?? ''}',
                        selection: TextSelection.fromPosition(
                          TextPosition(
                            affinity: TextAffinity.downstream,
                            offset:
                                '${param['reply_content'] == null ? '' : jsonDecode(param['reply_content'])['msg_content'] ?? ''}'
                                    .length,
                          ),
                        ),
                      )),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.only(
                          top: 6,
                          bottom: 6,
                          left: 15,
                          right: 15,
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          param['reply_content'] = jsonEncode({'msg_content': val});
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          Offstage(
            offstage: param['reply_type'] != '3',
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 80,
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 10),
                        child: Text('消息标题'),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          style: TextStyle(fontSize: CFFontSize.content),
                          maxLines: 4,
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text:
                                  '${param['reply_content'] == null ? '' : jsonDecode(param['reply_content'])['msg_title'] ?? ''}',
                              selection: TextSelection.fromPosition(
                                TextPosition(
                                  affinity: TextAffinity.downstream,
                                  offset:
                                      '${param['reply_content'] == null ? '' : jsonDecode(param['reply_content'])['msg_title'] ?? ''}'
                                          .length,
                                ),
                              ),
                            ),
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.only(
                              top: 6,
                              bottom: 6,
                              left: 15,
                              right: 15,
                            ),
                          ),
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
                        width: 80,
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 10),
                        child: Text('消息内容'),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          style: TextStyle(fontSize: CFFontSize.content),
                          maxLines: 4,
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text:
                                  '${param['reply_content'] == null ? '' : jsonDecode(param['reply_content'])['msg_content'] ?? ''}',
                              selection: TextSelection.fromPosition(
                                TextPosition(
                                  affinity: TextAffinity.downstream,
                                  offset:
                                      '${param['reply_content'] == null ? '' : jsonDecode(param['reply_content'])['msg_content'] ?? ''}'
                                          .length,
                                ),
                              ),
                            ),
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.only(
                              top: 6,
                              bottom: 6,
                              left: 15,
                              right: 15,
                            ),
                          ),
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
                        width: 80,
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 10),
                        child: Text('图片路径'),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          style: TextStyle(fontSize: CFFontSize.content),
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text:
                                  '${param['reply_content'] == null ? '' : jsonDecode(param['reply_content'])['pic_url'] ?? ''}',
                              selection: TextSelection.fromPosition(
                                TextPosition(
                                  affinity: TextAffinity.downstream,
                                  offset:
                                      '${param['reply_content'] == null ? '' : jsonDecode(param['reply_content'])['pic_url'] ?? ''}'
                                          .length,
                                ),
                              ),
                            ),
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.only(
                              top: 6,
                              bottom: 6,
                              left: 15,
                              right: 15,
                            ),
                          ),
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
                        ),
                      ),
                      Container(
                        width: 60,
                        child: PrimaryButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () {},
                          child: Text('图片'),
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
                        width: 80,
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 10),
                        child: Text('链接地址'),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          style: TextStyle(fontSize: CFFontSize.content),
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text:
                                  '${param['reply_content'] == null ? '' : jsonDecode(param['reply_content'])['msg_url'] ?? ''}',
                              selection: TextSelection.fromPosition(
                                TextPosition(
                                  affinity: TextAffinity.downstream,
                                  offset:
                                      '${param['reply_content'] == null ? '' : jsonDecode(param['reply_content'])['msg_url'] ?? ''}'
                                          .length,
                                ),
                              ),
                            ),
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.only(
                              top: 6,
                              bottom: 6,
                              left: 15,
                              right: 15,
                            ),
                          ),
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
                        ),
                      )
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
                  width: 80,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Text('备注'),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    style: TextStyle(fontSize: CFFontSize.content),
                    maxLines: 4,
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: '${param['comments'] ?? ''}',
                        selection: TextSelection.fromPosition(
                          TextPosition(
                            affinity: TextAffinity.downstream,
                            offset: '${param['comments']}'.length,
                          ),
                        ),
                      ),
                    ),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.only(
                          top: 6,
                          bottom: 6,
                          left: 15,
                          right: 15,
                        )),
                    onChanged: (val) {
                      setState(() {
                        param['comments'] = val;
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
