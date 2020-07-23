import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ErpOrders extends StatefulWidget {
  @override
  _ErpOrdersState createState() => _ErpOrdersState();
}

class _ErpOrdersState extends State<ErpOrders> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15, 'get_amount': 1};
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  bool isExpandedFlag = true;
  List columns = [
    {'title': '订单号', 'key': 'order_no'},
    {'title': '店铺名称', 'key': 'shop_name'},
    {'title': '订单类型', 'key': 'order_type'},
    {'title': '订单状态', 'key': 'order_state'},
    {'title': '创建时间', 'key': 'create_date'},
  ];

  Map orderType = {
    "1": {"type_id": "1", "type_en_name": "ERP_ORDER_TYPE_PRODUCE", "type_ch_name": "柜体订单", "comments": null},
    "2": {"type_id": "2", "type_en_name": "ERP_ORDER_TYPE_SALES", "type_ch_name": "销售订单", "comments": null},
    "3": {"type_id": "3", "type_en_name": "ERP_ORDER_TYPE_DESIGN", "type_ch_name": "设计订单", "comments": null},
    "4": {"type_id": "4", "type_en_name": "ERP_ORDER_TYPE_INSTALL", "type_ch_name": "安装订单", "comments": null},
    "5": {"type_id": "5", "type_en_name": "ERP_ORDER_TYPE_SUPPLY", "type_ch_name": "供货订单", "comments": null}
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
    ajax('Adminrelas-ErpManage-orderList', {'param': jsonEncode(param)}, true, (res) {
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

  String defaultVal = 'all';

  Map selects = {
    //
    'all': '无',
    'order_no': '订单号 升序',
    'order_no desc': '订单号 降序',
    'shop_name': '店铺名称 升序',
    'shop_name desc': '店铺名称 降序',
    'order_type': '订单类型 升序',
    'order_type desc': '订单类型 降序',
    'order_state': '订单状态 升序',
    'order_state desc': '订单状态 降序',
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

  getDateTime(val) {
    setState(() {
      if (val['min'] == null) {
        param.remove('create_date_min');
      } else {
        param['create_date_min'] = val['min'].toString().substring(0, 10);
      }
      if (val['max'] == null) {
        param.remove('create_date_max');
      } else {
        param['create_date_max'] = val['max'].toString().substring(0, 10);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ERP订单'),
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
                  label: '订单编号',
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
                  label: '门店名称',
                  onChanged: (String val) {
                    setState(() {
                      if (val == '') {
                        param.remove('store_name');
                      } else {
                        param['store_name'] = val;
                      }
                    });
                  },
                ),
                DateSelectPlugin(onChanged: getDateTime, label: '创建时间'),
                Select(
                  selectOptions: selects,
                  selectedValue: defaultVal,
                  label: '排序',
                  onChanged: orderBy,
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
                                      case 'order_type':
                                        con = Text('${orderType[item['order_type']]['type_ch_name']}');
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
