import 'dart:async';

import 'package:admin_flutter/plugin/city_select_plugin.dart';
import 'package:admin_flutter/plugin/shop_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ArticleList extends StatefulWidget {
  @override
  _ArticleListState createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  int curr_page = 1;
  int page_count = 20;
  Map param = {};
  List logs = [];
  int count = 0;
  BuildContext _context;
  ScrollController _controller;
  Map searchData = {'user_name': '', 'ip': '', 'err_code': '', 'url': ''};
  Map searchName = {'user_name': '用户', 'ip': 'IP地址', 'err_code': '错误码', 'url': '访问路径'};

  DateTime create_date_min;
  DateTime create_date_max;

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    setState(() {
      curr_page = 1;
      getData(isRefresh: true);
    });
  }

//  void _onLoading() async{
//    // monitor network fetch
//    await Future.delayed(Duration(milliseconds: 1000));
//    // if failed,use loadFailed(),if no data return,use LoadNodata()
////    items.add((items.length+1).toString());
//    if(mounted)
//      setState(() {
//
//      });
//    _refreshController.loadComplete();
//  }

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
//    ajax(
//        'Adminrelas-Logs-csLogs',
//        {'curr_page': curr_page, 'page_count': page_count, 'param': jsonEncode(param)},
//        true, (res) {
//      if (mounted) {
//        setState(() {
//          logs = res['data'];
//          count = int.tryParse(res['count']);
//          toTop();
//        });
//        if (isRefresh) {
//          _refreshController.refreshCompleted();
//        }
//      }
//    }, () {}, _context);
  }

  toTop() {
    _controller.animateTo(
      0,
      duration: new Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  Map shopData = {};

  getArea(val) {
    print(val);
  }

  String _url = "share text from fluwx";
  String _title = "Fluwx";
  String _thumnail = "https://www.ihome6.com/Public/images/index-2018/6_02.jpg";
  fluwx.WeChatScene scene = fluwx.WeChatScene.SESSION;

  void _share() {
    fluwx.registerWxApi(appId: "wxd930ea5d5a258f4f", universalLink: "https://your.univeral.link.com/placeholder/");
    var model = fluwx.WeChatShareTextModel('xxxx', scene: fluwx.WeChatScene.SESSION);
    fluwx.shareToWeChat(model);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('文章列表'),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
//          onLoading: _onLoading,
        child: ListView(
          padding: EdgeInsets.all(10),
          controller: _controller,
          children: <Widget>[
            Wrap(
              spacing: 10,
              children: <Widget>[
                PrimaryButton(
                  child: Text('多选'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new ShopPlugin(
                                shopCount: 0,
                                selectShopsData: shopData,
                              )),
                    ).then((val) {
                      if (val != null) {
                        setState(() {
                          shopData = val;
                        });
                      }
                    });
                  },
                ),
                PrimaryButton(
                  child: Text('单选'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new ShopPlugin(
                                shopCount: 1,
                                selectShopsData: shopData,
                              )),
                    ).then((val) {
                      print(val);
                      if (val != null) {
                        setState(() {
                          shopData = val;
                        });
                      }
                    });
                  },
                ),
                PrimaryButton(
                  child: Text('选2个'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new ShopPlugin(
                                shopCount: 2,
                                selectShopsData: shopData,
                              )),
                    ).then((val) {
                      print(val);
                      if (val != null) {
                        setState(() {
                          shopData = val;
                        });
                      }
                    });
                  },
                ),
                Column(
                  children: shopData.keys.map<Widget>((key) {
                    return Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text(
                              shopData[key]['shop_name'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  shopData.remove(key);
                                });
                              })
                        ],
                      ),
                    );
                  }).toList(),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 80,
                        alignment: Alignment.centerRight,
                        child: Text('地址'),
                      ),
                      Expanded(
                        flex: 1,
                        child: CitySelectPlugin(
                          getArea: getArea,
                        ),
                      )
                    ],
                  ),
                ),
                Wrap(
                  children: <Widget>[PrimaryButton(onPressed: _share, child: Text('分享微信'))],
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
