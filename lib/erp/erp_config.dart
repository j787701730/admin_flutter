import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/erp/erp_config_modify.dart';
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

class ErpConfig extends StatefulWidget {
  @override
  _ErpConfigState createState() => _ErpConfigState();
}

class _ErpConfigState extends State<ErpConfig> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  bool isExpandedFlag = true;
  List columns = [
    {'title': '店铺名称', 'key': 'shop_name'},
    {'title': '电话号码', 'key': 'user_phone'},
    {'title': '平台盈利', 'key': 'plat_rate'},
    {'title': '在线支付', 'key': 'pay_online'},
    {'title': '订单折扣率', 'key': 'order_disrate'},
    {'title': '订单收入提现率', 'key': 'order_extrate'},
    {'title': '返红包率下限', 'key': 'return_rate_lower'},
    {'title': '返红包率上限', 'key': 'return_rate_upper'},
    {'title': '创建时间', 'key': 'create_date'},
    {'title': '更新时间', 'key': 'update_date'},
    {'title': '备注', 'key': 'comments'},
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
      loading = true;
    });
    ajax('Adminrelas-ErpManage-getErpConfig', {'param': jsonEncode(param)}, true, (res) {
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

  delDialog(item) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context1, state) {
          return AlertDialog(
            title: Text(
              '信息',
              style: TextStyle(fontSize: CFFontSize.topTitle),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    '确认删除 ${item['shop_name']} ERP配置?',
                    style: TextStyle(fontSize: CFFontSize.content),
                  )
                ],
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
                color: Colors.blue,
                textColor: Colors.white,
                child: Text('确认'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }); //
      },
    );
  }

  getDateTime(val) {
    setState(() {
      if (val['min'] == null) {
        param.remove('create_date_l');
      } else {
        param['create_date_l'] = val['min'].toString().substring(0, 10);
      }
      if (val['max'] == null) {
        param.remove('create_date_r');
      } else {
        param['create_date_r'] = val['max'].toString().substring(0, 10);
      }
    });
  }

  getDateTime2(val) {
    setState(() {
      if (val['min'] == null) {
        param.remove('update_date_l');
      } else {
        param['update_date_l'] = val['min'].toString().substring(0, 10);
      }
      if (val['max'] == null) {
        param.remove('update_date_r');
      } else {
        param['update_date_r'] = val['max'].toString().substring(0, 10);
      }
    });
  }

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'plat_rate': '平台盈利 升序',
    'plat_rate desc': '平台盈利 降序',
    'pay_online': '在线支付 升序',
    'pay_online desc': '在线支付 降序',
    'order_disrate': '订单折扣率 升序',
    'order_disrate desc': '订单折扣率 降序',
    'order_extrate': '订单收入提现率 升序',
    'order_extrate desc': '订单收入提现率 降序',
    'return_rate_lower': '返红包率下限 升序',
    'return_rate_lower desc': '返红包率下限 降序',
    'return_rate_upper': '返红包率上限 升序',
    'return_rate_upper desc': '返红包率上限 降序',
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

  turnTo(val) {
    Navigator.push(
      _context,
      MaterialPageRoute(builder: (context) => ErpConfigModify(val)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ERP配置'),
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
              duration: const Duration(
                milliseconds: 300,
              ),
              firstChild: Container(),
              secondChild: Column(children: <Widget>[
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
                  label: '电话号码',
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
                DateSelectPlugin(
                  onChanged: getDateTime,
                  label: '创建时间',
                ),
                DateSelectPlugin(
                  onChanged: getDateTime2,
                  label: '更新时间',
                ),
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
                  SizedBox(
                    height: 30,
                    child: PrimaryButton(
                      onPressed: () {
                        turnTo(null);
                      },
                      child: Text('新增'),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: PrimaryButton(
                      color: CFColors.success,
                      onPressed: () {
                        setState(() {
                          isExpandedFlag = !isExpandedFlag;
                        });
                      },
                      child: Text('${isExpandedFlag ? '展开' : '收缩'}选项'),
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
                                  border: Border.all(color: Color(0xffdddddd), width: 1),
                                ),
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: columns.map<Widget>((col) {
                                    Widget con = Text('${item[col['key']] ?? ''}');
                                    switch (col['key']) {
                                      case 'pay_online':
                                        con = '${item[col['key']]}' == '1' ? Text('是') : Text('否');
                                        break;
                                      case 'option':
                                        con = Wrap(
                                          runSpacing: 10,
                                          spacing: 10,
                                          children: <Widget>[
                                            Container(
                                              height: 30,
                                              child: PrimaryButton(
                                                onPressed: () {
                                                  turnTo(item);
                                                },
                                                child: Text('修改'),
                                              ),
                                            ),
                                            Container(
                                              height: 30,
                                              child: PrimaryButton(
                                                type: 'error',
                                                onPressed: () {
                                                  delDialog(item);
                                                },
                                                child: Text('删除'),
                                              ),
                                            )
                                          ],
                                        );
                                        break;
                                    }
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            width: 130,
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
