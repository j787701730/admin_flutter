import 'dart:async';

import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ShopMenus extends StatefulWidget {
  @override
  _ShopMenusState createState() => _ShopMenusState();
}

class _ShopMenusState extends State<ShopMenus> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List rightsErp = [];
  List rightsPlat = [];
  bool loading = true;
  bool isExpandedFlag = true;
  int type = 1;
  double width;

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
    ajax('Adminrelas-ShopMenus-ajaxGetShopMenus', {}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          rightsErp = res['rightsErp'] ?? [];
          rightsPlat = res['rightsPlat'] ?? [];
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
      duration: Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  topDialog(item) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '信息',
          ),
          content: SingleChildScrollView(
            child: Container(
//                width: MediaQuery.of(context).size.width - 100,
              child: Text(
                '确认删除 ${item['name']}?',
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  content(data) {
    return Container(
      child: data.isEmpty
          ? Container(
              alignment: Alignment.center,
              child: Text(
                '无数据',
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.map<Widget>((item) {
                if (item['c'] != null && item['c'][item['c'].length - 1]['mnm'] != '') {
                  item['c'].add({'mnm': ''});
                }
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xffdddddd),
                    ),
                  ),
                  margin: EdgeInsets.only(
                    bottom: 10,
                  ),
                  padding: EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 100,
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('${item['mnm']}'),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: item['c'].map<Widget>(
                              (item2) {
                                if (item2['c'] != null && item2['c'][item2['c'].length - 1]['fnm'] != '') {
                                  item2['c'].add({'fnm': ''});
                                }
                                return '${item2['mnm']}' == ''
                                    ? Icon(
                                        Icons.add,
                                        color: Colors.green,
                                      )
                                    : Row(
                                        children: <Widget>[
                                          Container(
                                            width: 110,
                                            child: Text('${item2['mnm']}'),
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  left: BorderSide(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 6),
                                              margin: EdgeInsets.symmetric(
                                                vertical: 6,
//                                                        horizontal: 6,
                                              ),
                                              child: item2['c'] == null
                                                  ? Container()
                                                  : Wrap(
                                                      spacing: 10,
                                                      runSpacing: 10,
                                                      children: item2['c'].map<Widget>(
                                                        (item3) {
                                                          return '${item3['fnm']}' == ''
                                                              ? Icon(
                                                                  Icons.add,
                                                                  color: Colors.green,
                                                                )
                                                              : Container(
                                                                  padding: EdgeInsets.symmetric(
                                                                    horizontal: 4,
                                                                  ),
                                                                  decoration: BoxDecoration(
                                                                    color: '${item3['kp']}' == '1'
                                                                        ? Color(0xffFFFCED)
                                                                        : Color(0xffE5F5FF),
                                                                    border: Border.all(
                                                                      color: '${item3['kp']}' == '1'
                                                                          ? Color(0xffEFA843)
                                                                          : Color(0xff79CAFF),
                                                                    ),
                                                                  ),
                                                                  child: Text(' ${item3['fnm']}'),
                                                                );
                                                        },
                                                      ).toList(),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      );
                              },
                            ).toList(),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('菜单设置'),
        leading: IconButton(
          icon: const BackButtonIcon(),
          color: Colors.white,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
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
            Container(
              margin: EdgeInsets.only(
                bottom: 15,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CFColors.primary,
                  ),
                ),
              ),
              child: Wrap(
                runSpacing: 10,
                spacing: 12,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        type = 1;
                      });
                    },
                    child: Container(
                      child: Text(
                        'ERP权限',
                        style: TextStyle(
                          color: type == 1 ? CFColors.primary : CFColors.text,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        type = 2;
                      });
                    },
                    child: Container(
                      child: Text(
                        '生产权限（MES）',
                        style: TextStyle(
                          color: type == 2 ? CFColors.primary : CFColors.text,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            loading
                ? Container(
                    alignment: Alignment.center,
                    child: CupertinoActivityIndicator(),
                  )
                : Column(
                    children: <Widget>[
                      Offstage(
                        offstage: type == 1,
                        child: content(rightsErp),
                      ),
                      Offstage(
                        offstage: type == 2,
                        child: content(rightsPlat),
                      )
                    ],
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
