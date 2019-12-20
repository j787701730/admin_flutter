import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/shop/create_cad_user_relation.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CadUserRelation extends StatefulWidget {
  @override
  _CadUserRelationState createState() => _CadUserRelationState();
}

class _CadUserRelationState extends State<CadUserRelation> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '发送店铺', 'key': 'a_shop_name'},
    {'title': '发送电话', 'key': 'a_user_phone'},
    {'title': '接收店铺', 'key': 'z_shop_name'},
    {'title': '接收电话', 'key': 'z_user_phone'},
    {'title': '数据来源', 'key': 'rela_source_name'},
    {'title': '设置默认', 'key': 'default_val'},
    {'title': '备注', 'key': 'comments'},
    {'title': '创建时间', 'key': 'create_date'},
    {'title': '生效日期', 'key': 'eff_date'},
    {'title': '失效日期', 'key': 'exp_date'},
    {'title': '操作', 'key': 'option'},
  ];

  Map ifDefault = {'all': '全部', '1': '默认', '0': '非默认'};
  Map relationSource = {'all': '全部', '1': '平台添加', '0': '门店授权'};

  void _onRefresh() async {
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

  getData({isRefresh: false}) async {
    setState(() {
      loading = true;
    });
    ajax('Adminrelas-shopsManage-cadUserRelaList', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'];
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
      duration: new Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  getPage(page) {
    if (loading) return;
    param['curr_page'] += page;
    getData();
  }

  getDateTime(val) {
    if (val['min'] == null) {
      param.remove('create_date_l');
    } else {
      param['create_date_l'] = val['min'].toString().substring(0, 10);
    }
    if (val['max'] == null) {
      param.remove('create_date_r');
    } else {
      param['create_date_r'] = val['max'].toString().substring(0, 10);
    }
  }

  getDateTime2(val) {
    if (val['min'] == null) {
      param.remove('eff_date');
    } else {
      param['eff_date'] = val['min'].toString().substring(0, 10);
    }
    if (val['max'] == null) {
      param.remove('exp_date');
    } else {
      param['exp_date'] = val['max'].toString().substring(0, 10);
    }
  }

  delDialog(item) {
    return showDialog<void>(
      context: _context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '提示',
            style: TextStyle(fontSize: CFFontSize.topTitle),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width - 100,
                  child: Text(
                    '确认删除 ${item['a_shop_name']} 发送到 ${item['z_shop_name']} 的CAD用户关系',
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

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'create_date': '创建时间 升序',
    'create_date desc': '创建时间 降序',
    'eff_date': '生效时间 升序',
    'eff_date desc': '生效时间 降序',
    'exp_date': '失效时间 升序',
    'exp_date desc': '失效时间 降序',
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
    return Scaffold(
      appBar: AppBar(
        title: Text('CAD用户关系'),
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
            Input(
              label: '发送店铺',
              onChanged: (String val) {
                setState(() {
                  if (val == '') {
                    param.remove('a_shop_name');
                  } else {
                    param['a_shop_name'] = val;
                  }
                });
              },
            ),
            Input(
              label: '发送电话',
              onChanged: (String val) {
                setState(() {
                  if (val == '') {
                    param.remove('a_user_phone');
                  } else {
                    param['a_user_phone'] = val;
                  }
                });
              },
            ),
            Input(
              label: '接收店铺',
              onChanged: (String val) {
                setState(() {
                  if (val == '') {
                    param.remove('z_shop_name');
                  } else {
                    param['z_shop_name'] = val;
                  }
                });
              },
            ),
            Input(
              label: '接收电话',
              onChanged: (String val) {
                setState(() {
                  if (val == '') {
                    param.remove('z_user_phone');
                  } else {
                    param['z_user_phone'] = val;
                  }
                });
              },
            ),
            Select(
              selectOptions: ifDefault,
              selectedValue: param['if_default'] ?? 'all',
              label: '状态',
              onChanged: (String newValue) {
                setState(() {
                  if (newValue == 'all') {
                    param.remove('if_default');
                  } else {
                    param['if_default'] = newValue;
                  }
                });
              },
            ),
            Select(
              selectOptions: relationSource,
              selectedValue: param['rela_source'] ?? 'all',
              label: '数据来源',
              onChanged: (String newValue) {
                setState(() {
                  if (newValue == 'all') {
                    param.remove('rela_source');
                  } else {
                    param['rela_source'] = newValue;
                  }
                });
              },
            ),
            DateSelectPlugin(
              onChanged: getDateTime,
              label: '创建时间',
            ),
            DateSelectPlugin(
              onChanged: getDateTime2,
              label: '有效时间',
            ),
            Select(
              selectOptions: selects,
              selectedValue: defaultVal,
              label: '排序',
              onChanged: orderBy,
            ),
            Container(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  SizedBox(
                    height: 30,
                    child: PrimaryButton(
                      onPressed: () {
                        param['curr_page'] = 1;
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (context) => new CreateCadUserRelation(null),
                          ),
                        );
                      },
                      child: Text('新增CAD用户关系'),
                    ),
                  )
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
                                  border: Border.all(color: Color(0xffdddddd), width: 1),
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
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: <Widget>[
                                            SizedBox(
                                              height: 30,
                                              child: PrimaryButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    new MaterialPageRoute(
                                                      builder: (context) => new CreateCadUserRelation({'item': item}),
                                                    ),
                                                  );
                                                },
                                                child: Text('修改'),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 30,
                                              child: PrimaryButton(
                                                type: 'error',
                                                onPressed: () {
                                                  delDialog(item);
                                                },
                                                child: Text('删除'),
                                              ),
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
    );
  }
}
