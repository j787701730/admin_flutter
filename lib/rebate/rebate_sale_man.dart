import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  List ajaxData = [];
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
    ajax('Adminrelas-Api-getSalesmanRate', {}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'] ?? [];
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

  save() {
    List arr = [];
    int sort = 1;
    bool flag = true;
    List msg = [];
    for (var o in ajaxData) {
      if (o['left_value'] != null &&
          o['right_value'] != null &&
          o['rate'] != null &&
          '${o['left_value']}'.trim() != '' &&
          '${o['right_value']}'.trim() != '' &&
          '${o['rate']}'.trim() != '') {
        o['sort'] = '$sort';
        arr.add(o);
        sort += 1;
      }
    }
    if (arr.length == 0) {
      msg.add('请设置成长规则');
    } else {
      for (var i = 0; i < ajaxData.length; i++) {
        if (int.parse('${ajaxData[i]['left_value']}') > int.parse('${ajaxData[i]['right_value']}')) {
          msg.add('规则的最大值 ${ajaxData[i]['right_value']} 要大于最后一条规则的最小值 ${ajaxData[i]['left_value']}');
          flag = false;
        }
        if (i == 0) {
          if ('${ajaxData[0]['left_value']}' != '0') {
            msg.add('第一条规则的最小值要从0开始');
            flag = false;
          }
        } else {
          if (int.parse('${ajaxData[i]['left_value']}') != int.parse('${ajaxData[i - 1]['right_value']}') + 1) {
            msg.add('规则在最小值 ${ajaxData[i]['left_value']} 要等于前一条规则最大值 ${ajaxData[i - 1]['right_value']} 加 1 , 请修改! ');
            flag = false;
          }
        }
        if (i == ajaxData.length - 1) {
          if ('${ajaxData[i]['right_value']}' != '999999999') {
            msg.add('最后一条规则的最大值要等于999999999');
            flag = false;
          }
        }
      }
    }
    FocusScope.of(context).requestFocus(FocusNode());
    if (flag) {
      ajax(
        'Adminrelas-RebateManage-setSalesmanRate',
        {
          'data': jsonEncode({'salesman_rate': ajaxData})
        },
        true,
        (data) {},
        () {},
        _context,
      );
    } else {
      Fluttertoast.showToast(
        msg: '${msg.join(', ')}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
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
                                padding: EdgeInsets.only(top: 10, right: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: columns.map<Widget>((col) {
                                    Widget con = Text('${item[col['key']] ?? ''}');
                                    switch (col['key']) {
                                      case 'left_value':
                                        con = Input(
                                          label: '',
                                          onChanged: (val) {
                                            setState(() {
                                              item['left_value'] = val;
                                            });
                                          },
                                          labelWidth: 0,
                                          value: '${item['left_value']}',
                                        );
                                        break;
                                      case 'right_value':
                                        con = Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              child: Input(
                                                label: '',
                                                onChanged: (val) {
                                                  setState(() {
                                                    item['right_value'] = val;
                                                  });
                                                },
                                                labelWidth: 0,
                                                value: '${item['right_value']}',
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                bottom: 10,
                                                left: 10,
                                              ),
                                              child: Text(' (含)'),
                                            ),
                                          ],
                                        );
                                        break;
                                      case 'rate':
                                        con = Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Input(
                                                label: '',
                                                onChanged: (val) {
                                                  setState(() {
                                                    item['rate'] = val;
                                                  });
                                                },
                                                labelWidth: 0,
                                                value: '${item['rate']}',
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                bottom: 10,
                                                left: 10,
                                              ),
                                              child: Text(' %'),
                                            ),
                                          ],
                                        );
                                        break;
                                      case 'option':
                                        con = Container(
                                          margin: EdgeInsets.only(bottom: 10),
                                          child: Wrap(
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
                                          ),
                                        );
                                        break;
                                    }

                                    return Container(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            width: 80,
                                            alignment: Alignment.centerRight,
                                            child: Text('${col['title']}'),
                                            margin: EdgeInsets.only(right: 10, bottom: 10),
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
              margin: EdgeInsets.only(bottom: 10),
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
                    onPressed: save,
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
