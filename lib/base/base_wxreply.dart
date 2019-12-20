import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/base/wxreply_modify.dart';
import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BaseWxreply extends StatefulWidget {
  @override
  _BaseWxreplyState createState() => _BaseWxreplyState();
}

class _BaseWxreplyState extends State<BaseWxreply> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '关键词', 'key': 'keyword'},
    {'title': '回复类型', 'key': 'type_ch_name'},
    {'title': '平台绑定', 'key': 'web_bind_type'},
    {'title': '创建时间', 'key': 'create_date'},
    {'title': '备注', 'key': 'comments'},
    {'title': '操作', 'key': 'option'},
  ];

  Map replyType = {
    '0': '全部',
    '1': '自定义函数',
    '2': '文本消息',
    '3': '图文消息',
  };

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
    ajax('Adminrelas-wxReply-getReplys', {'param': jsonEncode(param)}, true, (res) {
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

  getDateTime(val) {
    setState(() {
      if (val['min'] == null) {
        param.remove('start_date');
      } else {
        param['start_date'] = val['min'].toString().substring(0, 10);
      }

      if (val['max'] == null) {
        param.remove('end_date');
      } else {
        param['end_date'] = val['max'].toString().substring(0, 10);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('微信回复'),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Input(
                  label: '关键字',
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('keyword');
                    } else {
                      param['keyword'] = val;
                    }
                  },
                ),
                Select(
                  selectOptions: replyType,
                  selectedValue: param['reply_type'] ?? '0',
                  label: '回复类型',
                  onChanged: (String newValue) {
                    setState(() {
                      if (newValue == '0') {
                        param.remove('reply_type');
                      } else {
                        param['reply_type'] = newValue;
                      }
                    });
                  },
                ),
                DateSelectPlugin(
                  onChanged: getDateTime,
                  label: '创建时间',
                ),
                Container(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      SizedBox(
                        height: 30,
                        child: PrimaryButton(
                          onPressed: () {
                            param['curr_page'] = 1;
                            getData();
                          },
                          child: Text('搜索'),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: PrimaryButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              new MaterialPageRoute(builder: (context) => new WxReplyModify(null)),
                            );
                          },
                          child: Text('添加回复'),
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
                                      border: Border.all(color: Color(0xffdddddd), width: 1),
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
                                              spacing: 10,
                                              runSpacing: 10,
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 30,
                                                  child: PrimaryButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        new MaterialPageRoute(
                                                          builder: (context) => new WxReplyModify(
                                                            {'item': item},
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Text('修改'),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 30,
                                                  child: PrimaryButton(
                                                    type: 'error',
                                                    onPressed: () {},
                                                    child: Text('删除'),
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
