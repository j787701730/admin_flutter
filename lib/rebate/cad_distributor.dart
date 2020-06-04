import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/rebate/cad_distributor_history.dart';
import 'package:admin_flutter/rebate/cad_distributor_modify.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CADDistributor extends StatefulWidget {
  @override
  _CADDistributorState createState() => _CADDistributorState();
}

class _CADDistributorState extends State<CADDistributor> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = false;

  List columns = [
    {'title': '账号', 'key': 'login_name'},
    {'title': '手机号', 'key': 'user_phone'},
    {'title': '注册时间', 'key': 'register_time'},
    {'title': '开通时间', 'key': 'create_date'},
    {'title': '广告展示', 'key': 'if_show'},
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
    ajax('Adminrelas-RebateManage-cadSellerList', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'];
          count = int.tryParse('${res['count'] ?? 0}');
          toTop();
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

  turnToHistory(val) {
    Navigator.push(
      _context,
      MaterialPageRoute(builder: (context) => CADDistributorHistory(val)),
    );
  }

  turnToModify(val) {
    Navigator.push(
      _context,
      MaterialPageRoute(builder: (context) => CADDistributorModify(val)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CAD经销商'),
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
            Input(
              label: '用户名',
              onChanged: (String val) {
                setState(() {
                  param['loginName'] = val;
                });
              },
            ),
            Container(
              margin: EdgeInsets.only(bottom: 6),
              alignment: Alignment.centerRight,
              child: NumberBar(count: count),
            ),
            loading
                ? CupertinoActivityIndicator()
                : Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ajaxData.map<Widget>((item) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xffdddddd),
                              width: 1,
                            ),
                          ),
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: columns.map<Widget>((col) {
                              Widget con = Text('${item[col['key']] ?? ''}');
                              switch (col['key']) {
                                case 'if_show':
                                  con = Container(
                                    alignment: Alignment.centerLeft,
                                    child: '${item[col['key']]}' == '1' ? Text('是') : Text('否'),
                                  );
                                  break;
                                case 'option':
                                  con = Wrap(
                                    runSpacing: 10,
                                    spacing: 10,
                                    children: <Widget>[
                                      PrimaryButton(
                                        onPressed: () {
                                          turnToModify({'item': item});
                                        },
                                        child: Text('修改'),
                                      ),
                                      PrimaryButton(
                                        onPressed: () {
                                          turnToHistory({'item': item});
                                        },
                                        child: Text('开通历史'),
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
