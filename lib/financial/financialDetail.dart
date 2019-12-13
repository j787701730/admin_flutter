import 'dart:async';
import 'dart:convert';

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

class FinancialDetail extends StatefulWidget {
  @override
  _FinancialDetailState createState() => _FinancialDetailState();
}

class _FinancialDetailState extends State<FinancialDetail> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  Map sumData = {};
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '订单编号', 'key': 'order_no'},
    {'title': '支付金额', 'key': 'pay_amount'},
    {'title': '现金支付金额', 'key': 'cash_amount'},
    {'title': '红包支付金额', 'key': 'red_amount'},
    {'title': '丰收贷支付金额', 'key': 'loan_amount'},
    {'title': '订单折扣率', 'key': 'order_disrate'},
    {'title': '付款流水', 'key': 'payment_id'},
    {'title': '营业收入', 'key': 'in_amount'},
    {'title': '订单收入提现率', 'key': 'extract_rate'},
    {'title': '不可提现值', 'key': 'extract_amount'},
    {'title': '红包配置率', 'key': 'rconfig_rate'},
    {'title': '红包返还率', 'key': 'ractual_rate'},
    {'title': '红包支出', 'key': 'out_amount'},
    {'title': '平台盈利率', 'key': 'plat_rate'},
    {'title': '平台盈利', 'key': 'earn_amount'},
    {'title': '红包盈余', 'key': 'use_amount'},
    {'title': '创建时间', 'key': 'create_date'},
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
    print(param);
    setState(() {
      loading = true;
    });
    ajax('Adminrelas-financialLoan-getFinancialDetail', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'] ?? [];
          sumData = res['sum_data'] ?? {};
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

  getPage(page) {if (loading) return;
    param['curr_page'] += page;
    getData();
  }

  Map detail = {
    'shop_name': '卖家',
    'user_phone': '卖家电话',
    'store_shop_name': '门店',
    'store_user_phone': '门店电话',
    'cosignee_name': '客户',
    'cosignee_phone': '客户电话',
    'cosignee_address': '客户地址',
  };

  detailDialog(item) {
    return showDialog<void>(
      context: _context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${item['order_no']} 详情',
            style: TextStyle(fontSize: CFFontSize.topTitle),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width - 100,
                  child: Column(
                    children: detail.keys.map<Widget>((key) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 80,
                              alignment: Alignment.centerRight,
                              margin: EdgeInsets.only(right: 10),
                              child: Text('${detail[key]}'),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text('${item[key]}'),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('关闭'),
              onPressed: () {
                Navigator.of(_context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  getDateTime(val) {
    setState(() {
      if (val['min'] == null) {
        param.remove('create_date_l');
      } else {
        param['create_date_l'] = val['min'].toString().substring(0, 10);
      }
      if (val['max'] == null) {
        param.remove('create_date_r');
      } else {
        param['create_date_r'] = val['max'].toString().substring(0, 10);
      }
    });
  }

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'pay_amount': '支付金额 升序',
    'pay_amount desc': '支付金额 降序',
    'cash_amount': '现金支付金额 升序',
    'cash_amount desc': '现金支付金额 降序',
    'red_amount': '红包支付金额 升序',
    'red_amount desc': '红包支付金额 降序',
    'loan_amount': '丰收贷支付金额 升序',
    'loan_amount desc': '丰收贷支付金额 降序',
    'order_disrate': '订单折扣率 升序',
    'order_disrate desc': '订单折扣率 降序',
    'payment_id': '付款流水 升序',
    'payment_id desc': '付款流水 降序',
    'in_amount': '营业收入 升序',
    'in_amount desc': '营业收入 降序',
    'extract_rate': '订单收入提现率 升序',
    'extract_rate desc': '订单收入提现率 降序',
    'extract_amount': '不可提现值 升序',
    'extract_amount desc': '不可提现值 降序',
    'rconfig_rate': '红包配置率 升序',
    'rconfig_rate desc': '红包配置率 降序',
    'ractual_rate': '红包返还率 升序',
    'ractual_rate desc': '红包返还率 降序',
    'out_amount': '红包支出 升序',
    'out_amount desc': '红包支出 降序',
    'plat_rate': '平台盈利率 升序',
    'plat_rate desc': '平台盈利率 降序',
    'earn_amount': '平台盈利 升序',
    'earn_amount desc': '平台盈利 降序',
    'use_amount': '红包盈余 升序',
    'use_amount desc': '红包盈余 降序',
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

  Map searchOptions = {
    'order_no': '订单编号',
    'shop_name': '卖家名称',
    'shop_phone': '卖家电话',
    'store_name': '门店名称',
    'store_phone': '门店电话',
    'cosignee_name': '客户名称',
    'cosignee_phone': '客户电话',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('金融明细'),
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
              Column(
                children: searchOptions.keys.map<Widget>((key) {
                  return Input(
                    label: searchOptions[key],
                    onChanged: (val) {
                      if (val == '') {
                        param.remove(key);
                      } else {
                        param[key] = val;
                      }
                    },
                  );
                }).toList(),
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
                            FocusScope.of(context).requestFocus(FocusNode());
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
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(bottom: 6),
                                  child: Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            '支付总金额：',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text('${sumData['sum_pay_amount']}元')
                                        ],
                                        mainAxisSize: MainAxisSize.min,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            '现金支付金额：',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text('${sumData['sum_cash_amount']}元')
                                        ],
                                        mainAxisSize: MainAxisSize.min,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            '红包支付金额：',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text('${sumData['sum_red_amount']}元')
                                        ],
                                        mainAxisSize: MainAxisSize.min,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            '丰收贷支付金额：',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text('${sumData['sum_loan_amount']}元')
                                        ],
                                        mainAxisSize: MainAxisSize.min,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            '营业收入：',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text('${sumData['sum_in_amount']}元')
                                        ],
                                        mainAxisSize: MainAxisSize.min,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            '红包支出：',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text('${sumData['sum_out_amount']}元')
                                        ],
                                        mainAxisSize: MainAxisSize.min,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            '平台盈利：',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text('${sumData['sum_earn_amount']}元')
                                        ],
                                        mainAxisSize: MainAxisSize.min,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            '红包盈余：',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text('${sumData['sum_use_amount']}元')
                                        ],
                                        mainAxisSize: MainAxisSize.min,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: ajaxData.map<Widget>((item) {
                                    return Container(
                                        decoration:
                                            BoxDecoration(border: Border.all(color: Colors.grey, width: 1)),
                                        margin: EdgeInsets.only(bottom: 10),
                                        padding: EdgeInsets.only(top: 5, bottom: 5),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: columns.map<Widget>((col) {
                                            Widget con = Text('${item[col['key']] ?? ''}');
                                            switch (col['key']) {
                                              case 'order_no':
                                                con = InkWell(
                                                  onTap: () {
                                                    detailDialog(item);
                                                  },
                                                  child: Text(
                                                    '${item[col['key']]}',
                                                    style: TextStyle(color: Colors.blue),
                                                  ),
                                                );
                                                break;
                                            }

                                            return Container(
                                              margin: EdgeInsets.only(bottom: 6),
                                              child: Row(
                                                children: <Widget>[
                                                  Container(
                                                    width: 130,
                                                    alignment: Alignment.centerRight,
                                                    child: Text('${col['title']}'),
                                                    margin: EdgeInsets.only(right: 10),
                                                  ),
                                                  Expanded(flex: 1, child: con)
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ));
                                  }).toList(),
                                )
                              ],
                            ),
                    ),
              Container(
                child: PagePlugin(
                    current: param['curr_page'], total: count, pageSize: param['page_count'], function: getPage),
              ),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: toTop,
        child: Icon(Icons.keyboard_arrow_up),
      ),
    );
  }
}
