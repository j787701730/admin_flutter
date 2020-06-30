import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/city_select_plugin.dart';
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

class ChargeSummary extends StatefulWidget {
  @override
  _ChargeSummaryState createState() => _ChargeSummaryState();
}

class _ChargeSummaryState extends State<ChargeSummary> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  bool isExpandedFlag = true;

  List columns = [
    {'title': '用户名', 'key': 'login_name'},
    {'title': '月', 'key': 'months'},
    {'title': '年', 'key': 'years'},
    {'title': '充值类型', 'key': 'charge_type'},
    {'title': '余额类型', 'key': 'balance_type'},
    {'title': '状态', 'key': 'state'},
    {'title': '总金额', 'key': 'amount'},
  ];

  Map cardState = {"-2": "全部"};
  Map balanceType = {'0': '全部'};
  Map chargeTypeRes = {'0': '全部'};
  Map constranctResult = {'-2': '全部'};

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
      getParamData();
      getData();
    });
  }

  getParamData() {
    ajax('Adminrelas-Api-chargeInParam', {}, true, (data) {
      if (mounted) {
        Map balanceTypeTemp = {};
        for (var o in data['balanceTypeRes'].keys.toList()) {
          balanceTypeTemp[o] = data['balanceTypeRes'][o]['balance_type_ch_name'];
        }

        Map chargeTypeResTemp = {};
        for (var o in data['chargeTypeRes']) {
          chargeTypeResTemp[o] = o['charge_type_ch_name'];
        }

        Map constranctResultTemp = {};
        for (var o in data['constranctResult']) {
          constranctResultTemp[o] = o;
        }
        setState(() {
          cardState.addAll(data['chargeInState']);
          balanceType.addAll(balanceTypeTemp);
          chargeTypeRes.addAll(chargeTypeResTemp);
          constranctResult.addAll(constranctResultTemp);
        });
      }
    }, () {}, _context);
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
    ajax(
        'Adminrelas-balance-ajaxChargeInCollect1',
        {
          'search': jsonEncode(param),
          'group': jsonEncode(["user_id", "months", "years", "charge_type", "balance_type", "state"])
        },
        true, (res) {
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
        title: Text('充值汇总'),
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
              secondChild: Column(
                children: <Widget>[
                  Input(
                    label: '用户名',
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
                    label: '外部流水',
                    onChanged: (String val) {
                      setState(() {
                        if (val == '') {
                          param.remove('ext_searial_id');
                        } else {
                          param['ext_searial_id'] = val;
                        }
                      });
                    },
                  ),
                  Select(
                    selectOptions: chargeTypeRes,
                    selectedValue: param['charge_type'] ?? '0',
                    label: '充值类型',
                    onChanged: (String newValue) {
                      setState(() {
                        if (newValue == '0') {
                          param.remove('charge_type');
                        } else {
                          param['charge_type'] = newValue;
                        }
                      });
                    },
                  ),
                  Select(
                    selectOptions: balanceType,
                    selectedValue: param['balance_type'] ?? '0',
                    label: '余额类型',
                    onChanged: (String newValue) {
                      setState(() {
                        if (newValue == '0') {
                          param.remove('balance_type');
                        } else {
                          param['balance_type'] = newValue;
                        }
                      });
                    },
                  ),
                  Select(
                    selectOptions: constranctResult,
                    selectedValue: param['constract_result'] ?? '-2',
                    label: '对账结果',
                    onChanged: (String newValue) {
                      setState(() {
                        if (newValue == '-2') {
                          param.remove('constract_result');
                        } else {
                          param['constract_result'] = newValue;
                        }
                      });
                    },
                  ),
                  Select(
                    selectOptions: cardState,
                    selectedValue: param['charge_state'] ?? '-2',
                    label: '充值状态',
                    onChanged: (String newValue) {
                      setState(() {
                        if (newValue == '0') {
                          param.remove('charge_state');
                        } else {
                          param['charge_state'] = newValue;
                        }
                      });
                    },
                  ),
                  DateSelectPlugin(
                    onChanged: (val) {
                      setState(() {
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
                      });
                    },
                    label: '创建时间',
                  ),
                  DateSelectPlugin(
                    onChanged: (val) {
                      setState(() {
                        if (val['min'] == null) {
                          param.remove('constract_dateL');
                        } else {
                          param['constract_dateL'] = val['min'].toString().substring(0, 10);
                        }
                        if (val['max'] == null) {
                          param.remove('constract_dateU');
                        } else {
                          param['constract_dateU'] = val['max'].toString().substring(0, 10);
                        }
                      });
                    },
                    label: '对账时间',
                  ),
                  CitySelectPlugin(
                    getArea: (val) {
                      param['city'] = {};
                      if (val['province'] == '0') {
                        param.remove('city');
                      } else {
                        param['city']['province'] = val['province'];
                      }
                      if (val['city'] != '0') {
                        param['city']['city'] = val['city'];
                      }
//                      if (val['region'] != '0') {
//                        param['city']['region'] = val['region'];
//                      }
                    },
                    label: '充值区域',
                    hiddenRegion: true,
                  )
                ],
              ),
              crossFadeState: isExpandedFlag ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            ),
            Container(
              child: Wrap(
                runSpacing: 10,
                spacing: 10,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  PrimaryButton(
                    onPressed: () {
                      param['curr_page'] = 1;
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
                                  border: Border.all(color: Color(0xffdddddd), width: 1),
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
