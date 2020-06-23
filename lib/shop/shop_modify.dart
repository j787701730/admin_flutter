import 'dart:async';

import 'package:admin_flutter/plugin/city_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/shop/industry_class_select.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/material.dart';

class ShopModify extends StatefulWidget {
  final props;

  ShopModify({this.props});

  @override
  _ShopModifyState createState() => _ShopModifyState();
}

class _ShopModifyState extends State<ShopModify> {
  BuildContext _context;
  double width;

  @override
  void initState() {
    super.initState();
    _context = context;
    Timer(Duration(milliseconds: 200), () {
      if (widget.props != null) {
        getData();
      }
      getIndustryClass();
      getSupplyClass();
    });
  }

  Map shopInfo = {};
  Map userRole = {};
  Map serviceType = {};
  List serviceTypeDisabled = [];
  Map shopAddress = {
    'province': '',
    'city': '',
    'region': '',
  };
  List industryClass = []; // 行业分类
  List supplyClass = []; // 供应分类

  getData() {
    ajax('Adminrelas-Api-editShopShow-shopId-${widget.props['shop_id']}', {}, true, (data) {
      if (mounted) {
        List arr = [];
        for (var key in data['serviceType'].keys) {
          if (data['serviceType'][key]['check'] == '1') {
            arr.add(key);
          }
        }
        print(arr);
        setState(() {
          shopInfo = data['data'];
          userRole = data['userRole'];
          serviceType = data['serviceType'];
          shopAddress['province'] = data['shop_province'];
          shopAddress['city'] = data['shop_city'];
          shopAddress['region'] = data['shop_region'];
          serviceTypeDisabled = arr;
        });
      }
    }, () {}, _context);
  }

  getIndustryClass() {
    ajax('Adminrelas-shopsManage-getIndustryClass', {}, true, (data) {
      if (mounted) {
        industryClass = data['data'];
      }
    }, () {}, _context);
  }

  getSupplyClass() {
    ajax('Adminrelas-shopsManage-getSupplyClass', {}, true, (data) {
      if (mounted) {
        supplyClass = data['data'];
      }
    }, () {}, _context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.props == null ? '新增店铺' : '${widget.props['shop_name']} 修改'),
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: <Widget>[
          Input(
            labelWidth: 100,
            label: '店铺名称',
            onChanged: (val) {
              setState(() {
                shopInfo['shop_name'] = val;
              });
            },
            value: shopInfo['shop_name'],
            require: true,
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
                        '*',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('角色选择')
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Wrap(
                    children: userRole.keys.toList().map<Widget>(
                      (item) {
                        return Container(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                userRole[item]['check'] = userRole[item]['check'] == 1 ? 0 : 1;
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Checkbox(
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  value: userRole[item]['check'] == 1,
                                  onChanged: (val) {},
                                ),
                                Text('${userRole[item]['role_ch_name']}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ).toList(),
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
                  width: 100,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '*',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('服务提供')
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Wrap(
                    children: serviceType.keys.toList().map<Widget>(
                      (item) {
                        return Container(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (serviceTypeDisabled.indexOf(item) == -1) {
                                  serviceType[item]['check'] = serviceType[item]['check'] == '1' ? '0' : '1';
                                }
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Checkbox(
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  value: serviceType[item]['check'] == '1',
                                  onChanged: (val) {},
                                  activeColor: serviceTypeDisabled.indexOf(item) == -1
                                      ? CFColors.text
                                      : Theme.of(context).toggleableActiveColor,
                                ),
                                Text('${serviceType[item]['service_type_ch_name']}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                )
              ],
            ),
          ),
          Input(
            label: '公司名称',
            labelWidth: 100,
            onChanged: (val) {
              setState(() {
                shopInfo['company_name'] = val;
              });
            },
            value: shopInfo['company_name'],
          ),
          Input(
            label: '纳税识别号',
            labelWidth: 100,
            onChanged: (val) {
              setState(() {
                shopInfo['tax_no'] = val;
              });
            },
            value: shopInfo['tax_no'],
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
                    children: <Widget>[Text('行业分类')],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Wrap(
                    children: <Widget>[
                      PrimaryButton(
                        onPressed: () {
                          Navigator.push(
                            _context,
                            MaterialPageRoute(
                              builder: (context) => IndustryClassSelect(
                                selectClass: [],
                                classData: industryClass,
                              ),
                            ),
                          ).then((value) {
                            print(value);
                          });
                        },
                        child: Text('添加'),
                      ),
                    ],
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
                  width: 100,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[Text('供应分类')],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Wrap(
                    children: <Widget>[],
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
                  width: 100,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[Text('店铺图标')],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Wrap(
                    children: <Widget>[],
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
                  width: 100,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[Text('店铺图片')],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Wrap(
                    children: <Widget>[],
                  ),
                )
              ],
            ),
          ),
          Input(
            label: '店铺简介',
            labelWidth: 100,
            onChanged: (val) {
              setState(() {
                shopInfo['shop_desc'] = val;
              });
            },
            value: shopInfo['shop_desc'],
            maxLines: 6,
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
                    children: <Widget>[Text('联系地址')],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CitySelectPlugin(
                    getArea: (val) {
//                      print(val);
                    },
                  ),
                )
              ],
            ),
          ),
          Input(
            label: '详细地址',
            labelWidth: 100,
            onChanged: (val) {
              setState(() {
                shopInfo['shop_address'] = val;
              });
            },
            value: shopInfo['shop_address'],
            require: true,
          ),
        ],
      ),
    );
  }
}
