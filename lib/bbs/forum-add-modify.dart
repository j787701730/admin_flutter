import 'dart:async';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ForumAddModify extends StatefulWidget {
  final props;

  ForumAddModify(this.props);

  @override
  _ForumAddModifyState createState() => _ForumAddModifyState();
}

class _ForumAddModifyState extends State<ForumAddModify> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map ajaxData = {};
  bool loading = false;
  Map isExpandedFlag = {};

  void _onRefresh() {
    setState(() {
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
    ajax('Adminrelas-Api-bbsForumEdit-forumId-${widget.props['bfid']}', {}, true, (res) {
      if (mounted) {
        setState(() {
          ajaxData = res['data'] ?? {};
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props == null ? '新增帖子' : '${widget.props['bfname']} 修改'}'),
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
                : Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Input(
                          label: '版块名称',
                          onChanged: (val) {
                            ajaxData['bbs_forum_name'] = val;
                          },
                          require: true,
                          value: ajaxData['bbs_forum_name'],
                        ),
                        Input(
                          label: '版块公告',
                          onChanged: (val) {
                            ajaxData['bbs_forum_announcement'] = val;
                          },
                          value: ajaxData['bbs_forum_announcement'],
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 80,
                                alignment: Alignment.centerRight,
                                child: Text('版主用户'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(
                                child: Container(
                                  child: ajaxData['bbs_forum_user'] is List
                                      ? Wrap(
                                          children: ajaxData['bbs_forum_user'].map<Widget>(
                                            (item) {
                                              return Container();
                                            },
                                          ).toList(),
                                        )
                                      : Container(),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 90),
                          margin: EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: <Widget>[
                              PrimaryButton(
                                onPressed: () {},
                                child: Text('添加用户'),
                              ),
                            ],
                          ),
                        ),
                        Input(
                          label: '版块简介',
                          onChanged: (val) {
                            ajaxData['bbs_forum_brief'] = val;
                          },
                          value: ajaxData['bbs_forum_brief'] ?? '',
                        ),
                        Input(
                          label: '版块排序',
                          require: true,
                          onChanged: (val) {
                            ajaxData['bbs_subject_sort'] = val;
                          },
                          value: ajaxData['bbs_subject_sort'] ?? '',
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 80,
                                alignment: Alignment.centerRight,
                                child: Text('版块主题'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(
                                child: Container(
                                  child: Container(),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 90),
                          margin: EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: <Widget>[
                              PrimaryButton(
                                onPressed: () {},
                                child: Text('添加主题'),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 80,
                                alignment: Alignment.centerRight,
                                child: Text('版主用户'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  child: Image.network(
                                    '$baseUrl${ajaxData['bbs_forum_logo']}',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
