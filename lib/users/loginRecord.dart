import 'dart:async';

import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LoginRecord extends StatefulWidget {
  final props;

  LoginRecord(this.props);

  @override
  _LoginRecordState createState() => _LoginRecordState();
}

class _LoginRecordState extends State<LoginRecord> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"currPage": 1, "pageCount": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = false;
  List columns = [
    {'title': '登录地区', 'key': 'detail'},
    {'title': 'IP地址', 'key': 'login_ip'},
    {'title': 'MAC地址', 'key': 'login_mac'},
    {'title': '浏览器指纹', 'key': 'finger_print'},
    {'title': '登录时间', 'key': 'login_time'},
    {'title': '登录来源', 'key': 'login_source'},
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
    param['uid'] = widget.props['user_id'];
    ajax('Adminrelas-UserManager-loginRecord', param, true, (res) {
      if (mounted) {
        setState(() {
          ajaxData = res['data'];
          count = int.tryParse('${res['count'] ?? 0}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props['login_name']} 登录记录'),
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
              loading
                  ? CupertinoActivityIndicator()
                  : ajaxData.isEmpty
                      ? Container(
                          width: 0,
                        )
                      : Column(
                          children: ajaxData.map<Widget>((item) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 15),
                              child: Container(
                                decoration:
                                    BoxDecoration(border: Border.all(color: Color(0xffdddddd), width: 1), boxShadow: [
                                  BoxShadow(
                                      color: Color(0xffdddddd),
                                      offset: Offset(0.0, 3.0),
                                      blurRadius: 3.0,
                                      spreadRadius: 3),
                                ]),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xffffffff),
                                  ),
                                  padding: EdgeInsets.only(left: 6, right: 6, top: 8, bottom: 8),
                                  child: Column(
                                    children: columns.map<Widget>((col) {
                                      return Row(
                                        children: <Widget>[
                                          Container(
                                            width: 90,
                                            alignment: Alignment.centerRight,
                                            child: Text('${col['title']}'),
                                            margin: EdgeInsets.only(right: 10),
                                          ),
                                          Expanded(flex: 1, child: Text('${item[col['key']]}'))
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
              Container(
                child: PagePlugin(
                    current: param['currPage'], total: count, pageSize: param['pageCount'], function: getPage),
              )
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: toTop,
        child: Icon(Icons.keyboard_arrow_up),
      ),
    );
  }
}
