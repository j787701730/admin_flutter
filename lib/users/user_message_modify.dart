import 'package:admin_flutter/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:admin_flutter/utils.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class UserMessageModify extends StatefulWidget {
  final props;

  UserMessageModify(this.props);

  @override
  _UserMessageModifyState createState() => _UserMessageModifyState();
}

class _UserMessageModifyState extends State<UserMessageModify> {
  Map userInfo = {};
  BuildContext _context;

  @override
  void initState() {
    super.initState();
    _context = context;
    getInfo();
  }

  getInfo() async {
    ajaxSimple('Adminrelas-UserManager-userInfo', {'uid': widget.props['user_id']}, (data) {
      if (mounted) {
        setState(() {
          userInfo = data;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.props['login_name']} 信息修改'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  child: Text('头像'),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: 100,
                      height: 100,
                      child: Image.network('$baseUrl${userInfo['avatar']}'),
                    ))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10, right: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  child: Text('登录名'),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                    flex: 1,
                    child: TextField(
                      controller: TextEditingController(text: '${userInfo['login_name']}'),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15)),
                      onChanged: (String val) {
                        setState(() {
//                          searchData[key] = val;
                        });
                      },
                    ))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10, right: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  child: Text('手机号'),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                    flex: 1,
                    child: TextField(
                      controller: TextEditingController(text: '${userInfo['user_phone']}'),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15)),
                      onChanged: (String val) {
                        setState(() {
//                          searchData[key] = val;
                        });
                      },
                    ))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10, right: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  child: Text('邮箱'),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                    flex: 1,
                    child: TextField(
                      controller: TextEditingController(text: '${userInfo['user_mail']}'),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15)),
                      onChanged: (String val) {
                        setState(() {
//                          searchData[key] = val;
                        });
                      },
                    ))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10, right: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  child: Text('生效时间'),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                    flex: 1,
                    child: TextField(
                      controller: TextEditingController(text: '${userInfo['eff_date']}'),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15)),
                      onTap: () {
                        DatePicker.showDateTimePicker(
                          context,
                          showTitleActions: true,
                          minTime: DateTime(1970, 1, 1),
                          maxTime: DateTime(2099, 12, 31),
                          onChanged: (date) {
                            print('change $date');
                          },
                          onConfirm: (date) {
                            print('confirm $date');
                          },
                          currentTime: DateTime.parse('${userInfo['eff_date']}'),
                          locale: LocaleType.zh,
                        );
                      },
                    ))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10, right: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  child: Text('失效时间'),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                    flex: 1,
                    child: TextField(
                      controller: TextEditingController(text: '${userInfo['exp_date']}'),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15)),
                      onTap: () {
                        DatePicker.showDateTimePicker(
                          context,
                          showTitleActions: true,
                          minTime: DateTime(1970, 1, 1),
                          maxTime: DateTime(2099, 12, 31),
                          onChanged: (date) {
                            print('change $date');
                          },
                          onConfirm: (date) {
                            print('confirm $date');
                          },
                          currentTime: DateTime.parse('${userInfo['exp_date']}'),
                          locale: LocaleType.zh,
                        );
                      },
                    ))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10, right: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  child: Text(''),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[PrimaryButton(onPressed: () {}, child: Text('提交更改'))],
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
