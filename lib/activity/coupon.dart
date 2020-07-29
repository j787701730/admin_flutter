import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/activity/coupon_create.dart';
import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input-single.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/search-bar-plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Coupon extends StatefulWidget {
  @override
  _CouponState createState() => _CouponState();
}

class _CouponState extends State<Coupon> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  Map state = {"all": "全部"};
  Map couponType = {"all": "全部"};
  Map goodsType = {"all": "全部"};
  Map couponSource = {"all": "全部"};
  List columns = [
    {'title': '店铺', 'key': 'shop_name'},
    {'title': '优惠券URL', 'key': 'coupon_id'},
    {'title': '优惠券类型', 'key': 'coupon_type'},
    {'title': '商品类型', 'key': 'goods_type'},
    {'title': '优惠券来源', 'key': 'coupon_source'},
    {'title': '限临数量', 'key': 'limit_nums'},
    {'title': '剩余数量', 'key': 'left_nums'},
    {'title': '优惠值', 'key': 'coupon_value'},
    {'title': '状态', 'key': 'state'},
    {'title': '创建时间', 'key': 'create_date'},
    {'title': '起始时间', 'key': 'eff_date'},
    {'title': '截止时间', 'key': 'exp_date'},
    {'title': '操作', 'key': 'option'},
  ];

  void _onRefresh() {
    setState(() {
      param['curr_page'] = 1;
      getData(isRefresh: true);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _context = context;
    Timer(Duration(milliseconds: 200), () {
      getParamData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getParamData() {
    ajax('Adminrelas-Api-couponData', {}, true, (data) {
      if (mounted) {
        Map goodsTypeTemp = {};
        for (var key in data['goodsType'].keys.toList()) {
          goodsTypeTemp[key] = data['goodsType'][key]['goods_type_ch_name'];
        }
        setState(() {
          couponType.addAll(data['couponsType']);
          goodsType.addAll(goodsTypeTemp);
          couponSource.addAll(data['shopCoupon']['coupon_source']);
          state.addAll(data['shopCoupon']['coupon_state']);
          getData();
        });
      }
    }, () {}, _context);
  }

  getData({isRefresh: false}) {
    setState(() {
      loading = true;
    });
    Map tempParam = jsonDecode(jsonEncode(param));
    tempParam['curr_page'] -= 1;
    ajax('Adminrelas-coupon-getCoupon', {'param': jsonEncode(tempParam)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'] ?? [];
          count = int.tryParse('${res['count'] ?? 0}');
          toTop();
        });
        if (isRefresh) {
          _refreshController.refreshCompleted();
        }
      }
    }, () {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }, _context);
  }

  toTop() {
    _controller.animateTo(
      0,
      duration: Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  getPage(page) {
    param['curr_page'] = page;
    getData();
  }

  getDateTime(val) {
    if (val['min'] == null) {
      param.remove('create_time_l');
    } else {
      param['create_time_l'] = '${val['min'].toString().substring(0, 10)} 00:00:00';
    }
    if (val['max'] == null) {
      param.remove('create_time_r');
    } else {
      param['create_time_r'] = '${val['max'].toString().substring(0, 10)} 23:59:59';
    }
  }

  getDateTime2(val) {
    if (val['min'] == null) {
      param.remove('eff_date');
    } else {
      param['eff_date'] = '${val['min'].toString().substring(0, 10)} 00:00:00';
    }
    if (val['max'] == null) {
      param.remove('exp_date');
    } else {
      param['exp_date'] = '${val['max'].toString().substring(0, 10)} 23:59:59';
    }
  }

  String defaultVal = 'all';
  Map selects = {
    'all': '无',
    'shop_name': '店铺 升序',
    'shop_name desc': '店铺 降序',
    'coupon_type': '优惠券类型 升序',
    'coupon_type desc': '优惠券类型 降序',
    'goods_type': '商品类型 升序',
    'goods_type desc': '商品类型 降序',
    'coupon_source': '优惠券来源 升序',
    'coupon_source desc': '优惠券来源 降序',
    'limit_nums': '限临数量 升序',
    'limit_nums desc': '限临数量 降序',
    'left_nums': '剩余数量 升序',
    'left_nums desc': '剩余数量 降序',
    'coupon_value': '优惠值 升序',
    'coupon_value desc': '优惠值 降序',
    'state': '状态 升序',
    'state desc': '状态 降序',
    'create_date': '创建时间 升序',
    'create_date desc': '创建时间 降序',
    'eff_date': '起始时间 升序',
    'eff_date desc': '起始时间 降序',
    'exp_date': '截止时间 升序',
    'exp_date desc': '截止时间 降序',
  };

  orderBy(val) {
    if (val == 'all') {
      param.remove('order');
    } else {
      param['order'] = val;
    }
    param['curr_page'] = 1;
    defaultVal = val;
    getData();
  }

  stateDialog(item) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10),
          titlePadding: EdgeInsets.all(10),
          title: Text(
            '提示',
          ),
          content: SingleChildScrollView(
            child: Container(
              // width: MediaQuery.of(context).size.width - 100,
              child: Text(
                '确认${item['state'].toString() == '1' ? '停用' : '开启'} ${item['shop_name']}的优惠券?',
                style: TextStyle(fontSize: CFFontSize.content),
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('确认'),
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () {
                ajax(
                    'Adminrelas-coupon-editState',
                    {
                      'coupon_id': item['coupon_id'],
                      'state': int.parse('${item['state'].toString() == '1' ? '0' : '1'}'),
                    },
                    true, (data) {
                  getData();
                  Navigator.of(context).pop();
                }, () {}, _context);
              },
            ),
          ],
        );
      },
    );
  }

  Map modifyItem = {};

  modifyDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10),
          titlePadding: EdgeInsets.all(10),
          title: Text(
            '${modifyItem['shop_name']}优惠券修改',
          ),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width - 100,
              child: Column(
                children: <Widget>[
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
                                    style: TextStyle(color: CFColors.danger, fontSize: CFFontSize.content),
                                  ),
                                  Text(
                                    '限领数量',
                                    style: TextStyle(fontSize: CFFontSize.content),
                                  )
                                ],
                              ),
                              Text(
                                '(张/人)',
                                style: TextStyle(fontSize: CFFontSize.tabBar),
                              )
                            ],
                          ),
                          margin: EdgeInsets.only(right: 10),
                        ),
                        Expanded(
                          flex: 1,
                          child: InputSingle(
                            onChanged: (val) {
                              setState(() {
                                modifyItem['limit_nums'] = val;
                              });
                            },
                            value: modifyItem['limit_nums'],
                            type: NumberType.int,
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
                                style: TextStyle(color: CFColors.danger, fontSize: CFFontSize.content),
                              ),
                              Text(
                                '剩余数量',
                                style: TextStyle(fontSize: CFFontSize.content),
                              )
                            ],
                          ),
                          margin: EdgeInsets.only(right: 10),
                        ),
                        Expanded(
                          flex: 1,
                          child: InputSingle(
                            onChanged: (val) {
                              setState(() {
                                modifyItem['left_nums'] = val;
                              });
                            },
                            value: modifyItem['left_nums'],
                            type: NumberType.int,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('确认'),
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () {
                ajax(
                    'Adminrelas-coupon-ajaxEditCoupon',
                    {
                      'leftnum': modifyItem['left_nums'],
                      'limitnum': modifyItem['limit_nums'],
                      'coupon_id': modifyItem['coupon_id']
                    },
                    true, (data) {
                  getData();
                  Navigator.of(context).pop();
                }, () {}, _context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('优惠券'),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        // onLoading: _onLoading,
        child: ListView(
          controller: _controller,
          padding: EdgeInsets.all(10),
          children: <Widget>[
            SearchBarPlugin(
              secondChild: Column(children: <Widget>[
                Input(
                  label: '店铺',
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('shop_name');
                    } else {
                      param['shop_name'] = val;
                    }
                  },
                  labelWidth: 90,
                ),
                Select(
                  selectOptions: couponType,
                  selectedValue: param['coupon_type'] ?? 'all',
                  label: '优惠券类型',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('coupon_type');
                    } else {
                      param['coupon_type'] = val;
                    }
                  },
                  labelWidth: 90,
                ),
                Select(
                  selectOptions: couponType,
                  selectedValue: param['goods_type'] ?? 'all',
                  label: '商品类型',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('goods_type');
                    } else {
                      param['goods_type'] = val;
                    }
                  },
                  labelWidth: 90,
                ),
                Select(
                  selectOptions: couponSource,
                  selectedValue: param['coupon_source'] ?? 'all',
                  label: '优惠券来源',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('coupon_source');
                    } else {
                      param['coupon_source'] = val;
                    }
                  },
                  labelWidth: 90,
                ),
                Select(
                  selectOptions: state,
                  selectedValue: param['state'] ?? 'all',
                  label: '状态',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('state');
                    } else {
                      param['state'] = val;
                    }
                  },
                  labelWidth: 90,
                ),
                DateSelectPlugin(
                  onChanged: getDateTime,
                  label: '创建时间',
                  labelWidth: 90,
                ),
                DateSelectPlugin(
                  onChanged: getDateTime2,
                  label: '有效时间',
                  labelWidth: 90,
                ),
                Select(
                  selectOptions: selects,
                  selectedValue: defaultVal,
                  label: '排序',
                  onChanged: orderBy,
                  labelWidth: 90,
                ),
              ]),
            ),
            Container(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  PrimaryButton(
                    onPressed: () {
                      param['curr_page'] = 1;
                      getData();
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text('搜索'),
                  ),
                  PrimaryButton(
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CouponCreate()),
                      ).then((value) {
                        if (value == true) {
                          getData();
                          print(value);
                        }
                      });
                    },
                    child: Text('创建优惠券'),
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: 10),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 6),
              alignment: Alignment.centerRight,
              child: NumberBar(count: count),
            ),
            loading
                ? Container(
                    alignment: Alignment.center,
                    child: CupertinoActivityIndicator(),
                  )
                : Container(
                    child: ajaxData.isEmpty
                        ? Container(
                            alignment: Alignment.center,
                            child: Text('无数据'),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: ajaxData.map<Widget>((item) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xffdddddd),
                                  ),
                                ),
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: columns.map<Widget>((col) {
                                    Widget con = Text('${item[col['key']] ?? ''}');
                                    switch (col['key']) {
                                      case 'coupon_id':
                                        con = Text('coupons-${item['coupon_id']}');
                                        break;
                                      case 'coupon_type':
                                        con = Text('${couponType[item['coupon_type']]}');
                                        break;
                                      case 'goods_type':
                                        con = '${item['goods_type']}' == '0'
                                            ? Text('全部商品')
                                            : Text('${goodsType[item['goods_type']]}');
                                        break;
                                      case 'coupon_source':
                                        con = Text('${couponSource[item['coupon_source']]}');
                                        break;
                                      case 'state':
                                        con = Text('${state[item['state']]}');
                                        break;
                                      case 'option':
                                        con = Wrap(
                                          runSpacing: 10,
                                          spacing: 10,
                                          children: <Widget>[
                                            PrimaryButton(
                                              onPressed: () {
                                                setState(() {
                                                  modifyItem = jsonDecode(jsonEncode(item));
                                                  modifyDialog();
                                                });
                                              },
                                              child: Text('修改'),
                                            ),
                                            '${item['state']}' == '1'
                                                ? PrimaryButton(
                                                    onPressed: () {
                                                      stateDialog(item);
                                                    },
                                                    child: Text('停用'),
                                                    type: BtnType.danger,
                                                  )
                                                : PrimaryButton(
                                                    onPressed: () {
                                                      stateDialog(item);
                                                    },
                                                    child: Text('开启'),
                                                  ),
                                          ],
                                        );
                                        break;
                                    }

                                    return Container(
                                      margin: EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            width: 100,
                                            alignment: Alignment.centerRight,
                                            child: Text('${col['title']}'),
                                            margin: EdgeInsets.only(right: 10),
                                          ),
                                          Expanded(flex: 1, child: con)
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
            Container(
              child: PagePlugin(
                current: param['curr_page'],
                total: count,
                pageSize: param['page_count'],
                function: getPage,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CFFloatingActionButton(
        onPressed: toTop,
        child: Icon(Icons.keyboard_arrow_up),
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
