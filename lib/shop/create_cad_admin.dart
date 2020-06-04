import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/shop_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:flutter/material.dart';

class CreateCadAdmin extends StatefulWidget {
  @override
  _CreateCadAdminState createState() => _CreateCadAdminState();
}

class _CreateCadAdminState extends State<CreateCadAdmin> {
  Map param = {'shops': {}};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新增CAD管理员'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('店铺')
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    padding: EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    height: 300,
                    child: ListView(
                      children: <Widget>[
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: param['shops'].keys.toList().map<Widget>((key) {
                            return Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.all(Radius.circular(4))),
                              height: 34,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(left: 6),
                                    child: Text(
                                      '${param['shops'][key]['login_name']}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        param['shops'].remove(key);
                                      });
                                    },
                                    child: Icon(
                                      Icons.clear,
                                      color: CFColors.danger,
                                      size: 20,
                                    ),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 34,
                  child: PrimaryButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new ShopPlugin(
                                  shopCount: 0,
                                  selectShopsData: param['shops'],
                                )),
                      ).then((val) {
                        if (val != null) {
                          param['shops'] = val;
                        }
                      });
                    },
                    child: Text('店铺'),
                  ),
                )
              ],
            ),
          ),
          Input(
              label: '备注',
              onChanged: (String val) {
                setState(() {
                  param['comments'] = val;
                });
              }),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
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
                        },
                        child: Text('保存'),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
