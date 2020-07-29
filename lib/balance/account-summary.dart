import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/search-bar-plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AccountSummary extends StatefulWidget {
  @override
  _AccountSummaryState createState() => _AccountSummaryState();
}

class _AccountSummaryState extends State<AccountSummary> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  Map sumData = {};
  bool loading = true;

  List columns = [
    {'title': '店铺', 'key': 'shop_name'},
    {'title': '用户', 'key': 'login_name'},
    {'title': '帐目类型', 'key': 'type_name'},
    {'title': '帐目来源', 'key': 'source_name'},
    {'title': '年', 'key': 'years'},
    {'title': '月', 'key': 'months'},
    {'title': '账期', 'key': 'billing_cycle'},
    {'title': '发票状态', 'key': "case ai.invoice_state when 0 then '未开票' when 1 then '申请开票' else '已开票' end"},
    {'title': '总金额', 'key': 'amount'},
    {'title': '总滞纳金', 'key': 'sum_late_amount'},
    {'title': '已还款金额', 'key': 'repay_amount'},
    {'title': '已还滞纳金额', 'key': 'repay_late_amount'},
  ];

  Map cardState = {"-2": "全部"};
  Map balanceType = {'0': '全部'};
  Map chargeTypeRes = {'0': '全部'};
  Map constranctResult = {'-2': '全部'};

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
      getData();
    });
  }

  getParamData() {
    ajax('Adminrelas-Api-chargeInParam', {}, true, (data) {
      if (mounted) {
        Map balanceTypeTemp = {};
        for (var o in data['balanceTypeRes'].keys.toList()) {
          balanceTypeTemp[o] = data['balanceTypeRes'][o]['balance_type_ch_name'];
        }

        Map chargeTypeResTemp = {};
        for (var o in data['chargeTypeRes']) {
          chargeTypeResTemp[o] = o['charge_type_ch_name'];
        }

        Map constranctResultTemp = {};
        for (var o in data['constranctResult']) {
          constranctResultTemp[o] = o;
        }
        setState(() {
          cardState.addAll(data['chargeInState']);
          balanceType.addAll(balanceTypeTemp);
          chargeTypeRes.addAll(chargeTypeResTemp);
          constranctResult.addAll(constranctResultTemp);
        });
      }
    }, () {}, _context);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getData({isRefresh: false}) {
    setState(() {
      loading = true;
    });
    ajax(
        'Adminrelas-balance-getItem',
        {
          'search': jsonEncode(param),
          'group': jsonEncode([
            "shop_id",
            "user_id",
            "acct_item_type_id",
            "acct_item_source_id",
            "years",
            "months",
            "billing_cycle_id",
            "invoice_state",
          ])
        },
        true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'] ?? [];
          count = int.tryParse('${res['count'] ?? 0}');
          sumData = res['sumAmount'] ?? {};
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
      duration: new Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  getPage(page) {
    if (loading) return;
    param['curr_page'] = page;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('账目汇总'),
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
            SearchBarPlugin(
              secondChild: Column(
                children: <Widget>[
                  Input(
                    label: '用户名',
                    onChanged: (String val) {
                      if (val == '') {
                        param.remove('user_name');
                      } else {
                        param['user_name'] = val;
                      }
                    },
                  ),
                  Input(
                    label: '店铺查询',
                    onChanged: (String val) {
                      if (val == '') {
                        param.remove('shop_name');
                      } else {
                        param['shop_name'] = val;
                      }
                    },
                  ),
                  Input(
                    label: '电话号码',
                    onChanged: (String val) {
                      if (val == '') {
                        param.remove('user_phone');
                      } else {
                        param['user_phone'] = val;
                      }
                    },
                  ),
                  Select(
                    selectOptions: chargeTypeRes,
                    selectedValue: param['charge_type'] ?? '0',
                    label: '充值类型',
                    onChanged: (String newValue) {
                      if (newValue == '0') {
                        param.remove('charge_type');
                      } else {
                        param['charge_type'] = newValue;
                      }
                    },
                  ),
                  Select(
                    selectOptions: balanceType,
                    selectedValue: param['balance_type'] ?? '0',
                    label: '余额类型',
                    onChanged: (String newValue) {
                      if (newValue == '0') {
                        param.remove('balance_type');
                      } else {
                        param['balance_type'] = newValue;
                      }
                    },
                  ),
                  Select(
                    selectOptions: constranctResult,
                    selectedValue: param['constract_result'] ?? '-2',
                    label: '对账结果',
                    onChanged: (String newValue) {
                      if (newValue == '-2') {
                        param.remove('constract_result');
                      } else {
                        param['constract_result'] = newValue;
                      }
                    },
                  ),
                  Select(
                    selectOptions: cardState,
                    selectedValue: param['charge_state'] ?? '-2',
                    label: '充值状态',
                    onChanged: (String newValue) {
                      if (newValue == '0') {
                        param.remove('charge_state');
                      } else {
                        param['charge_state'] = newValue;
                      }
                    },
                  ),
                  DateSelectPlugin(
                    onChanged: (val) {
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
                    },
                    label: '创建时间',
                  ),
                  DateSelectPlugin(
                    onChanged: (val) {
                      if (val['min'] == null) {
                        param.remove('billing_cycle_idL');
                      } else {
                        param['billing_cycle_idL'] = val['min'].toString().substring(0, 10);
                      }
                      if (val['max'] == null) {
                        param.remove('billing_cycle_idU');
                      } else {
                        param['billing_cycle_idU'] = val['max'].toString().substring(0, 10);
                      }
                    },
                    label: '账期',
                  ),
                  DateSelectPlugin(
                    onChanged: (val) {
                      if (val['min'] == null) {
                        param.remove('repay_dateL');
                      } else {
                        param['repay_dateL'] = val['min'].toString().substring(0, 10);
                      }
                      if (val['max'] == null) {
                        param.remove('repay_dateU');
                      } else {
                        param['repay_dateU'] = val['max'].toString().substring(0, 10);
                      }
                    },
                    label: '还款日期',
                  ),
                ],
              ),
            ),
            Container(
              child: Wrap(
                runSpacing: 10,
                spacing: 10,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  PrimaryButton(
                    onPressed: () {
                      param['curr_page'] = 1;
                      getData();
                    },
                    child: Text('搜索'),
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
            sumData.isEmpty
                ? Container()
                : Container(
                    margin: EdgeInsets.only(bottom: 6),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
//              ￥2709311.58    ：￥15.72   ：￥185.91   ：￥1.01
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '账目流水总金额：',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('￥${sumData['amount']}'),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '已还款金额：',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('￥${sumData['repay_amount']}'),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '总滞纳金额：',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('￥${sumData['sum_late_amount']}'),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '已还滞纳金额：',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('￥${sumData['repay_late_amount']}'),
                          ],
                        ),
                      ],
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
                                  border: Border.all(color: Color(0xffdddddd), width: 1),
                                ),
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: columns.map<Widget>((col) {
                                    Widget con = Text('${item[col['key']] ?? ''}');
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            width: 110,
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
            )
          ],
        ),
      ),
      floatingActionButton: CFFloatingActionButton(
        onPressed: toTop,
        child: Icon(Icons.keyboard_arrow_up),
      ),
      floatingActionButtonAnimator: ScalingAnimation(),
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(
        FloatingActionButtonLocation.endFloat,
        floatingActionButtonOffsetX,
        floatingActionButtonOffsetY,
      ),
    );
  }
}
