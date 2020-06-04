import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/opt/board_cut_user_grant_modify.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BoardCutUserGrant extends StatefulWidget {
  @override
  _BoardCutUserGrantState createState() => _BoardCutUserGrantState();
}

class _BoardCutUserGrantState extends State<BoardCutUserGrant> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  Map chargeConfig = {
    "6": {
      "config_id": "6",
      "config_name": "标签配置89",
      "type_id": "2",
      "type_ch_name": "标签配置",
      "brand": "豪迈",
      "version": "3.2.14"
    },
    "7": {
      "config_id": "7",
      "config_name": "样式配置2",
      "type_id": "3",
      "type_ch_name": "样式配置",
      "brand": "豪迈",
      "version": "3.2.14"
    },
    "29": {
      "config_id": "29",
      "config_name": "测试配置",
      "type_id": "1",
      "type_ch_name": "机台配置",
      "brand": "test",
      "version": "1.22"
    }
  };
  List columns = [
    {'title': '用户', 'key': 'login_name'},
    {'title': '店铺', 'key': 'shop_name'},
    {'title': '授权', 'key': 'group_rights'},
    {'title': '创建时间', 'key': 'create_date'},
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
    ajax('Adminrelas-BoardCut-userConf', {'param': jsonEncode(param)}, true, (res) {
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

  turnTo(item) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (context) => BoardCutUserGrantModify(item),
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
                '确认删除 ${data['login_name']} 用户配置?',
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

  String defaultVal = 'all';

  Map selects = {
    // 	 	授权	创建时间
    'all': '无',
    'u.login_name': '用户 升序',
    'u.login_name desc': '用户 降序',
    's.shop_name': '店铺 升序',
    's.shop_name desc': '店铺 降序',
    'bccc.create_date': '创建时间 升序',
    'bccc.create_date desc': '创建时间 降序',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('用户收费开料配置'),
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
            Input(
              label: '用户',
              onChanged: (String val) {
                setState(() {
                  if (val == '') {
                    param.remove('login_name');
                  } else {
                    param['login_name'] = val;
                  }
                });
              },
            ),
            Input(
              label: '店铺',
              onChanged: (String val) {
                setState(() {
                  if (val == '') {
                    param.remove('shop_name');
                  } else {
                    param['shop_name'] = val;
                  }
                });
              },
            ),
            Select(
              selectOptions: selects,
              selectedValue: defaultVal,
              label: '排序',
              onChanged: orderBy,
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
                      FocusScope.of(context).requestFocus(FocusNode());
                      turnTo(null);
                    },
                    child: Text('新增'),
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
                                      case 'group_rights':
                                        List rights = jsonDecode(item['group_rights']);
                                        con = Wrap(
                                          runSpacing: 6,
                                          children: rights.map<Widget>(
                                            (right) {
                                              return Container(
                                                margin: EdgeInsets.only(
                                                  right: chargeConfig[right] == null ? 0 : 6,
                                                ),
                                                child: Text(
                                                    '${chargeConfig[right] == null ? '' : chargeConfig[right]['config_name']}'),
                                              );
                                            },
                                          ).toList(),
                                        );
                                        break;
                                      case 'option':
                                        con = Wrap(
                                          runSpacing: 10,
                                          spacing: 10,
                                          children: <Widget>[
                                            PrimaryButton(
                                              onPressed: () {
                                                FocusScope.of(context).requestFocus(FocusNode());
                                                turnTo(item);
                                              },
                                              child: Text('修改'),
                                            ),
                                            PrimaryButton(
                                              onPressed: () {
                                                FocusScope.of(context).requestFocus(FocusNode());
                                                delDialog(item);
                                              },
                                              child: Text('删除'),
                                              type: 'error',
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
