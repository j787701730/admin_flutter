import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/log/components/log_card.dart';
import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AnalysisLogs extends StatefulWidget {
  @override
  _AnalysisLogsState createState() => _AnalysisLogsState();
}

class _AnalysisLogsState extends State<AnalysisLogs> {
  Map param = {'curr_page': 1, 'page_count': 20};
  Map param2 = {'curr_page': 1, 'page_count': 20};
  List logs = [];
  List logs2 = [];
  int count = 0;
  int count2 = 0;
  BuildContext _context;
  ScrollController _controller;
  List columns = [
    {'title': '日志来源', 'key': 'log_source'},
    {'title': '接口名称', 'key': 'name'},
    {'title': '调用次数', 'key': 'log_times'},
    {'title': '调用日期', 'key': 'log_day'},
  ];
  bool isExpandedFlag = true;
  Map url = {
    "all": "全部",
  };

  Map logSource = {
    'all': '全部',
  };

  DateTime create_date_min;
  DateTime create_date_max;
  bool loading = true;
  int tabType = 1; // 1: 日志明细 2: 日志汇总
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() {
    setState(() {
      param['curr_page'] = 1;
      param2['curr_page'] = 1;
      getData(isRefresh: true);
      getData2(isRefresh: true);
    });
  }

//  void _onLoading() async{
//    // monitor network fetch
//    await Future.delayed(Duration(milliseconds: 1000));
//    // if failed,use loadFailed(),if no data return,use LoadNodata()
////    items.add((items.length+1).toString());
//    if(mounted)
//      setState(() {
//
//      });
//    _refreshController.loadComplete();
//  }

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
    ajax('Adminrelas-Api-analysisLog', {}, true, (data) {
      if (mounted) {
        setState(() {
          logSource.addAll(data['source']);
          for (var o in data['url_list']) {
            url[o['url_id']] = o['name'];
          }
          getData();
          getData2();
        });
      }
    }, () {}, _context);
  }

  getData({isRefresh: false}) {
    if (create_date_min != null) {
      param['log_dayL'] = create_date_min.toString().substring(0, 10);
    } else {
      param.remove('log_dayL');
    }

    if (create_date_max != null) {
      param['log_dayR'] = create_date_max.toString().substring(0, 10);
    } else {
      param.remove('log_dayR');
    }

    ajax('Adminrelas-Logs-logsDetail', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        List temp = [];
        if (res['data'] != null && res['data'].isNotEmpty) {
          for (var o in res['data']) {
            o['log_source'] = logSource[o['log_source']];
            temp.add(jsonDecode(jsonEncode(o)));
          }
        }
        setState(() {
          logs = temp;
          count = int.tryParse('${res['count'] ?? 0}');
          toTop();
          loading = false;
        });
        if (isRefresh) {
          _refreshController.refreshCompleted();
        }
      }
    }, () {
      setState(() {
        loading = false;
      });
    }, _context);
  }

  getData2({isRefresh: false}) {
    if (create_date_min != null) {
      param2['log_dayL'] = create_date_min.toString().substring(0, 10);
    } else {
      param2.remove('log_dayL');
    }

    if (create_date_max != null) {
      param2['log_dayR'] = create_date_max.toString().substring(0, 10);
    } else {
      param2.remove('log_dayR');
    }

    param2['group'] = true;
    ajax('Adminrelas-Logs-logsDetail', {'param': jsonEncode(param2)}, true, (res) {
      if (mounted) {
        List temp = [];
        if (res['data'] != null && res['data'].isNotEmpty) {
          for (var o in res['data']) {
            o['log_source'] = logSource[o['log_source']];
            temp.add(jsonDecode(jsonEncode(o)));
          }
        }
        setState(() {
          logs2 = temp;
          count2 = int.tryParse('${res['count'] ?? 0}');
          toTop();
          loading = false;
        });
        if (isRefresh) {
          _refreshController.refreshCompleted();
        }
      }
    }, () {
      setState(() {
        loading = false;
      });
    }, _context);
  }

  toTop() {
    _controller.animateTo(
      0,
      duration: new Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  getPage(page) {
    if (loading) return;
    if (tabType == 1) {
      param['curr_page'] += page;
      getData();
    } else {
      param2['curr_page'] += page;
      getData2();
    }
  }

  getDateTime(val) {
    setState(() {
      create_date_min = val['min'];
      create_date_max = val['max'];
    });
  }

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'log_source': '日志来源 升序',
    'log_source desc': '日志来源 降序',
    'name': '接口名称 升序',
    'name desc': '接口名称 降序',
    'log_times': '调用次数 升序',
    'log_times desc': '调用次数 降序',
    'log_day': '调用日期 升序',
    'log_day desc': '调用日期 降序',
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
    getData2();
  }

  @override
  Widget build(BuildContext context) {
//    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('日志分析'),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
//          onLoading: _onLoading,
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
                Select(
                  selectOptions: logSource,
                  selectedValue: param['log_source'] ?? 'all',
                  label: '日志来源',
                  onChanged: (String newValue) {
                    setState(() {
                      if (newValue == 'all') {
                        param.remove('log_source');
                        param2.remove('log_source');
                      } else {
                        param['log_source'] = newValue;
                        param2['log_source'] = newValue;
                      }
                    });
                  },
                ),
                Select(
                  selectOptions: url,
                  selectedValue: param['url_id'] ?? 'all',
                  label: '接口名称',
                  onChanged: (String newValue) {
                    setState(() {
                      if (newValue == 'all') {
                        param.remove('url_id');
                        param2.remove('url_id');
                      } else {
                        param['url_id'] = newValue;
                        param2['url_id'] = newValue;
                      }
                    });
                  },
                ),
                DateSelectPlugin(
                  onChanged: getDateTime,
                  label: '操作日期',
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
                      param2['curr_page'] = 1;
                      getData();
                      getData2();
                      FocusScope.of(context).requestFocus(
                        FocusNode(),
                      );
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
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(),
              height: 34,
              child: Row(
                children: <Widget>[
                  Container(
                    height: 34,
                    width: 15,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xffff4400),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        tabType = 1;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: tabType == 1 ? Color(0xffff4400) : Colors.transparent, width: 2),
                          left: BorderSide(color: tabType == 1 ? Color(0xffff4400) : Colors.transparent, width: 1),
                          right: BorderSide(color: tabType == 1 ? Color(0xffff4400) : Colors.transparent, width: 1),
                          bottom: BorderSide(color: tabType == 2 ? Color(0xffff4400) : Colors.transparent, width: 1),
                        ),
                      ),
                      height: 34,
                      child: Center(
                        child: Text(
                          '日志明细',
                          style: TextStyle(color: tabType == 1 ? Color(0xffff4400) : CFColors.text),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        tabType = 2;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      height: 34,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: tabType == 2 ? Color(0xffff4400) : Colors.transparent, width: 2),
                          left: BorderSide(color: tabType == 2 ? Color(0xffff4400) : Colors.transparent, width: 1),
                          right: BorderSide(color: tabType == 2 ? Color(0xffff4400) : Colors.transparent, width: 1),
                          bottom: BorderSide(color: tabType == 1 ? Color(0xffff4400) : Colors.transparent, width: 1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '日志汇总',
                          style: TextStyle(color: tabType == 2 ? Color(0xffff4400) : CFColors.text),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 34,
                      width: 15,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xffff4400), width: 1),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            loading
                ? Container(
                    child: CupertinoActivityIndicator(),
                  )
                : Column(
                    children: <Widget>[
                      Offstage(
                        offstage: tabType != 1,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(bottom: 8),
                              alignment: Alignment.centerRight,
                              child: NumberBar(count: count),
                            ),
                            logs.isEmpty
                                ? Container(
                                    alignment: Alignment.topCenter,
                                    child: Text('无数据'),
                                  )
                                : LogCard(
                                    columns,
                                    logs,
                                    labelWidth: 110.0,
                                  ),
                            Container(
                              child: PagePlugin(
                                current: param['curr_page'],
                                total: count,
                                pageSize: param['page_count'],
                                function: getPage,
                              ),
                            )
                          ],
                        ),
                      ),
                      Offstage(
                        offstage: tabType != 2,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(bottom: 8),
                              alignment: Alignment.centerRight,
                              child: NumberBar(count: count2),
                            ),
                            logs2.isEmpty
                                ? Container(
                                    alignment: Alignment.topCenter,
                                    child: Text('无数据'),
                                  )
                                : LogCard(
                                    columns,
                                    logs2,
                                    labelWidth: 110.0,
                                  ),
                            Container(
                              child: PagePlugin(
                                current: param2['curr_page'],
                                total: count2,
                                pageSize: param2['page_count'],
                                function: getPage,
                              ),
                            )
                          ],
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
