import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/cf-provider.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class StaffGroup extends StatefulWidget {
  @override
  _StaffGroupState createState() => _StaffGroupState();
}

class _StaffGroupState extends State<StaffGroup> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map selectGroup = {
    'grpID': '1',
    'name': '超级管理员',
  };
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
    {'id': '1', 'name': '超级管理员'},
    {'id': '2', 'name': '研发组'},
    {'id': '3', 'name': '测试组'},
    {'id': '4', 'name': '工程组'},
    {'id': '5', 'name': '业务组'},
    {'id': '6', 'name': '客服组'},
    {'id': '7', 'name': '财务组'},
  ];

  void _onRefresh() async {
    setState(() {
      getData(isRefresh: true);
    });
  }

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

  topDialog(item) {
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
        title: Text('${selectGroup['name']} 岗位架构'),
        leading: IconButton(
          icon: const BackButtonIcon(),
          color: context.watch<CFProvider>().themeMode == ThemeMode.dark ? CFColors.dark : Colors.white,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
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
//              color: department[index]['id'] == selectGroup['id'] ? CFColors.white : Color(0xfff5f5f5),
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
                            selectGroup = jsonDecode(jsonEncode(department[index]));
                            Navigator.of(context).pop();
                            getData();
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Text('${department[index]['name']}'),
                      ),
                    ),
                  ),
                  Container(
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
                  Container(
                    child: Material(
                      child: IconButton(
                        onPressed: () {
                          topDialog(department[index]);
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
                        _scaffoldKey.currentState.openDrawer();
                      },
                      child: Text('岗位'),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: PrimaryButton(
                      onPressed: () {
                        modifyName({});
                      },
                      child: Text('新增岗位'),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: PrimaryButton(
                      onPressed: () {
//                        _scaffoldKey.currentState.openDrawer();
                      },
                      child: Text('修改权限'),
                    ),
                  ),
                ],
              ),
              margin: EdgeInsets.only(
                bottom: 10,
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
//                                                                  color:
//                                                                      '${item3['ck']}' == '1' && '${item3['kp']}' == '1'
//                                                                          ? Color(0xffFFFCED)
//                                                                          : Colors.white,
                                                              ),
                                                              child: InkWell(
                                                                onTap: () {
                                                                  setState(() {
                                                                    item3['ck'] = '${item3['ck']}' == '1' ? '0' : '1';
                                                                  });
                                                                },
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: <Widget>[
                                                                    Checkbox(
                                                                      materialTapTargetSize:
                                                                          MaterialTapTargetSize.shrinkWrap,
                                                                      value: '${item3['ck']}' == '1',
                                                                      onChanged: (bool newValue) {
                                                                        setState(() {
                                                                          item3['ck'] = newValue ? '1' : '0';
                                                                        });
                                                                      },
                                                                    ),
                                                                    Text(' ${item3['fnm']}'),
                                                                  ],
                                                                ),
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
      ),
      floatingActionButton: CFFloatingActionButton(
        onPressed: toTop,
        child: Icon(Icons.keyboard_arrow_up),
      ),
    );
  }
}
