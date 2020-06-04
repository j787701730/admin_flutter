import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/base/sitemap_modify_three.dart';
import 'package:admin_flutter/base/sitemap_modify_top.dart';
import 'package:admin_flutter/base/sitemap_modify_two.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BaseSitemap extends StatefulWidget {
  @override
  _BaseSitemapState createState() => _BaseSitemapState();
}

class _BaseSitemapState extends State<BaseSitemap> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  List ajaxData = [];
  bool loading = true;

  void _onRefresh() async {
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

  getData({isRefresh: false}) async {
    setState(() {
      loading = true;
    });
    ajax('Adminrelas-WebSysConfig-getWebSiteMap', {}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('网站导航'),
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
                Container(
                  child: PrimaryButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SiteMapModifyTop(null),
                        ),
                      );
                    },
                    child: Text('添加顶级菜单'),
                  ),
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
                                children: ajaxData.map<Widget>((item) {
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Colors.grey, width: 1),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(bottom: 10),
                                          alignment: Alignment.center,
                                          child: Wrap(
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            runSpacing: 10,
                                            spacing: 10,
                                            children: <Widget>[
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => SiteMapModifyTop({'item': item}),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  '${item['mnm']}',
                                                ),
                                              ),
                                              PrimaryButton(
                                                onPressed: () {},
                                                child: Text(
                                                  '添加二级菜单',
                                                  style: TextStyle(fontSize: 14),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: item['c'].map<Widget>((c) {
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  margin: EdgeInsets.only(bottom: 10),
                                                  alignment: Alignment.center,
                                                  child: Wrap(
                                                    crossAxisAlignment: WrapCrossAlignment.center,
                                                    runSpacing: 10,
                                                    spacing: 10,
                                                    children: <Widget>[
                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  SiteMapModifyTwo({'item': c, 'data': ajaxData}),
                                                            ),
                                                          );
                                                        },
                                                        child: Text('${c['mnm']}'),
                                                      ),
                                                      PrimaryButton(
                                                        onPressed: () {},
                                                        child: Text(
                                                          '添加三级菜单',
                                                          style: TextStyle(fontSize: 14),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(bottom: 10),
                                                  child: Wrap(
                                                    spacing: 10,
                                                    runSpacing: 10,
                                                    children: c['c'].map<Widget>((cc) {
                                                      return Stack(
                                                        overflow: Overflow.visible,
                                                        children: <Widget>[
                                                          Container(
                                                            padding: EdgeInsets.only(
                                                              left: 10,
                                                              right: 10,
                                                              top: 6,
                                                              bottom: 6,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              border: Border.all(color: Color(0xffEFA843), width: 1),
                                                              color: Color(0xffFFFCED),
                                                            ),
                                                            child: InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => SiteMapModifyThree({
                                                                      'item': cc,
                                                                      'data': ajaxData,
                                                                      'pmid': c['mid']
                                                                    }),
                                                                  ),
                                                                );
                                                              },
                                                              child: Text('${cc['mnm']}'),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: -4,
                                                            right: -4,
                                                            child: cc['map_type'] == '0'
                                                                ? Container(
                                                                    width: 0,
                                                                  )
                                                                : cc['map_type'] == '1'
                                                                    ? Image.network(
                                                                        '${baseUrl}Public/images/nav-hot.gif')
                                                                    : Image.network(
                                                                        '${baseUrl}Public/images/nav-new.gif'),
                                                          )
                                                        ],
                                                      );
                                                    }).toList(),
                                                  ),
                                                )
                                              ],
                                            );
                                          }).toList(),
                                        )
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
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
