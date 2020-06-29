import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/range_input.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/task/create_task_pricing.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TaskPricing extends StatefulWidget {
  @override
  _TaskPricingState createState() => _TaskPricingState();
}

class _TaskPricingState extends State<TaskPricing> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  Map taskType = {
    "all": '全部',
    "104": "设计任务",
  };
  bool isExpandedFlag = true;
  Map taskType2 = {
    "104": "设计任务",
  };
  List columns = [
    {'title': '名称', 'key': 'user_name'},
    {'title': '任务类型', 'key': 'task_type'},
    {'title': '价格', 'key': 'price'},
    {'title': '平台补贴', 'key': 'subsidy'},
    {'title': '创建时间', 'key': 'create_date'},
    {'title': '更新时间', 'key': 'update_date'},
    {'title': '描述', 'key': 'comments'},
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

    Map data = {
      'curr_page': param['curr_page'],
      'page_count': param['page_count'],
      'param': jsonEncode(param),
    };

    if (param['order'] != null) {
      data['order'] = param['order'];
    }
    ajax('Adminrelas-taskManage-taskPriceList', data, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'] ?? [];
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

  Map modifyItem = {};

  modifyDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${modifyItem['user_name']} 任务定价修改',
          ),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width - 100,
              child: Column(
                children: <Widget>[
                  Select(
                    selectOptions: taskType2,
                    selectedValue: modifyItem['task_type'],
                    label: '任务类型',
                    onChanged: (val) {
                      setState(() {
                        modifyItem['task_type'] = val;
                      });
                    },
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 80,
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '* ',
                                style: TextStyle(color: CFColors.danger, fontSize: CFFontSize.content),
                              ),
                              Text(
                                '价格',
                                style: TextStyle(fontSize: CFFontSize.content),
                              )
                            ],
                          ),
                          margin: EdgeInsets.only(right: 10),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 34,
                            child: TextField(
                              style: TextStyle(fontSize: CFFontSize.content),
                              controller: TextEditingController.fromValue(
                                TextEditingValue(
                                  text: '${modifyItem['price'] ?? ''}',
                                  selection: TextSelection.fromPosition(
                                    TextPosition(
                                      affinity: TextAffinity.downstream,
                                      offset: '${modifyItem['price'] ?? ''}'.length,
                                    ),
                                  ),
                                ),
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.only(
                                  top: 0,
                                  bottom: 0,
                                  left: 15,
                                  right: 15,
                                ),
                              ),
                              onChanged: (String val) {
                                setState(() {
                                  modifyItem['price'] = val;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 80,
                          alignment: Alignment.centerRight,
                          height: 34,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '* ',
                                style: TextStyle(color: CFColors.danger, fontSize: CFFontSize.content),
                              ),
                              Text(
                                '平台补贴',
                                style: TextStyle(fontSize: CFFontSize.content),
                              )
                            ],
                          ),
                          margin: EdgeInsets.only(right: 10),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 34,
                            child: TextField(
                              style: TextStyle(fontSize: CFFontSize.content),
                              controller: TextEditingController.fromValue(
                                TextEditingValue(
                                  text: '${modifyItem['subsidy'] ?? ''}',
                                  selection: TextSelection.fromPosition(
                                    TextPosition(
                                      affinity: TextAffinity.downstream,
                                      offset: '${modifyItem['subsidy'] ?? ''}'.length,
                                    ),
                                  ),
                                ),
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.only(
                                  top: 0,
                                  bottom: 0,
                                  left: 15,
                                  right: 15,
                                ),
                              ),
                              onChanged: (String val) {
                                setState(() {
                                  modifyItem['subsidy'] = val;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
              child: Text('确认'),
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () {
                ajax(
                  'Adminrelas-taskManage-alterTaskPrice',
                  {
                    'subsidy': modifyItem['subsidy'],
                    'pricing_id': modifyItem['pricing_id'],
                    'task_type': modifyItem['task_type'],
                    'price': modifyItem['price'],
                  },
                  true,
                  (data) {
                    Navigator.of(context).pop();
                    getData();
                  },
                  () {},
                  _context,
                );
              },
            ),
          ],
        );
      },
    );
  }

  getDateTime(val) {
    if (val['min'] == null) {
      param.remove('create_date_min');
    } else {
      param['create_date_min'] = val['min'].toString().substring(0, 10);
    }
    if (val['max'] == null) {
      param.remove('create_date_max');
    } else {
      param['create_date_max'] = val['max'].toString().substring(0, 10);
    }
  }

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'user_id': '名称 升序',
    'user_id desc': '名称 降序',
    'task_type': '任务类型 升序',
    'task_type desc': '任务类型 降序',
    'price': '价格 升序',
    'price desc': '价格 降序',
    'create_date': '创建时间 升序',
    'create_date desc': '创建时间 降序',
    'subsidy': '平台补贴 升序',
    'subsidy desc': '平台补贴 降序',
    'update_date': '更新时间 升序',
    'update_date desc': '更新时间 降序',
    'comments': '描述 升序',
    'comments desc': '描述 降序',
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
        title: Text('任务定价'),
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
                  label: '用户名',
                  onChanged: (String val) {
                    setState(() {
                      if (val == '') {
                        param.remove('user_name');
                      } else {
                        param['user_name'] = val;
                      }
                    });
                  },
                ),
                Select(
                  selectOptions: taskType,
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
                RangeInput(
                  label: '定价区间',
                  onChangeL: (val) {
                    if (val == '') {
                      param.remove('price_min');
                    } else {
                      param['price_min'] = val;
                    }
                  },
                  onChangeR: (val) {
                    if (val == '') {
                      param.remove('price_max');
                    } else {
                      param['price_max'] = val;
                    }
                  },
                ),
                RangeInput(
                  label: '补贴区间',
                  onChangeL: (val) {
                    if (val == '') {
                      param.remove('subsidy_min');
                    } else {
                      param['subsidy_min'] = val;
                    }
                  },
                  onChangeR: (val) {
                    if (val == '') {
                      param.remove('subsidy_max');
                    } else {
                      param['subsidy_max'] = val;
                    }
                  },
                ),
                DateSelectPlugin(
                  onChanged: getDateTime,
                  label: '创建时间',
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
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateTaskPricing(),
                        ),
                      ).then((value) {
                        if (value == true) {
                          getData();
                        }
                      });
                    },
                    child: Text('添加任务定价'),
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
              child: NumberBar(count: count),
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
                            children: ajaxData.map<Widget>(
                              (item) {
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
                                    children: columns.map<Widget>(
                                      (col) {
                                        Widget con = Text('${item[col['key']] ?? ''}');
                                        switch (col['key']) {
                                          case 'task_type':
                                            con = Text('${taskType[item['task_type']]}');
                                            break;
                                          case 'option':
                                            con = Wrap(
                                              runSpacing: 10,
                                              spacing: 10,
                                              children: <Widget>[
                                                PrimaryButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      modifyItem = jsonDecode(jsonEncode(item));
                                                      modifyDialog();
                                                    });
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
                                              Expanded(flex: 1, child: con),
                                            ],
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                );
                              },
                            ).toList(),
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
