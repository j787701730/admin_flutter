import 'dart:async';

import 'package:admin_flutter/bbs/forum-add-modify.dart';
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
    });
    ajax('Adminrelas-Api-bbsForum', {}, true, (res) {
      if (mounted) {
        setState(() {
          print(res);
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
              padding: EdgeInsets.all(6),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Text('属性名称'),
                    ),
                  ),
                  Container(
                    width: 120,
                    margin: EdgeInsets.only(right: 10),
                    child: Text('帖子排序'),
                  ),
                  Container(
                    width: 80,
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
//                        {bfid: 15, bpfid: 0, bfname: 设计软件, bflogo: , bfsort: 0,
//                        bfchildren: [{bfid: 16, bpfid: 15, bfname: 晨丰家具设计软件,
//                        bflogo: Uploads/zone/user_-1/20181105/04e09921787728c905d0816c0e94767b.png, bfsort: 1}
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xffdddddd),
                                width: 1,
                              ),
                            ),
                          ),
                          margin: EdgeInsets.only(bottom: 10),
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
                                          child: Text('${item['bfname']}'),
                                        ),
                                      ),
                                      Container(
                                        width: 120,
                                        margin: EdgeInsets.only(right: 10),
                                        child: Text('${item['bfsort']}'),
                                      ),
                                      Container(
                                        width: 80,
                                        margin: EdgeInsets.only(right: 10),
                                        child: Text('操作'),
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
                                                        padding: EdgeInsets.only(left: 20),
                                                        child: Text('${child['bfname']}'),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 120,
                                                      margin: EdgeInsets.only(right: 10),
                                                      child: Text('${child['bfsort']}'),
                                                    ),
                                                    Container(
                                                      width: 80,
                                                      margin: EdgeInsets.only(right: 10),
                                                      child: Wrap(
                                                        spacing: 10,
                                                        runSpacing: 10,
                                                        children: <Widget>[
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
                                                            onTap: () {},
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
