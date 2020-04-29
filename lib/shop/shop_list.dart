import 'dart:async';
import 'dart:ui';

import 'package:admin_flutter/plugin/city_select_plugin.dart';
import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/shop/shop_staff.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ShopList extends StatefulWidget {
  @override
  _ShopListState createState() => _ShopListState();
}

class _ShopListState extends State<ShopList> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {
    'limit': 10,
    'timemin': '',
    'timemax': '',
    'shopName': '',
    'company_name': '',
    'tax_no': '',
    'page': 1,
  };
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  Map shopState = {'-2': '被冻结', '-1': '已打烊', '0': '待审核', '1': '营业中'};
  List columns = [
    {'title': '店铺名', 'key': 'shop_name'},
    {'title': '详细地址', 'key': 'shop_address'},
    {'title': '店铺角色', 'key': 'role_id'},
    {'title': '管理员', 'key': 'login_name'},
    {'title': '公司名称', 'key': 'company_name'},
    {'title': '信用代码', 'key': 'tax_no'},
    {'title': '收藏次数', 'key': 'collect_times'},
    {'title': '创建日期', 'key': 'create_date'},
    {'title': '更新日期', 'key': 'update_date'},
    {'title': '状态', 'key': 'state'},
    {'title': '操作', 'key': 'option'},
  ];
  Map roles = {
    "101": {
      "role_id": "101",
      "role_en_name": "ROLE_TYPE_STORE",
      "role_ch_name": "销售门店",
      "can_apply": "1",
      "comments": "提供全方位的销售定制门店",
      "icon": "icon-shopping-cart"
    },
    "102": {
      "role_id": "102",
      "role_en_name": "ROLE_TYPE_SUPPLIER",
      "role_ch_name": "供货商",
      "can_apply": "1",
      "comments": "提供五金建材的供货服务",
      "icon": "icon-truck"
    },
    "103": {
      "role_id": "103",
      "role_en_name": "ROLE_TYPE_FACTORY",
      "role_ch_name": "加工工厂",
      "can_apply": "1",
      "comments": "提供定价加工服务",
      "icon": "icon-gears"
    },
    "104": {
      "role_id": "104",
      "role_en_name": "ROLE_TYPE_DESIGNER",
      "role_ch_name": "设计师",
      "can_apply": "1",
      "comments": "提供设计、测量等服务",
      "icon": "icon-male"
    },
    "105": {
      "role_id": "105",
      "role_en_name": "ROLE_TYPE_CONSTRUCTION",
      "role_ch_name": "工程施工",
      "can_apply": "1",
      "comments": "提供上门施工服务",
      "icon": "icon-wrench"
    }
  };
  List selectRole = [];
  Map order = {
    'all': '无',
    'company_name': '公司名称 升序',
    'company_name desc': '公司名称 降序',
    'tax_no': '信用代码 升序',
    'tax_no desc': '信用代码 降序',
    'collect_times': '收藏次数 升序',
    'collect_times desc': '收藏次数 降序',
    'create_date': '创建时间 升序',
    'create_date desc': '创建时间 降序',
    'update_date': '更新时间 升序',
    'update_date desc': '更新时间 降序',
    'state': '状态 升序',
    'state desc': '状态 降序',
  };
  String defaultVal = 'all';

  orderBy(val) {
    if (val == 'all') {
      param.remove('order');
    } else {
      param['order'] = val;
    }
    param['page'] = 1;
    defaultVal = val;
    getData();
  }

  void _onRefresh() async {
    setState(() {
      param['page'] = 1;
      getData(isRefresh: true);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _context = context;
    Timer(Duration(milliseconds: 200), () {
      getData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getData({isRefresh: false}) async {
    setState(() {
      loading = true;
    });
    ajax('Adminrelas-ShopsManage-shopsList', param, true, (res) {
      if (mounted) {
        setState(() {
          ajaxData = res['err_msg']['data'] ?? [];
          count = int.tryParse('${res['err_msg']['num']}');
          loading = false;
          toTop();
        });
        if (isRefresh) {
          _refreshController.refreshCompleted();
        }
      }
    }, () {
      setState(() {
        loading = false;
      });
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
    if (loading) return;
    param['page'] += page;
    getData();
  }

  getArea(val) {
    param['city'] = {};
    if (val['city'] != '0') {
      param['city']['city'] = val['city'];
    }
    if (val['region'] != '0') {
      param['city']['region'] = val['region'];
    }
    if (val['province'] == '0') {
      param.remove('city');
    } else {
      param['city']['province'] = val['province'];
    }
  }

  getArea2(val) {
    param['service_city'] = {};
    if (val['city'] != '0') {
      param['service_city']['city'] = val['city'];
    }
    if (val['region'] != '0') {
      param['service_city']['region'] = val['region'];
    }
    if (val['province'] == '0') {
      param.remove('service_city');
    } else {
      param['service_city']['province'] = val['province'];
    }
  }

  operaDialog(item) {
    return showDialog<void>(
      context: _context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '系统提示',
            style: TextStyle(fontSize: CFFontSize.topTitle),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '确定要 ${item['state'] == '1' || item['state'] == '-1' ? '冻结' : '解冻'} ${item['login_name']} 账号?',
                  style: TextStyle(fontSize: CFFontSize.content),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  getDateTime(val) {
    if (val['min'] == null) {
      param.remove('timemin');
    } else {
      param['timemin'] = val['min'].toString().substring(0, 10);
    }
    if (val['max'] == null) {
      param.remove('timemax');
    } else {
      param['timemax'] = val['max'].toString().substring(0, 10);
    }
  }

  turnTo(item) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (context) => ShopStaff({'shop_name': item['shop_name'], 'shop_id': item['shop_id']}),
      ),
    );
  }

  roleDialog() {
    return showDialog<void>(
      context: _context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context1, state) {
          /// 这里的state就是setState
          return AlertDialog(
            title: Text(
              '权限管理',
              style: TextStyle(fontSize: CFFontSize.topTitle),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Wrap(
                    spacing: 10,
                    children: roles.keys.toList().map<Widget>((key) {
                      return InkWell(
                        onTap: () {
                          if (selectRole.indexOf(key) > -1) {
                            setState(() {
                              selectRole.remove(key);
                            });
                            state(() {
                              selectRole.remove(key);
                            });
                          } else {
                            setState(() {
                              selectRole.add(key);
                            });
                            state(() {
                              selectRole.add(key);
                            });
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Checkbox(
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              value: selectRole.indexOf(key) > -1,
                              onChanged: (val) {
                                if (selectRole.indexOf(key) > -1) {
                                  setState(() {
                                    selectRole.remove(key);
                                  });
                                  state(() {
                                    selectRole.remove(key);
                                  });
                                } else {
                                  setState(() {
                                    selectRole.add(key);
                                  });
                                  state(() {
                                    selectRole.add(key);
                                  });
                                }
                              },
                            ),
                            Container(
                              child: Text(
                                '${roles[key]['role_ch_name']}',
                                style: TextStyle(fontSize: CFFontSize.content),
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
            actions: <Widget>[
              FlatButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: Text('提交'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }); //
      },
    );
  }

  bool isExpandedFlag = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('店铺列表'),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: ListView(
          controller: _controller,
          padding: EdgeInsets.all(15),
          children: <Widget>[
            AnimatedCrossFade(
              duration: const Duration(
                milliseconds: 300,
              ),
              firstChild: Container(),
              secondChild: Column(
                children: <Widget>[
                  Input(
                    label: '店铺列表',
                    onChanged: (String val) {
                      setState(() {
                        param['shopName'] = val;
                      });
                    },
                  ),
                  Input(
                    label: '公司名称',
                    onChanged: (String val) {
                      setState(() {
                        param['company_name'] = val;
                      });
                    },
                  ),
                  Input(
                    label: '信用代码',
                    onChanged: (String val) {
                      setState(() {
                        param['tax_no'] = val;
                      });
                    },
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 80,
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 10),
                          child: Text('店铺地址'),
                        ),
                        Expanded(
                          flex: 1,
                          child: CitySelectPlugin(
                            getArea: getArea,
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
                          margin: EdgeInsets.only(right: 10),
                          child: Text('服务地址'),
                        ),
                        Expanded(
                          flex: 1,
                          child: CitySelectPlugin(
                            getArea: getArea2,
                          ),
                        )
                      ],
                    ),
                  ),
                  DateSelectPlugin(
                    onChanged: getDateTime,
                    label: '创建时间',
                  ),
                  Select(
                    selectOptions: order,
                    selectedValue: defaultVal,
                    onChanged: orderBy,
                    label: "排序",
                  ),
                ],
              ),
              crossFadeState: isExpandedFlag ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            ),
            Container(
              margin: EdgeInsets.only(
                bottom: 15,
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  SizedBox(
                    height: 30,
                    child: PrimaryButton(
                      onPressed: () {
                        param['page'] = 1;
                        getData();
                        FocusScope.of(context).requestFocus(
                          FocusNode(),
                        );
                      },
                      child: Text('搜索'),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: PrimaryButton(
                      color: CFColors.success,
                      onPressed: () {
                        setState(() {
                          isExpandedFlag = !isExpandedFlag;
                        });
                      },
                      child: Text('${isExpandedFlag ? '展开' : '收缩'}选项'),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              alignment: Alignment.centerRight,
              child: NumberBar(count: count),
            ),
            loading
                ? Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: CupertinoActivityIndicator(),
                  )
                : ajaxData.isEmpty
                    ? Container(
                        alignment: Alignment.center,
                        height: 40,
                        child: Text('无数据'),
                      )
                    : Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: ajaxData.map<Widget>((item) {
                            return Container(
                              padding: EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xffeeeeee),
                                ),
                              ),
                              margin: EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: columns.map<Widget>((col) {
                                  Widget con = Text('${item[col['key']] ?? ''}');
                                  switch (col['key']) {
                                    case 'login_name':
                                      con = Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: <Widget>[
                                          Text('[店主] ${item['login_name']} '),
                                          InkWell(
                                            child: Container(
                                              child: Text(
                                                '查看员工',
                                                style: TextStyle(color: Colors.blue),
                                              ),
                                            ),
                                            onTap: () {
                                              turnTo(item);
                                            },
                                          )
                                        ],
                                      );
                                      break;
                                    case 'state':
                                      con = Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          width: 60,
                                          height: 22,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Color(0xff5cb85c),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(4),
                                            ),
                                          ),
                                          child: Text(
                                            '${shopState[item['state']]}',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      );
                                      break;
                                    case 'role_id':
                                      con = InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectRole = item['role_id'].split(',');
                                            roleDialog();
                                          });
                                        },
                                        child: Container(
                                          child: Wrap(
                                            spacing: 10,
                                            runSpacing: 10,
                                            children: item['role_id'].split(',').map<Widget>((role) {
                                              return Container(
                                                child: Text(
                                                  '${roles[role]['role_ch_name']}',
                                                  style: TextStyle(color: Colors.blue),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      );
                                      break;
                                    case 'option':
                                      con = Row(
                                        children: <Widget>[
                                          Container(
                                            height: 30,
                                            child: PrimaryButton(
                                              type: item['state'] == '1' || item['state'] == '-1' ? 'error' : null,
                                              onPressed: () {
                                                operaDialog(item);
                                              },
                                              child: Text(item['state'] == '1' || item['state'] == '-1' ? '冻结' : '解冻'),
                                            ),
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
                                          width: 80,
                                          alignment: Alignment.centerRight,
                                          child: Text('${col['title']}'),
                                          margin: EdgeInsets.only(right: 10),
                                        ),
                                        Expanded(flex: 1, child: con),
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
                current: param['page'],
                total: count,
                pageSize: param['limit'],
                function: getPage,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: CFFloatingActionButton(
        onPressed: toTop,
        child: Icon(Icons.keyboard_arrow_up),
      ),
    );
  }
}
