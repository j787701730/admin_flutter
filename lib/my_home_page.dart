import 'dart:convert';

import 'package:admin_flutter/login.dart';
import 'package:admin_flutter/menu_data.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;
  DateTime _lastPressedAt; // 上次点击时间

  BuildContext _context;
  GlobalKey<_MenusWidgetState> _menusKey = GlobalKey<_MenusWidgetState>();

  @override
  void initState() {
    super.initState();
    _context = context;
  }

  @override
  void dispose() {
    super.dispose();
  }

  updateLog() {
    return showDialog<void>(
      context: _context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '更新内容',
          ),
          content: Container(
            width: MediaQuery.of(context).size.width - 100,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[],
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
              child: Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//  void countDown() {
//    // 设置倒计时三秒后执行跳转方法
//    Duration duration = Duration(seconds: 1);
//    setState(() {
//      isAjax = false;
//    });
//    Future.delayed(duration, checkLogin);
//  }

// 菜单筛选
  filterMenu(String val) {
    _menusKey.currentState.filterMenu(val);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        Fluttertoast.showToast(
          msg: '再按一次退出app',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt) > Duration(seconds: 1)) {
          // 两次点击间隔超过1秒则重新计时
          _lastPressedAt = DateTime.now();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('后台管理系统'),
          centerTitle: true,
          actions: <Widget>[
            UserOpera(),
            InkWell(
              child: Container(
                width: 56,
                child: Center(
                  child: Icon(
                    Icons.settings,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/AppSettings');
              },
            ),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            MenuSearchInput(filterMenu),
            MenusWidget(key: _menusKey),
          ],
        ),
      ),
    );
  }
}

class UserOpera extends StatefulWidget {
  @override
  _UserOperaState createState() => _UserOperaState();
}

class _UserOperaState extends State<UserOpera> {
  BuildContext _context;

  @override
  void initState() {
    super.initState();
    _context = context;
  }

