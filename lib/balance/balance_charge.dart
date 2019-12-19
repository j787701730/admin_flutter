import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BalanceCharge extends StatefulWidget {
  @override
  _BalanceChargeState createState() => _BalanceChargeState();
}

class _BalanceChargeState extends State<BalanceCharge> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '用户名', 'key': 'login_name'},
    {'title': '充值类型', 'key': 'charge_type_name'},
    {'title': '余额类型', 'key': 'balance_type_name'},
    {'title': '充值金额', 'key': 'amount'},
    {'title': '赠送类型', 'key': 'present_balance_type_name'},
    {'title': '赠送金额', 'key': 'present_amount'},
    {'title': '外部流水', 'key': 'ext_searial_id'},
    {'title': '充值状态', 'key': 'state'},
    {'title': '对账结果', 'key': 'constract_result_name'},
    {'title': '创建时间', 'key': 'create_date'},
    {'title': '对账时间', 'key': 'constract_time'},
    {'title': '充值区域', 'key': 'province'},
    {'title': '操作', 'key': 'option'},
  ];

  Map cardState = {"-2": "全部", "0": "等待充值", "1": "充值成功", "-1": "充值失败"};
  Map balanceType = {
    '0': '全部',
    '1': '商城现金',
    '2': '商城红包',
    '3': '云端计费',
    '4': '云端计费-赠送',
    '5': '经销商',
    '6': '丰收贷',
  };

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
    ajax('Adminrelas-Balance-getAjaxChargeIn', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'];
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
      duration: new Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  getPage(page) {
    if (loading) return;
    param['curr_page'] += page;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('充值流水'),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Input(
                    label: '用户名',
                    onChanged: (String val) {
                      setState(() {
                        param['user_name'] = val;
                      });
                    },
                  ),
                  Select(
                    selectOptions: balanceType,
                    selectedValue: param['balance_type'] ?? '0',
                    label: '余额类型',
                    onChanged: (String newValue) {
                      setState(() {
                        if (newValue == '0') {
                          param.remove('balance_type');
                        } else {
                          param['balance_type'] = newValue;
                        }
                      });
                    },
                  ),
                  Select(
                    selectOptions: cardState,
                    selectedValue: param['charge_state'] ?? '-2',
                    label: '充值状态',
                    onChanged: (String newValue) {
                      setState(() {
                        if (newValue == '0') {
                          param.remove('charge_state');
                        } else {
                          param['charge_state'] = newValue;
                        }
                      });
                    },
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 30,
                          child: PrimaryButton(
                              onPressed: () {
                                param['curr_page'] = 1;
                                getData();
                              },
                              child: Text('搜索')),
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
                                          border: Border.all(color: Color(0xffdddddd), width: 1),
                                        ),
                                        margin: EdgeInsets.only(bottom: 10),
                                        padding: EdgeInsets.only(top: 5, bottom: 5),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: columns.map<Widget>((col) {
                                            Widget con = Text('${item[col['key']] ?? ''}');
                                            switch (col['key']) {
                                              case 'state':
                                                con = Text('${cardState[item['state']]}');
                                                break;
                                              case 'province':
                                                con = Text('${item['province']} ${item['city']}');
                                                break;
                                              case 'option':
                                                con = Text('');
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
                                    },
                                  ).toList(),
                                ),
                        ),
                  Container(
                    child: PagePlugin(
                        current: param['curr_page'], total: count, pageSize: param['page_count'], function: getPage),
                  )
                ],
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
