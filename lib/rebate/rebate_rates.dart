import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/range_input.dart';
import 'package:admin_flutter/plugin/search-bar-plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/rebate/rebate_rates_modify.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RebateRates extends StatefulWidget {
  @override
  _RebateRatesState createState() => _RebateRatesState();
}

class _RebateRatesState extends State<RebateRates> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '用户名', 'key': 'login_name'},
    {'title': '返利类型', 'key': 'type_ch_name'},
    {'title': '返还账本', 'key': 'balance_type_ch_name'},
    {'title': '直接返利', 'key': 'direct_rate'},
    {'title': '间接返利', 'key': 'indirect_rate'},
    {'title': '保证金返还', 'key': 'return_rate'},
    {'title': '创建时间', 'key': 'create_date'},
    {'title': '操作', 'key': 'option'},
  ];
  Map type = {
    "all": "全部",
    "1": "商品推荐返利",
    "2": "店铺注册返利",
    "3": "月基本费返利",
    "4": "流量计费返利",
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
    ajax('Adminrelas-RebateManage-getRateList', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'] ?? [];
          count = int.tryParse('${res['serialCount'] ?? 0}');
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

  getDateTime(val) {
    if (val['min'] == null) {
      param.remove('create_dateL');
    } else {
      param['create_dateL'] = val['min'].toString().substring(0, 10);
    }
    if (val['max'] == null) {
      param.remove('create_dateU');
    } else {
      param['create_dateU'] = val['max'].toString().substring(0, 10);
    }
  }

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'rate_id': '用户名 升序',
    'rate_id desc': '用户名 降序',
    'type_ch_name': '返利类型 升序',
    'type_ch_name desc': '返利类型 降序',
    'balance_type': '返还账本 升序',
    'balance_type desc': '返还账本 降序',
    'direct_rate': '直接返利 升序',
    'direct_rate desc': '直接返利 降序',
    'indirect_rate': '间接返利 升序',
    'indirect_rate desc': '间接返利 降序',
    'return_rate': '保证金返还 升序',
    'return_rate desc': '保证金返还 降序',
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

  delDialog(data) {
    return showDialog<void>(
      context: _context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '信息',
          ),
          content: SingleChildScrollView(
            child: Container(
//                width: MediaQuery.of(context).size.width - 100,
              child: Text(
                '确认删除 ${data['login_name']} 返利信息?',
                style: TextStyle(fontSize: CFFontSize.content),
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
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('提交'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  turnTo(val) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (context) => RebateRatesModify(val),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('返利比例'),
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
              secondChild: Column(
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
                  Select(
                    selectOptions: type,
                    selectedValue: param['rebate_type'] ?? 'all',
                    label: '返利类型',
                    onChanged: (val) {
                      if (val == 'all') {
                        param.remove('rebate_type');
                      } else {
                        param['rebate_type'] = val;
                      }
                    },
                  ),
                  RangeInput(
                    label: '直接返利',
                    onChangeL: (val) {
                      if (val == '') {
                        param.remove('direct_rate_min');
                      } else {
                        param['direct_rate_min'] = val;
                      }
                    },
                    onChangeR: (val) {
                      if (val == '') {
                        param.remove('direct_rate_max');
                      } else {
                        param['direct_rate_max'] = val;
                      }
                    },
                  ),
                  RangeInput(
                    label: '间接返利',
                    onChangeL: (val) {
                      if (val == '') {
                        param.remove('invite_rate_min');
                      } else {
                        param['invite_rate_min'] = val;
                      }
                    },
                    onChangeR: (val) {
                      if (val == '') {
                        param.remove('invite_rate_max');
                      } else {
                        param['invite_rate_max'] = val;
                      }
                    },
                  ),
                  DateSelectPlugin(
                    onChanged: getDateTime,
                    label: '创建时间',
                  ),
                  Select(
                    selectOptions: selects,
                    selectedValue: defaultVal,
                    label: '排序',
                    onChanged: orderBy,
                  ),
                ],
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
                      param['curr_page'] = 1;
                      getData();
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text('搜索'),
                  ),
                  PrimaryButton(
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      turnTo(null);
                    },
                    child: Text('添加返利比例'),
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
                                  ),
                                ),
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: columns.map<Widget>((col) {
                                    Widget con = Text('${item[col['key']] ?? ''}');
                                    switch (col['key']) {
                                      case 'option':
                                        con = Wrap(
                                          runSpacing: 10,
                                          spacing: 10,
                                          children: <Widget>[
                                            PrimaryButton(
                                              onPressed: () {
                                                turnTo(item);
                                              },
                                              child: Text('修改'),
                                            ),
                                            PrimaryButton(
                                              type: BtnType.danger,
                                              onPressed: () {
                                                delDialog(item);
                                              },
                                              child: Text('删除'),
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
                                            width: 100,
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
