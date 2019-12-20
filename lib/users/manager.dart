import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/users/loginRecord.dart';
import 'package:admin_flutter/users/user_message_modify.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UsersManager extends StatefulWidget {
  @override
  _UsersManagerState createState() => _UsersManagerState();
}

class _UsersManagerState extends State<UsersManager> {
  Map param = {"curr_page": 1, "page_count": 15};
  List logs = [];
  int count = 0;
  bool loading = false;
  BuildContext _context;
  ScrollController _controller;
  Map searchData = {'user_name': '', 'ip': '', 'err_code': '', 'url': ''};
  Map searchName = {'user_name': '用户', 'ip': 'IP地址', 'err_code': '错误码', 'url': '访问路径'};
  List columns = [
    {'title': '类型', 'key': 'type'},
    {'title': '用户', 'key': 'login_name'},
    {'title': '手机号', 'key': 'user_phone'},
    {'title': '用户类型', 'key': 'user_type'},
    {'title': '店铺名', 'key': 'shop_name'},
    {'title': '扣费类型', 'key': 'pricing_class'},
    {'title': '定价类型', 'key': 'pricing_strategy_id'},
    {'title': '定价时间', 'key': 'pricing_time'},
    {'title': '注册时间', 'key': 'register_time'},
    {'title': '有效期', 'key': 'eff_date'},
    {'title': '最后登录', 'key': 'last_login_time'},
    {'title': '登录数', 'key': 'visit_times'},
    {'title': '状态', 'key': 'user_state'},
    {'title': '操作', 'key': 'option'},
  ];

  Map userType = {
    "0": {"icon": "icon-user", "type_id": 0, "type_ch_name": "普通用户", "comments": "普通用户"},
    "1": {
      "type_id": "1",
      "type_en_name": "USER_TYPE_CAD_LOGIN",
      "select_type": "0",
      "icon": "icon-windows",
      "type_ch_name": "旧版CAD登录",
      "comments": "可以登录旧设计软件"
    },
    "2": {
      "type_id": "2",
      "type_en_name": "USER_TYPE_ERP_BIND",
      "select_type": "0",
      "icon": "icon-fire ",
      "type_ch_name": "ERP工厂端-软件绑定",
      "comments": "可以绑定平台用户"
    },
    "4": {
      "type_id": "4",
      "type_en_name": "USER_TYPE_BILL_DESIGN",
      "select_type": "0",
      "icon": "icon-maxcdn",
      "type_ch_name": "CAD设计端-完整版",
      "comments": "可以登录CAD设计端完整版"
    },
    "5": {
      "type_id": "5",
      "type_en_name": "USER_TYPE_BILL_WEB",
      "select_type": "0",
      "icon": "icon-skype",
      "type_ch_name": "网页端登录",
      "comments": "可以登录网页端"
    },
    "6": {
      "type_id": "6",
      "type_en_name": "USER_TYPE_BILL_OPENS",
      "select_type": "0",
      "icon": "icon-tumblr-sign",
      "type_ch_name": "开料软件登录",
      "comments": "可以登录开料软件"
    },
    "7": {
      "type_id": "7",
      "type_en_name": "USER_TYPE_AREA_MANAGER",
      "select_type": "1",
      "icon": "icon-adn",
      "type_ch_name": "经销商",
      "comments": "顶级推荐人"
    },
    "8": {
      "type_id": "8",
      "type_en_name": "USER_TYPE_SALESMAN",
      "select_type": "1",
      "icon": "icon-male",
      "type_ch_name": "业务员",
      "comments": "公司业务员"
    },
    "9": {
      "type_id": "9",
      "type_en_name": "USER_TYPE_OPTIMIZE",
      "select_type": "0",
      "icon": "icon-pinterest",
      "type_ch_name": "优化软件-免费版",
      "comments": "可以登录优化软件"
    },
    "10": {
      "type_id": "10",
      "type_en_name": "USER_TYPE_BASE_LIMIT",
      "select_type": "0",
      "icon": "icon-tasks",
      "type_ch_name": "CAD设计端-精简版",
      "comments": "1.8W，设计端版本"
    },
    "11": {
      "type_id": "11",
      "type_en_name": "USER_TYPE_WEB_CAD",
      "select_type": "0",
      "icon": "icon-desktop",
      "type_ch_name": "CAD设计端-WEB版",
      "comments": "可以登录WEB-CAD版本"
    },
    "12": {
      "type_id": "12",
      "type_en_name": "USER_TYPE_NEW_ERP",
      "select_type": "0",
      "icon": "icon-inbox",
      "type_ch_name": "新版ERP",
      "comments": "新版的计费ERP，需设置在主帐号上"
    },
    "13": {
      "type_id": "13",
      "type_en_name": "USER_TYPE_WEBCAD_SELLER",
      "select_type": "0",
      "icon": "icon-adn",
      "type_ch_name": "WebCAD经销商",
      "comments": "负责WebCAD推广的经销商"
    }
  };

