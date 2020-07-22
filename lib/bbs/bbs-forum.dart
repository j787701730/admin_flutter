import 'dart:async';

import 'package:admin_flutter/bbs/forum-add-modify.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BbsForum extends StatefulWidget {
  @override
  _BbsForumState createState() => _BbsForumState();
}

class _BbsForumState extends State<BbsForum> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  List ajaxData = [];
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
      isExpandedFlag.clear();
    });
    ajax('Adminrelas-Api-bbsForum', {}, true, (res) {
      if (mounted) {
        setState(() {
          ajaxData = res['data'];
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

  forumModify(item) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (context) => ForumAddModify(item),
      ),
    );
  }

  delDialog(item) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '系统提示',
          ),
          content: SingleChildScrollView(
            child: Container(
//              width: MediaQuery.of(context).size.width * 0.8,
              child: Text('确认删除 ${item['bfname']} ?'),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('关闭'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            PrimaryButton(
              child: Text('确认'),
              onPressed: () {
                ajax('Adminrelas-bbsForum-delForum', {'forumId': item['bfid']}, true, (data) {
                  Navigator.of(context).pop();
                  getData();
                }, () {}, _context);
              },
            ),
          ],
        );
      },
    );
  }

  addAndModifyDialog(item, {flag = true}) {
    Map submitData = {'n': '', 's': '1'};
    if (flag) {
      submitData['n'] = item['bfname'];
      submitData['s'] = item['bfsort'];
    }
    return showDialog<void>(
      context: _context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            flag ? '${item['bfname']} 修改' : item == null ? '新增帖子' : '${item['bfname']} 新增子帖子',
          ),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                children: <Widget>[
                  Input(
                    label: '帖子名称',
                    require: true,
                    onChanged: (val) {
                      submitData['n'] = val;
                    },
                    value: submitData['n'],
                  ),
                  Input(
                    label: '帖子排序',
                    require: true,
                    onChanged: (val) {
                      submitData['s'] = val;
                    },
                    value: submitData['s'],
                  )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('关闭'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            PrimaryButton(
              child: Text('确认'),
              onPressed: () {
                print(submitData);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('版块管理'),
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
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Wrap(
                runSpacing: 10,
                spacing: 10,
                children: <Widget>[
                  PrimaryButton(
                    onPressed: () {
                      addAndModifyDialog(null, flag: false);
                    },
                    child: Text('添加帖子'),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(6),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Text('帖子名称'),
                    ),
                  ),
                  Container(
                    width: 100,
                    margin: EdgeInsets.only(right: 10),
                    child: Text('帖子排序'),
                  ),
                  Container(
                    width: 120,
                    margin: EdgeInsets.only(right: 10),
                    child: Text('操作'),
                  ),
                ],
              ),
              color: Color(0xffeeeeee),
            ),
            loading
                ? CupertinoActivityIndicator()
                : Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ajaxData.map<Widget>((item) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xffdddddd),
                                width: 1,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    if (isExpandedFlag['${item['bfid']}'] == true) {
                                      isExpandedFlag['${item['bfid']}'] = false;
                                    } else {
                                      isExpandedFlag['${item['bfid']}'] = true;
                                    }
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          child: Row(
                                            children: <Widget>[
                                              Icon(
                                                isExpandedFlag['${item['bfid']}'] == true
                                                    ? Icons.keyboard_arrow_up
                                                    : Icons.keyboard_arrow_down,
                                              ),
                                              Text('${item['bfname']}'),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 100,
                                        margin: EdgeInsets.only(right: 10),
                                        child: Text('${item['bfsort']}'),
                                      ),
                                      Container(
                                        width: 120,
                                        margin: EdgeInsets.only(right: 10),
                                        child: Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: <Widget>[
                                            InkWell(
                                              onTap: () {
                                                addAndModifyDialog(item);
                                              },
                                              child: Text(
                                                '修改',
                                                style: TextStyle(
                                                  color: CFColors.primary,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                addAndModifyDialog(item, flag: false);
                                              },
                                              child: Text(
                                                '添加',
                                                style: TextStyle(
                                                  color: CFColors.primary,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                delDialog(item);
                                              },
                                              child: Text(
                                                '删除',
                                                style: TextStyle(
                                                  color: CFColors.danger,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              AnimatedCrossFade(
                                duration: const Duration(
                                  milliseconds: 300,
                                ),
                                firstChild: Placeholder(
                                  fallbackHeight: 0.1,
                                  color: Colors.transparent,
                                ),
                                secondChild: Column(children: <Widget>[
                                  item['bfchildren'] is List && item['bfchildren'].isNotEmpty
                                      ? Column(
                                          children: item['bfchildren'].map<Widget>(
                                            (child) {
                                              return Container(
                                                padding: EdgeInsets.all(6),
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Container(
                                                        padding: EdgeInsets.only(left: 42),
                                                        child: Text('${child['bfname']}'),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 100,
                                                      margin: EdgeInsets.only(right: 10),
                                                      child: Text('${child['bfsort']}'),
                                                    ),
                                                    Container(
                                                      width: 120,
                                                      margin: EdgeInsets.only(right: 10),
                                                      child: Wrap(
                                                        spacing: 10,
                                                        runSpacing: 10,
                                                        children: <Widget>[
                                                          InkWell(
                                                            child: Text(
                                                              '修改',
                                                              style: TextStyle(
                                                                color: CFColors.primary,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              addAndModifyDialog(child);
                                                            },
                                                          ),
                                                          InkWell(
                                                            child: Text(
                                                              '编辑',
                                                              style: TextStyle(
                                                                color: CFColors.primary,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              forumModify(child);
                                                            },
                                                          ),
                                                          InkWell(
                                                            child: Text(
                                                              '删除',
                                                              style: TextStyle(
                                                                color: CFColors.danger,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              delDialog(child);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ).toList(),
                                        )
                                      : Container()
                                ]),
                                crossFadeState: isExpandedFlag['${item['bfid']}'] == true
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
