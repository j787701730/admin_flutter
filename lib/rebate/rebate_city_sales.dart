import 'dart:async';
import 'dart:convert';

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

class RebateCitySales extends StatefulWidget {
  @override
  _RebateCitySalesState createState() => _RebateCitySalesState();
}

class _RebateCitySalesState extends State<RebateCitySales> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  bool isExpandedFlag = true;
  List columns = [
    {'title': '用户名', 'key': 'login_name'},
    {'title': '联系人', 'key': 'user_name'},
    {'title': '联系电话', 'key': 'user_phone'},
    {'title': '联系地址', 'key': 'user_address'},
    {'title': '分销省份', 'key': 'sales_province_name'},
    {'title': '分销城市', 'key': 'sales_city_name'},
    {'title': '状态', 'key': 'state'},
    {'title': '创建时间', 'key': 'create_date'},
    {'title': '审核时间', 'key': 'update_date'},
    {'title': '审核描述', 'key': 'audit_content'},
    {'title': '操作', 'key': 'option'},
  ];
  Map state = {
    "all": "全部",
    "-1": "审核失败",
    "0": "待审核",
    "1": "审核通过",
  };

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
      selectSales.clear();
    });
    ajax('Adminrelas-CitySales-ajaxGetList', {'param': jsonEncode(param)}, true, (res) {
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
    if (loading) return;
    param['curr_page'] += page;
    getData();
  }

  List selectSales = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('城市分销'),
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
                  label: '联系人',
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('user_name');
                    } else {
                      param['user_name'] = val;
                    }
                  },
                ),
                Input(
                  label: '联系电话',
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('user_phone');
                    } else {
                      param['user_phone'] = val;
                    }
                  },
                ),
                Select(
                  selectOptions: state,
                  selectedValue: param['state'] ?? 'all',
                  label: '状态',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('state');
                    } else {
                      param['state'] = val;
                    }
                  },
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
                      param['curr_page'] = 1;
                      getData();
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text('搜索'),
                  ),
                  PrimaryButton(
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text('通过'),
                  ),
                  PrimaryButton(
                    color: CFColors.secondary,
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text('待审核'),
                  ),
                  PrimaryButton(
                    type: 'error',
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text('不通过'),
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
                            children: ajaxData.map<Widget>((item) {
                              return Stack(
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xffdddddd),
                                      ),
                                    ),
                                    margin: EdgeInsets.only(bottom: 10),
                                    padding: EdgeInsets.only(top: 5, bottom: 5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: columns.map<Widget>((col) {
                                        Widget con = Text('${item[col['key']] ?? ''}');
                                        switch (col['key']) {
                                          case 'state':
                                            con = Text('${state[item['state']]}');
                                            break;
                                          case 'option':
                                            con = Wrap(
                                              runSpacing: 10,
                                              spacing: 10,
                                              children: <Widget>[
                                                PrimaryButton(
                                                  onPressed: () {},
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
                                                width: 90,
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
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: Checkbox(
                                      value: selectSales.contains(item['sales_id']),
                                      onChanged: (val) {
                                        setState(() {
                                          if (selectSales.contains(item['sales_id'])) {
                                            selectSales.remove(item['sales_id']);
                                          } else {
                                            selectSales.add(item['sales_id']);
                                          }
                                        });
                                      },
                                    ),
                                  )
                                ],
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
    );
  }
}
