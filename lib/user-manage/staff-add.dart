import 'dart:async';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StaffAdd extends StatefulWidget {
  final props;

  StaffAdd({this.props});

  @override
  _StaffAddState createState() => _StaffAddState();
}

class _StaffAddState extends State<StaffAdd> {
  BuildContext _context;
  ScrollController _controller;
  Map selectGroup = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  bool isExpandedFlag = true;
  Map param = {'sex': '1', 'depid': '0', 'grpID': '1', 'wx_check': '1'};
  Map staffInfo = {};
  double width;
  List department = [
    {'department_id': '0', 'department_name': '我的团队'},
  ];
  List group = [];

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _context = context;

    Timer(Duration(milliseconds: 200), () {
      getGroupsDepartment();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getGroupsDepartment({isRefresh: false}) async {
    setState(() {
      loading = true;
    });
    ajax('Adminrelas-Api-groupsDepartMent', {}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          department.addAll(res['department'] ?? []);
          group = res['groups'] ?? [];
          selectGroup = group[0];
          if (widget.props != null) {
            getStaffInfo();
          }
          getData();
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

  getStaffInfo({isRefresh: false}) async {
    setState(() {
      loading = true;
    });
    ajax('Adminrelas-Api-editStaffData', {'staffID': widget.props['staff_id']}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          staffInfo = res['userInfo'] ?? {};
          param['uname'] = staffInfo['login_name'];
          param['fname'] = staffInfo['full_name'];
          param['wx_check'] = staffInfo['wx_check'];
          param['depid'] = staffInfo['department_id'];
          param['grpID'] = staffInfo['group_id'];
          param['sex'] = staffInfo['user_sex'];
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

  getData({isRefresh: false}) async {
    setState(() {
      loading = true;
    });
    ajax('Adminrelas-Staff-GroupRightsShow', {'grpID': selectGroup['group_id']}, true, (res) {
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

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.props == null ? '添加员工' : widget.props['login_name'] + ' 员工修改'),
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
                PrimaryButton(
                  onPressed: () {
                    print(param);
                  },
                  child: Text('保存'),
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
            value: param['uname'],
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
            value: param['fname'],
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
                              value: '2',
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
                                  value: '${item['department_id']}',
                                  groupValue: param['depid'],
                                  onChanged: (value) {
                                    setState(() {
                                      param['depid'] = value;
                                    });
                                  },
                                ),
                                Text('${item['department_name']}')
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
                                  value: '${item['group_id']}',
                                  groupValue: param['grpID'],
                                  onChanged: (value) {
                                    setState(() {
                                      param['grpID'] = value;
                                      getData();
                                    });
                                  },
                                ),
                                Text('${item['group_name']}')
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
