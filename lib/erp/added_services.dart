import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/balance/pricing_data.dart';
import 'package:admin_flutter/plugin/date_select_plugin.dart';
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

class AddedServices extends StatefulWidget {
  @override
  _AddedServicesState createState() => _AddedServicesState();
}

class _AddedServicesState extends State<AddedServices> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"currPage": 1, "pageCount": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '用户', 'key': 'user_name'},
    {'title': '工厂', 'key': 'shop_name'},
    {'title': '购买时间', 'key': 'payout_date'},
    {'title': '业务名称', 'key': 'pricing_class'},
    {'title': '购买月数(个)', 'key': 'payout_nums'},
    {'title': '购买费用(元)', 'key': 'payout_amount'},
    {'title': '生效时间', 'key': 'start_date'},
    {'title': '失效时间', 'key': 'end_date'},
  ];

  Map type = {
    '0': '全部',
    '3': '微信推送',
    '4': '生产执行',
    '5': '财务管理',
    '6': '仓库管理',
    '8': 'WEB开料',
    '9': 'WebCAD云盘',
    '11': '增值包(WebCAD)',
  };
  bool isExpandedFlag = true;

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
    ajax('Adminrelas-ErpManage-getAddedService', {'param': jsonEncode(param)}, true, (res) {
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
    param['currPage'] += page;
    getData();
  }

  getDateTime(val) {
    if (val['min'] == null) {
      param.remove('payout_date_min');
    } else {
      param['payout_date_min'] = '${val['min'].toString().substring(0, 10)} 00:00:00';
    }
    if (val['max'] == null) {
      param.remove('payout_date_max');
    } else {
      param['payout_date_max'] = '${val['max'].toString().substring(0, 10)} 23:59:59';
    }
  }

  getDateTime2(val) {
    if (val['min'] == null) {
      param.remove('start_date');
    } else {
      param['start_date'] = '${val['min'].toString().substring(0, 10)}';
    }
    if (val['max'] == null) {
      param.remove('end_date');
    } else {
      param['end_date'] = '${val['max'].toString().substring(0, 10)}';
    }
  }

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'user_name': '用户 升序',
    'user_name desc': '用户 降序',
    'shop_name': '工厂 升序',
    'shop_name desc': '工厂 降序',
    'payout_date': '购买时间 升序',
    'payout_date desc': '购买时间 降序',
    'class_ch_name': '业务名称 升序',
    'class_ch_name desc': '业务名称 降序',
    'payout_nums': '购买月数 升序',
    'payout_nums desc': '购买月数 降序',
    'payout_amount': '购买费用 升序',
    'payout_amount desc': '购买费用 降序',
    'start_date': '生效日期 升序',
    'start_date desc': '生效日期 降序',
    'end_date': '失效日期 升序',
    'end_date desc': '失效日期 降序',
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
        title: Text('增值服务'),
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
            AnimatedCrossFade(
              firstChild: Container(),
              secondChild: Column(
                children: <Widget>[
                  Input(
                    label: '用户',
                    onChanged: (String val) {
                      setState(() {
                        if (val == '') {
                          param.remove('user_name');
                        } else {
                          param['user_name'] = val;
                        }
                      });
                    },
                  ),
                  Input(
                    label: '工厂',
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
                  Select(
                    selectOptions: type,
                    selectedValue: param['pricing_class'] ?? '0',
                    label: '服务类型',
                    onChanged: (String newValue) {
                      setState(() {
                        if (newValue == '0') {
                          param.remove('pricing_class');
                        } else {
                          param['pricing_class'] = newValue;
                        }
                      });
                    },
                  ),
                  DateSelectPlugin(
                    onChanged: getDateTime,
                    label: '购买时间',
                  ),
                  DateSelectPlugin(
                    onChanged: getDateTime2,
                    label: '有效时间',
                  ),
                  Select(
                    selectOptions: selects,
                    selectedValue: defaultVal,
                    label: '排序',
                    onChanged: orderBy,
                  ),
                ],
              ),
              crossFadeState: isExpandedFlag ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: const Duration(
                milliseconds: 300,
              ),
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
                  PrimaryButton(
                    color: CFColors.success,
                    onPressed: () {
                      setState(() {
                        isExpandedFlag = !isExpandedFlag;
                      });
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
                                  border: Border.all(
                                    color: Color(0xffdddddd),
                                    width: 1,
                                  ),
                                ),
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: columns.map<Widget>((col) {
                                    Widget con = Text('${item[col['key']] ?? ''}');
                                    switch (col['key']) {
                                      case 'pricing_class':
                                        con = Text('${pricingClass[item['pricing_class']]['class_ch_name']}');
                                        break;
                                    }

                                    return Container(
                                      margin: EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            width: 110,
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
