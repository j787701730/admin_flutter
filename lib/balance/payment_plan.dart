import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/balance/payment_plan_modify.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PaymentPlan extends StatefulWidget {
  @override
  _PaymentPlanState createState() => _PaymentPlanState();
}

class _PaymentPlanState extends State<PaymentPlan> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  Map paymentMethod = {"all": '全部', "1": "现金支付"};
  Map planType = {
    "1": {
      "type_id": "1",
      "type_en_name": "PAYMENT_PLAN_TYPE_PLAT",
      "type_ch_name": "平台购物",
      "comments": "仅供在平台的商品卖卖",
    },
    "2": {
      "type_id": "2",
      "type_en_name": "PAYMENT_PLAN_TYPE_CLOUD_BILL",
      "type_ch_name": "云端计费",
      "comments": "仅供云端ERP按平米计费"
    },
    "3": {
      "type_id": "3",
      "type_en_name": "PAYMENT_PLAN_TYPE_TASK",
      "type_ch_name": "任务扣费",
      "comments": "仅供任务扣费使用",
    },
    "4": {
      "type_id": "4",
      "type_en_name": "PAYMENT_PLAN_TYPE_ERP_ORDER",
      "type_ch_name": "ERP订单",
      "comments": "ERP订单付款余额支付方案",
    }
  };
  Map balanceType = {
    "1": {
      "balance_type_id": "1",
      "balance_type_en_name": "BALANCE_TYPE_CASH",
      "balance_type_ch_name": "商城现金",
      "if_charge": "1",
      "if_extract": "1",
      "if_transfer": "1",
      "comments": "平台购物使用，暂时不可充值，可转账，可提取",
    },
    "2": {
      "balance_type_id": "2",
      "balance_type_en_name": "BALANCE_TYPE_CASH_PRESENT",
      "balance_type_ch_name": "商城红包",
      "if_charge": "0",
      "if_extract": "0",
      "if_transfer": "0",
      "comments": "平台购物使用，不可充值，不可转账，不可提取",
    },
    "3": {
      "balance_type_id": "3",
      "balance_type_en_name": "BALANCE_TYPE_BILL",
      "balance_type_ch_name": "云端计费",
      "if_charge": "1",
      "if_extract": "0",
      "if_transfer": "0",
      "comments": "云拆单与软件包月使用，可充值，不可转账，不可提取",
    },
    "4": {
      "balance_type_id": "4",
      "balance_type_en_name": "BALANCE_TYPE_BILL_PRESENT",
      "balance_type_ch_name": "云端计费-赠送",
      "if_charge": "0",
      "if_extract": "0",
      "if_transfer": "0",
      "comments": "云拆单与软件包月使用，不可充值，不可转账，不可提取",
    },
    "5": {
      "balance_type_id": "5",
      "balance_type_en_name": "BALANCE_TYPE_DISTRIBUTOR",
      "balance_type_ch_name": "经销商",
      "if_charge": "1",
      "if_extract": "0",
      "if_transfer": "0",
      "comments": "经销商充值，可充值，不可转账，不可提取",
    },
    "6": {
      "balance_type_id": "6",
      "balance_type_en_name": "BALANCE_TYPE_HARVEST_LOAN",
      "balance_type_ch_name": "丰收贷",
      "if_charge": "0",
      "if_extract": "0",
      "if_transfer": "0",
      "comments": "晨丰贷款业务，不可充值，不可转账，不可提取",
    }
  };

  Map balanceTypeSelect = {};
  Map planTypeSelect = {};
  List columns = [
    {'title': '支付方式', 'key': 'payment_method'},
    {'title': '资金类型', 'key': 'balance_type_id'},
    {'title': '资金操作', 'key': 'type'},
    {'title': '支付顺序', 'key': 'balance_sort'},
    {'title': '备注', 'key': 'comments'},
    {'title': '操作', 'key': 'option'},
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
      balanceTypeSelect['all'] = '全部';
      planTypeSelect['all'] = '全部';
      for (var key in balanceType.keys.toList()) {
        balanceTypeSelect[key] = balanceType[key]['balance_type_ch_name'];
      }

      for (var key in planType.keys.toList()) {
        planTypeSelect[key] = planType[key]['type_ch_name'];
      }
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
    ajax('adminrelas-Balance-payMentPlans', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'] ?? [];
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
      duration: Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  getPage(page) {
    param['curr_page'] += page;
    getData();
  }

  turnTo(data) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (context) => PaymentPlanModify(data),
      ),
    );
  }

  delDialog(data) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '提示',
            style: TextStyle(fontSize: CFFontSize.topTitle),
          ),
          content: SingleChildScrollView(
            child: Container(
//                width: MediaQuery.of(context).size.width - 100,
              child: Text(
                '确认删除 ${paymentMethod[data['payment_method']]} ${balanceTypeSelect[data['balance_type_id']]} ?',
                style: TextStyle(fontSize: CFFontSize.content),
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('提交'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Map planTypeModify;

  modifyDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '修改支付方案类型',
            style: TextStyle(fontSize: CFFontSize.topTitle),
          ),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width - 100,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    height: 34,
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 80,
                          alignment: Alignment.centerRight,
                          child: Text('中文名字'),
                          margin: EdgeInsets.only(right: 10),
                        ),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            style: TextStyle(fontSize: CFFontSize.content),
                            controller: TextEditingController.fromValue(
                              TextEditingValue(
                                text: '${planTypeModify['type_ch_name'] ?? ''}',
                                selection: TextSelection.fromPosition(
                                  TextPosition(
                                    affinity: TextAffinity.downstream,
                                    offset: '${planTypeModify['type_ch_name'] ?? ''}'.length,
                                  ),
                                ),
                              ),
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 15),
                            ),
                            onChanged: (String val) {
                              setState(() {
                                planTypeModify['type_ch_name'] = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    height: 34,
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 80,
                          alignment: Alignment.centerRight,
                          child: Text('英文名字'),
                          margin: EdgeInsets.only(right: 10),
                        ),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: TextEditingController.fromValue(
                              TextEditingValue(
                                text: '${planTypeModify['type_en_name'] ?? ''}',
                                selection: TextSelection.fromPosition(
                                  TextPosition(
                                    affinity: TextAffinity.downstream,
                                    offset: '${planTypeModify['type_en_name'] ?? ''}'.length,
                                  ),
                                ),
                              ),
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 15),
                            ),
                            onChanged: (String val) {
                              setState(() {
                                planTypeModify['type_en_name'] = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 80,
                          alignment: Alignment.centerRight,
                          child: Text('描述'),
                          margin: EdgeInsets.only(right: 10),
                        ),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            maxLines: 3,
                            controller: TextEditingController.fromValue(
                              TextEditingValue(
                                text: '${planTypeModify['comments'] ?? ''}',
                                selection: TextSelection.fromPosition(
                                  TextPosition(
                                    affinity: TextAffinity.downstream,
                                    offset: '${planTypeModify['comments'] ?? ''}'.length,
                                  ),
                                ),
                              ),
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                            ),
                            onChanged: (String val) {
                              setState(() {
                                planTypeModify['comments'] = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('提交'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('支付方案'),
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
              Select(
                selectOptions: paymentMethod,
                selectedValue: param['payment_method'] ?? 'all',
                label: '支付方式',
                onChanged: (val) {
                  if (val == 'all') {
                    param.remove('payment_method');
                  } else {
                    param['payment_method'] = val;
                  }
                },
              ),
              Select(
                selectOptions: planTypeSelect,
                selectedValue: param['payment_plan_type'] ?? 'all',
                label: '支付方案',
                onChanged: (val) {
                  if (val == 'all') {
                    param.remove('payment_plan_type');
                  } else {
                    param['payment_plan_type'] = val;
                  }
                },
              ),
              Select(
                selectOptions: balanceTypeSelect,
                selectedValue: param['balance_type_id'] ?? 'all',
                label: '现金类型',
                onChanged: (val) {
                  if (val == 'all') {
                    param.remove('balance_type_id');
                  } else {
                    param['balance_type_id'] = val;
                  }
                },
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
                        child: Text('搜索'),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: PrimaryButton(
                        onPressed: () {
                          turnTo(null);
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        child: Text('添加支付方案'),
                      ),
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
                              children: ajaxData.map<Widget>((data) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(0xffdddddd),
                                    ),
                                  ),
                                  margin: EdgeInsets.only(bottom: 10),
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              '${planTypeSelect[data['payment_plan_type']]}：',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            Text('${data['name']} '),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  planTypeModify = {
                                                    'type_ch_name': '${data['name']}',
                                                    'type_en_name':
                                                        '${planType[data['payment_plan_type']]['type_en_name']}',
                                                    'comments': '${planType[data['payment_plan_type']]['comments']}',
                                                  };
                                                  modifyDialog();
                                                });
                                              },
                                              child: Container(
                                                child: Icon(
                                                  Icons.mode_edit,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: data['data'].map<Widget>((item) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Color(0xffdddddd),
                                                width: 1,
                                              ),
                                            ),
                                            margin: EdgeInsets.only(bottom: 10),
                                            padding: EdgeInsets.only(top: 5, bottom: 5),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: columns.map<Widget>((col) {
                                                Widget con = Text('${item[col['key']] ?? ''}');
                                                switch (col['key']) {
                                                  case 'payment_method':
                                                    con = Text('${paymentMethod[item['payment_method']]}');
                                                    break;
                                                  case 'balance_type_id':
                                                    con = Text('${balanceTypeSelect[item['balance_type_id']]}');
                                                    break;
                                                  case 'type':
                                                    Map typeTemp = balanceType[item['balance_type_id']];
                                                    con = Container(
                                                      child: Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            flex: 1,
                                                            child: Row(
                                                              children: <Widget>[
                                                                Text('充值'),
                                                                typeTemp['if_charge'] == '1'
                                                                    ? Icon(
                                                                        Icons.check,
                                                                        color: CFColors.success,
                                                                      )
                                                                    : Icon(
                                                                        Icons.close,
                                                                        color: CFColors.danger,
                                                                      )
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Row(
                                                              children: <Widget>[
                                                                Text('提现'),
                                                                typeTemp['if_extract'] == '1'
                                                                    ? Icon(
                                                                        Icons.check,
                                                                        color: CFColors.success,
                                                                      )
                                                                    : Icon(
                                                                        Icons.close,
                                                                        color: CFColors.danger,
                                                                      )
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Row(
                                                              children: <Widget>[
                                                                Text('转账'),
                                                                typeTemp['if_transfer'] == '1'
                                                                    ? Icon(
                                                                        Icons.check,
                                                                        color: CFColors.success,
                                                                      )
                                                                    : Icon(
                                                                        Icons.close,
                                                                        color: CFColors.danger,
                                                                      )
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                    break;
                                                  case 'option':
                                                    con = Wrap(
                                                      runSpacing: 10,
                                                      spacing: 10,
                                                      children: <Widget>[
                                                        Container(
                                                          height: 30,
                                                          child: PrimaryButton(
                                                            onPressed: () {
                                                              turnTo(item);
                                                            },
                                                            child: Text('修改'),
                                                          ),
                                                        ),
                                                        Container(
                                                          height: 30,
                                                          child: PrimaryButton(
                                                            onPressed: () {
                                                              delDialog(item);
                                                            },
                                                            child: Text('删除'),
                                                            type: 'error',
                                                          ),
                                                        )
                                                      ],
                                                    );
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
                                        }).toList(),
                                      )
                                    ],
                                  ),
                                );
                              }).toList(),
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
