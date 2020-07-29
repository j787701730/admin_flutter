import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/balance/price_plan.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 定价计划
class BalancePricing extends StatefulWidget {
  BalancePricing();

  @override
  _BalancePricingState createState() => _BalancePricingState();
}

class _BalancePricingState extends State<BalancePricing> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"currPage": 1, "pageCount": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = false;
  Map pricingStrategy = {};
  Map unit = {};
  Map pricingClass = {};
  Map adminInfo = {};

  List columns = [
    {'title': '用户ID', 'key': 'user_id'},
    {'title': '用户名', 'key': 'login_name'},
    {'title': '手机号', 'key': 'user_phone'},
    {'title': '店铺名', 'key': 'shop_name'},
    {'title': '扣费类型', 'key': 'pricing_class'},
    {'title': '计费方式', 'key': 'pricing_strategy_id'},
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
      getParamData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getParamData() {
    ajax('Adminrelas-Api-pricePlanData', {}, true, (data) {
      if (mounted) {
        setState(() {
          pricingClass = data['pricingClass'];
          unit = data['princingUnit'];
          pricingStrategy = data['template'];
          adminInfo = data['adminInfo'];
          getData();
        });
      }
    }, () {}, _context);
  }

  getData({isRefresh: false}) {
    setState(() {
      loading = true;
    });
    ajax('Adminrelas-Balance-pricePlanUser', {'data': jsonEncode(param)}, true, (res) {
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
      duration: Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  getPage(page) {
    if (loading) return;
    param['currPage'] = page;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('定价计划'),
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
                if (val == '') {
                  param.remove('login_name');
                } else {
                  param['login_name'] = val;
                }
              },
            ),
            Input(
              label: '手机',
              onChanged: (String val) {
                if (val == '') {
                  param.remove('user_phone');
                } else {
                  param['user_phone'] = val;
                }
              },
            ),
            Wrap(
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PricePlan(null)),
                    );
                  },
                  child: Text('添加新用户定价计划'),
                ),
              ],
            ),
            Container(
              height: 15,
            ),
            loading
                ? CupertinoActivityIndicator()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: ajaxData.map<Widget>((item) {
                      return Container(
                        padding: EdgeInsets.only(
                          top: 5,
                          bottom: 5,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xffdddddd), width: 1),
                        ),
                        margin: EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: columns.map<Widget>((col) {
                            Widget con = Text('${item[col['key']] ?? ''}');
                            switch (col['key']) {
                              case 'pricing_class':
                                con = Text(
                                    '${pricingClass[item[col['key']]] == null ? '' : pricingClass[item[col['key']]]['class_ch_name']}');
                                break;
                              case 'pricing_strategy_id':
                                con = Text(
                                  '${pricingStrategy[item[col['key']]] == null ? '' : pricingStrategy[item[col['key']]]['ch_name']}',
                                );
                                break;
                              case 'option':
                                con = Wrap(
                                  spacing: 10,
                                  children: <Widget>[
                                    PrimaryButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PricePlan(
                                              {
                                                'item': {
                                                  'login_name': '${item['login_name']}',
                                                  'pricing_id': '${item['pricing_id']}'
                                                }
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text('修改'),
                                    ),
                                    PrimaryButton(
                                      onPressed: () {
                                        showDialog<void>(
                                          context: _context,
                                          barrierDismissible: false, // user must tap button!
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              contentPadding: EdgeInsets.all(10),
                                              titlePadding: EdgeInsets.all(10),
                                              title: Text(
                                                '系统提示',
                                              ),
                                              content: SingleChildScrollView(
                                                child: ListBody(
                                                  children: <Widget>[
                                                    Text(
                                                      '确定删除 ${item['login_name']} 的定价计划?',
                                                      style: TextStyle(fontSize: CFFontSize.content),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text('取消'),
                                                  color: Colors.white,
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                FlatButton(
                                                  color: Colors.blue,
                                                  textColor: Colors.white,
                                                  child: Text('确定'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
//                                                      ajax('Adminrelas-Balance-balanceCheck', balanceCheckParam, true, (
//                                                          data) {
//
//                                                      }, () {}, _context);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
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
                                    child: Text('${col['title']}:'),
                                    margin: EdgeInsets.only(right: 6),
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
      floatingActionButtonAnimator: ScalingAnimation(),
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(
        FloatingActionButtonLocation.endFloat,
        floatingActionButtonOffsetX,
        floatingActionButtonOffsetY,
      ),
    );
  }
}
