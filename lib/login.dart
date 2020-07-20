import 'dart:async';
import 'package:admin_flutter/my_home_page.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String loginName = '';
  String password = '';
  BuildContext _context;
  Timer _timer;
  DateTime _lastPressedAt; // 上次点击时间
  @override
  void initState() {
    super.initState();
    _context = context;
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }

  login() {
    ajax('Adminrelas-Index-loginCheck', {"psw": password, "username": loginName}, true, (res) {
      if (res.runtimeType != String && res['err_code'] == 0) {
//        getAccess();

        if ('${res['wx_check']}' == '1') {
          _timer = Timer.periodic(Duration(seconds: 3), (timer) {
            loginStatus({'sign': res.sign});
          });
        } else {
          getAccess();
        }
      } else {
        if (res.runtimeType == String) {
          Fluttertoast.showToast(
            msg: '未登录',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
        } else {
          Fluttertoast.showToast(
            msg: '${res['err_code']}: ${res['err_msg']}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
        }
      }
    }, () {}, _context);
  }

  loginStatus(data) {
    ajax('Adminrelas-Index-loginStatus', data, true, (data) {
      _timer.cancel();
      _timer = null;
      if (data['request_state'] == 0) {
      } else if (data['request_state'] == -1) {
        Fluttertoast.showToast(
          msg: '拒绝登录',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      } else if (data['request_state'] == 1) {
        getAccess();
      }
    }, () {
      _timer.cancel();
      _timer = null;
    }, _context);
  }

  getAccess() {
    ajax('Adminrelas-Manage-getTest', {}, true, (res) {
      if (res.runtimeType != String && res['err_code'] == 0) {
//        Navigator.pop(_context, {'islogin': true, 'access': res['data']});
        Navigator.pushAndRemoveUntil(
          _context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
          (route) => route == null,
        );
      } else {
        if (res.runtimeType == String) {
          Fluttertoast.showToast(
            msg: '未登录',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
        } else {
          Fluttertoast.showToast(
            msg: '${res['err_code']}: ${res['err_msg']}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
        }
      }
    }, () {}, _context);
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double width = mediaQuery.size.width;
    double height = mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom - 56;
    _context = context;
    SizeFit.initialize(context);
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
          title: Text('登录'),
        ),
        body: Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: height * (1 - 0.618) - (34 * 4 + 30) / 2),
          child: Container(
            width: width * 0.618,
            child: Column(
              children: <Widget>[
//            Container(
//              width: HYSizeFit.setPx(100),
//              height: HYSizeFit.setPx(100),
//              decoration: BoxDecoration(
//                gradient: RadialGradient(colors: [Colors.white, Colors.black]),
//              ),
//            ),
                Container(
                  alignment: Alignment.center,
                  height: 34,
                  margin: EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Text(
                    '后台管理系统',
                    style: TextStyle(
                      fontSize: CFFontSize.topTitle,
                    ),
                  ),
                ),
                Container(
                  height: 34,
                  child: TextField(
                    style: TextStyle(fontSize: CFFontSize.content),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        size: 20,
                      ),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(top: 0, bottom: 0),
                      hintText: "账号",
                    ),
                    onChanged: (String val) {
                      setState(() {
                        loginName = val;
                      });
                    },
                  ),
                ),
                Container(
                  height: 34,
                  margin: EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                  ),
                  child: TextField(
                    style: TextStyle(fontSize: CFFontSize.content),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock,
                        size: 20,
                      ),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(top: 0, bottom: 0),
                      hintText: "密码",
                    ),
                    obscureText: true,
                    onChanged: (String val) {
                      setState(() {
                        password = val;
                      });
                    },
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: PrimaryButton(
                        onPressed: () {
                          if (loginName.length < 4) {
                            Fluttertoast.showToast(
                              msg: '账号不少于4位',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                            );
                          } else if (password.length < 4) {
                            Fluttertoast.showToast(
                              msg: '密码不少于4位',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                            );
                          } else {
                            login();
                          }
                        },
                        child: Text(
                          '登录',
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
