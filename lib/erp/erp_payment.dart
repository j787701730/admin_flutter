import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/search-bar-plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ErpPayment extends StatefulWidget {
  @override
  _ErpPaymentState createState() => _ErpPaymentState();
}

class _ErpPaymentState extends State<ErpPayment> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '订单编号', 'key': 'order_no'},
    {'title': '店铺名称', 'key': 'shop_name'},
    {'title': '收款人', 'key': 'login_name'},
    {'title': '收款金额', 'key': 'amount'},
    {'title': '收款时间', 'key': 'payment_time'},
    {'title': '创建时间', 'key': 'create_date'},
    {'title': '备注', 'key': 'comments'},
  ];

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
    ajax('Adminrelas-ErpManage-ajaxPaymentList', {'param': jsonEncode(param)}, true, (res) {
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
    param['curr_page'] = page;
    getData();
  }

  dialog(shopName) {
    return showDialog<void>(
      context: _context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '参数解析',
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(_context).size.width - 100,
                  child: Column(
                    children: jsonDecode(shopName).keys.map<Widget>((key) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 5),
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              width: 120,
                              alignment: Alignment.centerRight,
                              child: Text(
                                '$key:',
                                style: TextStyle(fontSize: CFFontSize.content),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${jsonDecode(shopName)[key]}',
                                style: TextStyle(fontSize: CFFontSize.content),
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('关闭'),
              onPressed: () {
                Navigator.of(_context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  getCreateDate(val) {
    if (val['min'] != null) {
      param['create_dateL'] = val['min'].toString().substring(0, 10);
    } else {
      param.remove('create_dateL');
    }
    if (val['max'] != null) {
      param['create_dateU'] = val['max'].toString().substring(0, 10);
    } else {
      param.remove('create_dateU');
    }
  }

  getPaymentDate(val) {
    if (val['min'] != null) {
      param['payment_timeL'] = val['min'].toString().substring(0, 10);
    } else {
      param.remove('payment_timeL');
    }
    if (val['max'] != null) {
      param['payment_timeU'] = val['max'].toString().substring(0, 10);
    } else {
      param.remove('payment_timeU');
    }
  }

  Map searchInputs = {
    'order_no': '订单编号',
    'shop_name': '店铺名称',
    'login_name': '收款人',
  };

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'order_no': '订单编号 升序',
    'order_no desc': '订单编号 降序',
    'shop_name': '店铺名称 升序',
    'shop_name desc': '店铺名称 降序',
    'login_name': '收款人 升序',
    'login_name desc': '收款人 降序',
    'amount': '收款金额 升序',
    'amount desc': '收款金额 降序',
    'payment_time': '收款时间 升序',
    'payment_time desc': '收款时间 降序',
    'create_date': '创建时间 升序',
    'create_date desc': '创建时间 降序',
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
        title: Text('收款记录'),
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
                Column(
                  children: searchInputs.keys.toList().map<Widget>((item) {
                    return Input(
                      label: '${searchInputs[item]}',
                      onChanged: (String val) {
                        if (val == '') {
                          param.remove('$item');
                        } else {
                          param['$item'] = val;
                        }
                      },
                    );
                  }).toList(),
                ),
                DateSelectPlugin(
                  onChanged: getCreateDate,
                  label: '收款时间',
                ),
                DateSelectPlugin(
                  onChanged: getPaymentDate,
                  label: '创建时间',
                ),
                Select(selectOptions: selects, selectedValue: defaultVal, label: '排序', onChanged: orderBy),
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
                                      case 'shop_name':
                                        con = '${item[col['key']] ?? ''}' == ''
                                            ? Text('')
                                            : InkWell(
                                                onTap: () {
                                                  dialog(item['shop_name']);
                                                },
                                                child: Text(
                                                  '${item[col['key']] ?? ''}',
                                                  style: TextStyle(color: CFColors.primary),
                                                ),
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
