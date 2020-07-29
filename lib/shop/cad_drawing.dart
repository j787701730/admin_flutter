import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/search-bar-plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/shop/cad_drawing_modify.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CadDrawing extends StatefulWidget {
  @override
  _CadDrawingState createState() => _CadDrawingState();
}

class _CadDrawingState extends State<CadDrawing> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '用户名', 'key': 'user_name'},
    {'title': '用户电话', 'key': 'user_phone'},
    {'title': '用户地址', 'key': 'user_address'},
    {'title': '行业分类', 'key': 'class_name'},
    {'title': '效果图标题', 'key': 'sd_title'},
    {'title': '状态', 'key': 'state_name'},
    {'title': '创建日期', 'key': 'create_date'},
    {'title': '更新日期', 'key': 'update_date'},
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
    ajax('Adminrelas-ShopsManage-drawingSearchList', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['supplys'] ?? [];
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
    if (loading) return;
    param['curr_page'] = page;
    getData();
  }

  Map order = {
    'all': '无',
    'create_date': '创建时间 升序',
    'create_date desc': '创建时间 降序',
    'update_date': '更新时间 升序',
    'update_date desc': '更新时间 降序',
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

  Map state = {
    'all': '全部',
    '0': '作废',
    '1': '在用',
    '2': '设计中',
    '3': '已设计',
  };

  getDateTime(val) {
    if (val['min'] == null) {
      param.remove('create_dateL');
    } else {
      param['create_dateL'] = val['min'].toString().substring(0, 10);
    }
    if (val['max'] == null) {
      param.remove('create_dateR');
    } else {
      param['create_dateR'] = val['max'].toString().substring(0, 10);
    }
  }

  getDateTime2(val) {
    if (val['min'] == null) {
      param.remove('update_dateL');
    } else {
      param['update_dateL'] = val['min'].toString().substring(0, 10);
    }
    if (val['max'] == null) {
      param.remove('update_dateR');
    } else {
      param['update_dateR'] = val['max'].toString().substring(0, 10);
    }
  }

  stateDialog(item) {
    return showDialog<void>(
      context: _context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10),
          titlePadding: EdgeInsets.all(10),
          title: Text(
            '提示',
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width - 100,
                  child: Text(
                    '确认 ${item['sd_title']} ${item['state'].toString() == '2' ? '效果图已完成' : '将状态修改为设计中'}',
                    style: TextStyle(fontSize: CFFontSize.content),
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('关闭'),
              onPressed: () {
                Navigator.of(_context).pop();
              },
            ),
            FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('保存'),
              onPressed: () {
                Navigator.of(_context).pop();
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
        title: Text('效果图制作'),
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
            SearchBarPlugin(
              secondChild: Column(
                children: <Widget>[
                  Input(
                    labelWidth: 100,
                    label: '用户名',
                    onChanged: (String val) {
                      if (val == '') {
                        param.remove('user_name');
                      } else {
                        param['user_name'] = val;
                      }
                    },
                  ),
                  Input(
                    labelWidth: 100,
                    label: '用户电话',
                    onChanged: (String val) {
                      if (val == '') {
                        param.remove('user_phone');
                      } else {
                        param['user_phone'] = val;
                      }
                    },
                  ),
                  Input(
                    labelWidth: 100,
                    label: '效果图标题',
                    onChanged: (String val) {
                      if (val == '') {
                        param.remove('sd_title');
                      } else {
                        param['sd_title'] = val;
                      }
                    },
                  ),
                  DateSelectPlugin(
                    onChanged: getDateTime,
                    label: '创建时间',
                    labelWidth: 100,
                  ),
                  DateSelectPlugin(
                    onChanged: getDateTime2,
                    label: '更新时间',
                    labelWidth: 100,
                  ),
                  Select(
                    selectOptions: state,
                    selectedValue: param['state'] ?? 'all',
                    label: '状态',
                    onChanged: (String newValue) {
                      if (newValue == 'all') {
                        param.remove('state');
                      } else {
                        param['state'] = newValue;
                      }
                    },
                    labelWidth: 100,
                  ),
                  Select(
                    selectOptions: order,
                    selectedValue: defaultVal,
                    onChanged: orderBy,
                    label: '排序',
                    labelWidth: 100,
                  ),
                ],
              ),
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
                                      case 'option':
                                        con = Wrap(
                                          runSpacing: 10,
                                          spacing: 10,
                                          children: <Widget>[
                                            PrimaryButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => CadDrawingModify({'item': item}),
                                                  ),
                                                );
                                              },
                                              child: Text('修改'),
                                            ),
                                            '${item['state']}' == '2' &&
                                                    item['render_pics'] != null &&
                                                    item['render_pics'].isNotEmpty
                                                ? Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    child: PrimaryButton(
                                                      onPressed: () {
                                                        stateDialog(item);
                                                      },
                                                      child: Text('设计完成'),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 0,
                                                  ),
                                            '${item['state']}' == '1'
                                                ? Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    child: PrimaryButton(
                                                      onPressed: () {
                                                        stateDialog(item);
                                                      },
                                                      child: Text('设计中'),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 0,
                                                  )
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
