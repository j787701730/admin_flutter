import 'dart:async';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StaffAdd extends StatefulWidget {
  @override
  _StaffAddState createState() => _StaffAddState();
}

class _StaffAddState extends State<StaffAdd> {
  BuildContext _context;
  ScrollController _controller;
  Map selectGroup = {
    'grpID': '1',
    'name': '超级管理员',
  };
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  bool isExpandedFlag = true;
  Map param = {'sex': '1', 'depid': '0', 'grpID': '1', 'wx_check': '1'};
  double width;
  List department = [
    {'id': '0', 'name': '我的团队'},
    {'id': '1', 'name': '11112'},
    {'id': '2', 'name': '新部门'},
    {'id': '3', 'name': '测试部'},
    {'id': '4', 'name': '工程部'},
    {'id': '5', 'name': '业务部'},
    {'id': '6', 'name': '客服部'},
    {'id': '7', 'name': '财务部'},
  ];
  List group = [
    {'id': '1', 'name': '超级管理员'},
    {'id': '2', 'name': '研发组'},
    {'id': '3', 'name': '测试组'},
    {'id': '4', 'name': '工程组'},
    {'id': '5', 'name': '业务组'},
    {'id': '6', 'name': '客服组'},
    {'id': '7', 'name': '财务组'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _context = context;
    Timer(Duration(milliseconds: 200), () {
      getData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getData({isRefresh: false}) async {
    setState(() {
      loading = true;
    });
    ajax('Adminrelas-Staff-GroupRightsShow', {'grpID': selectGroup['grpID']}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['rights'] ?? [];
        });
      }
    }, () {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }, _context);
  }

