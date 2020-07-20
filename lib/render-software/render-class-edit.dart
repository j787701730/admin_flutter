import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
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

class RenderClassEdit extends StatefulWidget {
  final props;

  RenderClassEdit(this.props);

  @override
  _RenderClassEditState createState() => _RenderClassEditState();
}

class _RenderClassEditState extends State<RenderClassEdit> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {
    'page_count': 15,
    'curr_page': 1,
  };
  List ajaxData = [];
  int count = 0;
  bool loading = true;

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

    ajax('Adminrelas-RenderSoftware-getAllParams', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          ajaxData = res['data'] ?? [];
          count = int.tryParse('${res['count'] ?? 0}');
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
    param['curr_page'] += page;
    getData();
  }

  priceDialog(item) {
    String price = item['order_price'];
    return showDialog<void>(
      context: _context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
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

  turnTo(item) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (context) => WorkOrdersDetail(item),
      ),
    );
  }

  bool isExpandedFlag = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('资源属性配置'),
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
            AnimatedCrossFade(
              duration: const Duration(
                milliseconds: 300,
              ),
              firstChild: Placeholder(
                fallbackHeight: 0.1,
                color: Colors.transparent,
              ),
              secondChild: Column(
                children: <Widget>[
                  Input(
                    label: '属性名称',
                    onChanged: (String val) {
                      param['order_no'] = val;
                    },
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
                    },
                    child: Text('添加属性'),
                  ),
                  PrimaryButton(
                    color: CFColors.success,
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          isExpandedFlag = !isExpandedFlag;
                        });
                      }
                    },
                    child: Text('${isExpandedFlag ? '展开' : '收缩'}选项'),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              alignment: Alignment.centerRight,
              child: NumberBar(count: count),
            ),
            Container(
              padding: EdgeInsets.all(6),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 90,
                    child: Text('属性ID'),
                  ),
                  Expanded(
                    child: Container(
                      child: Text('属性名称'),
                    ),
                  ),
                  Container(
                    width: 90,
                    child: Text('操作'),
                  ),
                ],
              ),
              color: Color(0xffeeeeee),
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
                        : Column(
                            children: ajaxData.map<Widget>(
                              (item) {
                                return Container(
                                  padding: EdgeInsets.all(6),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        width: 90,
                                        child: Text('${item['param_id']}'),
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Text('${item['param_name']}'),
                                        ),
                                      ),
                                      Container(
                                        width: 90,
                                        child: Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: <Widget>[
                                            InkWell(
                                              onTap: () {},
                                              child: Text(
                                                '编辑',
                                                style: TextStyle(
                                                  color: CFColors.primary,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {},
                                              child: Text(
                                                '删除',
                                                style: TextStyle(
                                                  color: CFColors.primary,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {},
                                              child: Text(
                                                '加入',
                                                style: TextStyle(
                                                  color: CFColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ).toList(),
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
    );
  }
}
