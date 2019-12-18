import 'dart:convert';

import 'package:admin_flutter/login.dart';
import 'package:admin_flutter/menu_data.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List menu = [];
  String searchStr = '';
  bool isLogin = false;
  bool isAjax = true;
  DateTime _lastPressedAt; // 上次点击时间
  BuildContext _context;
  List access = [];

  @override
  void initState() {
    super.initState();
    menu = jsonDecode(jsonEncode(menuData));
    _context = context;
    getAccess();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void countDown() {
//设置倒计时三秒后执行跳转方法
    var duration = Duration(seconds: 1);
    setState(() {
      isAjax = false;
    });
    Future.delayed(duration, checkLogin);
  }

  getAccess() async {
    ajaxSimple('Adminrelas-Manage-getTest', {}, (res) {
      setState(() {
        isAjax = false;
      });
      if (res.runtimeType != String && res['err_code'] == 0) {
        setState(() {
          isLogin = true;
          access = res['data'];
        });
      } else {
        checkLogin();
      }
    });
  }

  checkLogin() {
    Navigator.push(
      _context,
      MaterialPageRoute(builder: (context) => Login()),
    );
//      .then((data) {
//      if (data != null) {
//        setState(() {
//          isLogin = data['islogin'];
//          access = data['access'];
//        });
//      }
//    });
  }

// 菜单筛选
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

  modifyPasswordDialog() {
    return showDialog<void>(
      context: _context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '修改密码',
            style: TextStyle(fontSize: CFFontSize.topTitle),
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
//                                            password = val;
                              });
                            },
                          ),
                        ))
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
//                                            password = val;
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

  @override
  Widget build(BuildContext context) {
    _context = context;
    return WillPopScope(
        onWillPop: () async {
          Toast.show("再按一次退出app", context, duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
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
            actions: <Widget>[
              isLogin
                  ? PopupMenuButton(
                      offset: Offset(0, 60),
                      onSelected: (String value) {
                        if (value == '0') {
                          modifyPasswordDialog();
                        } else if (value == '1') {
                          setState(() {
                            isLogin = false;
                          });
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
                                Text("修改密码", style: TextStyle(fontSize: CFFontSize.content))
                              ],
                            )),
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
                                Text("退出",
                                    style: TextStyle(
                                      fontSize: CFFontSize.content,
                                    ))
                              ],
                            ))
                      ],
                      child: Container(
                        width: 56,
                        child: Center(
                          child: Icon(Icons.person),
                        ),
                      ),
                    )
                  : Container(
                      width: 0,
                    ),
            ],
          ),
          body: !isLogin
              ? Container(
                  child: Center(
                      child: isAjax
                          ? CupertinoActivityIndicator()
                          : PrimaryButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Login()),
                                );
//                                  .then((data) {
//                                  if (data != null) {
//                                    setState(() {
//                                      isLogin = data['islogin'];
//                                      access = data['access'];
//                                    });
//                                  }
//                                });
                              },
                              child: Text(
                                '登录',
                                style: TextStyle(),
                              ),
                            )),
                )
              : ListView(
                  padding: EdgeInsets.all(10),
                  children: <Widget>[
                    Container(
                      height: 34,
                      decoration:
                          BoxDecoration(color: Color(0xffeeeeee), borderRadius: BorderRadius.all(Radius.circular(44))),
                      margin: EdgeInsets.only(bottom: 15),
                      child: TextField(
                        style: TextStyle(fontSize: CFFontSize.content),
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15),
                            hintText: '请输入关键字'),
                        onChanged: (val) {
                          filterMenu(val.trim());
                        },
                      ),
                    ),
                    menu.isEmpty
                        ? Container(
                            alignment: Alignment.topCenter,
                            child: Text(
                              '空空如也',
                              style: TextStyle(fontSize: CFFontSize.content),
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
                                    ? Container(
                                        width: 0,
                                      )
                                    : Container(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.only(bottom: 6),
                                              child: Center(
                                                child: Text(
                                                  '${item['name']}',
                                                  style: TextStyle(
                                                      fontSize: CFFontSize.content,
                                                      color: CFColors.text,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            Wrap(
                                              runSpacing: 4,
                                              children: item['children'].map<Widget>((child) {
                                                return access.indexOf(child['access'][0]) == -1
                                                    ? Container(
                                                        width: 0,
                                                      )
                                                    : InkWell(
                                                        onTap: () {
                                                          FocusScope.of(context).requestFocus(FocusNode());
                                                          if (child['path'] != null) {
                                                            Navigator.pushNamed(context, child['path']);
                                                          }
                                                        },
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
                                                          child: Text(
                                                            '${child['name']}',
                                                            style: TextStyle(
                                                              fontSize: CFFontSize.content,
                                                              color: child['path'] == null ? Colors.black : Colors.blue,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                              }).toList(),
                                            ),
                                            Container(
                                              height: 10,
                                            )
                                          ],
                                        ),
                                      );
                              }).toList(),
                            ),
                          )
                  ],
                ),
        ));
  }
}