  toTop() {
    _controller.animateTo(
      0,
      duration: Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  topDialog(item) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '信息',
            style: TextStyle(fontSize: CFFontSize.topTitle),
          ),
          content: SingleChildScrollView(
            child: Container(
//                width: MediaQuery.of(context).size.width - 100,
              child: Text(
                '确认删除 ${item['name']}?',
                style: TextStyle(fontSize: CFFontSize.content),
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('提交'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  modifyName(item) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '信息',
            style: TextStyle(fontSize: CFFontSize.topTitle),
          ),
          content: SingleChildScrollView(
            child: Container(
              height: 34,
//                width: MediaQuery.of(context).size.width - 100,
              child: TextField(
                style: TextStyle(fontSize: CFFontSize.content),
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: '${item['name'] ?? ''}',
                    selection: TextSelection.fromPosition(
                      TextPosition(
                        affinity: TextAffinity.downstream,
                        offset: '${item['name'] ?? ''}'.length,
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
                    item['name'] = val;
                  });
                },
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('提交'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('添加员工'),
        leading: IconButton(
          icon: const BackButtonIcon(),
          color: Colors.white,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: ListView(
        controller: _controller,
        padding: EdgeInsets.all(12),
        children: <Widget>[
          Container(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                SizedBox(
                  height: 30,
                  child: PrimaryButton(
                    onPressed: () {
                      modifyName({});
                    },
                    child: Text('保存'),
                  ),
                ),
              ],
            ),
            margin: EdgeInsets.only(
              bottom: 10,
            ),
          ),
          Input(
            label: '账号',
            labelWidth: 90,
            require: true,
            onChanged: (String val) {
              setState(() {
                param['uname'] = val;
              });
            },
          ),
          Input(
            label: '密码',
            labelWidth: 90,
            require: true,
            onChanged: (String val) {
              setState(() {
                param['upwd'] = val;
              });
            },
          ),
          Input(
            label: '确认密码',
            labelWidth: 90,
            require: true,
            onChanged: (String val) {
              setState(() {
                param['upwd2'] = val;
              });
            },
          ),
          Input(
            label: '姓名',
            labelWidth: 90,
            require: true,
            onChanged: (String val) {
              setState(() {
                param['fname'] = val;
              });
            },
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
                      Text('性别')
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Radio(
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              value: '1',
                              groupValue: param['sex'],
                              onChanged: (value) {
                                setState(() {
                                  param['sex'] = value;
                                });
                              },
                            ),
                            Text('男')
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Radio(
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              value: '0',
                              groupValue: param['sex'],
                              onChanged: (value) {
                                setState(() {
                                  param['sex'] = value;
                                });
                              },
                            ),
                            Text('女')
                          ],
                        ),
                      ],
                    ),
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
                      Text('登录验证')
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      runSpacing: 10,
                      spacing: 10,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Radio(
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              value: '1',
                              groupValue: param['wx_check'],
                              onChanged: (value) {
                                setState(() {
                                  param['wx_check'] = value;
                                });
                              },
                            ),
                            Text('微信验证')
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Radio(
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              value: '0',
                              groupValue: param['wx_check'],
                              onChanged: (value) {
                                setState(() {
                                  param['wx_check'] = value;
                                });
                              },
                            ),
                            Text('普通验证')
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 90,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10, top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('我的部门')
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                        runSpacing: 6,
                        spacing: 10,
                        children: department.map<Widget>(
                          (item) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Radio(
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  value: '${item['id']}',
                                  groupValue: param['depid'],
                                  onChanged: (value) {
                                    setState(() {
                                      param['depid'] = value;
                                    });
                                  },
                                ),
                                Text('${item['name']}')
                              ],
                            );
                          },
                        ).toList()),
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 90,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10, top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('岗位角色')
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                        runSpacing: 6,
                        spacing: 10,
                        children: group.map<Widget>(
                          (item) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Radio(
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  value: '${item['id']}',
                                  groupValue: selectGroup['grpID'],
                                  onChanged: (value) {
                                    setState(() {
                                      param['grpid'] = value;
                                      selectGroup['grpID'] = value;
                                      getData();
                                    });
                                  },
                                ),
                                Text('${item['name']}')
                              ],
                            );
                          },
                        ).toList()),
                  ),
                )
              ],
            ),
          ),
          loading
              ? Container(
                  alignment: Alignment.center,
                  child: CupertinoActivityIndicator(),
                )
              : Container(
                  child: ajaxData.isEmpty
                      ? Container(
                          alignment: Alignment.center,
                          child: Text(
                            '无数据',
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: ajaxData.map<Widget>((item) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xffdddddd),
                                ),
                              ),
                              margin: EdgeInsets.only(
                                bottom: 10,
                              ),
                              padding: EdgeInsets.only(
                                top: 5,
                                bottom: 5,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 100,
                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                    child: Text('${item['mnm']}'),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        children: item['c'].map<Widget>(
                                          (item2) {
                                            return Row(
                                              children: <Widget>[
                                                Container(
                                                  width: 110,
                                                  child: Text('${item2['mnm']}'),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        left: BorderSide(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                                    margin: EdgeInsets.symmetric(
                                                      vertical: 6,
//                                                        horizontal: 6,
                                                    ),
                                                    child: Wrap(
                                                      spacing: 10,
                                                      runSpacing: 10,
                                                      children: item2['c'].map<Widget>(
                                                        (item3) {
                                                          return Container(
                                                            padding: EdgeInsets.symmetric(
                                                              horizontal: 4,
                                                            ),
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    '${item3['ck']}' == '1' && '${item3['kp']}' == '1'
                                                                        ? Color(0xffFFFCED)
                                                                        : Colors.white),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: <Widget>[
                                                                Checkbox(
                                                                  materialTapTargetSize:
                                                                      MaterialTapTargetSize.shrinkWrap,
                                                                  value: '${item3['ck']}' == '1',
                                                                  onChanged: (bool newValue) {},
                                                                ),
                                                                Text(' ${item3['fnm']}'),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ).toList(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ).toList(),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
        ],
      ),
      floatingActionButton: CFFloatingActionButton(
        onPressed: toTop,
        child: Icon(Icons.keyboard_arrow_up),
      ),
    );
  }
}
