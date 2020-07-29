import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/search-bar-plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:admin_flutter/work-orders/work-order-assign.dart';
import 'package:admin_flutter/work-orders/work-orders-detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class WorkOrdersList extends StatefulWidget {
  @override
  _WorkOrdersListState createState() => _WorkOrdersListState();
}

class _WorkOrdersListState extends State<WorkOrdersList> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {
    'page_count': 10,
    'curr_page': 1,
  };
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  Map priority = {'0': '全部', '1': '普通', '2': '紧急'};
  Map state = {
    '0': '全部',
  };
  List columns = [
    {'title': '工单编号', 'key': 'order_no'},
    {'title': '工单标题', 'key': 'order_topic'},
    {'title': '工单分类', 'key': 'class_name'},
    {'title': '状态', 'key': 'state'},
    {'title': '优先级', 'key': 'priority'},
    {'title': '联系人', 'key': 'user_name'},
    {'title': '费用', 'key': 'order_price'},
    {'title': '指派', 'key': 'owner_user_name'},
    {'title': '创建日期', 'key': 'create_date'},
    {'title': '评价', 'key': 'evaluate_stars'},
    {'title': '操作', 'key': 'option'},
  ];
  Map order = {
    'all': '无',
    'order_topic': '工单标题 升序',
    'order_topic desc': '工单标题 降序',
    'class_id': '工单分类 升序',
    'class_id desc': '工单分类 降序',
    'state': '状态 升序',
    'state desc': '状态 降序',
    'priority': '优先级 升序',
    'priority desc': '优先级 降序',
    'create_date': '创建时间 升序',
    'create_date desc': '创建时间 降序'
  };
  String defaultVal = 'all';

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
      getData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getData({isRefresh: false}) {
    setState(() {
      loading = true;
    });
    for (var o in param.keys.toList()) {
      if (param[o] == '' || param[o] == null || '${param[o]}'.trim() == '') {
        param.remove(o);
      }
    }
    ajax('Adminrelas-WorkOrders-getData', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          ajaxData = res['data'] ?? [];
          count = int.tryParse('${res['count'] ?? 0}');
          loading = false;
          if (param['curr_page'] == 1 && res['state'] != null && state.length == 1) {
            for (var o in res['state'].keys.toList()) {
              state[o] = res['state'][o]['name'];
            }
          }
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
    param['curr_page'] = page;
    getData();
  }

  operaDialog(item) {
    return showDialog<void>(
      context: _context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10),
          titlePadding: EdgeInsets.all(10),
          title: Text(
            '系统提示',
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '确定要完成 ${item['order_no']} ?',
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
                ajax('Adminrelas-WorkOrders-setState', {'order_no': item['order_no']}, true, (data) {
                  Navigator.of(context).pop();
                  getData();
                }, () {}, _context);
              },
            ),
          ],
        );
      },
    );
  }

  evaluateContentDialog(item) {
    return showDialog<void>(
      context: _context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10),
          titlePadding: EdgeInsets.all(10),
          title: Text(
            '${item['order_no']} (${item['evaluate_stars']}星) 评价内容',
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '${item['evaluate_content']}',
                  style: TextStyle(fontSize: CFFontSize.content),
                ),
              ],
            ),
          ),
          actions: <Widget>[
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

  priceDialog(item) {
    String price = item['order_price'];
    return showDialog<void>(
      context: _context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10),
          titlePadding: EdgeInsets.all(10),
          title: Text(
            '系统提示',
          ),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(_context).size.width * 0.8,
              child: Input(
                label: '工单收费',
                value: price,
                onChanged: (val) {
                  price = val;
                },
              ),
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
                print(price);
                ajax('Adminrelas-WorkOrders-editW', {'order_no': item['order_no'], 'order_price': price}, true, (data) {
                  Fluttertoast.showToast(
                    msg: '修改成功',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                  );
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

  getDateTime(val) {
    if (val['min'] == null) {
      param.remove('create_dateL');
    } else {
      param['create_dateL'] = val['min'].toString().substring(0, 10);
    }
    if (val['max'] == null) {
      param.remove('create_dateU');
    } else {
      param['create_dateU'] = val['max'].toString().substring(0, 10);
    }
  }

  turnTo(item) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (context) => WorkOrdersDetail(item),
      ),
    );
  }

  // 指派
  assign(item) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (context) => WorkOrderAssign(item),
      ),
    ).then((value) {
      if (value == true) {
        getData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('工单列表'),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: ListView(
          controller: _controller,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          padding: EdgeInsets.all(15),
          children: <Widget>[
            SearchBarPlugin(
              secondChild: Column(
                children: <Widget>[
                  Input(
                    label: '工单编号',
                    onChanged: (String val) {
                      if (val.trim() == '') {
                        param.remove('order_no');
                      } else {
                        param['order_no'] = val;
                      }
                    },
                  ),
                  Input(
                    label: '工单标题',
                    onChanged: (String val) {
                      if (val.trim() == '') {
                        param.remove('order_topic');
                      } else {
                        param['order_topic'] = val;
                      }
                    },
                  ),
                  Input(
                    label: '联系人',
                    onChanged: (String val) {
                      if (val.trim() == '') {
                        param.remove('user_name');
                      } else {
                        param['user_name'] = val;
                      }
                    },
                  ),
                  Input(
                    label: '联系手机',
                    onChanged: (String val) {
                      if (val.trim() == '') {
                        param.remove('user_phone');
                      } else {
                        param['user_phone'] = val;
                      }
                    },
                  ),
                  Input(
                    label: '指派成员',
                    onChanged: (String val) {
                      if (val.trim() == '') {
                        param.remove('a_user');
                      } else {
                        param['a_user'] = val;
                      }
                    },
                  ),
                  Select(
                    selectOptions: priority,
                    selectedValue: param['priority'] ?? '0',
                    label: '优先级',
                    onChanged: (val) {
                      if (val == '0') {
                        param.remove('priority');
                      } else {
                        param['priority'] = val;
                      }
                    },
                  ),
                  Select(
                    selectOptions: state,
                    selectedValue: param['state'] ?? '0',
                    label: '状态',
                    onChanged: (val) {
                      if (val == '0') {
                        param.remove('state');
                      } else {
                        param['state'] = val;
                      }
                    },
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
                  PrimaryButton(
                    onPressed: () {
                      param['curr_page'] = 1;
                      getData();
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text('搜索'),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              alignment: Alignment.centerRight,
              child: NumberBar(count: count),
            ),
            Column(
              children: <Widget>[
                loading
                    ? Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: CupertinoActivityIndicator(),
                      )
                    : ajaxData.isEmpty
                        ? Container(
                            alignment: Alignment.center,
                            width: double.infinity,
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
                                    color: '${item['priority']}' == '2' ? Color(0xfffcf8e3) : Colors.white,
                                  ),
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: columns.map<Widget>((col) {
                                      Widget con = Text('${item[col['key']] ?? ''}');
                                      switch (col['key']) {
                                        case 'user_name':
                                          con = Text(
                                            '${item['user_name']}(${item['user_phone']})',
                                          );
                                          break;
                                        case 'state':
                                          con = Text(
                                            '${state[item['state']]}',
                                          );
                                          break;
                                        case 'priority':
                                          con = Text(
                                            '${priority[item['priority']]}',
                                          );
                                          break;
                                        case 'evaluate_stars':
                                          con = item['evaluate_stars'] == null || item['evaluate_stars'] == '0'
                                              ? Container()
                                              : Row(
                                                  children: <Widget>[
                                                    Text('${item['evaluate_stars']}星'),
                                                    item['evaluate_content'] == null || item['evaluate_content'] == ''
                                                        ? Container()
                                                        : IconButton(
                                                            icon: Icon(Icons.message),
                                                            onPressed: () {
                                                              evaluateContentDialog(item);
                                                            },
                                                            color: Colors.green,
                                                            iconSize: 20,
                                                            padding: EdgeInsets.zero,
                                                          )
                                                  ],
                                                );
                                          break;
                                        case 'option':
                                          con = Row(
                                            children: <Widget>[
                                              Container(
                                                margin: EdgeInsets.only(right: 10),
                                                child: PrimaryButton(
                                                  onPressed: () {
                                                    turnTo(item);
                                                  },
                                                  child: Text('查看'),
                                                ),
                                              ),
                                              item['if_exe']['price'] == 1
                                                  ? Container(
                                                      margin: EdgeInsets.only(right: 10),
                                                      child: PrimaryButton(
                                                        onPressed: () {
                                                          priceDialog(item);
                                                        },
                                                        child: Text('费用'),
                                                      ),
                                                    )
                                                  : Container(),
                                              item['if_exe']['owner'] == 1
                                                  ? Container(
                                                      margin: EdgeInsets.only(right: 10),
                                                      child: PrimaryButton(
                                                        onPressed: () {
                                                          assign(item);
                                                        },
                                                        child: Text('指派'),
                                                      ),
                                                    )
                                                  : Container(),
                                              item['if_exe']['confirm'] == 1
                                                  ? Container(
                                                      margin: EdgeInsets.only(right: 10),
                                                      child: PrimaryButton(
                                                        onPressed: () {
                                                          operaDialog(item);
                                                        },
                                                        child: Text('确认'),
                                                      ),
                                                    )
                                                  : Container(),
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
              ],
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
      floatingActionButtonAnimator: ScalingAnimation(),
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(
        FloatingActionButtonLocation.endFloat,
        floatingActionButtonOffsetX,
        floatingActionButtonOffsetY,
      ),
    );
  }
}
