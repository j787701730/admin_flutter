import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/user_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
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
  Map selectUsersData = {};

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
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          behavior: HitTestBehavior.opaque,
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
                                    constraints: BoxConstraints(
                                      minHeight: 34,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: CFColors.text,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    padding: EdgeInsets.all(6),
                                    child: Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: selectUsersData.keys.toList().map<Widget>((key) {
                                        Map item = selectUsersData[key];
                                        return Container(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text('${item['login_name']}'),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    selectUsersData.remove(key);
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.close,
                                                  color: CFColors.danger,
                                                  size: 20,
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
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
                                  onPressed: () {
                                    Navigator.push(
                                      _context,
                                      MaterialPageRoute(
                                        builder: (context) => UserPlugin(
                                          userCount: 0,
                                          selectUsersData: jsonDecode(jsonEncode(selectUsersData)),
                                        ),
                                      ),
                                    ).then((value) {
                                      if (value != null) {
                                        setState(() {
                                          selectUsersData = jsonDecode(
                                            jsonEncode(value),
                                          );
                                        });
                                      }
                                    });
                                  },
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 80,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        '* ',
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                      Text('版块主题')
                                    ],
                                  ),
                                  margin: EdgeInsets.only(right: 10, top: 5),
                                ),
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        height: 34,
                                        margin: EdgeInsets.only(bottom: 10),
                                        color: Color(0xffeeeeee),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(' 主题名称'),
                                            ),
                                            Container(
                                              margin: EdgeInsets.symmetric(horizontal: 10),
                                              width: 80,
                                              child: Text(' 排序'),
                                            ),
                                            Container(
                                              width: 44,
                                              child: Text(' 操作'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: ajaxData['subject'] != null && ajaxData['subject'] is List
                                            ? Column(
                                                children: ajaxData['subject'].map<Widget>((item) {
                                                return Container(
                                                  child: Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Input(
                                                          label: '',
                                                          onChanged: (val) {},
                                                          value: item['bbs_subject_name'] ?? '',
                                                          labelWidth: 0,
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.symmetric(horizontal: 10),
                                                        width: 80,
                                                        child: Input(
                                                          label: '',
                                                          onChanged: (val) {},
                                                          value: item['bbs_subject_sort'] ?? '',
                                                          labelWidth: 0,
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 44,
                                                        child: InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              ajaxData['subject'].remove(item);
                                                              if (ajaxData['subject'].isEmpty) {
                                                                ajaxData['subject'].add({
                                                                  'bbs_forum_id': 16,
                                                                  'bbs_subject_name': '',
                                                                  'bbs_subject_recommend': '',
                                                                  'bbs_subject_sort':
                                                                      ajaxData['subject'].length.toString()
                                                                });
                                                              }
                                                            });
                                                          },
                                                          child: Icon(
                                                            Icons.restore_from_trash,
                                                            color: CFColors.danger,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }).toList())
                                            : Container(),
                                      ),
                                    ],
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
                                  onPressed: () {
                                    setState(() {
                                      ajaxData['subject'].add({
                                        'bbs_forum_id': 16,
                                        'bbs_subject_name': '',
                                        'bbs_subject_recommend': '',
                                        'bbs_subject_sort': ajaxData['subject'].length.toString()
                                      });
                                    });
                                  },
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
                                  child: Text('版块logo'),
                                  margin: EdgeInsets.only(right: 10),
                                ),
                                Expanded(
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: CFColors.text),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        width: 100,
                                        height: 100,
                                        child: Image.network(
                                          '$baseUrl${ajaxData['bbs_forum_logo']}',
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            margin: EdgeInsets.only(left: 90, top: 10),
                            child: Row(
                              children: <Widget>[
                                PrimaryButton(
                                  onPressed: () {
                                    FocusScope.of(context).requestFocus(FocusNode());
                                  },
                                  child: Text('确认保存'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