  DateTime create_date_min;
  DateTime create_date_max;

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    setState(() {
      param['curr_page'] = 1;
      getData(isRefresh: true);
    });
  }

//  void _onLoading() async{
//    // monitor network fetch
//    await Future.delayed(Duration(milliseconds: 1000));
//    // if failed,use loadFailed(),if no data return,use LoadNodata()
////    items.add((items.length+1).toString());
//    if(mounted)
//      setState(() {
//
//      });
//    _refreshController.loadComplete();
//  }

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

  Map selectRow = {};
  double width;

  userTypeDialog() {
    showDialog<void>(
      context: _context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context1, state) {
          return AlertDialog(
            title: Text(
              '${selectRow['login_name']} 用户类型修改',
              style: TextStyle(fontSize: CFFontSize.topTitle),
            ),
            contentPadding: EdgeInsets.all(10),
            content: SingleChildScrollView(
              child: Container(
                width: 1400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      runSpacing: 4,
                      children: userType.keys.toList().map<Widget>(
                        (key) {
                          return key == '0' || '${userType[key]['select_type']}' == '1'
                              ? Container(
                                  width: 0,
                                )
                              : Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: InkWell(
                                    onTap: () {
                                      state(() {
                                        if (selectRow['user_type'].contains(key)) {
                                          selectRow['user_type'].remove(key);
                                        } else {
                                          selectRow['user_type'].add(key);
                                        }
                                      });
                                    },
                                    child: Container(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Checkbox(
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              value: selectRow['user_type'].contains(key),
                                              onChanged: (val) {
                                                state(() {
                                                  if (selectRow['user_type'].contains(key)) {
                                                    selectRow['user_type'].remove(key);
                                                  } else {
                                                    selectRow['user_type'].add(key);
                                                  }
                                                });
                                              }),
                                          Text(
                                            '${userType[key]['type_ch_name']}',
                                            style: TextStyle(
                                              fontSize: CFFontSize.content,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                        },
                      ).toList(),
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey,
                    ),
                    Wrap(
                      runSpacing: 4,
                      children: userType.keys.toList().map<Widget>(
                        (key) {
                          return '${userType[key]['select_type']}' == '1'
                              ? Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: InkWell(
                                    onTap: () {
                                      state(() {
                                        for (var k in userType.keys.toList()) {
                                          if ('${userType[k]['select_type']}' == '1') {
                                            if (k == key) {
                                              if (selectRow['user_type'].contains(k)) {
                                                selectRow['user_type'].remove(k);
                                              } else {
                                                selectRow['user_type'].add(k);
                                              }
                                            } else {
                                              selectRow['user_type'].remove(k);
                                            }
                                          }
                                        }
                                      });
                                    },
                                    child: Container(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Radio(
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              value: key,
                                              groupValue: selectRow['user_type'].indexOf(key) > -1
                                                  ? selectRow['user_type'][selectRow['user_type'].indexOf(key)]
                                                  : '',
                                              onChanged: (val) {
                                                state(() {
                                                  for (var k in userType.keys.toList()) {
                                                    if ('${userType[k]['select_type']}' == '1') {
                                                      if (k == key) {
                                                        if (selectRow['user_type'].contains(k)) {
                                                          selectRow['user_type'].remove(k);
                                                        } else {
                                                          selectRow['user_type'].add(k);
                                                        }
                                                      } else {
                                                        selectRow['user_type'].remove(k);
                                                      }
                                                    }
                                                  }
                                                });
                                              }),
                                          Text(
                                            '${userType[key]['type_ch_name']}',
                                            style: TextStyle(
                                              fontSize: CFFontSize.content,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 0,
                                );
                        },
                      ).toList(),
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
              PrimaryButton(
                child: Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  getData({isRefresh: false}) async {
    setState(() {
      loading = true;
    });
    if (create_date_min != null) {
      param['create_date_min'] = create_date_min.toString().substring(0, 10);
    } else {
      param.remove('create_date_min');
    }

    if (create_date_max != null) {
      param['create_date_max'] = create_date_max.toString().substring(0, 10);
    } else {
      param.remove('create_date_max');
    }

    for (String k in searchData.keys) {
      if (searchData[k] != '') {
        param[k] = searchData[k].toString();
      } else {
        param.remove(k);
      }
    }

    ajax('Adminrelas-userManager-userList', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          logs = res['data'];
          count = int.tryParse('${res['count'] ?? 0}');
          toTop();
          loading = false;
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
    param['curr_page'] += page;
    getData();
  }

  getDateTime(val) {
    setState(() {
      create_date_min = val['min'];
      create_date_max = val['max'];
    });
  }

  String defaultVal = 'all';

  Map selects = {
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

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('用户管理'),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
//          onLoading: _onLoading,
        child: ListView(
          controller: _controller,
          padding: EdgeInsets.all(10),
          children: <Widget>[
            Column(
              children: searchData.keys.map<Widget>((key) {
                return Input(
                    label: '${searchName[key]}',
                    onChanged: (String val) {
                      setState(() {
                        searchData[key] = val;
                      });
                    });
              }).toList(),
            ),
            DateSelectPlugin(
              onChanged: getDateTime,
              label: '操作日期',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                PrimaryButton(
                  onPressed: () {
                    setState(() {
                      param['curr_page'] = 1;
                      getData();
                    });
                  },
                  child: Text('搜索'),
                )
              ],
            ),
            Container(
              margin: EdgeInsets.only(bottom: 8),
              alignment: Alignment.centerRight,
              child: NumberBar(count: count),
            ),
            loading
                ? CupertinoActivityIndicator()
                : logs.isEmpty
                    ? Container(
                        alignment: Alignment.topCenter,
                        child: Text('无数据'),
                      )
                    : Column(
                        children: logs.map<Widget>((item) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xffdddddd), width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xffdddddd),
                                    offset: Offset(0.0, 3.0),
                                    blurRadius: 3.0,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xffffffff),
                                ),
                                padding: EdgeInsets.only(left: 6, right: 6, top: 8, bottom: 8),
                                child: Column(
                                  children: columns.map<Widget>((col) {
                                    Widget con = Container(
                                      width: 0,
                                    );

                                    switch (col['key']) {
                                      case 'type':
                                        if (0 >= int.tryParse(item['shop_id']) && int.tryParse(item['staff_id']) >= 1) {
                                          con = Text('员工账号');
                                        } else if (0 >= int.tryParse(item['shop_id']) &&
                                            int.tryParse(item['staff_id']) < 1) {
                                          con = Text('普通账号');
                                        } else if (int.tryParse(item['shop_id']) >= 1) {
                                          con = Text('企业主人');
                                        }
                                        break;
                                      case 'login_name':
                                        if (item['user_sex'] == '1') {
                                          con = Text('${item['login_name']}(真名: ${item['login_name']})(男)');
                                        } else if (item['user_sex'] == '2') {
                                          con = Text('${item['login_name']}(真名: ${item['login_name']})(女)');
                                        } else {
                                          con = Text('${item['login_name']}(真名: ${item['login_name']})');
                                        }
                                        break;
                                      case 'user_type':
                                        List uType = item['user_type'].split(',');
                                        con = InkWell(
                                          hoverColor: Colors.grey,
                                          onTap: () {
                                            setState(() {
                                              selectRow = jsonDecode(jsonEncode(item));
                                              selectRow['user_type'] = uType;
                                              userTypeDialog();
                                            });
                                          },
                                          child: Wrap(
                                            children: uType.map<Widget>((t) {
                                              return Container(
                                                margin: EdgeInsets.only(right: 10),
                                                child: Text(
                                                  '${userType[t]['type_ch_name']}',
                                                  style: TextStyle(color: Colors.blue),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        );
                                        break;
                                      case 'last_login_time':
                                        con = int.tryParse(item['visit_times']) > 0
                                            ? InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => LoginRecord(item),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  '${item['last_login_time']}',
                                                  style: TextStyle(color: Colors.blue),
                                                ),
                                              )
                                            : Text('${item['last_login_time']}');
                                        break;
                                      case 'user_state':
                                        if (item['user_state'] == '0') {
                                          con = Text('正常');
                                        } else if (item['user_state'] == '-1') {
                                          con = Text('冻结');
                                        } else {
                                          con = Text('${item['user_state']}');
                                        }
                                        break;
                                      case 'eff_date':
                                        con = Text('${item['eff_date']} 至 ${item['exp_date']}');
                                        break;
                                      case 'option':
                                        Widget btn;
                                        Widget btn2 = Container(width: 0);
                                        if (item['user_state'] == '0') {
                                          btn = Container(
                                            height: 30,
                                            margin: EdgeInsets.only(right: 10),
                                            child: PrimaryButton(
                                              onPressed: () {},
                                              padding: EdgeInsets.only(left: 0),
                                              child: Text('冻结'),
                                            ),
                                          );
                                        } else if (item['user_state'] == '-1') {
                                          btn = Container(
                                            height: 30,
                                            margin: EdgeInsets.only(right: 10),
                                            child: PrimaryButton(
                                              onPressed: () {},
                                              child: Text('解冻'),
                                            ),
                                          );
                                        } else {
                                          btn = Container(
                                            height: 30,
                                            margin: EdgeInsets.only(right: 10),
                                            child: PrimaryButton(
                                              onPressed: () {},
                                              child: Text('${item['user_state']}'),
                                            ),
                                          );
                                        }

                                        if (int.tryParse(item['shop_id']) >= 1) {
                                          if (item['invite_user_id'] != '0') {
                                            btn2 = Container(
                                              height: 30,
                                              margin: EdgeInsets.only(right: 10),
                                              child: PrimaryButton(
                                                onPressed: () {},
                                                child: Text('用户推荐人'),
                                              ),
                                            );
                                          } else if (item['invite_user_id'] == '0') {
                                            btn2 = Container(
                                              height: 30,
                                              margin: EdgeInsets.only(right: 10),
                                              child: PrimaryButton(
                                                onPressed: () {},
                                                child: Text('用户推荐人'),
                                              ),
                                            );
                                          }
                                        }

                                        con = Wrap(
                                          runSpacing: 10,
                                          spacing: 10,
                                          children: <Widget>[
                                            Container(
                                              height: 30,
                                              child: PrimaryButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => UserMessageModify(item),
                                                    ),
                                                  );
                                                },
                                                child: Text('编辑'),
                                              ),
                                            ),
                                            btn,
                                            item['erp_open_id '] == '1'
                                                ? Container(
                                                    height: 30,
                                                    child: PrimaryButton(
                                                      onPressed: () {},
                                                      child: Text('ERP解绑'),
                                                    ),
                                                  )
                                                : Container(width: 0),
                                            (0 >= int.tryParse(item['shop_id']) && int.tryParse(item['staff_id']) < 1)
                                                ? Container(
                                                    height: 30,
                                                    child: PrimaryButton(
                                                      onPressed: () {},
                                                      child: Text('升级为企业用户'),
                                                    ),
                                                  )
                                                : Container(width: 0),
                                            btn2
                                          ],
                                        );
                                        break;
                                      default:
                                        con = Text('${item[col['key']] ?? ''}');
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
                                          Expanded(flex: 1, child: con)
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
            Container(
              child: PagePlugin(
                current: param['curr_page'],
                total: count,
                pageSize: param['page_count'],
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
