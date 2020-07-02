import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/cf-provider.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/user-manage/staff-add.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class StaffDepartment extends StatefulWidget {
  @override
  _StaffDepartmentState createState() => _StaffDepartmentState();
}

class _StaffDepartmentState extends State<StaffDepartment> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15, 'dep_id': '0'};
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  bool isExpandedFlag = true;
  Map state = {
    "all": "全部",
    "1": "使用中",
    "0": "已停止",
  };
  double width;

  Map selectDepartment = {};

  List columns = [
    {'title': '账号', 'key': 'login_name'},
    {'title': '部门', 'key': 'department_name'},
    {'title': '岗位', 'key': 'group_name'},
    {'title': '真实姓名', 'key': 'full_name'},
    {'title': '访问次数', 'key': 'visit_times'},
    {'title': '状态', 'key': 'state'},
    {'title': '登录方式', 'key': 'wx_check_ch'},
    {'title': '操作', 'key': 'option'},
  ];

  List department = [
    {'department_id': '0', 'department_name': '我的团队'},
  ];

  void _onRefresh() {
    setState(() {
      param['curr_page'] = 1;
      getData(isRefresh: true);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _context = context;
    Timer(Duration(milliseconds: 200), () {
      getDepartment();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getDepartment({isRefresh: false}) {
    setState(() {
      loading = true;
    });
    ajax('Adminrelas-Api-getDepartment', {}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          department.addAll(res['data'] ?? []);
          selectDepartment = department[0];
          getData();
        });
        if (isRefresh) {
          _refreshController.refreshCompleted();
        }
      }
    }, () {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }, _context);
  }

  getData({isRefresh: false}) {
    setState(() {
      loading = true;
    });
    ajax('Adminrelas-Staff-departmentUsers', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['staff'] ?? [];
          count = int.tryParse('${res['staffCnt'] ?? 0}');
          toTop();
        });
        if (isRefresh) {
          _refreshController.refreshCompleted();
        }
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

  getPage(page) {
    param['curr_page'] += page;
    getData();
  }

  delDialog(item) {
    print(item);
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '信息',
          ),
          content: SingleChildScrollView(
            child: Container(
//                width: MediaQuery.of(context).size.width - 100,
              child: Text(
                '确认删除 ${item['department_name']}?',
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
                ajax('Adminrelas-Staff-deleteDepartment', {'depID': item['department_id']}, true, (data) {
                  setState(() {
                    department.remove(item);
                  });
                  Navigator.of(context).pop();
                }, () {}, _context);
              },
            ),
          ],
        );
      },
    );
  }

  wxCheckDialog(item) {
    return showDialog<void>(
      context: _context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '信息',
          ),
          content: SingleChildScrollView(
            child: Container(
//                width: MediaQuery.of(context).size.width - 100,
              child: Text(
                '确认把 ${item['login_name']} 调成 ${item['wx_check'] == '0' ? '微信登录' : '普通登录'} ?',
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
                ajax(
                    'Adminrelas-Staff-editUserWxCheck',
                    {
                      'param': jsonEncode({
                        'staffID': item['staff_id'],
                        'wx_check': item['wx_check'] == '0' ? '1' : '0',
                      })
                    },
                    true, (data) {
                  Navigator.of(_context).pop();
                  getData();
                }, () {}, _context);
              },
            ),
          ],
        );
      },
    );
  }

  stateDialog(item) {
    return showDialog<void>(
      context: _context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '信息',
          ),
          content: SingleChildScrollView(
            child: Container(
//                width: MediaQuery.of(context).size.width - 100,
              child: Text(
                '确认把 ${item['login_name']} 调成 ${item['state'] == '0' ? '启用' : '停止'} ?',
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
                ajax(
                    'Adminrelas-Staff-editUserState',
                    {
                      'param': jsonEncode({
                        'staffID': item['staff_id'],
                        'state': item['state'] == '0' ? '1' : '0',
                      })
                    },
                    true, (data) {
                  Navigator.of(_context).pop();
                  getData();
                }, () {}, _context);
              },
            ),
          ],
        );
      },
    );
  }

  modifyName(item) {
    Map itemTemp = jsonDecode(jsonEncode(item));
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            item['department_name'] == null ? '新增部门' : '${itemTemp['department_name']} 修改',
          ),
          content: SingleChildScrollView(
            child: Container(
              height: 34,
//                width: MediaQuery.of(context).size.width - 100,
              child: TextField(
                style: TextStyle(fontSize: CFFontSize.content),
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: '${itemTemp['department_name'] ?? ''}',
                    selection: TextSelection.fromPosition(
                      TextPosition(
                        affinity: TextAffinity.downstream,
                        offset: '${itemTemp['department_name'] ?? ''}'.length,
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
                    itemTemp['department_name'] = val;
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
                ajax('Adminrelas-Staff-editDepartmentName',
                    {'depID': itemTemp['department_id'], 'depName': itemTemp['department_name']}, true, (data) {
                  setState(() {
                    item['department_name'] = itemTemp['department_name'];
                    Navigator.of(context).pop();
                  });
                }, () {}, _context);
              },
            ),
          ],
        );
      },
    );
  }

  String defaultVal = 'all';
  Map selects = {
    'all': '无',
    'login_name': '账号 升序',
    'login_name desc': '账号 降序',
    'department_name': '部门 升序',
    'department_name desc': '部门 降序',
    'group_name': '岗位 升序',
    'group_name desc': '岗位 降序',
    'full_name': '真实姓名 升序',
    'full_name desc': '真实姓名 降序',
    'visit_times': '	访问次数 升序',
    'visit_times desc': '	访问次数 降序',
  };

  orderBy(val) {
    if (val == 'all') {
      param.remove('order');
    } else {
      param['order'] = val;
    }
    param['curr_page'] = 1;
    defaultVal = val;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('${selectDepartment['department_name']} 组织架构'),
        leading: BackButton(),
      ),
      drawer: Container(
        width: width * 0.85,
        decoration: BoxDecoration(
          color: context.watch<CFProvider>().themeMode == ThemeMode.dark ? CFColors.dark : Colors.white,
        ),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
        child: ListView.separated(
          itemBuilder: (context, index) {
            return Container(
//              color: department[index]['id'] == param['dep_id'] ? CFColors.white : Color(0xfff5f5f5),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 12,
                        top: 10,
                        bottom: 10,
                        right: 12,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            param['dep_id'] = department[index]['department_id'];
                            param['curr_page'] = 1;
                            selectDepartment = jsonDecode(jsonEncode(department[index]));
                            Navigator.of(context).pop();
                            getData();
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Text('${department[index]['department_name']}'),
                      ),
                    ),
                  ),
                  department[index]['department_id'] == '0'
                      ? Container()
                      : Container(
                          child: Material(
                            child: IconButton(
                              onPressed: () {
                                modifyName(department[index]);
                              },
                              icon: Icon(Icons.edit),
                              tooltip: '修改',
                            ),
                          ),
                        ),
                  department[index]['department_id'] == '0'
                      ? Container()
                      : Container(
                          margin: EdgeInsets.only(left: 8, right: 8),
                          child: Material(
                            child: IconButton(
                              onPressed: () {
                                delDialog(department[index]);
                              },
                              icon: Icon(Icons.delete_forever),
                              tooltip: '删除',
                            ),
                          ),
                        ),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) {
            return Divider();
          },
          itemCount: department.length,
        ),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        // onLoading: _onLoading,
        child: ListView(
          controller: _controller,
          padding: EdgeInsets.all(10),
          children: <Widget>[
            Select(
              selectOptions: selects,
              selectedValue: defaultVal,
              label: '排序',
              onChanged: orderBy,
            ),
            Container(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  PrimaryButton(
                    onPressed: () {
                      _scaffoldKey.currentState.openDrawer();
                    },
                    child: Text('部门'),
                  ),
                  PrimaryButton(
                    onPressed: () {
                      modifyName({});
                    },
                    child: Text('新增部门'),
                  ),
                  PrimaryButton(
                    onPressed: () {
                      Navigator.push(
                        _context,
                        MaterialPageRoute(
                          builder: (context) => StaffAdd(),
                        ),
                      );
                    },
                    child: Text('添加员工'),
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: 10),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 6),
              alignment: Alignment.centerRight,
              child: NumberBar(
                count: count,
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
                            child: Text('无数据'),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: ajaxData.map<Widget>((item) {
                              return Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                  color: Color(0xffdddddd),
                                )),
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: columns.map<Widget>((col) {
                                    Widget con = Text('${item[col['key']] ?? ''}');
                                    switch (col['key']) {
                                      case 'state':
                                        con = Row(
                                          children: <Widget>[
                                            Container(
                                              height: 30,
                                              alignment: Alignment.centerLeft,
                                              margin: EdgeInsets.only(
                                                right: 15,
                                              ),
                                              child: Text('${state[item['state']]}'),
                                            ),
                                            PrimaryButton(
                                              onPressed: () {
                                                stateDialog(item);
                                              },
                                              child:
                                                  '${item['state']}' == '1' ? Icon(Icons.play_arrow) : Icon(Icons.stop),
                                            ),
                                          ],
                                        );
                                        break;
                                      case 'wx_check_ch':
                                        con = Row(
                                          children: <Widget>[
                                            Container(
                                              height: 30,
                                              alignment: Alignment.centerLeft,
                                              margin: EdgeInsets.only(
                                                right: 15,
                                              ),
                                              child: Text('${item['wx_check_ch']}'),
                                            ),
                                            PrimaryButton(
                                              onPressed: () {
                                                wxCheckDialog(item);
                                              },
                                              child: Icon(Icons.repeat),
                                            ),
                                          ],
                                        );
                                        break;
                                      case 'option':
                                        con = Wrap(
                                          runSpacing: 10,
                                          spacing: 10,
                                          children: <Widget>[
                                            PrimaryButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  _context,
                                                  MaterialPageRoute(
                                                    builder: (context) => StaffAdd(
                                                      props: item,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text('修改'),
                                            ),
                                          ],
                                        );
                                        break;
                                    }

                                    return Container(
                                      margin: EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            width: 80,
                                            alignment: Alignment.centerRight,
                                            child: Text('${col['title']}'),
                                            margin: EdgeInsets.only(right: 10),
                                          ),
                                          Expanded(flex: 1, child: con)
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
            Container(
              child: PagePlugin(
                current: param['curr_page'],
                total: count,
                pageSize: param['page_count'],
                function: getPage,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CFFloatingActionButton(
        onPressed: toTop,
        child: Icon(Icons.keyboard_arrow_up),
      ),
    );
  }
}
