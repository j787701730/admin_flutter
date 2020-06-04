import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/task/task_list_log.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  bool isExpandedFlag = true;
  Map state = {
    "all": "全部",
    "1": "待接单",
    "2": "进行中",
    "3": "已完成待确认",
    "4": "问题处理中",
    "5": "任务结束",
    "6": "已取消",
  };
  Map taskType = {
    'all': '全部',
    '104': '设计任务',
  };
  Map evaluateState = {
    "all": "全部",
    "1": "待评价",
    "2": "发布人已评",
    "3": "接单人已评",
    "4": "双方已评",
  };

  List columns = [
    {'title': '编号名称', 'key': 'task_id'},
    {'title': '任务类型', 'key': 'type_ch_name'},
    {'title': '发布人', 'key': 'shop_name'},
    {'title': '创建时间', 'key': 'create_date'},
    {'title': '任务状态', 'key': 'state_ch_name'},
    {'title': '截止时间', 'key': 'end_date'},
    {'title': '操作', 'key': 'option'},
  ];

  void _onRefresh() async {
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
    ajax('Adminrelas-TaskManage-getTasks', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['tasks'] ?? [];
          count = int.tryParse('${res['count'] ?? 0}');
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
                '确认${item['top'].toString() == '1' ? '取消' : ''} ${item['task_name']} 置顶?',
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

  turnTo(item) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (context) => TaskListLog(item),
      ),
    );
  }

  getDateTime(val) {
    if (val['min'] == null) {
      param.remove('create_dateL');
    } else {
      param['create_dateL'] = val['min'].toString().substring(0, 10);
    }
    if (val['max'] == null) {
      param.remove('create_dateU');
    } else {
      param['create_dateU'] = val['max'].toString().substring(0, 10);
    }
  }

  getDateTime2(val) {
    if (val['min'] == null) {
      param.remove('start_date');
    } else {
      param['start_date'] = val['min'].toString().substring(0, 10);
    }
    if (val['max'] == null) {
      param.remove('end_date');
    } else {
      param['end_date'] = val['max'].toString().substring(0, 10);
    }
  }

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'task_id': '编号名称 升序',
    'task_id desc': '编号名称 降序',
    'task_type': '任务类型 升序',
    'task_type desc': '任务类型 降序',
    'shop_name': '发布人 升序',
    'shop_name desc': '发布人 降序',
    'create_date': '创建时间 升序',
    'create_date desc': '创建时间 降序',
    'state': '任务状态 升序',
    'state desc': '任务状态 降序',
    'start_date': '截止时间 升序',
    'start_date desc': '截止时间 降序',
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
    return Scaffold(
      appBar: AppBar(
        title: Text('任务列表'),
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
            AnimatedCrossFade(
              duration: const Duration(
                milliseconds: 300,
              ),
              firstChild: Container(),
              secondChild: Column(children: <Widget>[
                Input(
                  label: '任务标题',
                  onChanged: (String val) {
                    setState(() {
                      if (val == '') {
                        param.remove('task_name');
                      } else {
                        param['task_name'] = val;
                      }
                    });
                  },
                ),
                Input(
                  label: '任务编号',
                  onChanged: (String val) {
                    setState(() {
                      if (val == '') {
                        param.remove('task_id');
                      } else {
                        param['task_id'] = val;
                      }
                    });
                  },
                ),
                Select(
                  selectOptions: state,
                  selectedValue: param['state'] ?? 'all',
                  label: '任务状态',
                  onChanged: (val) {
                    setState(() {
                      if (val == 'all') {
                        param.remove('state');
                      } else {
                        param['state'] = val;
                      }
                    });
                  },
                ),
                Select(
                  selectOptions: state,
                  selectedValue: param['task_type'] ?? 'all',
                  label: '任务类型',
                  onChanged: (val) {
                    setState(() {
                      if (val == 'all') {
                        param.remove('task_type');
                      } else {
                        param['task_type'] = val;
                      }
                    });
                  },
                ),
                Select(
                  selectOptions: state,
                  selectedValue: param['evaluate_state'] ?? 'all',
                  label: '评价状态',
                  onChanged: (val) {
                    setState(() {
                      if (val == 'all') {
                        param.remove('evaluate_state');
                      } else {
                        param['evaluate_state'] = val;
                      }
                    });
                  },
                ),
                DateSelectPlugin(
                  onChanged: getDateTime,
                  label: '创建时间',
                ),
                DateSelectPlugin(
                  onChanged: getDateTime2,
                  label: '需求时间',
                ),
                Select(
                  selectOptions: selects,
                  selectedValue: defaultVal,
                  label: '排序',
                  onChanged: orderBy,
                ),
              ]),
              crossFadeState: isExpandedFlag ? CrossFadeState.showFirst : CrossFadeState.showSecond,
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
                  PrimaryButton(
                    color: CFColors.success,
                    onPressed: () {
                      setState(() {
                        isExpandedFlag = !isExpandedFlag;
                      });
                    },
                    child: Text('${isExpandedFlag ? '展开' : '收缩'}选项'),
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
                                  ),
                                ),
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: columns.map<Widget>((col) {
                                    Widget con = Text('${item[col['key']] ?? ''}');
                                    switch (col['key']) {
                                      case 'task_id':
                                        con = RichText(
                                          text: TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(text: '[${item['task_id']}]'),
                                              TextSpan(
                                                text: '${item['top'].toString() == '1' ? '[置顶]' : ''}',
                                                style: TextStyle(color: Colors.red),
                                              ),
                                              TextSpan(text: '${item['task_name']}')
                                            ],
                                            style: TextStyle(
                                              fontSize: CFFontSize.title,
                                            ),
                                          ),
                                        );
                                        break;
                                      case 'option':
                                        con = Wrap(
                                          runSpacing: 10,
                                          spacing: 10,
                                          children: <Widget>[
                                            Container(
                                              height: 30,
                                              child: PrimaryButton(
                                                onPressed: () {
                                                  topDialog(item);
                                                },
                                                child: Text('${item['top'].toString() == '1' ? '取消置顶' : '置顶'}'),
                                              ),
                                            ),
                                            Container(
                                              height: 30,
                                              child: PrimaryButton(
                                                onPressed: () {
                                                  turnTo(item);
                                                },
                                                child: Text('日志'),
                                              ),
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
