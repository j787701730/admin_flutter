import 'dart:async';

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

class ArticleRecycle extends StatefulWidget {
  @override
  _ArticleRecycleState createState() => _ArticleRecycleState();
}

class _ArticleRecycleState extends State<ArticleRecycle> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15, 'state': 0};
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  List columns = [
    {'title': '标题', 'key': 'article_topic'},
    {'title': '发布人', 'key': 'login_name'},
    {'title': '发布店铺', 'key': 'shop_name'},
    {'title': '点赞', 'key': 'up_counts'},
    {'title': '吐槽', 'key': 'down_counts'},
    {'title': '删除时间', 'key': 'update_date'},
    {'title': '浏览量', 'key': 'read_times'},
    {'title': '操作', 'key': 'option'},
  ];
  Map articleState = {'0': '全部', "1": "已发布", "2": "草稿箱", "3": "待审核"};

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
    ajaxSimple(
      'Adminrelas-ArticleManage-articleRecycles-page-${param['curr_page']}',
      param,
      (res) {
        if (mounted) {
          setState(() {
            loading = false;
            ajaxData = res is Map ? res['data'] ?? [] : [];
            count = res is Map ? int.tryParse('${res['num'] ?? 0}') : 0;
            toTop();
          });
          if (isRefresh) {
            _refreshController.refreshCompleted();
          }
        }
      },
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
    param['curr_page'] += page;
    getData();
  }

  stateDialog(data, {del = false}) {
    String text = '确认还原 ${data['article_topic']} ?';
    String url = 'Adminrelas-ArticleManage-articlestate';
    Map formData = {
      'state': 2,
      'articleid': data['article_id'],
    };
    if (del) {
      text = '确认彻底删除 ${data['article_topic']} ?';
      url = 'Adminrelas-ArticleManage-articledelete';
      formData = {
        'articleid': data['article_id'],
      };
    }

    print(formData);
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '提示',
          ),
          content: SingleChildScrollView(
            child: Container(
//                width: MediaQuery.of(context).size.width - 100,
              child: Text(
                text,
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
                ajax(url, formData, true, (data) {
                  getData();
                  Navigator.of(context).pop();
                }, () {}, _context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
//    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('文章回收站'),
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
                    label: '标题',
                    onChanged: (val) {
                      if (val == '') {
                        param.remove('article_topic');
                      } else {
                        param['article_topic'] = val;
                      }
                    },
                  ),
                  Input(
                    label: '内容',
                    onChanged: (val) {
                      if (val == '') {
                        param.remove('article_content');
                      } else {
                        param['article_content'] = val;
                      }
                    },
                  ),
                  Input(
                    label: '关键字',
                    onChanged: (val) {
                      if (val == '') {
                        param.remove('keywords');
                      } else {
                        param['keywords'] = val;
                      }
                    },
                  ),
                  Input(
                    label: '发布人',
                    onChanged: (val) {
                      if (val == '') {
                        param.remove('login_name');
                      } else {
                        param['login_name'] = val;
                      }
                    },
                  ),
                  Input(
                    label: '发布店铺',
                    onChanged: (val) {
                      if (val == '') {
                        param.remove('shop_name');
                      } else {
                        param['shop_name'] = val;
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
                      param['curr_page'] = 1;
                      getData();
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text('搜索'),
                  ),
//                  PrimaryButton(
//                    onPressed: () {
//                      FocusScope.of(context).requestFocus(FocusNode());
//                    },
//                    child: Text('批量还原'),
//                  ),
//                  PrimaryButton(
//                    type: BtnType.danger,
//                    onPressed: () {
//                      FocusScope.of(context).requestFocus(FocusNode());
//                    },
//                    child: Text('批量删除'),
//                  ),
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
                : ajaxData.isEmpty
                    ? Container(
                        alignment: Alignment.center,
                        child: Text('无数据'),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: ajaxData.map<Widget>((item) {
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
                                  case 'option':
                                    con = Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: <Widget>[
                                        PrimaryButton(
                                          onPressed: () {
                                            stateDialog(item);
                                          },
                                          child: Text('还原'),
                                        ),
//                                              PrimaryButton(
//                                                onPressed: () {
////                                            operaDialog(item);
//                                                },
//                                                child: Text('修改'),
//                                              ),
                                        PrimaryButton(
                                          type: BtnType.danger,
                                          onPressed: () {
                                            stateDialog(item, del: true);
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
                                      Expanded(flex: 1, child: con),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList(),
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
