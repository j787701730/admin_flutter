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
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RedPacketLogs extends StatefulWidget {
  @override
  _RedPacketLogsState createState() => _RedPacketLogsState();
}

class _RedPacketLogsState extends State<RedPacketLogs> {
  Map param = {'curr_page': 1, 'page_count': 20};
  List logs = [];
  int count = 0;
  BuildContext _context;
  ScrollController _controller;
  Map searchData = {'user_name': ''};
  Map searchName = {'user_name': '用户'};
  List columns = [
    {'title': '用户', 'key': 'login_name'},
    {'title': '金额(元)', 'key': 'receive_amount'},
    {'title': '红包(份)', 'key': 'nums'},
    {'title': '时间', 'key': 'receive_date'},
  ];
  bool isExpandedFlag = true;
  DateTime create_date_min;
  DateTime create_date_max;
  bool loading = true;

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() {
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

  getData({isRefresh: false}) {
    if (create_date_min != null) {
      param['receive_date_min'] = create_date_min.toString().substring(0, 10);
    } else {
      param.remove('receive_date_min');
    }

    if (create_date_max != null) {
      param['receive_date_max'] = create_date_max.toString().substring(0, 10);
    } else {
      param.remove('receive_date_max');
    }

    for (String k in searchData.keys) {
      if (searchData[k] != '') {
        param[k] = searchData[k].toString();
      } else {
        param.remove(k);
      }
    }

    ajax('Adminrelas-Logs-redPacketLogs', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          logs = res['data'] ?? [];
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
    // 	(元) 	(份)
    'all': '无',
    'login_name': '用户 升序',
    'login_name desc': '用户 降序',
    'receive_amount': '金额 升序',
    'receive_amount desc': '金额 降序',
    'nums': '红包 升序',
    'nums desc': '红包 降序',
    'receive_date': '时间 升序',
    'receive_date desc': '时间 降序',
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
        title: Text('红包日志'),
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
                      },
                    );
                  }).toList(),
                ),
                RangeInput(
                  label: '领取金额',
                  onChangeL: (String val) {
                    setState(() {
                      if (val == '') {
                        param.remove('receive_amount_min');
                      } else {
                        param['receive_amount_min'] = val;
                      }
                    });
                  },
                  onChangeR: (String val) {
                    setState(() {
                      if (val == '') {
                        param.remove('receive_amount_max');
                      } else {
                        param['receive_amount_max'] = val;
                      }
                    });
                  },
                ),
                RangeInput(
                  label: '领取数量',
                  onChangeL: (String val) {
                    setState(() {
                      if (val == '') {
                        param.remove('num_min');
                      } else {
                        param['num_min'] = val;
                      }
                    });
                  },
                  onChangeR: (String val) {
                    setState(() {
                      if (val == '') {
                        param.remove('num_max');
                      } else {
                        param['num_max'] = val;
                      }
                    });
                  },
                ),
                DateSelectPlugin(
                  onChanged: getDateTime,
                  label: '操作日期',
                ),
                Select(
                  label: '排序',
                  selectOptions: selects,
                  selectedValue: defaultVal,
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
