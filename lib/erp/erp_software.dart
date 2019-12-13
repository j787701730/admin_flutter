import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/balance/pricing_data.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
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
                      param['loginName'] = val;
                    });
                  }),
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
                  ? CupertinoActivityIndicator()
                  : Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: ajaxData.map<Widget>((item) {
                          return Container(
                              decoration: BoxDecoration(border: Border.all(color: Color(0xffdddddd), width: 1)),
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
                              ));
                        }).toList(),
                      ),
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
