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

class MQLogs extends StatefulWidget {
  @override
  _MQLogsState createState() => _MQLogsState();
}

class _MQLogsState extends State<MQLogs> {
  Map param = {'curr_page': 1, 'page_count': 20};
  List logs = [];
  int count = 0;
  BuildContext _context;
  ScrollController _controller;
  Map searchData = {
    'user_name': '',
    'order_no': '',
  };
  Map searchName = {
    'user_name': '用户',
    'order_no': '订单号',
  };
  List columns = [
    {'title': '队列标识', 'key': 'msg_id'},
    {'title': '消息内容', 'key': 'msg_content', 'event': true, 'lines': 4},
    {'title': '处理状态', 'key': 'data_state'},
    {'title': '数据失败原因', 'key': 'data_error', 'lines': 4},
    {'title': '微信推送状态', 'key': 'send_state'},
    {'title': '推送失败原因', 'key': 'send_error'},
    {'title': '消息时间', 'key': 'msg_time'},
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

  String defaultVal = 'all';
  bool isExpandedFlag = false;
  Map selects = {
    'all': '无',
    'msg_id': '队列标识 升序',
    'msg_id desc': '队列标识 降序',
    'msg_content': '消息内容 升序',
    'msg_content desc': '消息内容 降序',
    'data_state': '处理状态 升序',
    'data_state desc': '处理状态 降序',
    'data_error': '数据失败原因 升序',
    'data_error desc': '数据失败原因 降序',
    'send_state': '微信推送状态 升序',
    'send_state desc': '微信推送状态 降序',
    'send_error': '推送失败原因 升序',
    'send_error desc': '推送失败原因 降序',
    'msg_time': '消息时间 升序',
    'msg_time desc': '消息时间 降序',
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
    ajax('Adminrelas-Logs-mqLogs', {'param': jsonEncode(param)}, true, (res) {
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

  @override
  Widget build(BuildContext context) {
//    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('消息队列日志'),
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
                      label: searchName[key],
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
                  label: '消息时间',
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
