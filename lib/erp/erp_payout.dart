import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/range_input.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ErpPayout extends StatefulWidget {
  @override
  _ErpPayoutState createState() => _ErpPayoutState();
}

class _ErpPayoutState extends State<ErpPayout> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"currPage": 1, "pageCount": 15, 'class_id': 2};
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  List columns = [
    {'title': '订单号', 'key': 'order_no'},
    {'title': '工厂', 'key': 'shop_name'},
    {'title': '用户', 'key': 'user_name'},
    {'title': '数量(平方米)', 'key': 'payout_nums'},
    {'title': '金额(元)', 'key': 'payout_amount'},
    {'title': '付款日期', 'key': 'payout_date'},
  ];

  void _onRefresh() async {
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

  getData({isRefresh: false}) async {
    setState(() {
      loading = true;
    });
    ajax('Adminrelas-ErpManage-getPayOutSerial', {'param': jsonEncode(param)}, true, (res) {
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
    param['currPage'] += page;
    getData();
  }

  getDateTime(val) {
    if (val['min'] == null) {
      param.remove('payout_date_min');
    } else {
      param['payout_date_min'] = '${val['min'].toString().substring(0, 10)} 00:00:00';
    }
    if (val['max'] == null) {
      param.remove('payout_date_max');
    } else {
      param['payout_date_max'] = '${val['max'].toString().substring(0, 10)} 23:59:59';
    }
  }

  String defaultVal = 'all';

  Map selects = {
    // 	 	 	(平方米) 	(元)
    'all': '无',
    'order_no': '订单号 升序',
    'order_no desc': '订单号 降序',
    'shop_name': '工厂 升序',
    'shop_name desc': '工厂 降序',
    'user_id': '用户 升序',
    'user_id desc': '用户 降序',
    'payout_nums': '数量 升序',
    'payout_nums desc': '数量 降序',
    'payout_amount': '金额 升序',
    'payout_amount desc': '金额 降序',
    'payout_date': '付款日期 升序',
    'payout_date desc': '付款日期 降序',
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
        title: Text('拆单流水'),
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
              Input(
                label: '订单号',
                onChanged: (String val) {
                  setState(() {
                    if (val == '') {
                      param.remove('order_no');
                    } else {
                      param['order_no'] = val;
                    }
                  });
                },
              ),
              Input(
                label: '工厂',
                onChanged: (String val) {
                  setState(() {
                    if (val == '') {
                      param.remove('shop_name');
                    } else {
                      param['shop_name'] = val;
                    }
                  });
                },
              ),
              Input(
                label: '用户',
                onChanged: (String val) {
                  setState(() {
                    if (val == '') {
                      param.remove('user_name');
                    } else {
                      param['user_name'] = val;
                    }
                  });
                },
              ),
              RangeInput(
                label: '价格',
                onChangeL: (val) {
                  setState(() {
                    if (val == '') {
                      param.remove('payout_amount_min');
                    } else {
                      param['payout_amount_min'] = val;
                    }
                  });
                },
                onChangeR: (val) {
                  setState(() {
                    if (val == '') {
                      param.remove('payout_amount_max');
                    } else {
                      param['payout_amount_max'] = val;
                    }
                  });
                },
              ),
              DateSelectPlugin(
                onChanged: getDateTime,
                label: '付款时间',
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
                          param['currPage'] = 1;
                          getData();
                        },
                        child: Text('搜索'),
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
                  : ajaxData.isEmpty
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
                                  children: columns.map<Widget>(
                                    (col) {
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
                                    },
                                  ).toList(),
                                ),
                              );
                            },
                          ).toList(),
                        ),
              Container(
                child: PagePlugin(
                    current: param['currPage'], total: count, pageSize: param['pageCount'], function: getPage),
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
