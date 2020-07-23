import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/erp/payout_summary_detail.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/month_select_plugin.dart';
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

class PayoutSummary extends StatefulWidget {
  @override
  _PayoutSummaryState createState() => _PayoutSummaryState();
}

class _PayoutSummaryState extends State<PayoutSummary> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"currPage": 1, "pageCount": 15, 'group': '1'};
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  Map amount = {};
  Map group = {
    '1': '月份',
    '2': '季度',
    '3': '年份',
  };
  bool isExpandedFlag = true;
  List columns = [
    {'title': '工厂', 'key': 'shop_name'},
    {'title': '用户', 'key': 'user_name'},
    {'title': '数量(平方米)', 'key': 'payout_nums'},
    {'title': '金额(元)', 'key': 'payout_amount'},
    {'title': '统计时间', 'key': 'payout_month'},
    {'title': '操作', 'key': 'option'},
  ];

  void _onRefresh() {
    setState(() {
      param['currPage'] = 1;
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
    ajax('Adminrelas-ErpManage-getPayoutSummary', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'];
          amount = res['amount'];
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
    param['currPage'] += page;
    getData();
  }

  String defaultVal = 'all';

  Map selects = {
    // 	 	(平方米) 	(元)
    'all': '无',
    'shop_id': '工厂 升序',
    'shop_id desc': '工厂 降序',
    'user_id': '用户 升序',
    'user_id desc': '用户 降序',
    'payout_nums': '数量 升序',
    'payout_nums desc': '数量 降序',
    'payout_amount': '金额 升序',
    'payout_amount desc': '金额 降序',
    'payout_month': '统计时间 升序',
    'payout_month desc': '统计时间 降序',
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
    return Scaffold(
      appBar: AppBar(
        title: Text('拆单汇总'),
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
              firstChild: Placeholder(
                fallbackHeight: 0.1,
                color: Colors.transparent,
              ),
              secondChild: Column(children: <Widget>[
                Input(
                  label: '工厂',
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('shop_name');
                    } else {
                      param['shop_name'] = val;
                    }
                  },
                ),
                Input(
                  label: '用户',
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('user_name');
                    } else {
                      param['user_name'] = val;
                    }
                  },
                ),
                RangeInput(
                  label: '价格',
                  onChangeL: (val) {
                    if (val == '') {
                      param.remove('payout_amount_min');
                    } else {
                      param['payout_amount_min'] = val;
                    }
                  },
                  onChangeR: (val) {
                    if (val == '') {
                      param.remove('payout_amount_max');
                    } else {
                      param['payout_amount_max'] = val;
                    }
                  },
                ),
                Select(
                  selectOptions: group,
                  selectedValue: param['group'],
                  label: '卡状态:',
                  onChanged: (String newValue) {
                    setState(() {
                      param['group'] = newValue;
                    });
                  },
                ),
                MonthSelectPlugin(
                  onChanged: (val) {
                    if (val['min'] == null) {
                      param.remove('payout_month_min');
                    } else {
                      param['payout_month_min'] = val['min'].toString().substring(0, 7);
                    }
                    if (val['max'] == null) {
                      param.remove('payout_month_max');
                    } else {
                      param['payout_month_max'] = val['max'].toString().substring(0, 7);
                    }
                  },
                  label: '时间区间',
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
                  PrimaryButton(
                    onPressed: () {
                      param['currPage'] = 1;
                      getData();
                    },
                    child: Text('搜索'),
                  ),
                  PrimaryButton(
                    color: CFColors.success,
                    onPressed: () {
                      setState(() {
                        isExpandedFlag = !isExpandedFlag;
                      });
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text('${isExpandedFlag ? '展开' : '收缩'}选项'),
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
            amount.isEmpty
                ? Container()
                : Container(
                    margin: EdgeInsets.only(bottom: 6),
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 15,
                      runSpacing: 10,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '数量汇总：',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${amount['payout_nums']}平方米')
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '金额汇总：',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${amount['payout_amount']}元')
                          ],
                        )
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
                            children: ajaxData.map<Widget>(
                              (item) {
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
                                    children: columns.map<Widget>(
                                      (col) {
                                        Widget con = Text('${item[col['key']] ?? ''}');
                                        switch (col['key']) {
                                          case 'option':
                                            con = Wrap(
                                              runSpacing: 10,
                                              spacing: 10,
                                              children: <Widget>[
                                                PrimaryButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => PayoutSummaryDetail({'item': item}),
                                                      ),
                                                    );
                                                  },
                                                  child: Text('明细'),
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
                                                width: 100,
                                                alignment: Alignment.centerRight,
                                                child: Text('${col['title']}'),
                                                margin: EdgeInsets.only(right: 10),
                                              ),
                                              Expanded(flex: 1, child: con)
                                            ],
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                  ),
            Container(
              child: PagePlugin(
                current: param['currPage'],
                total: count,
                pageSize: param['pageCount'],
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
