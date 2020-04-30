import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/range_input.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RebateList extends StatefulWidget {
  @override
  _RebateListState createState() => _RebateListState();
}

class _RebateListState extends State<RebateList> {
  Map param = {'curr_page': 1, 'page_count': 20};
  Map param2 = {'curr_page': 1, 'page_count': 20};
  List logs = [];
  List logs2 = [];
  int count = 0;
  int count2 = 0;
  Map amount = {};
  BuildContext _context;
  ScrollController _controller;
  bool isExpandedFlag = true;
  List columns = [
    {'title': '收益用户', 'key': 'user_name'},
    {'title': '关联流水', 'key': 'rela_id'},
    {'title': '返利类型', 'key': 'type_name'},
    {'title': '消费用户', 'key': 'login_name'},
    {'title': '返利金额', 'key': 'amount'},
    {'title': '创建时间', 'key': 'create_date'},
  ];

  List columns2 = [
    {'title': '收益用户', 'key': 'u_name'},
    {'title': '总返利金额', 'key': 'actualrebate'},
    {'title': '总流失金额', 'key': 'toprebate'},
  ];

  Map type = {
    "all": "全部",
    "1": "商品推荐返利",
    "2": "店铺注册返利",
    "3": "月基本费返利",
    "4": "流量计费返利",
  };

  DateTime create_date_min;
  DateTime create_date_max;
  bool loading = true;
  int tabType = 1; // 1: 日志明细 2: 日志汇总
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    setState(() {
      param['curr_page'] = 1;
      param2['curr_page'] = 1;
      getData(isRefresh: true);
      getData2(isRefresh: true);
    });
  }

