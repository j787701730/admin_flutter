import 'dart:convert';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/plugin/user_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:flutter/material.dart';

/// 手工账
class BalanceManualOpera extends StatefulWidget {
  final props;

  BalanceManualOpera(this.props);

  @override
  _BalanceManualOperaState createState() => _BalanceManualOperaState();
}

class _BalanceManualOperaState extends State<BalanceManualOpera> {
  Map manualType = {
    "1": '商城现金',
    "3": '云端计费',
    "4": '云端计费-赠送',
    "5": '经销商',
  };
  String manualTypeID = '1';
  String manualState = '1';
  String manualAmount = '';
  String manualComment = '';
  Map selectUsersData = {};

  @override
  void initState() {
    super.initState();
    selectUsersData = widget.props == null ? {} : widget.props['user'];
    manualTypeID = widget.props == null ? '1' : widget.props['manualType'];
    manualState = widget.props == null ? '1' : widget.props['manualState'];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.props == null
            ? '新用户手工账'
            : '${widget.props['user'][widget.props['user'].keys.toList()[0]]['login_name']} 手工账'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 80,
                        alignment: Alignment.centerRight,
                        child: Text('用户'),
                        margin: EdgeInsets.only(right: 10),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.only(right: 6),
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          height: 32,
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            children: selectUsersData.keys.toList().map<Widget>(
                              (key) {
                                return Container(
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(right: 20),
                                        child: Text(
                                          '${selectUsersData[key]['login_name']}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      widget.props == null
                                          ? Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Container(
                                                color: Color(0xffeeeeee),
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      selectUsersData.remove(key);
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.clear,
                                                    color: Colors.red,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(
                                              width: 0,
                                            )
                                    ],
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      ),
                      widget.props == null
                          ? SizedBox(
                              width: 80,
                              child: PrimaryButton(
                                onPressed: () {
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserPlugin(
                                        userCount: 1,
                                        selectUsersData: jsonDecode(
                                          jsonEncode(selectUsersData),
                                        ),
                                      ),
                                    ),
                                  ).then((val) {
                                    if (val != null) {
                                      setState(() {
                                        selectUsersData = jsonDecode(jsonEncode(val));
                                      });
                                    }
                                  });
                                },
                                child: Text(
                                  '选择',
                                ),
                              ),
                            )
                          : Container(
                              width: 0,
                            )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 80,
                        alignment: Alignment.centerRight,
                        child: Text('余额类型'),
                        margin: EdgeInsets.only(right: 10),
                      ),
                      Expanded(
                        flex: 1,
                        child: widget.props == null || (widget.props != null && widget.props['manualTypeFlag'] == true)
                            ? Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                                height: 34,
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  elevation: 1,
                                  underline: Container(),
                                  value: manualTypeID,
                                  onChanged: (String newValue) {
                                    setState(() {
                                      manualTypeID = newValue;
                                    });
                                  },
                                  items: manualType.keys.toList().map<DropdownMenuItem<String>>(
                                    (item) {
                                      return DropdownMenuItem(
                                        value: '$item',
                                        child: Container(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(
                                            '${manualType[item]}',
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              )
                            : Container(
                                height: 34,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${manualType[widget.props['manualType']]}',
                                ),
                              ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 80,
                        alignment: Alignment.centerRight,
                        child: Text('调账类型'),
                        margin: EdgeInsets.only(right: 10),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: <Widget>[
                            Offstage(
                              offstage: widget.props != null && widget.props['manualState'] != '1',
                              child: InkWell(
                                onTap: () {
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  setState(() {
                                    manualState = '1';
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: manualState == '1' ? Colors.red : Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  height: 32,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.add,
                                        color: Colors.red,
                                      ),
                                      Text(' 调增')
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Offstage(
                              offstage: widget.props != null && widget.props['manualState'] != '1',
                              child: Container(
                                width: 10,
                              ),
                            ),
                            Offstage(
                              offstage: widget.props != null && widget.props['manualState'] != '2',
                              child: InkWell(
                                onTap: () {
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  setState(() {
                                    manualState = '2';
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: manualState == '2' ? Colors.red : Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  height: 32,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.remove,
                                        color: Colors.green,
                                      ),
                                      Text(' 调减')
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 80,
                        alignment: Alignment.centerRight,
                        child: Text('快捷'),
                        margin: EdgeInsets.only(right: 10),
                      ),
                      Expanded(
                        flex: 1,
                        child: Wrap(
                          runSpacing: 10,
                          spacing: 10,
                          children: [100, 200, 500, 1000, 10000].map<Widget>((item) {
                            return InkWell(
                              onTap: () {
                                FocusScope.of(context).requestFocus(FocusNode());
                                setState(() {
                                  manualAmount = '$item';
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                height: 32,
                                width: 70,
                                alignment: Alignment.center,
                                child: Text('$item'),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 80,
                        alignment: Alignment.centerRight,
                        child: Text('调账金额'),
                        margin: EdgeInsets.only(right: 10),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 34,
                          child: TextField(
                            style: TextStyle(fontSize: CFFontSize.content),
                            controller: TextEditingController.fromValue(
                              TextEditingValue(
                                text: '${manualAmount ?? ''}',
                                selection: TextSelection.fromPosition(
                                  TextPosition(
                                      affinity: TextAffinity.downstream, offset: '${manualAmount ?? ''}'.length),
                                ),
                              ),
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.only(
                                top: 0,
                                bottom: 0,
                                left: 10,
                                right: 10,
                              ),
                            ),
                            onChanged: (String val) {
                              setState(() {
                                manualAmount = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Input(
                  label: '调账备注',
                  onChanged: (String val) {
                    setState(
                      () {
                        manualComment = val;
                      },
                    );
                  },
                  maxLines: 4,
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                Text(
                                  ' 调增金额限制 10000 元以内',
                                  style: TextStyle(color: Colors.red),
                                )
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              height: 34,
                              child: PrimaryButton(
                                onPressed: () {
                                  FocusScope.of(context).requestFocus(FocusNode());
                                },
                                child: Text('确认提交'),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
