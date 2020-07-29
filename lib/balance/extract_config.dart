import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/balance/extract_config_modify.dart';
import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/range_input.dart';
import 'package:admin_flutter/plugin/search-bar-plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ExtractConfig extends StatefulWidget {
  @override
  _ExtractConfigState createState() => _ExtractConfigState();
}

class _ExtractConfigState extends State<ExtractConfig> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '用户', 'key': 'login_name'},
    {'title': '电话号码', 'key': 'user_phone'},
    {'title': '月免手续费额度', 'key': 'extract_limit'},
    {'title': '提现费率', 'key': 'extract_rate'},
    {'title': '备注', 'key': 'comments'},
    {'title': '创建时间', 'key': 'create_date'},
    {'title': '更新时间', 'key': 'update_date'},
    {'title': '操作', 'key': 'option'},
  ];

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
    ajax('Adminrelas-financialLoan-getExtractConfig', {'param': jsonEncode(param)}, true, (res) {
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
    param['curr_page'] = page;
    getData();
  }

  getDateTime(val) {
    if (val['min'] == null) {
      param.remove('create_date_l');
    } else {
      param['create_date_l'] = val['min'].toString().substring(0, 10);
    }
    if (val['max'] == null) {
      param.remove('create_date_r');
    } else {
      param['create_date_r'] = val['max'].toString().substring(0, 10);
    }
  }

  getDateTime2(val) {
    if (val['min'] == null) {
      param.remove('update_date_l');
    } else {
      param['update_date_l'] = val['min'].toString().substring(0, 10);
    }
    if (val['max'] == null) {
      param.remove('update_date_r');
    } else {
      param['update_date_r'] = val['max'].toString().substring(0, 10);
    }
  }

  turnTo(data) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExtractConfigModify(data)),
    );
  }

  delDialog(data) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10),
          titlePadding: EdgeInsets.all(10),
          title: Text(
            '信息',
          ),
          content: SingleChildScrollView(
            child: Container(
//                width: MediaQuery.of(context).size.width - 100,
              child: Text(
                '确认删除 ${data['login_name']} 提现配置?',
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
        title: Text('提现配置'),
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
                  labelWidth: 130,
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('user_name');
                    } else {
                      param['user_name'] = val;
                    }
                  },
                ),
                Input(
                  label: '电话号码',
                  labelWidth: 130,
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('user_phone');
                    } else {
                      param['user_phone'] = val;
                    }
                  },
                ),
                RangeInput(
                    label: '月免手续费额度',
                    labelWidth: 130,
                    onChangeL: (String val) {
                      if (val == '') {
                        param.remove('extract_limit_l');
                      } else {
                        param['extract_limit_l'] = val;
                      }
                    },
                    onChangeR: (String val) {
                      if (val == '') {
                        param.remove('extract_limit_r');
                      } else {
                        param['extract_limit_r'] = val;
                      }
                    }),
                DateSelectPlugin(
                  onChanged: getDateTime,
                  label: '创建时间',
                  labelWidth: 130,
                ),
                DateSelectPlugin(
                  onChanged: getDateTime2,
                  label: '更新时间',
                  labelWidth: 130,
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
                  PrimaryButton(
                    onPressed: () {
                      turnTo(null);
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text('提现配置'),
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
                                                FocusScope.of(context).requestFocus(FocusNode());
                                              },
                                              child: Text('修改'),
                                            ),
                                            PrimaryButton(
                                              onPressed: () {
                                                delDialog(item);
                                                FocusScope.of(context).requestFocus(FocusNode());
                                              },
                                              child: Text('删除'),
                                              type: BtnType.danger,
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
                                            width: 130,
                                            alignment: Alignment.centerRight,
                                            child: Text('${col['title']}'),
                                            margin: EdgeInsets.only(right: 10),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: con,
                                          ),
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
      floatingActionButtonAnimator: ScalingAnimation(),
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(
        FloatingActionButtonLocation.endFloat,
        floatingActionButtonOffsetX,
        floatingActionButtonOffsetY,
      ),
    );
  }
}
