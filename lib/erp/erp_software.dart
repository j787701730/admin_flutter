import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/balance/pricing_data.dart';
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

class ErpSoftware extends StatefulWidget {
  @override
  _ErpSoftwareState createState() => _ErpSoftwareState();
}

class _ErpSoftwareState extends State<ErpSoftware> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"currPage": 1, "pageCount": 15, "class_id": 1};
  List ajaxData = [];
  int count = 0;
  bool loading = false;

  List columns = [
    {'title': '用户', 'key': 'user_name'},
    {'title': '工厂', 'key': 'shop_name'},
    {'title': '购买时间', 'key': 'payout_date'},
    {'title': '业务名称', 'key': 'pricing_class'},
    {'title': '购买月数', 'key': 'payout_nums'},
    {'title': '购买费用', 'key': 'payout_amount'},
    {'title': '生效日期', 'key': 'start_date'},
    {'title': '失效日期', 'key': 'end_date'},
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
          ajaxData = res['data'];
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
    'all': '无',
    'user_name': '用户 升序',
    'user_name desc': '用户 降序',
    'shop_name': '工厂 升序',
    'shop_name desc': '工厂 降序',
    'payout_date': '购买时间 升序',
    'payout_date desc': '购买时间 降序',
    'class_ch_name': '业务名称 升序',
    'class_ch_name desc': '业务名称 降序',
    'payout_nums': '购买月数 升序',
    'payout_nums desc': '购买月数 降序',
    'payout_amount': '购买费用 升序',
    'payout_amount desc': '购买费用 降序',
    'start_date': '生效日期 升序',
    'start_date desc': '生效日期 降序',
    'end_date': '失效日期 升序',
    'end_date desc': '失效日期 降序',
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
        title: Text('软件包月'),
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
              label: '用户名',
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
              label: '时间区间',
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
                ? CupertinoActivityIndicator()
                : Container(
                    child: Column(
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
                              switch (col['key']) {
                                case 'payout_nums':
                                  con = Text('${item['payout_nums']}个月');
                                  break;
                                case 'payout_amount':
                                  con = Text('${item['payout_amount']}元');
                                  break;
                                case 'pricing_class':
                                  con = Text('${pricingClass[item['pricing_class']]['class_ch_name']}');
                                  break;
                              }

                              return Container(
                                margin: EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: 90,
                                      alignment: Alignment.centerRight,
                                      child: Text('${col['title']}:'),
                                      margin: EdgeInsets.only(right: 8),
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
