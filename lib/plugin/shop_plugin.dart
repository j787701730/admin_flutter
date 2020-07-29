import 'dart:convert';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ShopPlugin extends StatefulWidget {
  final shopCount; // 0 无限选择, 1 单选, >1 限制个数选择
  final selectShopsData;

  ShopPlugin({this.shopCount, this.selectShopsData});

  @override
  _ShopPluginState createState() => _ShopPluginState(shopCount);
}

class _ShopPluginState extends State<ShopPlugin> {
  final shopCount;
  Map selectShopsData = {};

  _ShopPluginState(this.shopCount);

  BuildContext _context;

  List shopsData = [];
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _context = context;
    fetchShop();
    selectShopsData = jsonDecode(jsonEncode(widget.selectShopsData));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  int count = 0;

  Map param = {
    'shopName': '',
    'pageCount': 10,
    'currPage': 1,
    'pricing_class': 10,
    'login_name': '',
    'user_phone': '',
    'serviceType': '0',
    'province': '',
    'city': '',
    'region': '',
    'service_province': '',
    'service_city': '',
    'service_region': '',
  };

  List columns = [
    {'title': '店铺名称', 'key': 'shop_name'},
    {'title': '服务类型', 'key': 'service_type_name'},
    {'title': '地区', 'key': 'area'},
    {'title': '详细地址', 'key': 'shop_address'},
  ];

  fetchShop() {
    ajax('Adminrelas-CrmSearch-fetchShop', param, true, (data) {
      if (mounted) {
        setState(() {
          shopsData = data['shop'];
          count = int.tryParse(data['shopCount']);
          toTop();
        });
      }
    }, () {}, _context);
  }

  selectOrCancel(item) {
    if (shopCount > 1 && selectShopsData.keys.length == shopCount && !selectShopsData.keys.contains(item['shop_id'])) {
      Fluttertoast.showToast(
        msg: '最多选择 $shopCount 家店铺',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      if (selectShopsData.keys.contains(item['shop_id'])) {
        selectShopsData.remove(item['shop_id']);
      } else {
        if (shopCount == 1) {
          selectShopsData.clear();
        }
        selectShopsData[item['shop_id']] = item;
      }
    });
  }

  shopsBox(width) {
    showModalBottomSheet(
      context: _context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context1, state) {
            /// 这里的state就是setState
            return Container(
              height: 400,
              child: ListView(
                children: selectShopsData.keys.map<Widget>((key) {
                  return Container(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${selectShopsData[key]['shop_name']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            state(() {
                              selectShopsData.remove(key);
                            });
                            setState(() {
                              selectShopsData.remove(key);
                            });
                          },
                          child: Container(
                            width: 40,
                            child: Icon(Icons.close),
                          ),
                        )
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  toTop() {
    _controller.animateTo(
      0,
      duration: Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  getPage(page) {
    param['currPage'] = page;
    fetchShop();
  }

  Map serviceType = {
    0: '全部',
    11: '实物商品交易',
    12: '虚拟商品交易',
    13: '设计服务',
    14: '生产加工',
    15: '施工服务',
    16: '物流服务',
    17: '培训服务',
  };

  Widget searchWidget() {
    return Column(
      children: <Widget>[
        Input(
          label: '用户名',
          onChanged: (String val) {
            setState(() {
              param['login_name'] = val;
            });
          },
        ),
        Input(
          label: '店铺名称',
          onChanged: (String val) {
            setState(() {
              param['shopName'] = val;
            });
          },
        ),
        Input(
          label: '手机',
          onChanged: (String val) {
            setState(() {
              param['user_phone'] = val;
            });
          },
        ),
        Select(
          selectOptions: serviceType,
          selectedValue: param['serviceType'],
          label: '服务类型',
          onChanged: (String newValue) {
            setState(() {
              param['serviceType'] = newValue;
            });
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('店铺选择'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          controller: _controller,
          padding: EdgeInsets.all(10),
          children: <Widget>[
            searchWidget(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                PrimaryButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    param['currPage'] = 1;
                    fetchShop();
                  },
                  child: Text('搜索'),
                ),
                Container(
                  width: 10,
                ),
                PrimaryButton(
                  onPressed: () {
                    Navigator.pop(context, selectShopsData);
                  },
                  child: Text('确定'),
                )
              ],
            ),
            Container(
              height: 10,
            ),
            Column(
              children: shopsData.map<Widget>((item) {
                return Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: InkWell(
                    onTap: () => selectOrCancel(item),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xffdddddd),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Center(
                              child: shopCount == 1
                                  ? Radio(
                                      value: item['shop_id'],
                                      groupValue: selectShopsData.keys.isEmpty ? '' : selectShopsData.keys.toList()[0],
                                      onChanged: (val) => selectOrCancel(item),
                                    )
                                  : Checkbox(
                                      value: selectShopsData.keys.toList().indexOf(item['shop_id']) != -1,
                                      onChanged: (val) => selectOrCancel(item),
                                    ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.only(left: 6, right: 6, top: 8, bottom: 8),
                              child: Column(
                                children: columns.map<Widget>((col) {
                                  return Row(
                                    children: <Widget>[
                                      Container(
                                        width: 80,
                                        alignment: Alignment.centerRight,
                                        child: Text('${col['title']}'),
                                        margin: EdgeInsets.only(right: 10),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          child: col['key'] == 'area'
                                              ? Text(
                                                  '${item['province_name']} ${item['city_name']} ${item['region_name']}',
                                                )
                                              : Text(
                                                  '${item[col['key']]}',
                                                ),
                                        ),
                                      )
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            Container(
              child: PagePlugin(
                current: param['currPage'],
                total: count,
                pageSize: param['pageCount'],
                function: getPage,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: CFFloatingActionButton(
        child: Icon(Icons.add_shopping_cart),
        onPressed: () => shopsBox(width),
      ),
      floatingActionButtonAnimator: ScalingAnimation(),
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(
        FloatingActionButtonLocation.endFloat,
        floatingActionButtonOffsetX,
        floatingActionButtonOffsetY,
      ),
    );
  }
}
