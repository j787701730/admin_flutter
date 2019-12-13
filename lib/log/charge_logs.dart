import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/log/components/log_card.dart';
import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/range_input.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ChargeLogs extends StatefulWidget {
  @override
  _ChargeLogsState createState() => _ChargeLogsState();
}

class _ChargeLogsState extends State<ChargeLogs> {
  Map param = {'curr_page': 1, 'page_count': 20};
  List logs = [];
  Map sum = {};
  int count = 0;
  BuildContext _context;
  ScrollController _controller;

  List columns = [
    {'title': '对账类型', 'key': 'charge_type_ch_name', 'event': false},
    {'title': '交易单量', 'key': 'bill_count', 'event': false},
    {'title': '交易总额', 'key': 'bill_amount', 'event': false},
    {'title': '手续费总额', 'key': 'service_amount', 'event': false},
    {'title': '对账结果', 'key': 'state', 'event': false},
    {'title': '对账日期', 'key': 'bill_date', 'event': false},
    {'title': '对账时间', 'key': 'create_date', 'event': false},
    {'title': '备注', 'key': 'comments', 'event': false},
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

    ajax('Adminrelas-Logs-chargeLogs', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        List temp = [];
        if (res['data'] != null && res['data'].isNotEmpty) {
          for (var o in res['data']) {
            o['state'] = '${o['state']}' == '1' ? '成功' : '失败';
            temp.add(jsonDecode(jsonEncode(o)));
          }
        }
        setState(() {
          logs = temp;
          count = int.tryParse('${res['count'] ?? 0}');
          toTop();
          loading = false;
          sum = res['sum'] ?? {};
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

  getPage(page) {if (loading) return;
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
    'charge_type': '对账类型 升序',
    'charge_type desc': '对账类型 降序',
    'bill_count': '交易单量 升序',
    'bill_count desc': '交易单量 降序',
    'bill_amount': '交易总额 升序',
    'bill_amount desc': '交易总额 降序',
    'service_amount': '手续费总额 升序',
    'service_amount desc': '手续费总额 降序',
    'state': '对账结果 升序',
    'state desc': '对账结果 降序',
    'bill_date': '对账日期 升序',
    'bill_date desc': '对账日期 降序',
    'create_date': '对账时间 升序',
    'create_date desc': '对账时间 降序',
  };

  Map constractType = {
    'all': '全部',
    '1': '充值卡',
    '2': '支付宝',
    '3': '微信',
  };

  Map state = {
    'all': '全部',
    '1': '成功',
    '0': '失败',
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
        title: Text('对账日志'),
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
              Select(
                selectOptions: constractType,
                selectedValue: param['constract_type'] ?? 'all',
                label: '对账类型',
                onChanged: (String newValue) {
                  setState(() {
                    if (newValue == 'all') {
                      param.remove('constract_type');
                    } else {
                      param['constract_type'] = newValue;
                    }
                  });
                },
              ),
              Select(
                selectOptions: state,
                selectedValue: param['state'] ?? 'all',
                label: '对账结果',
                onChanged: (String newValue) {
                  setState(() {
                    if (newValue == 'all') {
                      param.remove('state');
                    } else {
                      param['state'] = newValue;
                    }
                  });
                },
              ),
              RangeInput(
                label: '交易单量',
                onChangeL: (String val) {
                  setState(() {
                    if (val == '') {
                      param.remove('bill_countL');
                    } else {
                      param['bill_countL'] = val;
                    }
                  });
                },
                onChangeR: (String val) {
                  setState(() {
                    if (val == '') {
                      param.remove('bill_countU');
                    } else {
                      param['bill_countU'] = val;
                    }
                  });
                },
              ),
              RangeInput(
                label: '交易总额',
                onChangeL: (String val) {
                  setState(() {
                    if (val == '') {
                      param.remove('bill_amountL');
                    } else {
                      param['bill_amountL'] = val;
                    }
                  });
                },
                onChangeR: (String val) {
                  setState(() {
                    if (val == '') {
                      param.remove('bill_amountU');
                    } else {
                      param['bill_amountU'] = val;
                    }
                  });
                },
              ),
              DateSelectPlugin(onChanged: getDateTime,label: '操作日期',),
              Select(
                selectOptions: selects,
                selectedValue: defaultVal,
                onChanged: orderBy,
                label: "排序",
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
                margin: EdgeInsets.only(bottom: 6),
                alignment: Alignment.centerRight,
                child: NumberBar(count: count),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 6),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          '交易总单量：',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${sum['bc']}')
                      ],
                      mainAxisSize: MainAxisSize.min,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          '交易总额：',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${sum['ba']}元')
                      ],
                      mainAxisSize: MainAxisSize.min,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          '手续费总额：',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${sum['sa']}元')
                      ],
                      mainAxisSize: MainAxisSize.min,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          '入账总额：',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${sum['ia']}元')
                      ],
                      mainAxisSize: MainAxisSize.min,
                    ),
                  ],
                ),
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
                    current: param['curr_page'], total: count, pageSize: param['page_count'], function: getPage),
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
