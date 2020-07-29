import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/financial/financial_loan_modify.dart';
import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/range_input.dart';
import 'package:admin_flutter/plugin/search-bar-plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FinancialLoan extends StatefulWidget {
  @override
  _FinancialLoanState createState() => _FinancialLoanState();
}

class _FinancialLoanState extends State<FinancialLoan> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  Map stat = {};
  bool loading = true;

  List columns = [
    {'title': '店铺', 'key': 'shop_name'},
    {'title': '电话号码', 'key': 'user_phone'},
    {'title': '金融额度', 'key': 'amount'},
    {'title': '好行为', 'key': 'good_value'},
    {'title': '坏行为', 'key': 'bad_value'},
    {'title': '信用分', 'key': 'credit_score'},
    {'title': '金融状态', 'key': 'state_ch'},
    {'title': '申请说明', 'key': 'apply_desc'},
    {'title': '审核人', 'key': 'audit_user'},
    {'title': '审核时间', 'key': 'audit_date'},
    {'title': '创建时间', 'key': 'create_date'},
    {'title': '更新时间', 'key': 'update_date'},
    {'title': '操作', 'key': 'option'},
  ];

  Map state = {'all': '全部', '1': '审核中', '2': '审核失败', '3': '审核通过', '4': '已冻结', '5': '已关闭'};

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
      getData();
    });
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
    ajax('Adminrelas-financialLoan-getFinancialLoanData', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'] ?? [];
          stat = res['stat'] ?? {};
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
    param['curr_page'] = page;
    getData();
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

  getDateTime2(val) {
    setState(() {
      if (val['min'] == null) {
        param.remove('audit_date_l');
      } else {
        param['audit_date_l'] = val['min'].toString().substring(0, 10);
      }
      if (val['max'] == null) {
        param.remove('audit_date_r');
      } else {
        param['audit_date_r'] = val['max'].toString().substring(0, 10);
      }
    });
  }

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'amount': '金融额度 升序',
    'amount desc': '金融额度 降序',
    'good_value': '好行为 升序',
    'good_value desc': '好行为 降序',
    'bad_value': '坏行为 升序',
    'bad_value desc': '坏行为 降序',
    'credit_score': '信用分 升序',
    'credit_score desc': '信用分 降序',
    'state': '金融状态 升序',
    'state desc': '金融状态 降序',
    'audit_date': '审核时间 升序',
    'audit_date desc': '审核时间 降序',
    'create_date': '创建时间 升序',
    'create_date desc': '创建时间 降序',
    'update_date': '更新时间 升序',
    'update_date desc': '更新时间 降序',
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

  turnTo(val) {
    Navigator.push(
      _context,
      MaterialPageRoute(builder: (context) => FinancialLoanModify(val)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('丰收贷'),
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
            SearchBarPlugin(
              secondChild: Column(children: <Widget>[
                Input(
                  label: '店铺',
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
                  label: '状态',
                  selectOptions: state,
                  selectedValue: param['state'] ?? 'all',
                  onChanged: (String newValue) {
                    if (newValue == 'all') {
                      param.remove('state');
                    } else {
                      param['state'] = newValue;
                    }
                  },
                ),
                RangeInput(
                  label: '金融额度',
                  onChangeL: (String val) {
                    if (val == '') {
                      param.remove('amount_l');
                    } else {
                      param['amount_l'] = val;
                    }
                  },
                  onChangeR: (String val) {
                    if (val == '') {
                      param.remove('amount_r');
                    } else {
                      param['amount_r'] = val;
                    }
                  },
                ),
                RangeInput(
                  label: '信用分',
                  onChangeL: (String val) {
                    if (val == '') {
                      param.remove('credit_score_l');
                    } else {
                      param['credit_score_l'] = val;
                    }
                  },
                  onChangeR: (String val) {
                    if (val == '') {
                      param.remove('credit_score_r');
                    } else {
                      param['credit_score_r'] = val;
                    }
                  },
                ),
                DateSelectPlugin(
                  onChanged: getDateTime,
                  label: '创建时间',
                ),
                DateSelectPlugin(
                  onChanged: getDateTime2,
                  label: '审核时间',
                ),
                Select(
                  selectOptions: selects,
                  selectedValue: defaultVal,
                  label: '排序',
                  onChanged: orderBy,
                ),
              ]),
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
                      turnTo(null);
                    },
                    child: Text('创建丰收贷'),
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
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      stat.isEmpty
                          ? Container(
                              width: 0,
                            )
                          : Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: <Widget>[
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        '营业收入: ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text('${stat['in_amount']}元')
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        '红包支出: ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text('${stat['out_amount']}元')
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        '平台盈利: ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text('${stat['earn_amount']}元')
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        '红包盈余: ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text('${stat['use_amount']}元')
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        '支付笔数: ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text('${stat['pay_count']}元')
                                    ],
                                  ),
                                ],
                              ),
                            ),
                      ajaxData.isEmpty
                          ? Container(
                              alignment: Alignment.center,
                              child: Text('无数据'),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: ajaxData.map<Widget>((item) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey, width: 1),
                                  ),
                                  margin: EdgeInsets.only(bottom: 10),
                                  padding: EdgeInsets.only(top: 5, bottom: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: columns.map<Widget>((col) {
                                      Widget con = Text('${item[col['key']] ?? ''}');
                                      switch (col['key']) {
                                        case 'option':
                                          con = Wrap(
                                            runSpacing: 10,
                                            spacing: 10,
                                            children: <Widget>[
                                              PrimaryButton(
                                                onPressed: () {
                                                  turnTo({'item': item});
                                                },
                                                child: Text('修改'),
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
                            ),
                    ],
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
    );
  }
}
