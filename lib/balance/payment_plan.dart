import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/balance/payment_plan_modify.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  Map paymentMethod = {"all": '全部'};
  Map planType = {};
  Map balanceType = {};

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
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getParamData() {
    ajax('Adminrelas-Api-paymentPlan', {}, true, (data) {
      if (mounted) {
        Map paymentMethodTemp = {};
        for (var o in data['payment_method'].keys.toList()) {
          paymentMethodTemp[o] = data['payment_method'][o]['payment_method_ch_name'];
        }
        setState(() {
          paymentMethod.addAll(paymentMethodTemp);
          planType = data['plan_type'];
          balanceType = data['balance_type'];
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
    }, () {}, _context);
  }

  getData({isRefresh: false}) {
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
    param['curr_page'] = page;
    getData();
  }

  turnTo(data) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (context) => PaymentPlanModify(data),
      ),
    ).then((value) {
      if (value == true) {
        getData();
      }
    });
  }

  delDialog(data) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '提示',
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
                ajax('adminrelas-Balance-payMentPlansDel', {'payment_plan_id': data['payment_plan_id']}, true, (data) {
                  getData();
                  Navigator.of(context).pop();
                }, () {}, _context);
              },
            ),
          ],
        );
      },
    );
  }

  Map planTypeModify;

  addAndModifyDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '修改支付方案类型',
          ),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width - 100,
              child: Column(
                children: <Widget>[
                  Input(
                    label: '中文名字',
                    onChanged: (val) {
                      planTypeModify['type_ch_name'] = val;
                    },
                    value: planTypeModify['type_ch_name'] ?? '',
                  ),
                  Input(
                    label: '英文名字',
                    onChanged: (val) {
                      planTypeModify['type_en_name'] = val;
                    },
                    value: planTypeModify['type_en_name'] ?? '',
                  ),
                  Input(
                    label: '描述',
                    onChanged: (val) {
                      planTypeModify['comments'] = val;
                    },
                    value: planTypeModify['comments'] ?? '',
                    maxLines: 4,
                    marginTop: 4.0,
                  ),
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
                bool flag = true;
                List msg = [];
                if (planTypeModify['type_ch_name'] == null || planTypeModify['type_ch_name'].trim() == '') {
                  flag = false;
                  msg.add('中文名称');
                }
                if (planTypeModify['type_en_name'] == null || planTypeModify['type_en_name'].trim() == '') {
                  flag = false;
                  msg.add('英文名称');
                }
                String url = 'adminrelas-Balance-addPaymentPlanType';
                if (planTypeModify['type_id'] != null) {
                  url = 'adminrelas-Balance-alterPaymentPlanType';
                }
                if (flag) {
                  ajax(
                    url,
                    {'data': jsonEncode(planTypeModify)},
                    true,
                    (data) {
                      Navigator.of(context).pop();
                    },
                    () {},
                    _context,
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: '请填写 ${msg.join(', ')}',
                    gravity: ToastGravity.CENTER,
                  );
                }
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
                  PrimaryButton(
                    onPressed: () {
                      param['curr_page'] = 1;
                      getData();
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text('搜索'),
                  ),
                  PrimaryButton(
                    onPressed: () {
                      planTypeModify = {};
                      addAndModifyDialog();
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text('添加支付方案类型'),
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
                                            '支付方案：',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text('${data['name']} '),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                turnTo(null);
                                              });
                                            },
                                            child: Container(
                                              child: Icon(
                                                Icons.add,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                planTypeModify = {
                                                  'type_ch_name': '${data['name']}',
                                                  'type_en_name':
                                                      '${planType[data['payment_plan_type']]['type_en_name']}',
                                                  'comments': '${planType[data['payment_plan_type']]['comments']}',
                                                  'type_id': '${data['payment_plan_type']}',
                                                };
                                                addAndModifyDialog();
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
                                                      PrimaryButton(
                                                        onPressed: () {
                                                          turnTo(item);
                                                        },
                                                        child: Text('修改'),
                                                      ),
                                                      PrimaryButton(
                                                        onPressed: () {
                                                          delDialog(item);
                                                        },
                                                        child: Text('删除'),
                                                        type: BtnType.danger,
                                                      ),
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
                current: param['curr_page'],
                total: count,
                pageSize: param['page_count'],
                function: getPage,
              ),
            ),
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
