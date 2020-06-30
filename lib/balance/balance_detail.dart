import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BalanceDetail extends StatefulWidget {
  final props;

  BalanceDetail(this.props);

  @override
  _BalanceDetailState createState() => _BalanceDetailState();
}

class _BalanceDetailState extends State<BalanceDetail> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"currPage": 1, "pageCount": 15, "type": 1};
  int type = 1;
  List ajaxData = [];
  int count = 0;
  String stat;
  String balanceTypeID;
  DateTime beginDate;
  DateTime endDate;
  bool loading = false;

  List sourceType = [
    {"type_id": "0", "type_name": "请选择", 'type': '1'},
  ];

  List columns = [
    {'title': '外部流水', 'key': 'ext_serial_id'},
    {'title': '项目名称', 'key': 'balance_oper_name'},
    {'title': '类型', 'key': 'balance_type'},
    {'title': '发生金额', 'key': 'amount'},
    {'title': '剩余金额', 'key': 'curr_amount'},
    {'title': '发生时间', 'key': 'create_date'},
  ];

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
    param['acctBalanceID'] = '${widget.props['acct_balance_id']}';
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
        List sourceTypeTemp = [];
        for (var o in data['payoutType']) {
          sourceTypeTemp.add(
              {"type_id": o['balance_payout_type_id'], "type_name": o['balance_payout_type_ch_name'], 'type': '3'});
        }

        for (var o in data['sourceType']) {
          sourceTypeTemp.add(
              {"type_id": o['balance_source_type_id'], "type_name": o['balance_source_type_ch_name'], 'type': '2'});
        }

        setState(() {
          sourceType.addAll(sourceTypeTemp);
        });
      }
    }, () {}, _context);
  }

  getData({isRefresh: false}) {
    setState(() {
      loading = true;
    });
    param['type'] = type;
    ajax('Adminrelas-Balance-detail', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          ajaxData = res['balance'] ?? [];
          count = int.tryParse('${res['count'] ?? 0}');
          stat = res['stat'];
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
    param['currPage'] += page;
    getData();
  }

  getDateTime(val) {
    setState(() {
      beginDate = val['min'];
      endDate = val['max'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props['login_name']} ${widget.props['balance_type_ch_name']} 资金流水详情'),
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
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ['全部', '收入', '支出'].map<Widget>((item) {
                    int index = ['全部', '收入', '支出'].indexOf(item) + 1;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          type = index;
                          param['currPage'] = 1;
                          getData();
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        height: 34,
                        alignment: Alignment.center,
                        width: 60,
                        decoration: BoxDecoration(color: type == index ? Colors.green : Colors.white),
                        child: Text(
                          '$item',
                          style: TextStyle(color: type == index ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Text('类型: '),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.all(
                      Radius.circular(4),
                    ),
                  ),
                  height: 34,
                  child: DropdownButton<String>(
                    elevation: 0,
                    underline: Container(),
                    value: balanceTypeID ?? '01',
                    onChanged: (String newValue) {
                      setState(() {
                        param['balanceTypeID'] = newValue.substring(0, newValue.length - 1);
                        type = int.parse(newValue.substring(newValue.length - 1, newValue.length));
                        balanceTypeID = newValue;
                      });
                    },
                    items: sourceType.map<DropdownMenuItem<String>>((item) {
                      return DropdownMenuItem(
                        value: '${item['type_id']}${item['type']}',
                        child: Container(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            '${item['type_name']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                DateSelectPlugin(
                  onChanged: getDateTime,
                  label: "时间:",
                  labelWidth: 50,
                ),
                SizedBox(
                  width: 100,
                  height: 34,
                  child: PrimaryButton(
                    onPressed: () {
                      if (beginDate == null) {
                        param.remove('beginDate');
                      } else {
                        param['beginDate'] = beginDate.toString().substring(0, 10);
                      }

                      if (endDate == null) {
                        param.remove('endDate');
                      } else {
                        param['endDate'] = endDate.toString().substring(0, 10);
                      }
                      param['currPage'] = 1;

                      if (param['balanceTypeID'] != null && param['balanceTypeID'] == '0') {
                        param.remove('balanceTypeID');
                      }
                      getData();
                    },
                    child: Text('搜索'),
                  ),
                )
              ],
            ),
            Container(
              height: 15,
            ),
            loading
                ? CupertinoActivityIndicator()
                : ajaxData == null || ajaxData.isEmpty
                    ? Container(
                        alignment: Alignment.center,
                        child: Text('无数据'),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: ajaxData.map<Widget>((item) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xffeeeeee), width: 1),
                            ),
                            margin: EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: columns.map<Widget>((col) {
                                Widget con = Text('${item[col['key']] ?? ''}');
                                switch (col['key']) {
                                  case 'balance_type':
                                    if (item['type'] == '1') {
                                      if (double.parse('${item['amount']}') < 0) {
                                        con = Text('收入冲正');
                                      } else {
                                        con = Text('收入');
                                      }
                                    } else {
                                      if (double.parse('${item['amount']}') < 0) {
                                        con = Text('支出冲正');
                                      } else {
                                        con = Text('支出');
                                      }
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
                              }).toList(),
                            ),
                          );
                        }).toList(),
                      ),
            stat == null
                ? Container(
                    width: 0,
                  )
                : Container(
                    child: Html(
                      data: '$stat',
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
