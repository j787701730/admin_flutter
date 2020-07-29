import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/base/phone-menu-add-modify.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
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
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  bool sellerExpanded = false;
  bool buyerExpanded = false;
  String sellerSelectKey = '';
  String buyerSelectKey = '';
  String moveKey = '';
  Map menus = {};

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

  void _onRefresh() {
    setState(() {
      getParamData(isRefresh: true);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _context = context;
    Timer(Duration(milliseconds: 200), () {
      getParamData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getParamData({isRefresh: false}) {
    ajax('Adminrelas-Api-phoneMenusData', {}, true, (data) {
      if (mounted) {
        setState(() {
          menus = data['data'];
        });
        if (isRefresh) {
          _refreshController.refreshCompleted();
        }
      }
    }, () {}, _context);
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

  moveDialog(item, menuID, parentMenuID) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context1, state) {
          return AlertDialog(
            title: Text(
              '${item['mnm']} 移动',
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
                  print(menuID);
                  print(parentMenuID);
                  ajax(
                      'Adminrelas-WebSysConfig-alterPhoneMenus',
                      {
                        'data': jsonEncode({"menu_id": menuID, "parent_menu_id": parentMenuID})
                      },
                      true, (data) {
                    getParamData();
                    Navigator.of(context).pop();
                  }, () {}, _context);
                },
              ),
            ],
          );
        });
      },
    );
  }

  delDialog(item, menuID, {type: ''}) {
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
                ajax('Adminrelas-WebSysConfig-delPhoneMenus', {'menu_id': menuID}, true, (data) {
                  setState(() {
                    if (type == 'sellerSelectKey') {
                      sellerSelectKey = '';
                    } else if (type == buyerSelectKey) {
                      buyerSelectKey = '';
                    }
                    getParamData();
                  });
                }, () {}, _context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  phoneMenuAddModify(item, parentMenuID, menuID) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (context) => PhoneMenuAddModify(
          item: item,
          parentMenuID: parentMenuID,
          menuID: menuID,
        ),
      ),
    ).then((value) {
      if (value) {
        getParamData();
      }
    });
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
              firstChild: Placeholder(
                fallbackHeight: 0.1,
                color: Colors.transparent,
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
                            onPressed: () {
                              phoneMenuAddModify({'mt': '2'}, '0', null);
                            },
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
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 4),
                                                        child: Text(
                                                          '${menu['mnm']}',
                                                          style: TextStyle(
                                                            color: Color(0xffff4400),
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.edit,
                                                          size: 20,
                                                          color: CFColors.primary,
                                                        ),
                                                        onPressed: () {
                                                          phoneMenuAddModify(menu, '0', key);
                                                        },
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          delDialog(menu, sellerSelectKey, type: 'sellerSelectKey');
                                                        },
                                                        icon: Icon(
                                                          Icons.delete_outline,
                                                          size: 20,
                                                          color: CFColors.danger,
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : Row(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 4),
                                                        child: Text(
                                                          '${menu['mnm']}',
                                                        ),
                                                      ),
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
                        onPressed: () {
                          phoneMenuAddModify({'mt': '2'}, sellerSelectKey, null);
                        },
                        child: Text(
                          '新增子工具',
                        ),
                      ),
                    ),
                    sellerSelectKey == '' || menus[sellerSelectKey]['c'] == null
                        ? Container(
                            alignment: Alignment.center,
                            child: Text('无数据'),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: menus[sellerSelectKey]['c'].keys.toList().map<Widget>((key) {
                              Map item = menus[sellerSelectKey]['c'][key];
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xffdddddd),
                                  ),
                                ),
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
                                            PrimaryButton(
                                              onPressed: () {
                                                phoneMenuAddModify(item, sellerSelectKey, key);
                                              },
                                              child: Text('修改'),
                                            ),
                                            PrimaryButton(
                                              onPressed: () {
                                                setState(() {
                                                  moveKey = sellerSelectKey;
                                                  moveDialog(item, key, sellerSelectKey);
                                                });
                                              },
                                              child: Text('移动'),
                                            ),
                                            PrimaryButton(
                                              onPressed: () {
                                                delDialog(item, key);
                                              },
                                              child: Text('删除'),
                                              type: BtnType.danger,
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
              firstChild: Placeholder(
                fallbackHeight: 0.1,
                color: Colors.transparent,
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
                            onPressed: () {
                              phoneMenuAddModify({'mt': '1'}, '0', null);
                            },
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
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 4),
                                                        child: Text(
                                                          '${menu['mnm']}',
                                                          style: TextStyle(
                                                            color: Color(0xffff4400),
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.edit,
                                                          size: 20,
                                                          color: CFColors.primary,
                                                        ),
                                                        onPressed: () {
                                                          phoneMenuAddModify(menu, '0', key);
                                                        },
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          delDialog(menu, buyerSelectKey, type: 'buyerSelectKey');
                                                        },
                                                        icon: Icon(
                                                          Icons.delete_outline,
                                                          size: 20,
                                                          color: CFColors.danger,
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : Row(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 4),
                                                        child: Text(
                                                          '${menu['mnm']}',
                                                        ),
                                                      ),
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
                        onPressed: () {
                          phoneMenuAddModify({'mt': '1'}, buyerSelectKey, null);
                        },
                        child: Text(
                          '新增子工具',
                        ),
                      ),
                    ),
                    buyerSelectKey == '' || menus[buyerSelectKey]['c'] == null
                        ? Container(
                            alignment: Alignment.center,
                            child: Text('无数据'),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: menus[buyerSelectKey]['c'].keys.toList().map<Widget>((key) {
                              Map item = menus[buyerSelectKey]['c'][key];
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xffdddddd),
                                  ),
                                ),
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
                                            PrimaryButton(
                                              onPressed: () {
                                                phoneMenuAddModify(item, buyerSelectKey, key);
                                              },
                                              child: Text('修改'),
                                            ),
                                            PrimaryButton(
                                              onPressed: () {
                                                setState(() {
                                                  moveKey = buyerSelectKey;
                                                  moveDialog(item, key, buyerSelectKey);
                                                });
                                              },
                                              child: Text('移动'),
                                            ),
                                            PrimaryButton(
                                              onPressed: () {
                                                delDialog(item, key);
                                              },
                                              child: Text('删除'),
                                              type: BtnType.danger,
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
      floatingActionButtonAnimator: ScalingAnimation(),
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(
        FloatingActionButtonLocation.endFloat,
        floatingActionButtonOffsetX,
        floatingActionButtonOffsetY,
      ),
    );
  }
}
