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

  @override
  void initState() {
    super.initState();
    _context = context;
  }

  login() {
    ajax('Adminrelas-Index-loginCheck', {"psw": password, "username": loginName}, true, (res) {
      if (res.runtimeType != String && res['err_code'] == 0) {
        getAccess();
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
    double width = MediaQuery.of(context).size.width;
    _context = context;
    return Scaffold(
      appBar: AppBar(
        title: Text('登录'),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
            Container(
              width: width - 40,
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
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