  modifyPasswordDialog() {
    return showDialog<void>(
      context: _context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '修改密码',
          ),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                        '旧密码: ',
                        style: TextStyle(fontSize: CFFontSize.content),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 34,
                        child: TextField(
                          style: TextStyle(fontSize: CFFontSize.content),
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.only(top: 2, bottom: 2, left: 10, right: 10),
                            hintText: '输入新密码',
                          ),
                          obscureText: true,
                          onChanged: (String val) {
                            setState(() {
                              // password = val;
                            });
                          },
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  height: 15,
                  width: MediaQuery.of(context).size.width - 100,
                ),
                Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                        '新密码: ',
                        style: TextStyle(fontSize: CFFontSize.content),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 34,
                        child: TextField(
                          style: TextStyle(fontSize: CFFontSize.content),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              errorText: null,
                              contentPadding: EdgeInsets.only(top: 2, bottom: 2, left: 10, right: 10),
                              hintText: '输入新密码'),
                          obscureText: true,
                          onChanged: (String val) {
                            setState(() {
                              // password = val;
                            });
                          },
                        ),
                      ),
                    )
                  ],
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
      },
    );
  }

  login() {
    Navigator.pushAndRemoveUntil(
      _context,
      MaterialPageRoute(
        builder: (context) => Login(),
      ),
      (route) => route == null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      offset: Offset(0, 60),
      onSelected: (String value) {
        if (value == '0') {
          modifyPasswordDialog();
        } else if (value == '1') {
          login();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
        PopupMenuItem(
          value: "0",
          child: Row(
            children: <Widget>[
              Icon(
                Icons.settings,
                size: 20,
                color: CFColors.secondary,
              ),
              Container(
                width: 10,
              ),
              Text(
                "修改密码",
                style: TextStyle(
                  fontSize: CFFontSize.content,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: "1",
          child: Row(
            children: <Widget>[
              Icon(
                Icons.power_settings_new,
                size: 20,
                color: CFColors.secondary,
              ),
              Container(
                width: 10,
              ),
              Text(
                "退出",
                style: TextStyle(
                  fontSize: CFFontSize.content,
                ),
              )
            ],
          ),
        )
      ],
      child: Container(
        width: 56,
        child: Center(
          child: Icon(
            Icons.person,
          ),
        ),
      ),
    );
  }
}

class MenusWidget extends StatefulWidget {
  MenusWidget({Key key}) : super(key: key);

  @override
  _MenusWidgetState createState() => _MenusWidgetState();
}

class _MenusWidgetState extends State<MenusWidget> with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;
  List menu = [];
  List access = [];
  BuildContext _context;

  @override
  void initState() {
    super.initState();
    menu = jsonDecode(jsonEncode(menuData));
    _context = context;
    getAccess();
  }

  checkLogin() {
    Navigator.push(
      _context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  turnTo(path) {
    FocusScope.of(_context).requestFocus(FocusNode());
    if (path != null) {
      Navigator.pushNamed(_context, path);
    }
  }

  getAccess() {
    ajaxSimple('Adminrelas-Manage-getTest', {}, (res) {
      if (res.runtimeType != String && res['err_code'] == 0) {
        setState(() {
          access = res['data'];
        });
      } else {
        checkLogin();
      }
//      updateLog();
    }, netError: (val) {});
  }

  filterMenu(String val) {
    if (val == '') {
      setState(() {
        menu = jsonDecode(jsonEncode(menuData));
      });
    } else {
      List temp = [];
      for (int i = 0; i < menuData.length; i++) {
        Map o = jsonDecode(jsonEncode(menuData[i]));
        if (o['spell_all'].indexOf(val) > -1 || o['spell_index'].indexOf(val) > -1 || o['name'].indexOf(val) > -1) {
          temp.add(o);
        } else {
          int count = 0;
          for (int j = 0; j < o['children'].length; j++) {
            Map child = o['children'][j];
            if (child['spell_all'].indexOf(val) > -1 ||
                child['spell_index'].indexOf(val) > -1 ||
                child['name'].indexOf(val) > -1) {
              if (count == 0) {
                temp.add({
                  "spell_all": o['spell_all'],
                  "spell_index": o['spell_index'],
                  "name": o['name'],
                  "access": [o['access'][0]],
                  "children": [child]
                });
                count = 1;
              } else {
                temp[temp.length - 1]['children'].add(child);
              }
            }
          }
        }
      }
      setState(() {
        menu = jsonDecode(jsonEncode(temp));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return menu.isEmpty
        ? Container(
            alignment: Alignment.topCenter,
            child: Text(
              '无数据',
            ),
          )
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              children: menu.map<Widget>((item) {
                return access.indexOf(item['access'][0]) == -1
                    ? SizedBox(
                        width: 0,
                      )
                    : Container(
                        margin: EdgeInsets.only(bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                '${item['name']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Wrap(
                              children: item['children'].map<Widget>((child) {
                                return access.contains(child['access'][0])
                                    ? InkWell(
                                        onTap: () {
                                          turnTo(child['path']);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                          child: Text(
                                            '${child['name']}',
                                            style: TextStyle(
                                              color: child['path'] == null ? CFColors.text : CFColors.primary,
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        width: 0,
                                      );
                              }).toList(),
                            )
                          ],
                        ),
                      );
              }).toList(),
            ),
          );
  }
}

class MenuSearchInput extends StatefulWidget {
  final Function filterMenu;

  MenuSearchInput(this.filterMenu);

  @override
  _MenuSearchInputState createState() => _MenuSearchInputState();
}

class _MenuSearchInputState extends State<MenuSearchInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(44),
        ),
      ),
      margin: EdgeInsets.only(bottom: 15),
      child: TextField(
        style: TextStyle(
          fontSize: CFFontSize.content,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(),
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          contentPadding: EdgeInsets.only(
            top: 6,
            bottom: 6,
            left: 15,
          ),
          hintText: '请输入关键字',
        ),
        onChanged: (val) {
          widget.filterMenu(val.trim());
        },
      ),
    );
  }
}
