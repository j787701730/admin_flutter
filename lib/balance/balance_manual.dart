import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/search-bar-plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BalanceManual extends StatefulWidget {
  @override
  _BalanceManualState createState() => _BalanceManualState();
}

class _BalanceManualState extends State<BalanceManual> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '用户', 'key': 'login_name'},
    {'title': '余额类型', 'key': 'balance_type_name'},
    {'title': '调账类型', 'key': 'manual_type'},
    {'title': '调账金额', 'key': 'amount'},
    {'title': '调账时间', 'key': 'oper_time'},
    {'title': '操作者', 'key': 'full_name'},
    {'title': '备注', 'key': 'oper_reason'},
  ];

  Map manualType = {'0': '全部', '1': '调增', '2': '调减'};
  Map balanceType = {
    '0': '全部',
    '1': '商城现金',
    '2': '商城红包',
    '3': '云端计费',
    '4': '云端计费-赠送',
    '5': '经销商',
    '6': '丰收贷',
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
    });
    ajax('Adminrelas-Balance-ajaxManualList', {'param': jsonEncode(param)}, true, (res) {
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
    param['curr_page'] += page;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('手工帐'),
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
            SearchBarPlugin(
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
                  label: '操作者',
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('full_name');
                    } else {
                      param['full_name'] = val;
                    }
                  },
                ),
                Select(
                  selectOptions: balanceType,
                  selectedValue: param['balance_type_id'] ?? '0',
                  label: '余额类型:',
                  onChanged: (String newValue) {
                    if (newValue == '0') {
                      param.remove('balance_type_id');
                    } else {
                      param['balance_type_id'] = newValue;
                    }
                  },
                ),
                Select(
                  selectOptions: manualType,
                  selectedValue: param['manual_type'] ?? '0',
                  label: '调账类型:',
                  onChanged: (String newValue) {
                    if (newValue == '0') {
                      param.remove('manual_type');
                    } else {
                      param['manual_type'] = newValue;
                    }
                  },
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
                    },
                    child: Text('搜索'),
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: 10),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 6),
              alignment: Alignment.centerRight,
              child: NumberBar(
                count: count,
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
                                    border: Border.all(color: Color(0xffdddddd), width: 1),
                                  ),
                                  margin: EdgeInsets.only(bottom: 10),
                                  padding: EdgeInsets.only(top: 5, bottom: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: columns.map<Widget>((col) {
                                      Widget con = Text('${item[col['key']] ?? ''}');
                                      switch (col['key']) {
                                        case 'manual_type':
                                          con = '${item[col['key']]}' == '1'
                                              ? Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.add,
                                                      color: Colors.red,
                                                      size: 22,
                                                    ),
                                                    Text('调增')
                                                  ],
                                                )
                                              : Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.remove,
                                                      color: Colors.green,
                                                      size: 22,
                                                    ),
                                                    Text('调减')
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
                              },
                            ).toList(),
                          ),
                  ),
            Container(
              child: PagePlugin(
                current: param['curr_page'],
                total: count,
                pageSize: param['page_count'],
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
