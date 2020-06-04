import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TaskEvaluate extends StatefulWidget {
  @override
  _TaskEvaluateState createState() => _TaskEvaluateState();
}

class _TaskEvaluateState extends State<TaskEvaluate> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {};
  List ajaxData = [];
  bool loading = true;
  Map userType = {
    '1': '发布者',
    '2': '接收者',
  };
  Map taskType = {
    '104': '设计任务',
  };

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
    param['user_type'] = userType.keys.toList()[0];
    param['task_type'] = taskType.keys.toList()[0];
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
    ajax('Adminrelas-TaskManage-evalConList', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'] ?? [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('评价配置'),
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
              selectOptions: userType,
              selectedValue: param['user_type'],
              label: '用户类型',
              onChanged: (val) {
                setState(() {
                  param['user_type'] = val;
                });
              },
            ),
            Select(
              selectOptions: taskType,
              selectedValue: param['task_type'],
              label: '任务类型',
              onChanged: (val) {
                setState(() {
                  param['task_type'] = val;
                });
              },
            ),
            Container(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  PrimaryButton(
                    onPressed: () {
                      param['curr_page'] = 1;
                      getData();
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text('搜索'),
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: 10),
            ),
            loading
                ? Container(
                    alignment: Alignment.center,
                    child: CupertinoActivityIndicator(),
                  )
                : ajaxData.isEmpty
                    ? Container(
                        alignment: Alignment.center,
                        child: Text('无数据'),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: ajaxData.map<Widget>((item) {
                          int index = ajaxData.indexOf(item);
                          return Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(
                              bottom: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xffdddddd),
                              ),
                            ),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Text('从 '),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: 34,
                                          width: 60,
                                          child: TextField(
                                            style: TextStyle(fontSize: CFFontSize.content),
                                            controller: TextEditingController.fromValue(
                                              TextEditingValue(
                                                text: '${ajaxData[index]['left_value'] ?? ''}',
                                                selection: TextSelection.fromPosition(
                                                  TextPosition(
                                                    affinity: TextAffinity.downstream,
                                                    offset: '${ajaxData[index]['left_value'] ?? ''}'.length,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding: EdgeInsets.only(
                                                top: 0,
                                                bottom: 0,
                                                left: 10,
                                                right: 10,
                                              ),
                                            ),
                                            onChanged: (String val) {
                                              setState(() {
                                                ajaxData[index]['left_value'] = val;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 20,
                                        alignment: Alignment.center,
                                        child: Text('-'),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: 34,
                                          width: 60,
                                          child: TextField(
                                            style: TextStyle(fontSize: CFFontSize.content),
                                            controller: TextEditingController.fromValue(
                                              TextEditingValue(
                                                text: '${ajaxData[index]['right_value'] ?? ''}',
                                                selection: TextSelection.fromPosition(
                                                  TextPosition(
                                                    affinity: TextAffinity.downstream,
                                                    offset: '${ajaxData[index]['right_value'] ?? ''}'.length,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding: EdgeInsets.only(
                                                top: 0,
                                                bottom: 0,
                                                left: 10,
                                                right: 10,
                                              ),
                                            ),
                                            onChanged: (String val) {
                                              setState(() {
                                                ajaxData[index]['right_value'] = val;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      Text(' 分(含)'),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        '评价标题：',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: 34,
                                          child: TextField(
                                            style: TextStyle(fontSize: CFFontSize.content),
                                            controller: TextEditingController.fromValue(
                                              TextEditingValue(
                                                text: '${ajaxData[index]['topic'] ?? ''}',
                                                selection: TextSelection.fromPosition(
                                                  TextPosition(
                                                    affinity: TextAffinity.downstream,
                                                    offset: '${ajaxData[index]['topic'] ?? ''}'.length,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding: EdgeInsets.only(
                                                top: 0,
                                                bottom: 0,
                                                left: 10,
                                                right: 10,
                                              ),
                                            ),
                                            onChanged: (String val) {
                                              setState(() {
                                                ajaxData[index]['topic'] = val;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                    bottom: 10,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        '评价描述：',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          child: TextField(
                                            maxLines: 3,
                                            style: TextStyle(fontSize: CFFontSize.content),
                                            controller: TextEditingController.fromValue(
                                              TextEditingValue(
                                                text: '${ajaxData[index]['detail'] ?? ''}',
                                                selection: TextSelection.fromPosition(
                                                  TextPosition(
                                                    affinity: TextAffinity.downstream,
                                                    offset: '${ajaxData[index]['detail'] ?? ''}'.length,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding: EdgeInsets.all(10),
                                            ),
                                            onChanged: (String val) {
                                              setState(() {
                                                ajaxData[index]['detail'] = val;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        width: 34,
                                        height: 34,
                                        child: IconButton(
                                          padding: EdgeInsets.all(0),
                                          icon: Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: CFColors.danger,
                                          ),
                                          onPressed: () {
                                            FocusScope.of(context).requestFocus(FocusNode());
                                            setState(() {
                                              ajaxData.removeAt(index);
                                              if (ajaxData.length == 0) {
                                                ajaxData.add({
                                                  'user_type': param['user_type'],
                                                  'task_type': param['task_type'],
                                                  'left_value': '',
                                                  'right_value': '',
                                                  'topic': '',
                                                  'detail': '',
                                                });
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: 34,
                                        height: 34,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.add,
                                            size: 20,
                                            color: CFColors.success,
                                          ),
                                          onPressed: () {
                                            FocusScope.of(context).requestFocus(FocusNode());
                                            setState(() {
                                              if (ajaxData.length == 5) {
                                                Fluttertoast.showToast(
                                                  msg: '最多只能配置5条规则',
                                                  gravity: ToastGravity.CENTER,
                                                );
                                              } else {
                                                setState(() {
                                                  ajaxData.insert(index + 1, {
                                                    'user_type': param['user_type'],
                                                    'task_type': param['task_type'],
                                                    'left_value': '',
                                                    'right_value': '',
                                                    'topic': '',
                                                    'detail': '',
                                                  });
                                                });
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
            loading
                ? Container()
                : Row(
                    children: <Widget>[
                      PrimaryButton(
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          if (ajaxData.length == 5) {
                            Fluttertoast.showToast(
                              msg: '最多只能配置5条规则',
                              gravity: ToastGravity.CENTER,
                            );
                          } else {
                            setState(() {
                              ajaxData.insert(ajaxData.length, {
                                'user_type': param['user_type'],
                                'task_type': param['task_type'],
                                'left_value': '',
                                'right_value': '',
                                'topic': '',
                                'detail': '',
                              });
                            });
                          }
                        },
                        child: Text('添加规则'),
                      ),
                    ],
                  ),
            Container(
              margin: EdgeInsets.only(
                bottom: 10,
                top: 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                      right: 6,
                    ),
                    child: Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: CFColors.danger,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '1、第一个最小值要等于1；最后一个最大值要等于100；',
                          style: TextStyle(
                            color: CFColors.danger,
                          ),
                        ),
                        Text(
                          '2、每行配置有空行或者空值，该行将无效；',
                          style: TextStyle(
                            color: CFColors.danger,
                          ),
                        ),
                        Text(
                          '3、分数区间之间的值必须是连续性。',
                          style: TextStyle(
                            color: CFColors.danger,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            loading
                ? Container()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 30,
                        child: PrimaryButton(
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          child: Text('保存'),
                        ),
                      )
                    ],
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
