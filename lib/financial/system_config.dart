import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SystemConfig extends StatefulWidget {
  @override
  _SystemConfigState createState() => _SystemConfigState();
}

class _SystemConfigState extends State<SystemConfig> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '配置类型', 'key': 'config_ch'},
    {'title': '配置宏', 'key': 'config_define'},
    {'title': '配置名称', 'key': 'config_label'},
    {'title': '配置值', 'key': 'config_value'},
    {'title': '修改人', 'key': 'login_name'},
    {'title': '创建时间', 'key': 'create_date'},
    {'title': '更新时间', 'key': 'update_date'},
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
      loading = false;
    });
    ajax('Adminrelas-Api-systemConfigData', {}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'] ?? [];
//          count = int.tryParse('${res['count'] ?? 0}');
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

  commentsDialog(item) {
    return showDialog<void>(
      context: _context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${item['config_label']} 备注',
          ),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(_context).size.width - 100,
                  child: Text('${item['comments']}'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('关闭'),
              onPressed: () {
                Navigator.of(_context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  configValueDialog(item) {
    String configValue = '${item['config_value']}';
    return showDialog<void>(
      context: _context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${item['config_label']} 配置值修改',
          ),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(_context).size.width - 100,
                  child: Input(
                    label: '配置值',
                    onChanged: (val) {
                      configValue = val;
                    },
                    value: configValue,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('关闭'),
              onPressed: () {
                Navigator.of(_context).pop();
              },
            ),
            FlatButton(
              color: CFColors.primary,
              child: Text('修改'),
              onPressed: () {
                ajax(
                  'Adminrelas-financialLoan-setSystemConfig',
                  {
                    'data': jsonEncode({
                      "config_id": item['config_id'],
                      "config_value": configValue,
                    }),
                  },
                  true,
                  (data) {
                    getData();
                    Navigator.of(_context).pop();
                  },
                  () {},
                  _context,
                );
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
        title: Text('金融配置'),
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
//              Container(
//                margin: EdgeInsets.only(bottom: 10),
//                child: Row(
//                  children: <Widget>[
//                    Container(
//                      width: 80,
//                      alignment: Alignment.centerRight,
//                      margin: EdgeInsets.only(right: 10),
//                      child: Text('用户名'),
//                    ),
//                    Expanded(
//                      flex: 1,
//                      child: TextField(
//                        decoration: InputDecoration(
//                            border: OutlineInputBorder(),
//                            contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 15,right: 15,)),
//                        onChanged: (String val) {
//                          setState(() {
//                            if (val == '') {
//                              param.remove('login_name');
//                            } else {
//                              param['login_name'] = val;
//                            }
//                          });
//                        },
//                      ),
//                    )
//                  ],
//                ),
//              ),
//              Container(
//                child: Wrap(
//                  alignment: WrapAlignment.center,
//                  spacing: 10,
//                  runSpacing: 10,
//                  children: <Widget>[
//                    SizedBox(
//                      height: 32,
//                      child: PrimaryButton(
//                          onPressed: () {
//                            param['curr_page'] = 1;
//                            getData();
//                            FocusScope.of(context).requestFocus(FocusNode());
//                          },
//                          child: Text('搜索')),
//                    ),
//                  ],
//                ),
//                margin: EdgeInsets.only(bottom: 10),
//              ),
//              Container(
//                margin: EdgeInsets.only(bottom: 6),
//                alignment: Alignment.centerRight,
//                child: NumberBar(count: count),
//              ),
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
                                    switch (col['key']) {
                                      case 'config_value':
                                        con = Row(
                                          children: <Widget>[
                                            InkWell(
                                              onTap: () {
                                                configValueDialog(item);
                                              },
                                              child: Text(
                                                '${item['config_value']}',
                                                style: TextStyle(
                                                  color: CFColors.primary,
                                                ),
                                              ),
                                            ),
                                            item['comments'] == null || item['comments'] == ''
                                                ? Container()
                                                : Container(
                                                    width: 30,
                                                    height: 30,
                                                    child: IconButton(
                                                      iconSize: 20,
                                                      padding: EdgeInsets.all(2),
                                                      icon: Icon(Icons.help),
                                                      onPressed: () {
                                                        commentsDialog(item);
                                                      },
                                                    ),
                                                  )
                                          ],
                                        );
                                        break;
                                      case 'config_id':
                                        if ('${item['config_id']}' == '7') {
                                          con = Text('${item[col['key']] == '1' ? '是' : '否'}');
                                        } else {
                                          con = Text('${item['config_value']}');
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
                  ),
//              Container(
//                child: PagePlugin(
//                    current: param['curr_page'], total: count, pageSize: param['page_count'], function: getPage,),
//              ),
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
