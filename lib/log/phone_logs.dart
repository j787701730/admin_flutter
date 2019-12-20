import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/log/components/log_card.dart';
import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/range_input.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PhoneLogs extends StatefulWidget {
  @override
  _PhoneLogsState createState() => _PhoneLogsState();
}

class _PhoneLogsState extends State<PhoneLogs> {
  Map param = {'curr_page': 1, 'page_count': 20};
  List logs = [];
  int count = 0;
  BuildContext _context;
  ScrollController _controller;
  Map searchData = {'user_name': '', 'virtual': '', 'phone_num': ''};
  Map searchName = {'user_name': '用户', 'virtual': '虚拟号码', 'phone_num': '关联号码'};
  List columns = [
    {'title': '虚拟号码', 'key': 'virtual_nbr'},
    {'title': '主叫用户', 'key': 'calling_name'},
    {'title': '主叫号码', 'key': 'calling_nbr'},
    {'title': '被叫用户', 'key': 'called_name'},
    {'title': '被叫号码', 'key': 'called_nbr'},
    {'title': '拨打时间', 'key': 'start_time'},
    {'title': '挂断时间', 'key': 'end_time'},
    {'title': '通话时长(秒)', 'key': 'call_duration'},
    {'title': '通话费用(元)', 'key': 'fee'},
    {'title': '创建时间', 'key': 'create_date'},
  ];

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
    ajax('Adminrelas-Logs-getPhoneLogs', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        List temp = [];
        if (res['data'] != null && res['data'].isNotEmpty) {
          for (var o in res['data']) {
            o['fee'] = double.tryParse('${o['call_duration']}') * 0.001;
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

  getDateTime2(val) {
    setState(() {
      if (val['min'] == null) {
        param.remove('call_time_min');
      } else {
        param['call_time_min'] = val['min'].toString().substring(0, 10);
      }
      if (val['max'] == null) {
        param.remove('call_time_max');
      } else {
        param['call_time_max'] = val['max'].toString().substring(0, 10);
      }
    });
  }

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'call_duration': '通话时长 升序',
    'call_duration desc': '通话时长 降序',
    'call_duration': '通话费用 升序',
    'call_duration desc': '通话费用 降序',
    'create_date': '创建时间 升序',
    'create_date desc': '创建时间 降序',
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
        title: Text('通话日志'),
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
                  },
                );
              }).toList(),
            ),
            DateSelectPlugin(
              onChanged: getDateTime,
              label: '创建日期',
            ),
            DateSelectPlugin(
              onChanged: getDateTime2,
              label: '拨打时间',
            ),
            RangeInput(
              label: '通话时长',
              onChangeL: (String val) {
                setState(() {
                  if (val == '') {
                    param.remove('call_duration_min');
                  } else {
                    param['call_duration_min'] = val;
                  }
                });
              },
              onChangeR: (String val) {
                setState(() {
                  if (val == '') {
                    param.remove('call_duration_max');
                  } else {
                    param['call_duration_max'] = val;
                  }
                });
              },
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
                      param['curr_page'] = 1;
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
