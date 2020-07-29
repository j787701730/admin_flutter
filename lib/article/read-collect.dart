import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/article/read-collect-detail.dart';
import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/search-bar-plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ReadCollect extends StatefulWidget {
  @override
  _ReadCollectState createState() => _ReadCollectState();
}

class _ReadCollectState extends State<ReadCollect> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15, 'state': 0};
  Map param2 = {"curr_page": 1, "page_count": 15, 'state': 0};
  int type = 1;
  List ajaxData = [];
  List ajaxData2 = [];
  int count = 0;
  int count2 = 0;
  bool loading = true;

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
    ajax(
      'Adminrelas-ArticleManage-ajaxReadCollect',
      {'param': jsonEncode(param)},
      true,
      (res) {
        if (mounted) {
          setState(() {
            loading = false;
            ajaxData = res is Map ? res['data'] ?? [] : [];
            count = res is Map ? int.tryParse('${res['count'] ?? 0}') : 0;
            toTop();
          });
          if (isRefresh) {
            _refreshController.refreshCompleted();
          }
        }
      },
      () {},
      _context,
    );
  }

  getData2({isRefresh: false}) {
    setState(() {
      loading = true;
    });
    ajax(
      'Adminrelas-ArticleManage-ajaxSumReadCollect',
      {'param': jsonEncode(param2)},
      true,
      (res) {
        if (mounted) {
          setState(() {
            loading = false;
            ajaxData2 = res is Map ? res['data'] ?? [] : [];
            count2 = res is Map ? int.tryParse('${res['count'] ?? 0}') : 0;
            toTop();
          });
          if (isRefresh) {
            _refreshController.refreshCompleted();
          }
        }
      },
      () {},
      _context,
    );
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

  getPage2(page) {
    param2['curr_page'] = page;
    getData2();
  }

  @override
  Widget build(BuildContext context) {
//    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('教程阅读'),
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
              secondChild: Column(
                children: <Widget>[
                  Input(
                    label: '用户',
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
                  Input(
                    label: '教程标题',
                    onChanged: (val) {
                      if (val == '') {
                        param.remove('article_topic');
                        param2.remove('article_topic');
                      } else {
                        param['article_topic'] = val;
                        param2['article_topic'] = val;
                      }
                    },
                  ),
                  DateSelectPlugin(
                    label: '创建时间',
                    onChanged: (val) {
                      if (val['min'] == null) {
                        param.remove('start_date');
                        param2.remove('start_date');
                      } else {
                        param['start_date'] = val['min'].toString().substring(0, 10);
                        param2['start_date'] = val['min'].toString().substring(0, 10);
                      }
                      if (val['max'] == null) {
                        param.remove('end_date');
                        param2.remove('end_date');
                      } else {
                        param['end_date'] = val['max'].toString().substring(0, 10);
                        param2['end_date'] = val['max'].toString().substring(0, 10);
                      }
                    },
                  ),
                ],
              ),
            ),
            Container(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  PrimaryButton(
                    onPressed: () {
                      if (type == 1) {
                        param['curr_page'] = 1;
                        getData();
                      } else {
                        param2['curr_page'] = 1;
                        getData2();
                      }
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text('搜索'),
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: 10),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CFColors.text,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        type = 1;
                        if (ajaxData.isEmpty) {
                          getData();
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: type == 1 ? CFColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        '教程阅读',
                        style: TextStyle(
                          color: type == 1 ? CFColors.primary : CFColors.text,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        type = 2;
                        if (ajaxData2.isEmpty) {
                          getData2();
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: type == 2 ? CFColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        '阅读汇总',
                        style: TextStyle(
                          color: type == 2 ? CFColors.primary : CFColors.text,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Visibility(
              visible: type == 1,
              child: Column(
                children: <Widget>[
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
                              : ReadCollectContent(
                                  ajaxData: ajaxData,
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
            Visibility(
              visible: type == 2,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 6),
                    alignment: Alignment.centerRight,
                    child: NumberBar(count: count2),
                  ),
                  loading
                      ? Container(
                          alignment: Alignment.center,
                          child: CupertinoActivityIndicator(),
                        )
                      : ajaxData2.isEmpty
                          ? Container(
                              alignment: Alignment.center,
                              child: Text('无数据'),
                            )
                          : ReadCollectContent2(
                              ajaxData2: ajaxData2,
                            ),
                  Container(
                    child: PagePlugin(
                      current: param2['curr_page'],
                      total: count2,
                      pageSize: param2['page_count'],
                      function: getPage2,
                    ),
                  ),
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

class ReadCollectContent extends StatefulWidget {
  final List ajaxData;

  ReadCollectContent({this.ajaxData});

  @override
  _ReadCollectContentState createState() => _ReadCollectContentState();
}

class _ReadCollectContentState extends State<ReadCollectContent> {
  List columns = [
    {'title': '阅读用户', 'key': 'login_name'},
    {'title': '阅读教程', 'key': 'article_topic'},
    {'title': '教程类型', 'key': 'class_name'},
    {'title': '阅读次数', 'key': 'read_nums'},
    {'title': '阅读时长', 'key': 'read_duration'},
    {'title': '阅读时间', 'key': 'update_time'}
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.ajaxData.map<Widget>((item) {
          return Container(
            padding: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xffeeeeee),
              ),
            ),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columns.map<Widget>((col) {
                Widget con = Text('${item[col['key']] ?? ''}');
                switch (col['key']) {
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
                      Expanded(flex: 1, child: con),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ReadCollectContent2 extends StatefulWidget {
  final List ajaxData2;

  ReadCollectContent2({this.ajaxData2});

  @override
  _ReadCollectContent2State createState() => _ReadCollectContent2State();
}

class _ReadCollectContent2State extends State<ReadCollectContent2> {
  BuildContext _context;

  @override
  void initState() {
    super.initState();
    _context = context;
  }

  List columns2 = [
    {'title': '阅读用户', 'key': 'login_name'},
    {'title': '阅读总教程数', 'key': 'sum_article'},
    {'title': '阅读总次数', 'key': 'sum_nums'},
    {'title': '阅读总时长', 'key': 'sum_duration'},
    {'title': '操作', 'key': 'option'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.ajaxData2.map<Widget>((item) {
        return Container(
          padding: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: Color(0xffeeeeee),
            ),
          ),
          margin: EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columns2.map<Widget>((col) {
              Widget con = Text('${item[col['key']] ?? ''}');
              switch (col['key']) {
                case 'option':
                  con = Wrap(
                    children: <Widget>[
                      PrimaryButton(
                        onPressed: () {
                          Navigator.push(
                            _context,
                            MaterialPageRoute(
                              builder: (context) => ReadCollectDetail(item),
                            ),
                          );
                        },
                        child: Text(
                          '详情',
                        ),
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
                      width: 110,
                      alignment: Alignment.centerRight,
                      child: Text('${col['title']}'),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Expanded(flex: 1, child: con),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