//  void _onLoading() async{
//    // monitor network fetch
//    await Future.delayed(Duration(milliseconds: 1000),);
//    // if failed,use loadFailed(),if no data return,use LoadNodata()
////    items.add((items.length+1).toString(),);
//    if(mounted)
//      setState(() {
//
//      });
//    _refreshController.loadComplete();
//  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _context = context;
    Timer(Duration(milliseconds: 200), () {
      getData();
      getData2();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getData({isRefresh: false}) async {
    if (create_date_min != null) {
      param['start_date'] = create_date_min.toString().substring(0, 10);
    } else {
      param.remove('start_date');
    }

    if (create_date_max != null) {
      param['end_date'] = create_date_max.toString().substring(0, 10);
    } else {
      param.remove('end_date');
    }

    ajax('Adminrelas-RebateManage-getSerial', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          logs = res['data'];
          count = int.tryParse('${res['serialCount'] ?? 0}');
          toTop();
          loading = false;
          amount = res['amount'] == null || res['amount'].isEmpty ? {} : res['amount'];
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

  getData2({isRefresh: false}) async {
    if (create_date_min != null) {
      param2['log_dayL'] = create_date_min.toString().substring(0, 10);
    } else {
      param2.remove('log_dayL');
    }

    if (create_date_max != null) {
      param2['log_dayR'] = create_date_max.toString().substring(0, 10);
    } else {
      param2.remove('log_dayR');
    }

    param2['group'] = true;
    ajax('Adminrelas-RebateManage-sumRebate', {'param': jsonEncode(param2)}, true, (res) {
      if (mounted) {
        setState(() {
          logs2 = res['data'] ?? [];
          count2 = int.tryParse('${res['serialCount'] ?? 0}');
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
    if (tabType == 1) {
      param['curr_page'] += page;
      getData();
    } else {
      param2['curr_page'] += page;
      getData2();
    }
  }

  getDateTime(val) {
    setState(() {
      create_date_min = val['min'];
      create_date_max = val['max'];
    });
  }

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'log_source': '日志来源 升序',
    'log_source desc': '日志来源 降序',
    'name': '接口名称 升序',
    'name desc': '接口名称 降序',
    'log_times': '调用次数 升序',
    'log_times desc': '调用次数 降序',
    'log_day': '调用日期 升序',
    'log_day desc': '调用日期 降序',
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
    getData2();
  }

  @override
  Widget build(BuildContext context) {
//    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('返利流水'),
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
                Input(
                  label: '收益用户',
                  onChanged: (val) {
                    if (val == '') {
                      param.remove('user_name');
                      param2.remove('user_name');
                    } else {
                      param['user_name'] = val;
                      param2['user_name'] = val;
                    }
                  },
                ),
                Input(
                  label: '消费用户',
                  onChanged: (val) {
                    if (val == '') {
                      param.remove('login_name');
                      param2.remove('login_name');
                    } else {
                      param['login_name'] = val;
                      param2['login_name'] = val;
                    }
                  },
                ),
                RangeInput(
                  label: '返利区间',
                  onChangeL: (val) {
                    if (val == '') {
                      param.remove('amountL');
                      param2.remove('amountL');
                    } else {
                      param['amountL'] = val;
                      param2['amountL'] = val;
                    }
                  },
                  onChangeR: (val) {
                    if (val == '') {
                      param.remove('amountU');
                      param2.remove('amountU');
                    } else {
                      param['amountU'] = val;
                      param2['amountU'] = val;
                    }
                  },
                ),
                RangeInput(
                  label: '间接返利',
                  onChangeL: (val) {
                    if (val == '') {
                      param.remove('invite_rate_min');
                      param2.remove('invite_rate_min');
                    } else {
                      param['invite_rate_min'] = val;
                      param2['invite_rate_min'] = val;
                    }
                  },
                  onChangeR: (val) {
                    if (val == '') {
                      param.remove('invite_rate_max');
                      param2.remove('invite_rate_max');
                    } else {
                      param['invite_rate_max'] = val;
                      param2['invite_rate_max'] = val;
                    }
                  },
                ),
                DateSelectPlugin(
                  onChanged: getDateTime,
                  label: '操作日期',
                ),
                Select(
                  selectOptions: type,
                  selectedValue: param['rebate_type'] ?? 'all',
                  label: '返利类型',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('rebate_type');
                      param2.remove('rebate_type');
                    } else {
                      param['rebate_type'] = val;
                      param2['rebate_type'] = val;
                    }
                  },
                ),
              ]),
              crossFadeState: isExpandedFlag ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            ),

//              Select(
//                selectOptions: selects,
//                selectedValue: defaultVal,
//                label: '排序',
//                onChanged: orderBy,
//              ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                SizedBox(
                  height: 30,
                  child: PrimaryButton(
                    onPressed: () {
                      setState(() {
                        param['curr_page'] = 1;
                        param2['curr_page'] = 1;
                        getData();
                        getData2();
                      });
                    },
                    child: Text('搜索'),
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
            amount.isEmpty
                ? Container()
                : Container(
                    margin: EdgeInsets.only(bottom: 10, top: 6),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '返利总金额：',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${amount['actualrebate']}元')
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '直接推荐人返利总金额：',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${amount['directrebate']}元')
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '间接推荐人返利总金额：',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${amount['indirectrebate']}元')
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '流失金额：',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${amount['toprebate']}元')
                          ],
                        ),
                      ],
                    ),
                  ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(),
              height: 34,
              child: Row(
                children: <Widget>[
                  Container(
                    height: 34,
                    width: 15,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xffff4400),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        tabType = 1;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: tabType == 1 ? Color(0xffff4400) : Colors.transparent, width: 2),
                          left: BorderSide(
                            color: tabType == 1 ? Color(0xffff4400) : Colors.transparent,
                          ),
                          right: BorderSide(
                            color: tabType == 1 ? Color(0xffff4400) : Colors.transparent,
                          ),
                          bottom: BorderSide(
                            color: tabType == 2 ? Color(0xffff4400) : Colors.transparent,
                          ),
                        ),
                      ),
                      height: 34,
                      child: Center(
                        child: Text(
                          '返利明细',
                          style: TextStyle(color: tabType == 1 ? Color(0xffff4400) : CFColors.text),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        tabType = 2;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      height: 34,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: tabType == 2 ? Color(0xffff4400) : Colors.transparent, width: 2),
                          left: BorderSide(
                            color: tabType == 2 ? Color(0xffff4400) : Colors.transparent,
                          ),
                          right: BorderSide(
                            color: tabType == 2 ? Color(0xffff4400) : Colors.transparent,
                          ),
                          bottom: BorderSide(
                            color: tabType == 1 ? Color(0xffff4400) : Colors.transparent,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '返利汇总',
                          style: TextStyle(color: tabType == 2 ? Color(0xffff4400) : CFColors.text),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 34,
                      width: 15,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xffff4400),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            loading
                ? Container(
                    child: CupertinoActivityIndicator(),
                  )
                : Column(
                    children: <Widget>[
                      Offstage(
                        offstage: tabType != 1,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(bottom: 8),
                              alignment: Alignment.centerRight,
                              child: NumberBar(count: count),
                            ),
                            logs.isEmpty
                                ? Container(
                                    alignment: Alignment.topCenter,
                                    child: Text('无数据'),
                                  )
                                : Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: logs.map<Widget>((item) {
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
                      Offstage(
                        offstage: tabType != 2,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(bottom: 8),
                              alignment: Alignment.centerRight,
                              child: NumberBar(count: count2),
                            ),
                            logs2.isEmpty
                                ? Container(
                                    alignment: Alignment.topCenter,
                                    child: Text('无数据'),
                                  )
                                : Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: logs2.map<Widget>((item) {
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
                                            children: columns2.map<Widget>((col) {
                                              Widget con = Text('${item['${col['key']}'] ?? ''}');
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
                                current: param2['curr_page'],
                                total: count2,
                                pageSize: param2['page_count'],
                                function: getPage,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
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
