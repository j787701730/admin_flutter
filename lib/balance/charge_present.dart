import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/balance/charge_present_modify.dart';
import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ChargePresent extends StatefulWidget {
  @override
  _ChargePresentState createState() => _ChargePresentState();
}

class _ChargePresentState extends State<ChargePresent> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  bool isExpandedFlag = true;

  Map balanceType = {"all": '全部', "1": "商城现金", "3": "云端计费", "5": "经销商"};

  Map chargeType = {"all": '全部', "2": "支付宝", "3": "微信"};

  Map presentType = {"all": '全部', "1": "满x送x", "2": "按比例送"};

  Map userType = {"all": '全部', "1": "买家", "2": "卖家"};

  Map presentBalance = {"all": '全部', "2": "商城红包", "4": "云端计费-赠送", "6": "丰收贷"};

  List columns = [
    {'title': '账本类型', 'key': 'balance_type'},
    {'title': '用户类型', 'key': 'user_type'},
    {'title': '充值类型', 'key': 'charge_type'},
    {'title': '赠送类型', 'key': 'present_type'},
    {'title': '赠送账本类型', 'key': 'present_balance_type'},
    {'title': '规则名', 'key': 'rule_name'},
    {'title': '充值上限', 'key': 'charge_limit'},
    {'title': '赠送额度', 'key': 'present_value'},
    {'title': '生效时间', 'key': 'eff_date'},
    {'title': '失效时间', 'key': 'exp_date'},
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
    ajax('Adminrelas-balance-presentRules', {'param': jsonEncode(param)}, true, (res) {
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
      param.remove('eff_date');
    } else {
      param['eff_date'] = '${val['min'].toString().substring(0, 10)} 00:00:00';
    }
    if (val['max'] == null) {
      param.remove('exp_date');
    } else {
      param['exp_date'] = '${val['max'].toString().substring(0, 10)} 23:59:59';
    }
  }

  turnTo(item) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (context) => ChargePresentModify(item),
      ),
    );
  }

  delDialog(data) {
    return showDialog<void>(
      context: context,
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
                '确认删除 ${data['rule_name']} 赠送规则?',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('充值赠送'),
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
              firstChild: Container(),
              secondChild: Column(children: <Widget>[
                Select(
                  labelWidth: 100,
                  selectOptions: balanceType,
                  selectedValue: param['balance_type'] ?? 'all',
                  label: '账本类型',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('balance_type');
                    } else {
                      param['balance_type'] = val;
                    }
                  },
                ),
                Select(
                  labelWidth: 100,
                  selectOptions: chargeType,
                  selectedValue: param['charge_type'] ?? 'all',
                  label: '充值类型',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('charge_type');
                    } else {
                      param['charge_type'] = val;
                    }
                  },
                ),
                Select(
                  labelWidth: 100,
                  selectOptions: userType,
                  selectedValue: param['user_type'] ?? 'all',
                  label: '用户类型',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('user_type');
                    } else {
                      param['user_type'] = val;
                    }
                  },
                ),
                Select(
                  labelWidth: 100,
                  selectOptions: presentType,
                  selectedValue: param['present_type'] ?? 'all',
                  label: '赠送类型',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('present_type');
                    } else {
                      param['present_type'] = val;
                    }
                  },
                ),
                Select(
                  labelWidth: 100,
                  selectOptions: presentBalance,
                  selectedValue: param['present_balance_type'] ?? 'all',
                  label: '赠送账本类型',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('present_balance_type');
                    } else {
                      param['present_balance_type'] = val;
                    }
                  },
                ),
                DateSelectPlugin(
                  onChanged: getDateTime,
                  label: '有效时间',
                  labelWidth: 100,
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
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: Text('添加规则'),
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
                                  border: Border.all(
                                color: Color(0xffdddddd),
                              )),
                              margin: EdgeInsets.only(bottom: 10),
                              padding: EdgeInsets.only(top: 5, bottom: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: columns.map<Widget>((col) {
                                  Widget con = Text('${item[col['key']] ?? ''}');
                                  switch (col['key']) {
                                    case 'balance_type':
                                      con = Text('${balanceType[item['balance_type']]}');
                                      break;
                                    case 'user_type':
                                      con = Text('${userType[item['user_type']]}');
                                      break;
                                    case 'charge_type':
                                      con = Text('${chargeType[item['charge_type']]}');
                                      break;
                                    case 'present_type':
                                      con = Text('${presentType[item['present_type']]}');
                                      break;
                                    case 'present_balance_type':
                                      con = Text('${presentBalance[item['present_balance_type']]}');
                                      break;
                                    case 'comments':
                                      con = Container(
                                        child: Html(data: '${item['comments'] ?? ''}'),
                                      );
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
                                              onPressed: () {
                                                delDialog(item);
                                              },
                                              child: Text('删除'),
                                              type: "error",
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
                                          width: 120,
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
    );
  }
}
