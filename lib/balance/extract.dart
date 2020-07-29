import 'dart:async';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input-single.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BalanceExtract extends StatefulWidget {
  @override
  _BalanceExtractState createState() => _BalanceExtractState();
}

class _BalanceExtractState extends State<BalanceExtract> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"currPage": 1, "pageCount": 15, 'state': 'all', 'bank': '1'};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '申请时间', 'key': 'create_date'},
    {'title': '用户名', 'key': 'login_name'},
    {'title': '交易账号', 'key': 'account_nbr'},
    {'title': '账户类型', 'key': 'deposit'},
    {'title': '账户名字', 'key': 'account_name'},
    {'title': '金额', 'key': 'amount'},
    {'title': '备注', 'key': 'comments'},
    {'title': '状态', 'key': 's'},
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
    ajax('Adminrelas-Balance-withdrawList', param, true, (res) {
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
    param['currPage'] = page;
    getData();
  }

  getDateTime(val) {
    setState(() {
      if (val['min'] == null) {
        param.remove('effdata');
      } else {
        param['effdata'] = val['min'].toString().substring(0, 10);
      }

      if (val['max'] == null) {
        param.remove('expdata');
      } else {
        param['expdata'] = val['max'].toString().substring(0, 10);
      }
    });
  }

  transferQuery(item) {
    ajax('Adminrelas-Balance-transferQuery', {'serial_id': item['serial_id']}, true, (res) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              '信息',
            ),
            content: Container(
              width: MediaQuery.of(context).size.width - 100,
              child: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      '转账时间: ',
                      style: TextStyle(fontSize: CFFontSize.content),
                    ),
                    Text(
                      '${res['pay_date']}',
                      style: TextStyle(fontSize: CFFontSize.content),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('关闭'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }, () {}, _context);
  }

  String comments = '';

  model(type, item) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '确定${type == '1' ? '' : ' 取消'} ${item['login_name']} 提现?',
          ),
          content: Container(
            width: MediaQuery.of(context).size.width - 100,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  InputSingle(
                    onChanged: (val) {
                      comments = val;
                    },
                    value: '${comments ?? ''}',
                  )
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
              child: Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
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
        title: Text('提现管理'),
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
                    param.remove('login_name');
                  } else {
                    param['login_name'] = val;
                  }
                });
              },
            ),
            DateSelectPlugin(
              onChanged: getDateTime,
              label: '申请时间',
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
                              return Container(
                                  decoration: BoxDecoration(border: Border.all(color: Color(0xffdddddd), width: 1)),
                                  margin: EdgeInsets.only(bottom: 10),
                                  padding: EdgeInsets.only(top: 5, bottom: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: columns.map<Widget>((col) {
                                      Widget con = Text('${item[col['key']] ?? ''}');
                                      switch (col['key']) {
                                        case 'option':
                                          if (item['state'] == "1") {
                                            con = Wrap(
                                              spacing: 10,
                                              children: <Widget>[
                                                PrimaryButton(
                                                  onPressed: () {
                                                    model('0', item);
                                                  },
                                                  child: Text('取消'),
                                                ),
                                                PrimaryButton(
                                                  onPressed: () {
                                                    model('1', item);
                                                  },
                                                  child: Text('确认'),
                                                ),
                                              ],
                                            );
                                          } else if (item['state'] == "2") {
                                            con = Wrap(
                                              children: <Widget>[
                                                PrimaryButton(
                                                  onPressed: () {
                                                    transferQuery(item);
                                                  },
                                                  child: Text('查看'),
                                                ),
                                              ],
                                            );
                                          } else {
                                            con = Container(
                                              width: 0,
                                            );
                                          }
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
                                  ));
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
