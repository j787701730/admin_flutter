import 'dart:async';

import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RebateSaleMan extends StatefulWidget {
  @override
  _RebateSaleManState createState() => _RebateSaleManState();
}

class _RebateSaleManState extends State<RebateSaleMan> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [
    {"rate_id": "1", "left_value": "0", "right_value": "0", "rate": "10.0", "sort": "1"},
    {"rate_id": "6", "left_value": "1", "right_value": "1", "rate": "20.0", "sort": "2"},
    {"rate_id": "7", "left_value": "2", "right_value": "6", "rate": "30.0", "sort": "3"},
    {"rate_id": "8", "left_value": "7", "right_value": "999999999", "rate": "60.0", "sort": "4"}
  ];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '从', 'key': 'left_value'},
    {'title': '至', 'key': 'right_value'},
    {'title': '返利比例', 'key': 'rate'},
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
      loading = false;
    });
    if (isRefresh) {
      _refreshController.refreshCompleted();
    }
//    ajax('Adminrelas-goodsConfig-getAttrByClassID', {'param': jsonEncode(param)}, true, (res) {
//      if (mounted) {
//        setState(() {
//          loading = false;
//          ajaxData = res['data'] ?? [];
//          count = int.tryParse('${res['count'] ?? 0}');
//          toTop();
//        });
//        if (isRefresh) {
//          _refreshController.refreshCompleted();
//        }
//      }
//    }, () {
//      if (mounted) {
//        setState(() {
//          loading = false;
//        });
//      }
//    }, _context);
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

  add(index) {
    setState(() {
      ajaxData.insert(
        index,
        {"rate_id": "", "left_value": "", "right_value": "", "rate": "", "sort": ""},
      );
    });
  }

  del(index) {
    setState(() {
      ajaxData.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('业务员返利'),
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
                                      case 'right_value':
                                        con = Text('${item['right_value']} (含)');
                                        break;
                                      case 'rate':
                                        con = Text('${item['rate']} %');
                                        break;
                                      case 'option':
                                        con = Wrap(
                                          runSpacing: 10,
                                          spacing: 10,
                                          children: <Widget>[
                                            PrimaryButton(
                                              onPressed: () {
                                                add(ajaxData.indexOf(item) + 1);
                                              },
                                              child: Text('添加'),
                                            ),
                                            PrimaryButton(
                                              type: 'error',
                                              onPressed: () {
                                                del(
                                                  ajaxData.indexOf(item),
                                                );
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
              margin: EdgeInsets.only(bottom: 6),
              child: Wrap(
                spacing: 10,
                children: <Widget>[
                  PrimaryButton(
                    onPressed: () {
                      add(ajaxData.length);
                    },
                    child: Text('添加'),
                  ),
                  PrimaryButton(
                    onPressed: () {
                      FocusScope.of(context).requestFocus(
                        FocusNode(),
                      );
                    },
                    child: Text('保存'),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Icon(
                      Icons.lightbulb_outline,
                      color: CFColors.danger,
                      size: 24,
                    ),
                    margin: EdgeInsets.only(right: 6),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '1、第一个最小值要等于0；最后一个最大值要等于999999999；',
                          style: TextStyle(
                            color: CFColors.danger,
                          ),
                        ),
                        Text(
                          '2、每行返利有空行或者空值，该行将无效；',
                          style: TextStyle(
                            color: CFColors.danger,
                          ),
                        ),
                        Text(
                          '3、返利区间之间的值必须是连续性；',
                          style: TextStyle(
                            color: CFColors.danger,
                          ),
                        ),
                        Text(
                          '4、返利比例的值在0~100之间并只保留一位小数点。',
                          style: TextStyle(
                            color: CFColors.danger,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
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
