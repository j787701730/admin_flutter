import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/cf-provider.dart';
import 'package:admin_flutter/plugin/input-single.dart';
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
  Map selectGroup = {};
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

  List groups = [];
  bool canEdit = false;

  void _onRefresh() {
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
      getGroups();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getGroups({isRefresh: false}) {
    setState(() {
      loading = true;
    });
    ajax('Adminrelas-Api-getGroups', {}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          groups = res['data'] ?? [];
          selectGroup = groups[0];
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

  getData({isRefresh: false}) {
    setState(() {
      loading = true;
      canEdit = false;
    });
    ajax('Adminrelas-Staff-GroupRightsShow', {'grpID': selectGroup['group_id']}, true, (res) {
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

  delDialog(item) {
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
                '确认删除 ${item['group_name']}?',
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
                ajax('Adminrelas-Staff-deleteGroups', {'grpID': item['group_id']}, true, (data) {
                  setState(() {
                    groups.remove(item);
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

  modifyName(item) {
    Map itemTemp = jsonDecode(jsonEncode(item));
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            item['group_name'] == null ? '新增岗位' : '${item['group_name']} 修改',
          ),
          content: SingleChildScrollView(
            child: Container(
              child: InputSingle(
                onChanged: (val) => itemTemp['group_name'] = val,
                value: itemTemp['group_name'],
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
                ajax('Adminrelas-Staff-editGroupsName', {'grpID': item['group_id'], 'grpName': itemTemp['group_name']},
                    true, (data) {}, () {
                  setState(() {
                    item['group_name'] = itemTemp['group_name'];
                    Navigator.of(context).pop();
                  });
                }, _context);
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
        title: Text('${selectGroup['group_name']} 岗位架构'),
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
                            selectGroup = jsonDecode(jsonEncode(groups[index]));
                            Navigator.of(context).pop();
                            getData();
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Text('${groups[index]['group_name']}'),
                      ),
                    ),
                  ),
                  Container(
                    child: Material(
                      child: IconButton(
                        onPressed: () {
                          modifyName(groups[index]);
                        },
                        icon: Icon(Icons.edit),
                        tooltip: '修改',
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Material(
                      child: IconButton(
                        onPressed: () {
                          delDialog(groups[index]);
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
          itemCount: groups.length,
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
                  PrimaryButton(
                    onPressed: () {
                      _scaffoldKey.currentState.openDrawer();
                    },
                    child: Text('岗位'),
                  ),
                  PrimaryButton(
                    onPressed: () {
                      modifyName({});
                    },
                    child: Text('新增岗位'),
                  ),
                  canEdit
                      ? PrimaryButton(
                          onPressed: () {
//                        _scaffoldKey.currentState.openDrawer();
                            List grpRights = [];
                            String grpID = selectGroup['group_id'];
                            for (var o in ajaxData) {
                              for (var p in o['c']) {
                                for (var q in p['c']) {
                                  if ('${q['ck']}' == '1') {
                                    grpRights.add(q['fid']);
                                  }
                                }
                              }
                            }
                            print(grpRights);
                            ajax(
                                'Adminrelas-Staff-editGrpRights',
                                {'grpID': grpID, 'grpRights': grpRights.isEmpty ? -1 : grpRights.join(',')},
                                true, (data) {
                              setState(() {
                                canEdit = false;
                              });
                            }, () {}, _context);
                          },
                          child: Text('保存权限'),
                        )
                      : PrimaryButton(
                          onPressed: () {
                            setState(() {
                              canEdit = !canEdit;
                            });
//                        _scaffoldKey.currentState.openDrawer();
                          },
                          child: Text('修改权限'),
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
                                    InkWell(
                                      onTap: () {
                                        if (canEdit) {
                                          if (item['clickCount'] == null || item['clickCount'] == 0) {
                                            for (var o in item['c']) {
                                              for (var p in o['c']) {
                                                setState(() {
                                                  p['ck'] = 1;
                                                  item['clickCount'] = 1;
                                                });
                                              }
                                            }
                                          } else {
                                            for (var o in item['c']) {
                                              for (var p in o['c']) {
                                                setState(() {
                                                  p['ck'] = 0;
                                                  item['clickCount'] = 0;
                                                });
                                              }
                                            }
                                          }
                                        }
                                      },
                                      child: Container(
                                        width: 100,
                                        padding: EdgeInsets.symmetric(horizontal: 6),
                                        child: Text(
                                          '${item['mnm']}',
                                          style: TextStyle(
                                            color: canEdit ? CFColors.primary : CFColors.text,
                                          ),
                                        ),
                                      ),
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
                                                  InkWell(
                                                    onTap: () {
                                                      if (canEdit) {
                                                        if (item2['clickCount'] == null || item2['clickCount'] == 0) {
                                                          for (var o in item2['c']) {
                                                            setState(() {
                                                              o['ck'] = 1;
                                                              item2['clickCount'] = 1;
                                                            });
                                                          }
                                                        } else {
                                                          for (var o in item2['c']) {
                                                            setState(() {
                                                              o['ck'] = 0;
                                                              item2['clickCount'] = 0;
                                                            });
                                                          }
                                                        }
                                                      }
                                                    },
                                                    child: Container(
                                                      width: 110,
                                                      child: Text(
                                                        '${item2['mnm']}',
                                                        style: TextStyle(
                                                          color: canEdit ? CFColors.primary : CFColors.text,
                                                        ),
                                                      ),
                                                    ),
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
                                                                  if (canEdit) {
                                                                    bool flag = false;
                                                                    if (item2['c'].indexOf(item3) == 0) {
                                                                      if (item2['c'].length == 1) {
                                                                        flag = true;
                                                                      } else {
                                                                        flag = true;
                                                                        for (var i = 1; i < item2['c'].length; i++) {
                                                                          if ('${item2['c'][i]['ck']}' == '1') {
                                                                            flag = false;
                                                                            break;
                                                                          }
                                                                        }
                                                                      }
                                                                    } else {
                                                                      flag = true;
                                                                      setState(() {
                                                                        item2['c'][0]['ck'] = '1';
                                                                      });
                                                                    }
                                                                    if (flag) {
                                                                      setState(() {
                                                                        item3['ck'] =
                                                                            '${item3['ck']}' == '1' ? '0' : '1';
                                                                      });
                                                                    }
                                                                  }
                                                                },
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: <Widget>[
                                                                    Checkbox(
                                                                      materialTapTargetSize:
                                                                          MaterialTapTargetSize.shrinkWrap,
                                                                      value: '${item3['ck']}' == '1',
                                                                      onChanged: (bool newValue) {
//                                                                        setState(() {
//                                                                          item3['ck'] = newValue ? '1' : '0';
//                                                                        });
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
