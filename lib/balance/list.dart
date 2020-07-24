import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/balance/balance_manual_opera.dart';
import 'package:admin_flutter/balance/balance_detail.dart';
import 'package:admin_flutter/balance/balance_redbag_detail.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/range_input.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BalanceList extends StatefulWidget {
  @override
  _BalanceListState createState() => _BalanceListState();
}

class _BalanceListState extends State<BalanceList> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  Map ajaxData = {};
  int count = 0;
  Map balanceCheckParam = {'userId': '', 'acctBalanceID': ''};
  bool loading = false;
  bool isExpandedFlag = true;

  void _onRefresh() {
    setState(() {
      param['curr_page'] = 1;
      getData(isRefresh: true);
    });
  }

  List columns = [
    {'title': '余额类型', 'key': 'balance_type_ch_name'},
    {'title': '可用', 'key': 'amount'},
    {'title': '预占金额', 'key': 'pre_amount'},
    {'title': '状态', 'key': 'state'},
    {'title': '生效日期', 'key': 'eff_date'},
    {'title': '失效日期', 'key': 'exp_date'},
    {'title': '创建日期', 'key': 'create_date'},
    {'title': '更新日期', 'key': 'update_date'},
    {'title': '稽核结果', 'key': 'balance_check_name'},
    {'title': '稽核时间', 'key': 'check_time'},
    {'title': '资金操作', 'key': 'if_charge'},
    {'title': '操作', 'key': 'option'},
  ];
  Map balanceType = {'0': '全部'};
  Map state = {
    'all': '全部',
    '1': '在用',
    '0': '停用',
  };
  Map balanceCheckOptions = {"all": "全部"};

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

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getParamData() {
    ajax('Adminrelas-Api-flowData', {}, true, (data) {
      if (mounted) {
        Map balanceTypeTemp = {};
        for (var o in data['balanceType']) {
          balanceTypeTemp[o['balance_type_id']] = o['balance_type_ch_name'];
        }
        Map balanceCheck = {};
        for (var i = 0; i < data['balanceCheck'].length; ++i) {
          balanceCheck['$i'] = data['balanceCheck'][i];
        }

        setState(() {
          balanceType.addAll(balanceTypeTemp);
          balanceCheckOptions.addAll(balanceCheck);
        });
      }
    }, () {}, _context);
  }

  getData({isRefresh: false}) {
    setState(() {
      loading = true;
    });
    ajax('Adminrelas-Balance-getFlow', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          ajaxData = res['data'].isEmpty ? {} : res['data'];
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
      duration: new Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  getPage(page) {
    if (loading) return;
    param['curr_page'] += page;
    getData();
  }

  balanceCheck() {
    showDialog<void>(
      context: _context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '系统提示',
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '确定稽核?',
                  style: TextStyle(fontSize: CFFontSize.content),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
//                ajax('Adminrelas-Balance-balanceCheck', balanceCheckParam, true, (data) {
//
//                }, () {}, _context);
//
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
      MaterialPageRoute(builder: (context) => BalanceManualOpera(val)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('资金账本'),
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
              firstChild: Placeholder(
                fallbackHeight: 0.1,
                color: Colors.transparent,
              ),
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
                Input(
                  label: '手机',
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('user_phone');
                    } else {
                      param['user_phone'] = val;
                    }
                  },
                ),
                Select(
                  selectOptions: balanceType,
                  selectedValue: param['balance_type_id'] ?? '0',
                  label: '余额类型',
                  onChanged: (String newValue) {
                    if (newValue == '0') {
                      param.remove('balance_type_id');
                    } else {
                      param['balance_type_id'] = newValue;
                    }
                  },
                ),
                Select(
                  selectOptions: state,
                  selectedValue: param['state'] ?? 'all',
                  label: '状态',
                  onChanged: (String newValue) {
                    if (newValue == 'all') {
                      param.remove('state');
                    } else {
                      param['state'] = newValue;
                    }
                  },
                ),
                Select(
                  selectOptions: balanceCheckOptions,
                  selectedValue: param['balance_check'] ?? 'all',
                  label: '稽核结果',
                  onChanged: (String newValue) {
                    if (newValue == 'all') {
                      param.remove('balance_check');
                    } else {
                      param['balance_check'] = newValue;
                    }
                  },
                ),
                RangeInput(
                  label: '余额范围',
                  onChangeL: (val) {
                    if (val == '') {
                      param.remove('amountL');
                    } else {
                      param['amountL'] = val;
                    }
                  },
                  onChangeR: (val) {
                    if (val == '') {
                      param.remove('amountU');
                    } else {
                      param['amountU'] = val;
                    }
                  },
                ),
                RangeInput(
                  label: '预占金额',
                  onChangeL: (val) {
                    if (val == '') {
                      param.remove('pre_amountL');
                    } else {
                      param['pre_amountL'] = val;
                    }
                  },
                  onChangeR: (val) {
                    if (val == '') {
                      param.remove('pre_amountU');
                    } else {
                      param['pre_amountU'] = val;
                    }
                  },
                ),
              ]),
              crossFadeState: isExpandedFlag ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                PrimaryButton(
                  onPressed: () {
                    param['curr_page'] = 1;
                    getData();
                  },
                  child: Text('搜索'),
                ),
                PrimaryButton(
                  color: Colors.green,
                  onPressed: () {
                    setState(() {
                      balanceCheckParam = {'userId': '0', 'acctBalanceID': '0'};
                      balanceCheck();
                    });
                  },
                  child: Text('全量稽核'),
                ),
                PrimaryButton(
                  onPressed: () {
                    turnTo(null);
                  },
                  child: Text('新用户手工账'),
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
            Container(
              height: 12,
            ),
            loading
                ? CupertinoActivityIndicator()
                : ajaxData.isEmpty
                    ? Container(
                        height: 40,
                        child: Text('无数据'),
                        alignment: Alignment.center,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: ajaxData.keys.toList().map<Widget>(
                          (key) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(bottom: 6),
                                    child: Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 10,
                                      children: <Widget>[
                                        Text('用户: ${ajaxData[key]['login_name']}(${ajaxData[key]['user_phone']})'),
                                        PrimaryButton(
                                          onPressed: () {
                                            setState(() {
                                              balanceCheckParam = {'userId': '$key', 'acctBalanceID': '0'};
                                              balanceCheck();
                                            });
                                          },
                                          child: Text(
                                            '用户稽核',
                                          ),
                                        ),
                                        PrimaryButton(
                                          onPressed: () {
                                            Map data = {
                                              'user': {
                                                '$key': {
                                                  'user_id': '$key',
                                                  'login_name': '${ajaxData[key]['login_name']}',
                                                }
                                              },
                                              'manualType': '5',
                                              'manualState': '1',
                                              'manualTypeFlag': true
                                            };
                                            turnTo(data);
                                          },
                                          child: Text(
                                            '手工账',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top: 6, left: 6, right: 6),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Color(0xffdddddd), width: 1),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: ajaxData[key]['acctRes'].map<Widget>(
                                        (item) {
                                          return Container(
                                            padding: EdgeInsets.only(top: 10),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Color(0xffeeeeee), width: 1),
                                            ),
                                            margin: EdgeInsets.only(bottom: 6),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: columns.map<Widget>(
                                                (col) {
                                                  Widget con = Text('${item[col['key']] ?? ''}');
                                                  switch (col['key']) {
                                                    case 'state':
                                                      con = '${item[col['key']]}' == '1' ? Text('在用') : Text('停用');
                                                      break;
                                                    case 'if_charge':
                                                      con = Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            flex: 1,
                                                            child: Row(
                                                              children: <Widget>[
                                                                Text('充值:'),
                                                                '${item['if_charge']}' == '1'
                                                                    ? Icon(
                                                                        Icons.close,
                                                                        color: Colors.red,
                                                                      )
                                                                    : Icon(
                                                                        Icons.check,
                                                                        color: Colors.green,
                                                                      ),
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Row(
                                                              children: <Widget>[
                                                                Text('提取:'),
                                                                '${item['if_extract']}' == '1'
                                                                    ? Icon(
                                                                        Icons.close,
                                                                        color: Colors.red,
                                                                      )
                                                                    : Icon(
                                                                        Icons.check,
                                                                        color: Colors.green,
                                                                      ),
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Row(
                                                              children: <Widget>[
                                                                Text('转账:'),
                                                                '${item['if_transfer']}' == '1'
                                                                    ? Icon(
                                                                        Icons.close,
                                                                        color: Colors.red,
                                                                      )
                                                                    : Icon(
                                                                        Icons.check,
                                                                        color: Colors.green,
                                                                      ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      );
                                                      break;
                                                    case 'option':
                                                      EdgeInsets pad = EdgeInsets.only(left: 6, right: 6);
                                                      if ('${item['balance_type_id']}' != '2') {
                                                        con = Wrap(
                                                          runSpacing: 6,
                                                          spacing: 6,
                                                          children: <Widget>[
                                                            PrimaryButton(
                                                              onPressed: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => BalanceDetail({
                                                                      'login_name': '${ajaxData[key]['login_name']}',
                                                                      'balance_type_ch_name':
                                                                          '${item['balance_type_ch_name']}',
                                                                      'acct_balance_id': '${item['acct_balance_id']}',
                                                                    }),
                                                                  ),
                                                                );
                                                              },
                                                              child: Text('查看'),
                                                              padding: pad,
                                                            ),
                                                            PrimaryButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  balanceCheckParam = {
                                                                    'userId': '$key',
                                                                    'acctBalanceID': '${item['acct_balance_id']}'
                                                                  };
                                                                  balanceCheck();
                                                                });
                                                              },
                                                              padding: pad,
                                                              child: Text('稽核'),
                                                            ),
                                                            '${item['balance_type_id']}' != '6'
                                                                ? PrimaryButton(
                                                                    onPressed: () {
                                                                      Map data = {
                                                                        'user': {
                                                                          '$key': {
                                                                            'user_id': '$key',
                                                                            'login_name':
                                                                                '${ajaxData[key]['login_name']}',
                                                                          }
                                                                        },
                                                                        'manualType': '${item['balance_type_id']}',
                                                                        'manualState': '1'
                                                                      };
                                                                      Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              BalanceManualOpera(data),
                                                                        ),
                                                                      );
                                                                    },
                                                                    padding: pad,
                                                                    child: Text('手工帐调增'),
                                                                  )
                                                                : Container(
                                                                    width: 0,
                                                                  ),
                                                            '${item['balance_type_id']}' != '6'
                                                                ? PrimaryButton(
                                                                    onPressed: () {
                                                                      Map data = {
                                                                        'user': {
                                                                          '$key': {
                                                                            'user_id': '$key',
                                                                            'login_name':
                                                                                '${ajaxData[key]['login_name']}'
                                                                          },
                                                                        },
                                                                        'manualType': '${item['balance_type_id']}',
                                                                        'manualState': '2'
                                                                      };
                                                                      Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              BalanceManualOpera(data),
                                                                        ),
                                                                      );
                                                                    },
                                                                    padding: pad,
                                                                    child: Text('手工帐调减'),
                                                                  )
                                                                : Container(
                                                                    width: 0,
                                                                  )
                                                          ],
                                                        );
                                                      } else {
                                                        con = Row(
                                                          children: <Widget>[
                                                            PrimaryButton(
                                                              onPressed: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => BalanceRedBagDetail(
                                                                      {'item': item},
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              padding: pad,
                                                              child: Text('详情'),
                                                            )
                                                          ],
                                                        );
                                                      }
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
                                  ),
                                ],
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
