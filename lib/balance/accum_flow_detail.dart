import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AccumulateFlowDetail extends StatefulWidget {
  final props;

  AccumulateFlowDetail(this.props);

  @override
  _AccumulateFlowDetailState createState() => _AccumulateFlowDetailState();
}

class _AccumulateFlowDetailState extends State<AccumulateFlowDetail> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {
    "currPage": 1,
    "pageCount": 15,
    'type': '1',
  }; // type=> 1:全部 2:收入 3:支出
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '外部流水', 'key': 'ext_serial_id'},
    {'title': '来源', 'key': 'oper_name'},
    {'title': '类型', 'key': 'type'},
    {'title': '成长值', 'key': 'amount'},
    {'title': '当前成长值', 'key': 'curr_amount'},
    {'title': '发生时间', 'key': 'create_date'},
  ];

  List balanceType = [
    {
      "value": "",
      "type": "0",
      "name": "请选择",
    },
    {
      "value": "1",
      "type": "2",
      "name": "购买成长",
    },
    {
      "value": "2",
      "type": "2",
      "name": "登录成长",
    },
    {
      "value": "3",
      "type": "2",
      "name": "评价成长",
    },
    {
      "value": "4",
      "type": "2",
      "name": "附加成长",
    },
    {
      "value": "1",
      "type": "3",
      "name": "商品购买抵扣",
    }
  ];

  void _onRefresh() async {
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
    param['accumID'] = '${widget.props['accum_id']}';
    param['beginDate'] = DateTime.now().add(Duration(days: -30)).toString().substring(0, 10);
    param['endDate'] = DateTime.now().toString().substring(0, 10);
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
    ajax('Adminrelas-Accum-detail', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['balance'] ?? [];
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
    param['currPage'] += page;
    getData();
  }

  getDateTime(val) {
    setState(() {
      if (val['min'] != null) {
        param['beginDate'] = val['min'].toString().substring(0, 10);
      }
      if (val['max'] != null) {
        param['endDate'] = val['max'].toString().substring(0, 10);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props['login_name']} ${widget.props['type_ch_name']} 积量明细表'),
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
            Container(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          setState(() {
                            param.remove('accumTypeID');
                            param['type'] = '1';
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          color: param['type'] == '1' ? CFColors.success : Colors.white,
                          height: 30,
                          padding: EdgeInsets.only(left: 10, right: 10),
                          margin: EdgeInsets.only(right: 10),
                          child: Text(
                            '全部',
                            style: TextStyle(
                              color: param['type'] == '1' ? CFColors.white : CFColors.text,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            param.remove('accumTypeID');
                            param['type'] = '2';
                          });
                        },
                        child: Container(
                          color: param['type'] == '2' ? CFColors.success : Colors.white,
                          alignment: Alignment.center,
                          height: 30,
                          padding: EdgeInsets.only(left: 10, right: 10),
                          margin: EdgeInsets.only(right: 10),
                          child: Text(
                            '收入',
                            style: TextStyle(
                              color: param['type'] == '2' ? CFColors.white : CFColors.text,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            param.remove('accumTypeID');
                            param['type'] = '3';
                          });
                        },
                        child: Container(
                          color: param['type'] == '3' ? CFColors.success : Colors.white,
                          alignment: Alignment.center,
                          height: 30,
                          padding: EdgeInsets.only(left: 10, right: 10),
                          margin: EdgeInsets.only(right: 10),
                          child: Text(
                            '支出',
                            style: TextStyle(
                              color: param['type'] == '3' ? CFColors.white : CFColors.text,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 80,
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 10),
                        child: Text('类型'),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(4),),
                          ),
                          height: 34,
                          child: DropdownButton<String>(
                            isExpanded: true,
                            elevation: 1,
                            underline: Container(),
                            value: param['accumTypeID'] == null ? '-0' : '${param['accumTypeID']}-${param['type']}',
                            onChanged: (String newValue) {
                              List arr = newValue.split('-');
                              setState(() {
                                if (arr[0] == '') {
                                  param.remove('accumTypeID');
                                } else {
                                  param['accumTypeID'] = arr[0];
                                }
                                param['type'] = arr[1];
                              });
                            },
                            items: balanceType.map<DropdownMenuItem<String>>((item) {
                              return DropdownMenuItem(
                                value: '${item['value']}-${item['type']}',
                                child: Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    '${item['name']}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      )
                    ],
                  ),
                  DateSelectPlugin(
                    onChanged: getDateTime,
                    label: '时间',
                    min: param['beginDate'],
                    max: param['endDate'],
                    operaNull: true,
                  ),
                  SizedBox(
                    height: 30,
                    child: PrimaryButton(
                      onPressed: () {
                        param['currPage'] = 1;
                        getData();
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: Text('搜索'),
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
                                  border: Border.all(color: Color(0xffdddddd), ),
                                ),
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: columns.map<Widget>((col) {
                                    Widget con = Text('${item[col['key']] ?? ''}');
                                    switch (col['key']) {
                                      case 'type':
                                        if ('${item['type']}' == '1') {
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
                                      case 'option':
                                        con = Wrap(
                                          runSpacing: 10,
                                          spacing: 10,
                                          children: <Widget>[
                                            Container(
                                              height: 30,
                                              child: PrimaryButton(
                                                onPressed: () {},
                                                child: Text(''),
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
                                            width: 100,
                                            alignment: Alignment.centerRight,
                                            child: Text('${col['title']}'),
                                            margin: EdgeInsets.only(right: 10),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: con,
                                          )
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
