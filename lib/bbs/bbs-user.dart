import 'dart:async';
import 'dart:convert';

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

class BbsUser extends StatefulWidget {
  @override
  _BbsUserState createState() => _BbsUserState();
}

class _BbsUserState extends State<BbsUser> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"currPage": 1, "pageCount": 15, "login_name": ''};
  List ajaxData = [];
  int count = 0;
  bool loading = false;

  List columns = [
    {'title': '用户', 'key': 'login_name'},
    {'title': '版主组', 'key': 'group_name'},
    {'title': '昵称', 'key': 'full_name'},
    {'title': '发帖数', 'key': 'bbs_user_posts'},
    {'title': '回帖数', 'key': 'bbs_user_replies'},
    {'title': '积分', 'key': 'bbs_user_credits'},
    {'title': '操作', 'key': 'option'},
  ];
  Map group = {
    '1': '超级版主组',
    '2': '实习版主组',
    '3': '用户组',
    '4': '版主组',
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
    ajax('Adminrelas-BbsUser-getUsers', param, true, (res) {
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
    param['currPage'] = page;
    getData();
  }

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'bbs_user_posts': '发帖数 升序',
    'bbs_user_posts desc': '发帖数 降序',
    'bbs_user_replies': '回帖数 升序',
    'bbs_user_replies desc': '回帖数 降序',
    'bbs_user_credits': '积分 升序',
    'bbs_user_credits desc': '积分 降序',
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

  editDialog(item) {
    Map userData = jsonDecode(jsonEncode(item));
    return showDialog<void>(
      context: _context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context1, state) {
          return AlertDialog(
            title: Text(
              '${item['full_name']} 信息修改',
            ),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(_context).size.width * 0.8,
                child: Column(
                  children: <Widget>[
                    Input(
                      label: '用户昵称',
                      onChanged: (val) {
                        state(() {
                          userData['full_name'] = val;
                        });
                      },
                      require: true,
                      value: userData['full_name'],
                    ),
                    Select(
                      selectOptions: group,
                      selectedValue: userData['group_id'],
                      label: '版主组',
                      require: true,
                      onChanged: (val) {
                        state(() {
                          userData['group_id'] = val;
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('取消'),
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: Text('确认保存'),
                onPressed: () {
                  ajax(
                    'Adminrelas-BbsUser-setUserInfo',
                    {
                      'uid': int.parse('${userData['uid']}'),
                      'fullName': userData['full_name'],
                      'groupId': userData['group_id']
                    },
                    true,
                    (data) {
                      Navigator.of(context).pop();
                      getData();
                    },
                    () {},
                    _context,
                  );
                },
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('用户列表'),
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
                      param.remove('login_name');
                    } else {
                      param['login_name'] = val;
                    }
                  },
                ),
                Input(
                  label: '用户昵称',
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('full_name');
                    } else {
                      param['full_name'] = val;
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
                                case 'option':
                                  con = Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: <Widget>[
                                      PrimaryButton(
                                        onPressed: () {
                                          editDialog(item);
                                        },
                                        child: Text('编辑'),
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
      floatingActionButtonAnimator: ScalingAnimation(),
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(
        FloatingActionButtonLocation.endFloat,
        floatingActionButtonOffsetX,
        floatingActionButtonOffsetY,
      ),
    );
  }
}
