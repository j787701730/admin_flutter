import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
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

class AccountItem extends StatefulWidget {
  @override
  _AccountItemState createState() => _AccountItemState();
}

class _AccountItemState extends State<AccountItem> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '用户', 'key': 'login_name'},
    {'title': '出账状态', 'key': 'bill_state'},
    {'title': '总用户数', 'key': 'user_count'},
    {'title': '总费用', 'key': 'amount'},
    {'title': '出账说明', 'key': 'comments'},
    {'title': '创建时间', 'key': 'create_date'},
    {'title': '更新时间', 'key': 'update_date'},
  ];

  Map billState = {
    'all': "全部",
    '1': "出账成功",
    '0': "出账中",
    '-1': "出账失败",
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
    ajax('Adminrelas-Logs-billLogs', {'param': jsonEncode(param)}, true, (res) {
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

  getCreateDate(val) {
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

  getUpdateDate(val) {
    setState(() {
      if (val['min'] == null) {
        param.remove('update_date_min');
      } else {
        param['update_date_min'] = val['min'].toString().substring(0, 10);
      }

      if (val['max'] == null) {
        param.remove('update_date_max');
      } else {
        param['update_date_max'] = val['max'].toString().substring(0, 10);
      }
    });
  }

  getPage(page) {
    if (loading) return;
    param['curr_page'] = page;
    getData();
  }

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'user_id': '用户 升序',
    'user_id desc': '用户 降序',
    'bill_state': '出账状态 升序',
    'bill_state desc': '出账状态 降序',
    'user_count': '总用户数 升序',
    'user_count desc': '总用户数 降序',
    'amount': '总费用 升序',
    'amount desc': '总费用 降序',
    'comments': '出账说明 升序',
    'comments desc': '出账说明 降序',
    'create_date': '创建时间 升序',
    'create_date desc': '创建时间 降序',
    'update_date': '更新时间 升序',
    'update_date desc': '更新时间 降序',
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
        title: Text('出账日志'),
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
                Select(
                  selectOptions: billState,
                  selectedValue: param['bill_state'] ?? 'all',
                  label: '对账状态',
                  onChanged: (String newValue) {
                    if (newValue == 'all') {
                      param.remove('bill_state');
                    } else {
                      param['bill_state'] = newValue;
                    }
                  },
                ),
                DateSelectPlugin(
                  onChanged: getCreateDate,
                  label: '创建时间',
                ),
                DateSelectPlugin(
                  onChanged: getUpdateDate,
                  label: '更新时间',
                ),
                Select(
                  selectOptions: selects,
                  selectedValue: defaultVal,
                  label: '排序',
                  onChanged: orderBy,
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
                : ajaxData.isEmpty
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
                                children: columns.map<Widget>(
                                  (col) {
                                    Widget con = Text('${item[col['key']] ?? ''}');
                                    switch (col['key']) {
                                      case 'bill_state':
                                        con = Text('${billState[item['bill_state']]}');
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
                                  },
                                ).toList(),
                              ),
                            );
                          },
                        ).toList(),
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
      floatingActionButtonAnimator: ScalingAnimation(),
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(
        FloatingActionButtonLocation.endFloat,
        floatingActionButtonOffsetX,
        floatingActionButtonOffsetY,
      ),
    );
  }
}
