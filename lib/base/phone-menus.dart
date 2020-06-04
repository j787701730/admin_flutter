import 'dart:async';
import 'dart:convert';
import 'package:admin_flutter/style.dart';

import 'phone-menus-data.dart';

import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PhoneMenus extends StatefulWidget {
  @override
  _PhoneMenusState createState() => _PhoneMenusState();
}

class _PhoneMenusState extends State<PhoneMenus> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  bool sellerExpanded = false;
  bool buyerExpanded = false;
  String sellerSelectKey = '';
  String buyerSelectKey = '';
  String moveKey = '';

  List columns = [
    {'title': '图标', 'key': 'mio'},
    {'title': '中文名', 'key': 'mnm'},
    {'title': '英文名', 'key': 'mnm_en'},
    {'title': 'URL', 'key': 'mul'},
    {'title': 'target', 'key': 'tg'},
    {'title': '常用', 'key': 'ih'},
    {'title': '排序', 'key': 'mst'},
    {'title': '备注', 'key': 'cm'},
    {'title': '操作', 'key': 'option'},
  ];

  void _onRefresh() async {
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
//      getData();
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
    ajax('Adminrelas-goodsConfig-getAttrByClassID', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'] ?? [];
          count = int.tryParse('${res['count'] ?? 0}');
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

  getPage(page) {
    param['curr_page'] += page;
    getData();
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
                '确认${item['top'].toString() == '1' ? '取消' : ''} ${item['task_name']} 置顶?',
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

  moveDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context1, state) {
          return AlertDialog(
            title: Text(
              '移动',

            ),
            content: Container(
              height: 50,
              width: MediaQuery.of(_context).size.width - 100,
              child: Row(
                children: <Widget>[
                  Container(
                    child: Text('父工具栏'),
                    margin: EdgeInsets.only(
                      right: 12,
                    ),
                  ),
                  Expanded(
                    child: DropdownButton<String>(
                      value: moveKey,
                      onChanged: (String newValue) {
                        setState(() {
                          moveKey = newValue;
                        });
                        state(() {
                          moveKey = newValue;
                        });
                      },
                      items: menus.keys.toList().map<DropdownMenuItem<String>>((key) {
                        Map item = menus[key];
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text('${item['mnm']}(${item['mt'] == '1' ? '买家' : '卖家'})'),
                        );
                      }).toList(),
                    ),
                  )
                ],
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
        });
      },
    );
  }

  delDialog(item) {
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
                '确认删除 ${item['mnm']} ?',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('更多工具'),
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
            GestureDetector(
              onTap: () {
                setState(() {
                  sellerExpanded = !sellerExpanded;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xffd6e9c6),
                  ),
                  color: Color(0xffdff0d8),
                ),
                child: Text(
                  '卖家中心手机端菜单设置',
                  style: TextStyle(
                    color: Color(0xff3c763d),
                  ),
                ),
                alignment: Alignment.center,
              ),
            ),
            AnimatedCrossFade(
              firstChild: Container(
                height: 0,
              ),
              secondChild: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 40,
                      margin: EdgeInsets.only(
                        bottom: 10,
                        top: 10,
                      ),
                      child: Row(
                        children: <Widget>[
                          PrimaryButton(
                            onPressed: () {},
                            child: Text(
                              '新增',
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: menus.keys.toList().map<Widget>(
                                (key) {
                                  Map menu = menus[key];
                                  if (sellerSelectKey == '' && menu['mt'] == '2') {
                                    sellerSelectKey = key;
                                  }
                                  return menu['mt'] == '2'
                                      ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              sellerSelectKey = key;
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: sellerSelectKey == key ? Color(0xffff4400) : Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            child: sellerSelectKey == key
                                                ? Row(
                                                    children: <Widget>[
                                                      Text(
                                                        '${menu['mnm']}',
                                                        style: TextStyle(
                                                          color: Color(0xffff4400),
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.edit,
                                                        size: 20,
                                                        color: CFColors.primary,
                                                      ),
                                                      Icon(
                                                        Icons.delete_outline,
                                                        size: 20,
                                                        color: CFColors.danger,
                                                      ),
                                                    ],
                                                  )
                                                : Row(
                                                    children: <Widget>[
                                                      Text('${menu['mnm']}'),
                                                    ],
                                                  ),
                                          ),
                                        )
                                      : Container(
                                          width: 0,
                                        );
                                },
                              ).toList(),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        bottom: 10,
                      ),
                      alignment: Alignment.centerLeft,
                      child: PrimaryButton(
                        onPressed: () {},
                        child: Text(
                          '新增子工具',
                        ),
                      ),
                    ),
                    sellerSelectKey == ''
                        ? Container()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: menus[sellerSelectKey]['c'].keys.toList().map<Widget>((key) {
                              Map item = menus[sellerSelectKey]['c'][key];
                              return Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                  color: Color(0xffdddddd),
                                )),
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: columns.map<Widget>((col) {
                                    Widget con = Text('${item[col['key']] ?? ''}');
                                    switch (col['key']) {
                                      case 'mio':
                                        con = Container(
                                          alignment: Alignment.centerLeft,
                                          width: 60,
                                          height: 60,
                                          child: Image.network('$baseUrl/Public/images/phone_menu_icon/${item['mio']}'),
                                        );
                                        break;
                                      case 'ih':
                                        con = Text('${item['ih'].toString() == '1' ? '是' : '否'}');
                                        break;
                                      case 'option':
                                        con = Wrap(
                                          runSpacing: 10,
                                          spacing: 10,
                                          children: <Widget>[
                                            Container(
                                              height: 30,
                                              child: PrimaryButton(
                                                onPressed: () {
                                                  topDialog(item);
                                                },
                                                child: Text('修改'),
                                              ),
                                            ),
                                            Container(
                                              height: 30,
                                              child: PrimaryButton(
                                                onPressed: () {
                                                  setState(() {
                                                    moveKey = sellerSelectKey;
                                                    moveDialog();
                                                  });
                                                },
                                                child: Text('移动'),
                                              ),
                                            ),
                                            Container(
                                              height: 30,
                                              child: PrimaryButton(
                                                onPressed: () {
                                                  delDialog(item);
                                                },
                                                child: Text('删除'),
                                                type: 'error',
                                              ),
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
                                          Expanded(flex: 1, child: con)
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            }).toList(),
                          )
                  ],
                ),
              ),
              crossFadeState: sellerExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: const Duration(
                milliseconds: 300,
              ),
            ),
            Container(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  buyerExpanded = !buyerExpanded;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xffbce8f1),
                  ),
                  color: Color(0xffd9edf7),
                ),
                child: Text(
                  '买家中心手机端菜单设置',
                  style: TextStyle(
                    color: Color(0xff31708f),
                  ),
                ),
                alignment: Alignment.center,
              ),
            ),
            AnimatedCrossFade(
              firstChild: Container(
                height: 0,
              ),
              secondChild: Container(
                margin: EdgeInsets.only(
                  top: 10,
                  bottom: 6,
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 40,
                      margin: EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Row(
                        children: <Widget>[
                          PrimaryButton(
                            onPressed: () {},
                            child: Text(
                              '新增',
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: menus.keys.toList().map<Widget>(
                                (key) {
                                  Map menu = menus[key];
                                  if (buyerSelectKey == '' && menu['mt'] == '1') {
                                    buyerSelectKey = key;
                                  }
                                  return menu['mt'] == '1'
                                      ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              buyerSelectKey = key;
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: buyerSelectKey == key ? Color(0xffff4400) : Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            child: buyerSelectKey == key
                                                ? Row(
                                                    children: <Widget>[
                                                      Text(
                                                        '${menu['mnm']}',
                                                        style: TextStyle(
                                                          color: Color(0xffff4400),
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.edit,
                                                        size: 20,
                                                        color: CFColors.primary,
                                                      ),
                                                      Icon(
                                                        Icons.delete_outline,
                                                        size: 20,
                                                        color: CFColors.danger,
                                                      ),
                                                    ],
                                                  )
                                                : Row(
                                                    children: <Widget>[
                                                      Text('${menu['mnm']}'),
                                                    ],
                                                  ),
                                          ),
                                        )
                                      : Container(
                                          width: 0,
                                        );
                                },
                              ).toList(),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        bottom: 10,
                      ),
                      alignment: Alignment.centerLeft,
                      child: PrimaryButton(
                        onPressed: () {},
                        child: Text(
                          '新增子工具',
                        ),
                      ),
                    ),
                    buyerSelectKey == ''
                        ? Container()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: menus[buyerSelectKey]['c'].keys.toList().map<Widget>((key) {
                              Map item = menus[buyerSelectKey]['c'][key];
                              return Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                  color: Color(0xffdddddd),
                                )),
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: columns.map<Widget>((col) {
                                    Widget con = Text('${item[col['key']] ?? ''}');
                                    switch (col['key']) {
                                      case 'mio':
                                        con = Container(
                                          alignment: Alignment.centerLeft,
                                          width: 60,
                                          height: 60,
                                          child: Image.network('$baseUrl/Public/images/phone_menu_icon/${item['mio']}'),
                                        );
                                        break;
                                      case 'ih':
                                        con = Text('${item['ih'].toString() == '1' ? '是' : '否'}');
                                        break;
                                      case 'option':
                                        con = Wrap(
                                          runSpacing: 10,
                                          spacing: 10,
                                          children: <Widget>[
                                            Container(
                                              height: 30,
                                              child: PrimaryButton(
                                                onPressed: () {
                                                  topDialog(item);
                                                },
                                                child: Text('修改'),
                                              ),
                                            ),
                                            Container(
                                              height: 30,
                                              child: PrimaryButton(
                                                onPressed: () {
                                                  setState(() {
                                                    moveKey = sellerSelectKey;
                                                    moveDialog();
                                                  });
                                                },
                                                child: Text('移动'),
                                              ),
                                            ),
                                            Container(
                                              height: 30,
                                              child: PrimaryButton(
                                                onPressed: () {
                                                  delDialog(item);
                                                },
                                                child: Text('删除'),
                                                type: 'error',
                                              ),
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
                                          Expanded(flex: 1, child: con)
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            }).toList(),
                          )
                  ],
                ),
              ),
              crossFadeState: buyerExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: const Duration(
                milliseconds: 300,
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
