import 'package:admin_flutter/my_home_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'utils.dart';

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

  login() async {
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

  getAccess() async {
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
            TextField(
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.only(top: 10, bottom: 10),
                  hintText: "账号"),
              onChanged: (String val) {
                setState(() {
                  loginName = val;
                });
              },
            ),
            Container(
              height: 15,
            ),
            TextField(
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.only(top: 10, bottom: 10),
                  hintText: "密码"),
              obscureText: true,
              onChanged: (String val) {
                setState(() {
                  password = val;
                });
              },
            ),
            Container(
              margin: EdgeInsets.only(top: 15),
              width: width - 40,
              child: FlatButton(
                  padding: EdgeInsets.only(top: 13, bottom: 13),
                  color: Colors.blue,
                  textColor: Colors.white,
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
                  )),
            )
          ],
        ),
      ),
    );
  }
}
