import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/plugin/shop_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class CouponCreate extends StatefulWidget {
  @override
  _CouponCreateState createState() => _CouponCreateState();
}

class _CouponCreateState extends State<CouponCreate> {
  Map param = {'shops': {}, 'goods_type': '0'};
  Map goodsType = {'0': '全部商品'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('创建优惠券'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 100,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('店铺'),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    padding: EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    height: 34,
                    child: ListView(
                      children: <Widget>[
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: param['shops'].keys.toList().map<Widget>(
                            (key) {
                              return Container(
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
                            },
                          ).toList(),
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
                            shopCount: 1,
                            selectShopsData: param['shops'],
                          ),
                        ),
                      ).then((val) {
                        if (val != null) {
                          param['shops'] = val;
                        }
                      });
                    },
                    child: Text('店铺'),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              bottom: 10,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 100,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text('快捷'),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [10, 20, 30, 50, 100].map<Widget>((item) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              param['leftnum'] = item;
                            });
                          },
                          child: Container(
                            height: 34,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            width: 70,
                            alignment: Alignment.center,
                            child: Text('$item'),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 100,
                  alignment: Alignment.centerRight,
                  height: 34,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('发放量'),
                    ],
                  ),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 34,
                    child: TextField(
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: '${param['leftnum'] ?? '10'}',
                          selection: TextSelection.fromPosition(
                            TextPosition(
                                affinity: TextAffinity.downstream, offset: '${param['leftnum'] ?? '10'}'.length),
                          ),
                        ),
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 15),
                      ),
                      onChanged: (String val) {
                        setState(() {
                          param['leftnum'] = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 100,
                  alignment: Alignment.centerRight,
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '* ',
                            style: TextStyle(color: CFColors.danger),
                          ),
                          Text('限领数量')
                        ],
                      ),
                      Text(
                        '(每人限临张数)',
                        style: TextStyle(fontSize: CFFontSize.tabBar),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 34,
                    child: TextField(
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: '${param['limitnum'] ?? '1'}',
                          selection: TextSelection.fromPosition(
                            TextPosition(
                                affinity: TextAffinity.downstream, offset: '${param['limitnum'] ?? '1'}'.length),
                          ),
                        ),
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 15),
                      ),
                      onChanged: (String val) {
                        setState(() {
                          param['limitnum'] = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Container(
                  width: 100,
                  alignment: Alignment.centerRight,
                  height: 34,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('抵扣金额')
                    ],
                  ),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 34,
                    child: TextField(
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: '${param['subval'] ?? ''}',
                          selection: TextSelection.fromPosition(
                            TextPosition(affinity: TextAffinity.downstream, offset: '${param['subval'] ?? ''}'.length),
                          ),
                        ),
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 15),
                      ),
                      onChanged: (String val) {
                        setState(() {
                          param['subval'] = val;
                        });
                      },
                    ),
                  ),
                ),
              ])),
          Select(
            selectOptions: goodsType,
            selectedValue: param['goods_type'] ?? '0',
            label: '商品类型',
            onChanged: (val) {
              setState(() {
                param['goods_type'] = val;
              });
            },
            require: true,
            labelWidth: 100,
          ),
          Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 100,
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          '* ',
                          style: TextStyle(color: CFColors.danger),
                        ),
                        Text('生效日期'),
                      ],
                    ),
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
                              param['eff_date'] = date;
                            });
                          },
                          currentTime: param['eff_date'] ?? DateTime.now(),
                          locale: LocaleType.zh,
                        );
                      },
                      child: Container(
                        height: 34,
                        padding: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 1)),
                        child: Text(param['eff_date'] == null ? '' : '${param['eff_date']}'.substring(0, 19)),
                      ),
                    ),
                  ),
                  Container(
                    width: 20,
                    child: Text('-'),
                    alignment: Alignment.center,
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
                              param['exp_date'] = date;
                            });
                          },
                          currentTime: param['exp_date'] ?? DateTime.now(),
                          locale: LocaleType.zh,
                        );
                      },
                      child: Container(
                        height: 34,
                        padding: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 1)),
                        child: Text(param['exp_date'] == null ? '' : '${param['exp_date']}'.substring(0, 19)),
                      ),
                    ),
                  )
                ],
              )),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 100,
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
