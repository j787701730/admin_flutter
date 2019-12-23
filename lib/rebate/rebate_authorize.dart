import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RebateAuthorize extends StatefulWidget {
  @override
  _RebateAuthorizeState createState() => _RebateAuthorizeState();
}

class _RebateAuthorizeState extends State<RebateAuthorize> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '厂家名称', 'key': 'factory_name'},
    {'title': '厂家用户', 'key': 'opera_name'},
    {'title': '厂家手机', 'key': 'opera_phone'},
    {'title': '店铺名称', 'key': 'shop_name'},
    {'title': '店铺用户', 'key': 'login_name'},
    {'title': '店铺手机', 'key': 'user_phone'},
    {'title': '生效日期', 'key': 'start_date'},
    {'title': '失效日期', 'key': 'end_date'},
    {'title': '金额', 'key': 'payout_amount'},
    {'title': '操作时间', 'key': 'payout_date'},
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
      loading = true;
    });
    ajax('Adminrelas-RebateManage-authorizeList', {'param': jsonEncode(param)}, true, (res) {
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
    param['curr_page'] += page;
    getData();
  }

  getDateTime(val) {
    if (val['min'] == null) {
      param.remove('payout_timeL');
    } else {
      param['payout_timeL'] = val['min'].toString().substring(0, 10);
    }
    if (val['max'] == null) {
      param.remove('payout_timeR');
    } else {
      param['payout_timeR'] = val['max'].toString().substring(0, 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('门店授权'),
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
            Input(
              label: '厂家名称',
              onChanged: (String val) {
                setState(() {
                  if (val == '') {
                    param.remove('factory_name');
                  } else {
                    param['factory_name'] = val;
                  }
                });
              },
            ),
            Input(
              label: '厂家手机',
              onChanged: (String val) {
                setState(() {
                  if (val == '') {
                    param.remove('opera_phone');
                  } else {
                    param['opera_phone'] = val;
                  }
                });
              },
            ),
            Input(
              label: '店铺名称',
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
            Input(
              label: '店铺手机',
              onChanged: (String val) {
                setState(() {
                  if (val == '') {
                    param.remove('user_phone');
                  } else {
                    param['user_phone'] = val;
                  }
                });
              },
            ),
            DateSelectPlugin(onChanged: getDateTime, label: '操作时间'),
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
                        param['curr_page'] = 1;
                        getData();
                        FocusScope.of(context).requestFocus(FocusNode());
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
                                  border: Border.all(color: Color(0xffdddddd), ),
                                ),
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: columns.map<Widget>((col) {
                                    Widget con = Text('${item[col['key']] ?? ''}');
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
