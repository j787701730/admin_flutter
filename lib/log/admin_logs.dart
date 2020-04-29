import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/log/components/log_card.dart';
import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AdminLogs extends StatefulWidget {
  @override
  _AdminLogsState createState() => _AdminLogsState();
}

class _AdminLogsState extends State<AdminLogs> {
  Map param = {'curr_page': 1, 'page_count': 20};
  List logs = [];
  int count = 0;
  BuildContext _context;
  ScrollController _controller;
  Map searchData = {'login_name': '', 'full_name': '', 'oper_ip': ''};
  Map searchName = {'login_name': '用户', 'full_name': '真实姓名', 'oper_ip': 'IP地址'};
  List columns = [
    {'title': '用户', 'key': 'login_name'},
    {'title': '真实名字', 'key': 'full_name'},
    {'title': '操作类型', 'key': 'oper_type'},
    {'title': '菜单标识', 'key': 'menu_name'},
    {'title': '功能标识', 'key': 'function_name'},
    {'title': '操作标识', 'key': 'oper_content', 'event': true, 'lines': 4},
    {'title': '操作IP', 'key': 'oper_ip'},
    {'title': '操作时间', 'key': 'oper_time'},
  ];

  Map operaType = {'1': '后台登入', '2': '操作模块'};
  bool isExpandedFlag = false;

  DateTime create_date_min;
  DateTime create_date_max;
  bool loading = true;

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    setState(() {
      param['curr_page'] = 1;
      getData(isRefresh: true);
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
      getData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getData({isRefresh: false}) async {
    if (create_date_min != null) {
      param['create_date_min'] = create_date_min.toString().substring(0, 10);
    } else {
      param.remove('create_date_min');
    }

    if (create_date_max != null) {
      param['create_date_max'] = create_date_max.toString().substring(0, 10);
    } else {
      param.remove('create_date_max');
    }

    for (String k in searchData.keys) {
      if (searchData[k] != '') {
        param[k] = searchData[k].toString();
      } else {
        param.remove(k);
      }
    }
    ajax('Adminrelas-logs-adminLogs', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        List temp = [];
        if (res['data'] != null && res['data'].isNotEmpty) {
          for (var o in res['data']) {
            o['oper_type'] = operaType[o['oper_type']];
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

  toTop() {
    _controller.animateTo(
      0,
      duration: new Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  getPage(page) {
    if (loading) return;
    param['curr_page'] += page;
    getData();
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
    //
    'login_name': '登录名称 升序',
    'login_name desc': '登录名称 降序',
    'full_name': '真实名称 升序',
    'full_name desc': '真实名称 降序',
    'oper_type': '操作类型 升序',
    'oper_type desc': '操作类型 降序',
    'menu_name': '菜单标识 升序',
    'menu_name desc': '菜单标识 降序',
    'function_name': '功能标识 升序',
    'function_name desc': '功能标识 降序',
    'oper_content': '操作标识 升序',
    'oper_content desc': '操作标识 降序',
    'oper_ip': '操作IP 升序',
    'oper_ip desc': '操作时间 降序',
    'oper_time': '操作IP 升序',
    'oper_time desc': '操作时间 降序',
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
//    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('后台操作日志'),
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
                Column(
                  children: searchData.keys.map<Widget>((key) {
                    return Input(
                        label: '${searchName[key]}',
                        onChanged: (String val) {
                          setState(() {
                            searchData[key] = val;
                          });
                        });
                  }).toList(),
                ),
                DateSelectPlugin(
                  onChanged: getDateTime,
                  label: '操作日期',
                ),
                Select(
                  selectOptions: selects,
                  selectedValue: defaultVal,
                  onChanged: orderBy,
                  label: '排序',
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
                  SizedBox(
                    height: 30,
                    child: PrimaryButton(
                      onPressed: () {
                        param['curr_page'] = 1;
                        getData();
                        FocusScope.of(context).requestFocus(
                          FocusNode(),
                        );
                      },
                      child: Text('搜索'),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: PrimaryButton(
                      color: CFColors.success,
                      onPressed: () {
                        setState(() {
                          isExpandedFlag = !isExpandedFlag;
                        });
                      },
                      child: Text('${isExpandedFlag ? '展开' : '收缩'}选项'),
                    ),
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: 10),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 8),
              alignment: Alignment.centerRight,
              child: NumberBar(count: count),
            ),
            loading
                ? Container(
                    child: CupertinoActivityIndicator(),
                  )
                : logs.isEmpty
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
      floatingActionButton: CFFloatingActionButton(
        onPressed: toTop,
        child: Icon(Icons.keyboard_arrow_up),
      ),
    );
  }
}
