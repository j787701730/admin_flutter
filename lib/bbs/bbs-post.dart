import 'dart:async';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/search-bar-plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BbsPost extends StatefulWidget {
  @override
  _BbsPostState createState() => _BbsPostState();
}

class _BbsPostState extends State<BbsPost> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"currPage": 1, "pageCount": 15, "login_name": ''};
  List ajaxData = [];
  int count = 0;
  bool loading = false;

  List columns = [
    {'title': '帖子标题', 'key': 'bbs_post_title'},
    {'title': '用户昵称', 'key': 'full_name'},
    {'title': '用户', 'key': 'login_name'},
    {'title': '状态', 'key': 'bbs_post_state'},
    {'title': '所属版块', 'key': 'bbs_forum_name'},
    {'title': '类型', 'key': 'bbs_post_type'},
    {'title': '阅读量', 'key': 'bbs_post_read'},
    {'title': '回复量', 'key': 'bbs_reply'},
    {'title': '发表时间', 'key': 'bbs_post_date'},
    {'title': '操作', 'key': 'option'},
  ];

  Map bbsPostState = {
    '0': '全部',
    '1': '在用',
    '2': '草稿箱',
    '3': '冻结',
  };
  Map bbsPostType = {
    '0': '全部',
    '1': '普通',
    '2': '推荐',
    '3': '精华',
  };

  void _onRefresh() {
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

  getData({isRefresh: false}) {
    setState(() {
      loading = true;
    });
    ajax('Adminrelas-BbsPost-list', param, true, (res) {
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

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'bbs_post_read': '阅读量 升序',
    'bbs_post_read desc': '阅读量 降序',
    'bbs_reply': '回复量 升序',
    'bbs_reply desc': '回复量 降序',
    'bbs_post_date': '发表时间 升序',
    'bbs_post_date desc': '发表时间 降序',
  };

  orderBy(val) {
    if (val == 'all') {
      param.remove('postOrder');
    } else {
      param['postOrder'] = val;
    }
    param['curr_page'] = 1;
    defaultVal = val;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('帖子列表'),
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
            SearchBarPlugin(
              secondChild: Column(children: <Widget>[
                Input(
                  label: '用户',
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('loginName');
                    } else {
                      param['loginName'] = val;
                    }
                  },
                ),
                Input(
                  label: '用户昵称',
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('fullName');
                    } else {
                      param['fullName'] = val;
                    }
                  },
                ),
                Select(
                  selectOptions: bbsPostState,
                  selectedValue: param['postState'] ?? '0',
                  label: '状态',
                  onChanged: (val) {
                    if (val == '0') {
                      param.remove('postState');
                    } else {
                      param['postState'] = val;
                    }
                  },
                ),
                Select(
                  selectOptions: bbsPostType,
                  selectedValue: param['postType'] ?? '0',
                  label: '类型',
                  onChanged: (val) {
                    if (val == '0') {
                      param.remove('postType');
                    } else {
                      param['postType'] = val;
                    }
                  },
                ),
                Select(
                  selectOptions: selects,
                  selectedValue: defaultVal,
                  label: '排序',
                  onChanged: orderBy,
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
                      param['currPage'] = 1;
                      getData();
                    },
                    child: Text('搜索'),
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
                ? CupertinoActivityIndicator()
                : Container(
                    child: Column(
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
                                case 'bbs_post_state':
                                  con = Text('${bbsPostState[item['bbs_post_state']]}');
                                  break;
                                case 'bbs_post_type':
                                  con = Text('${bbsPostType[item['bbs_post_type']]}');
                                  break;
                                case 'option':
                                  con = Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: <Widget>[
//                                      PrimaryButton(
//                                        onPressed: () {},
//                                        child: Text('编辑'),
//                                      ),
                                    ],
                                  );
                                  break;
                              }

                              return Container(
                                margin: EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: 90,
                                      alignment: Alignment.centerRight,
                                      child: Text('${col['title']}:'),
                                      margin: EdgeInsets.only(right: 8),
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
                current: param['currPage'],
                total: count,
                pageSize: param['pageCount'],
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
