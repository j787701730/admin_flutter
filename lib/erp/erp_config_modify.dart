import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/plugin/shop_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:flutter/material.dart';

class ErpConfigModify extends StatefulWidget {
  final props;

  ErpConfigModify(this.props);

  @override
  _ErpConfigModifyState createState() => _ErpConfigModifyState();
}

class _ErpConfigModifyState extends State<ErpConfigModify> {
  Map param = {'pay_online': '1'};
  Map payOnline = {'1': '是', '0': '否'};

  @override
  void initState() {
    super.initState();
    if (widget.props != null) {
      param = {
        'shop_id': widget.props['shop_id'],
        'shop_name': widget.props['shop_name'],
        'pay_online': widget.props['pay_online'],
        'plat_rate': widget.props['plat_rate'],
        'order_disrate': widget.props['order_disrate'],
        'order_extrate': widget.props['order_extrate'],
        'return_rate_lower': widget.props['return_rate_lower'],
        'return_rate_upper': widget.props['return_rate_upper'],
        'pay_comments': widget.props['comments'] ?? '',
      };
    }
  }

  TextStyle _style = TextStyle(color: Color(0xff8a6d3b), height: 1.5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props == null ? '新增ERP配置' : '${widget.props['shop_name']} ERP配置修改'}'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 15),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xfffcf8e3),
              border: Border.all(color: Color(0xfffaebcc), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '注意事项：(以免造成亏损!)',
                  style: TextStyle(color: Color(0xff8a6d3b), fontWeight: FontWeight.bold, height: 1.5),
                ),
                Text(
                  '1、以下值均在0 ~ 1之间',
                  style: _style,
                ),
                Text(
                  '2、平台盈利值 + 返红包率上限值不能大于1',
                  style: _style,
                ),
                Text(
                  '3、返红包率上限值不能大于平台盈利值',
                  style: _style,
                ),
                Text(
                  '4、返红包率下限值不能大于返红包率上限值',
                  style: _style,
                ),
              ],
            ),
          ),
          widget.props == null
              ? Container(
                  margin: EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 150,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '* ',
                              style: TextStyle(color: CFColors.danger),
                            ),
                            Text('店铺：')
                          ],
                        ),
                        margin: EdgeInsets.only(right: 10),
                      ),
                      Expanded(
                          flex: 1,
                          child: Container(
                            height: 34,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(6))),
                            child: Text('${param['shop_name'] ?? ''}'),
                          )),
                      Container(
                        width: 70,
                        height: 34,
                        child: PrimaryButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            Map data = {};
                            if (param['shop_id'] != null) {
                              data = {
                                param['shop_id']: {'shop_id': param['shop_id'], 'shop_name': param['shop_name']}
                              };
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                  ShopPlugin(
                                    shopCount: 1,
                                    selectShopsData: data,
                                  )),
                            ).then((val) {
                              if (val != null) {
                                setState(() {
                                  param['shop_id'] = val.keys.toList()[0];
                                  param['shop_name'] = val[param['shop_id']]['shop_name'];
                                });
                              }
                            });
                          },
                          child: Text('店铺'),
                        ),
                      )
                    ],
                  ),
                )
              : Container(width: 0,),
          Select(selectOptions: payOnline, selectedValue: param['pay_online'] ?? '1', label: '在线支付：',labelWidth: 150, onChanged: (String newValue) {
            setState(() {
              param['pay_online'] = newValue;
            });
          }),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 150,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('平台盈利：')
                    ],
                  ),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                    flex: 1,
                    child: TextField(
                      controller: TextEditingController.fromValue(TextEditingValue(
                          text: '${param['plat_rate'] ?? ''}',
                          selection: TextSelection.fromPosition(TextPosition(
                              affinity: TextAffinity.downstream, offset: '${param['plat_rate'] ?? ''}'.length)))),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15)),
                      onChanged: (val) {
                        setState(() {
                          param['plat_rate'] = val;
                        });
                      },
                    )),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 150,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('订单折扣率：')
                    ],
                  ),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                    flex: 1,
                    child: TextField(
                      controller: TextEditingController.fromValue(TextEditingValue(
                          text: '${param['order_disrate'] ?? ''}',
                          selection: TextSelection.fromPosition(TextPosition(
                              affinity: TextAffinity.downstream, offset: '${param['order_disrate'] ?? ''}'.length)))),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15)),
                      onChanged: (val) {
                        setState(() {
                          param['order_disrate'] = val;
                        });
                      },
                    )),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 150,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('订单收入提现率：')
                    ],
                  ),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                    flex: 1,
                    child: TextField(
                      controller: TextEditingController.fromValue(TextEditingValue(
                          text: '${param['order_extrate'] ?? ''}',
                          selection: TextSelection.fromPosition(TextPosition(
                              affinity: TextAffinity.downstream, offset: '${param['order_extrate'] ?? ''}'.length)))),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15)),
                      onChanged: (val) {
                        setState(() {
                          param['order_extrate'] = val;
                        });
                      },
                    )),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 150,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('返红包率下限：')
                    ],
                  ),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                    flex: 1,
                    child: TextField(
                      controller: TextEditingController.fromValue(TextEditingValue(
                          text: '${param['return_rate_lower'] ?? ''}',
                          selection: TextSelection.fromPosition(TextPosition(
                              affinity: TextAffinity.downstream,
                              offset: '${param['return_rate_lower'] ?? ''}'.length)))),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15)),
                      onChanged: (val) {
                        setState(() {
                          param['return_rate_lower'] = val;
                        });
                      },
                    )),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 150,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('返红包率上限：')
                    ],
                  ),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                    flex: 1,
                    child: TextField(
                      controller: TextEditingController.fromValue(TextEditingValue(
                          text: '${param['return_rate_upper'] ?? ''}',
                          selection: TextSelection.fromPosition(TextPosition(
                              affinity: TextAffinity.downstream,
                              offset: '${param['return_rate_upper'] ?? ''}'.length)))),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15)),
                      onChanged: (val) {
                        setState(() {
                          param['return_rate_upper'] = val;
                        });
                      },
                    )),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 150,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[Text('备注：')],
                  ),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                    flex: 1,
                    child: TextField(
                      maxLines: 4,
                      controller: TextEditingController.fromValue(TextEditingValue(
                          text: '${param['pay_comments'] ?? ''}',
                          selection: TextSelection.fromPosition(TextPosition(
                              affinity: TextAffinity.downstream, offset: '${param['pay_comments'] ?? ''}'.length)))),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15)),
                      onChanged: (val) {
                        setState(() {
                          param['pay_comments'] = val;
                        });
                      },
                    )),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 150,
                  alignment: Alignment.centerRight,
                  child: Row(),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: 30,
                          child: PrimaryButton(
                            onPressed: () {
                              print(param);
                            },
                            child: Text('保存'),
                          ),
                        )
                      ],
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }
}
