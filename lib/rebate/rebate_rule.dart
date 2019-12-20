import 'dart:async';

import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RebateRule extends StatefulWidget {
  @override
  _RebateRuleState createState() => _RebateRuleState();
}

class _RebateRuleState extends State<RebateRule> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '', 'key': ''},
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
      loading = false;
    });

//    ajax('Adminrelas-goodsConfig-getAttrByClassID', {'param': jsonEncode(param)}, true, (res) {
//      if (mounted) {
//        setState(() {
//          loading = false;
//          ajaxData = res['data'] ?? [];
//          count = int.tryParse('${res['count'] ?? 0}');
//          toTop();
//        });
//        if (isRefresh) {
//          _refreshController.refreshCompleted();
//        }
//      }
//    }, () {
//      if (mounted) {
//        setState(() {
//          loading = false;
//        });
//      }
//    }, _context);
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
    param['curr_page'] += page;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('经销商规则'),
      ),
      body: SmartRefresher(
        enablePullDown: false,
        enablePullUp: false,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        // onLoading: _onLoading,
        child: ListView(
          controller: _controller,
          padding: EdgeInsets.all(10),
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 10),
              height: 34,
              child: Row(
                children: <Widget>[
                  Container(
                    width: 140,
                    alignment: Alignment.centerRight,
                    child: Text('最小充值金额(元)'),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      style: TextStyle(fontSize: CFFontSize.content),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: '${param['min_charge'] ?? ''}',
                          selection: TextSelection.fromPosition(
                            TextPosition(
                              affinity: TextAffinity.downstream,
                              offset: '${param['min_charge'] ?? ''}'.length,
                            ),
                          ),
                        ),
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.only(
                          top: 0,
                          bottom: 0,
                          left: 15,
                          right: 15,
                        ),
                      ),
                      onChanged: (String val) {
                        setState(() {
                          param['min_charge'] = val;
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
                    width: 140,
                    alignment: Alignment.centerRight,
                    child: Text('加价金额(元)'),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      style: TextStyle(fontSize: CFFontSize.content),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: '${param['plus_charge'] ?? ''}',
                          selection: TextSelection.fromPosition(
                            TextPosition(
                              affinity: TextAffinity.downstream,
                              offset: '${param['plus_charge'] ?? ''}'.length,
                            ),
                          ),
                        ),
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.only(
                          top: 0,
                          bottom: 0,
                          left: 15,
                          right: 15,
                        ),
                      ),
                      onChanged: (String val) {
                        setState(() {
                          param['plus_charge'] = val;
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 140,
                    height: 34,
                    alignment: Alignment.centerRight,
                    child: Text('最大充值金额(元)'),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 34,
                          child: TextField(
                            style: TextStyle(fontSize: CFFontSize.content),
                            controller: TextEditingController.fromValue(
                              TextEditingValue(
                                text: '${param['max_charge'] ?? ''}',
                                selection: TextSelection.fromPosition(
                                  TextPosition(
                                    affinity: TextAffinity.downstream,
                                    offset: '${param['max_charge'] ?? ''}'.length,
                                  ),
                                ),
                              ),
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.only(
                                top: 0,
                                bottom: 0,
                                left: 15,
                                right: 15,
                              ),
                            ),
                            onChanged: (String val) {
                              setState(() {
                                param['max_charge'] = val;
                              });
                            },
                          ),
                        ),
                        Text(
                          '最大充值金额 = 最小充值金额 + 加价金额 x n倍',
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 140,
                    height: 34,
                    alignment: Alignment.centerRight,
                    child: Text('每日封顶比例(%)'),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 34,
                          child: TextField(
                            style: TextStyle(fontSize: CFFontSize.content),
                            controller: TextEditingController.fromValue(
                              TextEditingValue(
                                text: '${param['day_limit'] ?? ''}',
                                selection: TextSelection.fromPosition(
                                  TextPosition(
                                    affinity: TextAffinity.downstream,
                                    offset: '${param['day_limit'] ?? ''}'.length,
                                  ),
                                ),
                              ),
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.only(
                                top: 0,
                                bottom: 0,
                                left: 15,
                                right: 15,
                              ),
                            ),
                            onChanged: (String val) {
                              setState(() {
                                param['day_limit'] = val;
                              });
                            },
                          ),
                        ),
                        Text(
                          '每日封顶比例大于等于0且小于等于100',
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Select(
              selectOptions: {'1': '是', '0': '否'},
              selectedValue: param['direct_minus'] ?? '1',
              label: '直接推荐人扣除',
              onChanged: (val) {
                setState(() {
                  param['direct_minus'] = val;
                });
              },
              labelWidth: 140,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              height: 34,
              child: Row(children: <Widget>[
                Container(
                  width: 140,
                  child: Text(''),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      PrimaryButton(
                        onPressed: () {},
                        child: Text('保存'),
                      )
                    ],
                  ),
                ),
              ]),
            )

//              Container(
//                child: PagePlugin(
//                    current: param['curr_page'], total: count, pageSize: param['page_count'], function: getPage,),
//              ),
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
