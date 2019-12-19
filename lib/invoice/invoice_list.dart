import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/invoice/Invoice_detail.dart';
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

class InvoiceList extends StatefulWidget {
  @override
  _InvoiceListState createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = false;

  List columns = [
    {'title': '用户', 'key': 'login_name'},
    {'title': '企业名称', 'key': 'shop_name'},
    {'title': '金额(元)', 'key': 'amount'},
    {'title': '申请时间', 'key': 'create_date'},
    {'title': '开票状态', 'key': 'invoice_state'},
    {'title': '开票时间', 'key': 'issue_date'},
    {'title': '开具人员', 'key': 'issue_user_name'},
    {'title': '备注', 'key': 'comments'},
    {'title': '操作', 'key': 'option'},
  ];

  Map invoiceState = {"all": '全部', "1": "待开发票", "2": "已开发票"};

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
      loading = true;
    });
    ajax('Adminrelas-Invoice-getlists', {'param': jsonEncode(param)}, true, (res) {
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
    param['curr_page'] += page;
    getData();
  }

  getDateTime(val) {
    if (val['min'] == null) {
      param.remove('create_date_min');
    } else {
      param['create_date_min'] = '${val['min'].toString().substring(0, 10)}';
    }
    if (val['max'] == null) {
      param.remove('create_date_max');
    } else {
      param['create_date_max'] = '${val['max'].toString().substring(0, 10)}';
    }
  }

  getDateTime2(val) {
    if (val['min'] == null) {
      param.remove('issue_date_min');
    } else {
      param['issue_date_min'] = '${val['min'].toString().substring(0, 10)} 00:00:00';
    }
    if (val['max'] == null) {
      param.remove('issue_date_max');
    } else {
      param['issue_date_max'] = '${val['max'].toString().substring(0, 10)} 23:59:59';
    }
  }

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'user_name': '用户 升序',
    'user_name desc': '用户 降序',
    'shop_name': '企业 升序',
    'shop_name desc': '企业 降序',
    'amount': '金额 升序',
    'amount desc': '金额 降序',
    'create_date': '申请时间 升序',
    'create_date desc': '申请时间 降序',
    'invoice_state': '开票状态 升序',
    'invoice_state desc': '开票状态 降序',
    'issue_date': '开票时间 升序',
    'issue_date desc': '开票时间 降序',
    'issue_user': '开具人员 升序',
    'issue_user desc': '开具人员 降序',
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
        title: Text('开票管理'),
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
                  param.remove('user_name');
                } else {
                  param['user_name'] = val;
                }
              },
            ),
            Input(
              label: '开具人员',
              onChanged: (String val) {
                if (val == '') {
                  param.remove('issue_user');
                } else {
                  param['issue_user'] = val;
                }
              },
            ),
            Select(
              selectOptions: invoiceState,
              selectedValue: param['invoice_state'] ?? 'all',
              label: '发票状态',
              onChanged: (val) {
                setState(() {
                  if (val == 'all') {
                    param.remove('invoice_state');
                  } else {
                    param['invoice_state'] = val;
                  }
                });
              },
            ),
            DateSelectPlugin(
              onChanged: getDateTime,
              label: '申请时间',
            ),
            DateSelectPlugin(
              onChanged: getDateTime2,
              label: '开具时间',
            ),
            RangeInput(
              label: '金额区间',
              onChangeL: (val) {
                if (val == '') {
                  param.remove('amount_min');
                } else {
                  param['amount_min'] = val;
                }
              },
              onChangeR: (val) {
                if (val == '') {
                  param.remove('amount_max');
                } else {
                  param['amount_max'] = val;
                }
              },
            ),
            Select(
              selectOptions: selects,
              selectedValue: defaultVal,
              label: '排序',
              onChanged: orderBy,
            ),
            Container(
              margin: EdgeInsets.only(
                bottom: 10,
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  SizedBox(
                    height: 30,
                    child: PrimaryButton(
                      onPressed: () {
                        param['curr_page'] = 1;
                        print(param);
                        getData();
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: Text('搜索'),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                bottom: 6,
              ),
              alignment: Alignment.centerRight,
              child: NumberBar(
                count: count,
              ),
            ),
            loading
                ? CupertinoActivityIndicator()
                : ajaxData.isEmpty
                    ? Container(
                        height: 40,
                        alignment: Alignment.center,
                        child: Text('无数据'),
                      )
                    : Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: ajaxData.map<Widget>(
                            (item) {
                              return Container(
                                decoration: BoxDecoration(border: Border.all(color: Color(0xffdddddd), width: 1)),
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.only(
                                  top: 5,
                                  bottom: 5,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: columns.map<Widget>(
                                    (col) {
                                      Widget con = Text('${item[col['key']] ?? ''}');
                                      switch (col['key']) {
                                        case 'invoice_state':
                                          con = Text(
                                            '${invoiceState[item['invoice_state']]}',
                                          );
                                          break;
                                        case 'option':
                                          con = Row(
                                            children: <Widget>[
                                              SizedBox(
                                                height: 30,
                                                child: PrimaryButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => InvoiceDetail({
                                                          'invoice_id': '${item['invoice_id']}',
                                                          'login_name': '${item['login_name']}',
                                                          'shop_name': '${item['shop_name']}',
                                                          'invoice_state': '${item['invoice_state']}',
                                                        }),
                                                      ),
                                                    );
                                                  },
                                                  child: Text(item['invoice_state'] == '1' ? '开票' : '查看'),
                                                ),
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
                                              child: Text('${col['title']}'),
                                              margin: EdgeInsets.only(right: 10),
                                            ),
                                            Expanded(flex: 1, child: con),
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
                current: param['curr_page'],
                total: count,
                pageSize: param['page_count'],
                function: getPage,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toTop,
        child: Icon(Icons.keyboard_arrow_up),
      ),
    );
  }
}
