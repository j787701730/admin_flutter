import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:flutter/material.dart';

class CreateRedPacket extends StatefulWidget {
  @override
  _CreateRedPacketState createState() => _CreateRedPacketState();
}

class _CreateRedPacketState extends State<CreateRedPacket> {
  Map param = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新建红包'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Input(
            label: '红包标题',
            onChanged: (String val) {
              setState(() {
                if (val == '') {
                  param.remove('title');
                } else {
                  param['title'] = val;
                }
              });
            },
            require: true,
            labelWidth: 120,
          ),
          Input(
            label: '红包金额',
            onChanged: (String val) {
              setState(() {
                if (val == '') {
                  param.remove('amount');
                } else {
                  param['amount'] = val;
                }
              });
            },
            require: true,
            labelWidth: 120,
          ),
          Input(
            label: '红包数量',
            onChanged: (String val) {
              setState(() {
                if (val == '') {
                  param.remove('num');
                } else {
                  param['num'] = val;
                }
              });
            },
            require: true,
            labelWidth: 120,
          ),
          Input(
            label: '单人最大金额',
            onChanged: (String val) {
              setState(() {
                if (val == '') {
                  param.remove('max_amount');
                } else {
                  param['max_amount'] = val;
                }
              });
            },
            labelWidth: 120,
          ),
          Input(
            label: '单人最小金额',
            onChanged: (String val) {
              setState(() {
                if (val == '') {
                  param.remove('min_amount');
                } else {
                  param['min_amount'] = val;
                }
              });
            },
            require: true,
            labelWidth: 120,
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 120,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Text(''),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      PrimaryButton(
                        onPressed: () {
                          print(param);
                          Navigator.pop(context, true);
                        },
                        child: Text('确认创建'),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
