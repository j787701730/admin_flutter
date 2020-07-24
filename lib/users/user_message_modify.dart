import 'dart:async';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class UserMessageModify extends StatefulWidget {
  final props;

  UserMessageModify(this.props);

  @override
  _UserMessageModifyState createState() => _UserMessageModifyState();
}

class _UserMessageModifyState extends State<UserMessageModify> {
  Map userInfo = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 200), () {
      getInfo();
    });
  }

  getInfo() {
    setState(() {
      loading = true;
    });
    ajaxSimple('Adminrelas-UserManager-userInfo', {'uid': widget.props['user_id']}, (data) {
      if (mounted) {
        setState(() {
          userInfo = data;
          loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props['login_name']} 信息修改'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          loading
              ? CupertinoActivityIndicator()
              : Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
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
                            ),
                          ),
                        ],
                      ),
                    ),
                    Input(
                      label: '登录名',
                      onChanged: (val) => userInfo['login_name'] = val,
                      value: userInfo['login_name'],
                    ),
                    Input(
                      label: '手机号',
                      onChanged: (val) => userInfo['user_phone'] = val,
                      value: userInfo['user_phone'],
                    ),
                    Input(
                      label: '邮箱',
                      onChanged: (val) => userInfo['user_mail'] = val,
                      value: userInfo['user_mail'],
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
                            child: InkWell(
                              onTap: () {
                                FocusScope.of(context).requestFocus(FocusNode());
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
                                    setState(() {
                                      userInfo['eff_date'] = date.toString().substring(0, 19);
                                    });
                                  },
                                  currentTime: DateTime.parse('${userInfo['eff_date']}'),
                                  locale: LocaleType.zh,
                                );
                              },
                              child: Container(
                                height: 34,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 15, right: 15),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                                child: Text('${userInfo['eff_date']}'),
                              ),
                            ),
                          ),
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
                            child: InkWell(
                              onTap: () {
                                FocusScope.of(context).requestFocus(FocusNode());
                                DatePicker.showDateTimePicker(
                                  context,
                                  showTitleActions: true,
                                  minTime: DateTime(1970, 1, 1),
                                  maxTime: DateTime(2099, 12, 31),
                                  onChanged: (date) {
                                    print('change $date');
                                  },
                                  onConfirm: (date) {
                                    setState(() {
                                      userInfo['exp_date'] = date.toString().substring(0, 19);
                                    });
                                  },
                                  currentTime: DateTime.parse('${userInfo['exp_date']}'),
                                  locale: LocaleType.zh,
                                );
                              },
                              child: Container(
                                height: 34,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 15, right: 15),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                                child: Text('${userInfo['exp_date']}'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10, right: 10),
                      child: Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(right: 90),
                            child: Row(
                              children: <Widget>[
                                PrimaryButton(
                                  onPressed: () {},
                                  child: Text('提交更改'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
        ],
      ),
    );
  }
}
