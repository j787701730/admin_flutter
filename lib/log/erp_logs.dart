import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/log/components/log_card.dart';
import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ErpLogs extends StatefulWidget {
  @override
  _ErpLogsState createState() => _ErpLogsState();
}

class _ErpLogsState extends State<ErpLogs> {
  int curr_page = 1;
  int page_count = 20;
  Map param = {};
  List logs = [];
  int count = 0;
  BuildContext _context;
  ScrollController _controller;
  Map searchData = {'user_name': '', 'ip': '', 'err_code': ''};
  Map searchName = {'user_name': '用户', 'ip': 'IP地址', 'err_code': '错误码'};
  List columns = [
    {'title': '用户', 'key': 'user_name'},
    {'title': '输入参数', 'key': 'in_param', 'event': true, 'lines': 4},
    {'title': '访问路径', 'key': 'url'},
    {'title': '输出参数', 'key': 'out_param', 'event': true, 'lines': 4},
    {'title': 'IP地址', 'key': 'ip'},
    {'title': '操作时间', 'key': 'create_date'},
  ];

  DateTime create_date_min;
  DateTime create_date_max;
  bool loading = true;
  String defaultVal = 'all';

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    setState(() {
      curr_page = 1;
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

  Map selects = {
    'all': '无',
    'user_id': '用户 升序',
    'user_id desc': '用户 降序',
    'in_param': '输入参数 升序',
    'in_param desc': '输入参数 降序',
    'url': '访问路径 升序',
    'url desc': '访问路径 降序',
    'out_param': '输出参数 升序',
    'out_param desc': '输出参数 降序',
    'ip': 'IP地址 升序',
    'ip desc': 'IP地址 降序',
    'create_date': '操作时间 升序',
    'create_date desc': '操作时间 降序',
  };

  orderBy(val) {
    curr_page = 1;
    defaultVal = val;
    getData();
  }

  getData({isRefresh: false}) async {
    setState(() {
      loading = true;
    });
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

    Map par = {'curr_page': curr_page, 'page_count': page_count, 'param': jsonEncode(param)};
    if (defaultVal != 'all') {
      par['order'] = defaultVal;
    }
    ajax('Adminrelas-Logs-erpLogs', par, true, (res) {
      if (mounted) {
        setState(() {
          logs = res['data'];
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
      duration: Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  getPage(page) {
    if (loading) return;
    curr_page += page;
    getData();
  }

  getDateTime(val) {
    setState(() {
      create_date_min = val['min'];
      create_date_max = val['max'];
    });
  }

  @override
  Widget build(BuildContext context) {
//    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('ERP日志'),
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
                label: '操作时间',
              ),
              Select(
                selectOptions: selects,
                selectedValue: defaultVal,
                label: '排序',
                onChanged: orderBy,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  PrimaryButton(
                    onPressed: () {
                      setState(() {
                        curr_page = 1;
                        getData();
                      });
                    },
                    child: Text('搜索'),
                  )
                ],
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
                      : LogCard(columns, logs),
              Container(
                child: PagePlugin(current: curr_page, total: count, pageSize: page_count, function: getPage),
              )
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: toTop,
        child: Icon(Icons.keyboard_arrow_up),
      ),
    );
  }
}
