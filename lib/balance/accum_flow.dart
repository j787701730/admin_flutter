import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/balance/accum_flow_detail.dart';
import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/range_input.dart';
import 'package:admin_flutter/plugin/search-bar-plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AccumulateFlow extends StatefulWidget {
  @override
  _AccumulateFlowState createState() => _AccumulateFlowState();
}

class _AccumulateFlowState extends State<AccumulateFlow> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  Map ajaxData = {};
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '积量类型', 'key': 'type_ch_name'},
    {'title': '积量值', 'key': 'amount'},
    {'title': '状态', 'key': 'state'},
    {'title': '生效日期', 'key': 'eff_date'},
    {'title': '失效日期', 'key': 'exp_date'},
    {'title': '创建日期', 'key': 'create_date'},
    {'title': '更新日期', 'key': 'update_date'},
    {'title': '操作', 'key': 'option'},
  ];

  Map state = {
    'all': "全部",
    '1': "在用",
    '0': "停用",
  };

  Map accumulateType = {
    'all': '全部',
    '1': '用户成长值',
    '2': '用户积分',
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
    ajax('Adminrelas-Accum-getFlow', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'] ?? {};
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

  getDateTime2(val) {
    if (val['min'] == null) {
      param.remove('update_dateL');
    } else {
      param['update_dateL'] = val['min'].toString().substring(0, 10);
    }
    if (val['max'] == null) {
      param.remove('update_dateU');
    } else {
      param['update_dateU'] = val['max'].toString().substring(0, 10);
    }
  }

  turnTo(data) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccumulateFlowDetail(data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('积量汇总'),
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
              secondChild: Column(children: <Widget>[
                Input(
                  label: '用户',
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
                  selectOptions: accumulateType,
                  selectedValue: param['accum_type_id'] ?? 'all',
                  label: '积量类型',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('accum_type_id');
                    } else {
                      param['accum_type_id'] = val;
                    }
                  },
                ),
                Select(
                  selectOptions: state,
                  selectedValue: param['state'] ?? 'all',
                  label: '状态',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('state');
                    } else {
                      param['state'] = val;
                    }
                  },
                ),
                RangeInput(
                  label: '剂量值',
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
                DateSelectPlugin(
                  onChanged: getDateTime,
                  label: '创建时间',
                ),
                DateSelectPlugin(
                  onChanged: getDateTime2,
                  label: '更新时间',
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
                : Container(
                    child: ajaxData.isEmpty
                        ? Container(
                            alignment: Alignment.center,
                            child: Text('无数据'),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: ajaxData.keys.toList().map<Widget>((key) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xffdddddd),
                                  ),
                                ),
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: <Widget>[
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                '用户：',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              Text('${ajaxData[key]['login_name']}'),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                '手机：',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              Text('${ajaxData[key]['user_phone']}'),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: ajaxData[key]['acctRes'].map<Widget>((item) {
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
                                                case "state":
                                                  con = Text('${state[item['state']]}');
                                                  break;
                                                case 'option':
                                                  con = Wrap(
                                                    runSpacing: 10,
                                                    spacing: 10,
                                                    children: <Widget>[
                                                      PrimaryButton(
                                                        onPressed: () {
                                                          turnTo(item);
                                                        },
                                                        child: Text('查看'),
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
                                                    Expanded(flex: 1, child: con)
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  ],
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
