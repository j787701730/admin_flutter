import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/city_select_plugin.dart';
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
  };
  Map taskType = {
    'all': '全部',
  };
  Map evaluateState = {
    "all": "全部",
    "1": "待评价",
    "2": "发布人已评",
    "3": "接单人已评",
    "4": "双方已评",
  };
  Map taskArea = {"province": "", "city": "", 'region': ''};
  List columns = [
    {'title': '编号名称', 'key': 'task_id'},
    {'title': '任务类型', 'key': 'type_ch_name'},
    {'title': '发布人', 'key': 'shop_name'},
    {'title': '创建时间', 'key': 'create_date'},
    {'title': '任务状态', 'key': 'state_ch_name'},
    {'title': '截止时间', 'key': 'end_date'},
    {'title': '操作', 'key': 'option'},
  ];

  String markupValue = '';
  Map markupValueList = {'markup_valueL': "", 'markup_valueU': ""};

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
      getParamData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getParamData() {
    ajax('Adminrelas-Api-getTaskType', {}, true, (data) {
      if (mounted) {
        Map stateTemp = {};
        Map typeTemp = {};
        for (var k in data['taskState'].keys.toList()) {
          stateTemp[k] = data['taskState'][k]['state_ch_name'];
        }
        for (var k in data['type'].keys.toList()) {
          typeTemp[k] = data['type'][k]['type_ch_name'];
        }
        setState(() {
          state.addAll(stateTemp);
          taskType.addAll(typeTemp);
          getData();
        });
      }
    }, () {}, _context);
  }

  getData({isRefresh: false}) {
    setState(() {
      loading = true;
    });
    if (taskArea['province'] == '' || taskArea['province'] == '0') {
      param.remove('province');
    } else {
      param['province'] = taskArea['province'];
    }
    if (taskArea['city'] == '' || taskArea['city'] == '0') {
      param.remove('city');
    } else {
      param['city'] = taskArea['city'];
    }
    if (param['markup_type'] == '2') {
      param['markup_value'] = [markupValueList];
    } else if (param['markup_type'] == '1') {
      param['markup_value'] = markupValue;
    } else {
      param.remove('markup_value');
    }

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
              firstChild: Placeholder(
                fallbackHeight: 0.1,
                color: Colors.transparent,
              ),
              secondChild: Column(children: <Widget>[
                Input(
                  label: '任务标题',
                  labelWidth: 100,
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('task_name');
                    } else {
                      param['task_name'] = val;
                    }
                  },
                ),
                Input(
                  label: '任务编号',
                  labelWidth: 100,
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('task_id');
                    } else {
                      param['task_id'] = val;
                    }
                  },
                ),
                Input(
                  label: '订单单号',
                  labelWidth: 100,
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('order_no');
                    } else {
                      param['order_no'] = val;
                    }
                  },
                ),
                Select(
                  selectOptions: state,
                  labelWidth: 100,
                  selectedValue: param['state'] ?? 'all',
                  label: '任务状态',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('state');
                    } else {
                      param['state'] = val;
                    }
                  },
                ),
                Select(
                  selectOptions: taskType,
                  labelWidth: 100,
                  selectedValue: param['task_type'] ?? 'all',
                  label: '任务类型',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('task_type');
                    } else {
                      param['task_type'] = val;
                    }
                  },
                ),
                Select(
                  selectOptions: evaluateState,
                  labelWidth: 100,
                  selectedValue: param['evaluate_state'] ?? 'all',
                  label: '评价状态',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('evaluate_state');
                    } else {
                      param['evaluate_state'] = val;
                    }
                  },
                ),
                DateSelectPlugin(
                  onChanged: getDateTime,
                  label: '创建时间',
                  labelWidth: 100,
                ),
                DateSelectPlugin(
                  onChanged: getDateTime2,
                  label: '需求时间',
                  labelWidth: 100,
                ),
                CitySelectPlugin(
                  getArea: (val) {
                    if (val != null) {
                      taskArea = val;
                    }
                  },
                  label: '地区',
                ),
                Container(
                  height: 34,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 100,
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 10),
                        child: Text('查看置顶'),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Checkbox(
                            value: param['top'] == '1',
                            onChanged: (val) {
                              setState(() {
                                if (val) {
                                  param['top'] = '1';
                                } else {
                                  param.remove('top');
                                }
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 34,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 100,
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 10),
                        child: Text('不加价'),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Radio(
                            groupValue: param['markup_type'],
                            value: '0',
                            onChanged: (val) {
                              setState(() {
                                param['markup_type'] = '0';
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 34,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 100,
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 10),
                        child: Text('按比例加价'),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: <Widget>[
                              Radio(
                                groupValue: param['markup_type'],
                                value: '1',
                                onChanged: (val) {
                                  setState(() {
                                    param['markup_type'] = '1';
                                  });
                                  FocusScope.of(context).requestFocus(FocusNode());
                                },
                              ),
                              Container(
                                width: 120,
                                height: 34,
                                child: TextField(
                                  controller: TextEditingController.fromValue(
                                    TextEditingValue(
                                      text: '${markupValue ?? ''}',
                                      selection: TextSelection.fromPosition(
                                        TextPosition(
                                          affinity: TextAffinity.downstream,
                                          offset: '${markupValue ?? ''}'.length,
                                        ),
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(fontSize: CFFontSize.content),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.only(
                                      top: 0,
                                      bottom: 0,
                                      left: 10,
                                      right: 10,
                                    ),
                                  ),
                                  maxLines: 1,
                                  onChanged: (String val) {
                                    setState(() {
                                      markupValue = val;
                                    });
                                  },
                                ),
                              ),
                              Text(' 倍'),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 34,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 100,
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 10),
                        child: Text('固定额度加价'),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: <Widget>[
                              Radio(
                                groupValue: param['markup_type'],
                                value: '2',
                                onChanged: (val) {
                                  setState(() {
                                    param['markup_type'] = '2';
                                  });
                                  FocusScope.of(context).requestFocus(FocusNode());
                                },
                              ),
                              Expanded(
                                child: Container(
                                  height: 34,
                                  child: TextField(
                                    controller: TextEditingController.fromValue(
                                      TextEditingValue(
                                        text: '${markupValueList['markup_valueL'] ?? ''}',
                                        selection: TextSelection.fromPosition(
                                          TextPosition(
                                            affinity: TextAffinity.downstream,
                                            offset: '${markupValueList['markup_valueL'] ?? ''}'.length,
                                          ),
                                        ),
                                      ),
                                    ),
                                    style: TextStyle(fontSize: CFFontSize.content),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.only(
                                        top: 0,
                                        bottom: 0,
                                        left: 10,
                                        right: 10,
                                      ),
                                    ),
                                    maxLines: 1,
                                    onChanged: (String val) {
                                      setState(() {
                                        markupValueList['markup_valueL'] = val;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Text(' - '),
                              Expanded(
                                child: Container(
                                  height: 34,
                                  child: TextField(
                                    controller: TextEditingController.fromValue(
                                      TextEditingValue(
                                        text: '${markupValueList['markup_valueU'] ?? ''}',
                                        selection: TextSelection.fromPosition(
                                          TextPosition(
                                            affinity: TextAffinity.downstream,
                                            offset: '${markupValueList['markup_valueU'] ?? ''}'.length,
                                          ),
                                        ),
                                      ),
                                    ),
                                    style: TextStyle(fontSize: CFFontSize.content),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.only(
                                        top: 0,
                                        bottom: 0,
                                        left: 10,
                                        right: 10,
                                      ),
                                    ),
                                    maxLines: 1,
                                    onChanged: (String val) {
                                      setState(() {
                                        markupValueList['markup_valueU'] = val;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Text(' 元'),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Select(
                  selectOptions: selects,
                  selectedValue: defaultVal,
                  label: '排序',
                  onChanged: orderBy,
                  labelWidth: 100,
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
                      FocusScope.of(context).requestFocus(FocusNode());
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
                                            PrimaryButton(
                                              onPressed: () {
                                                topDialog(item);
                                              },
                                              child: Text('${item['top'].toString() == '1' ? '取消置顶' : '置顶'}'),
                                            ),
                                            PrimaryButton(
                                              onPressed: () {
                                                turnTo(item);
                                              },
                                              child: Text('日志'),
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
