import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/shop/create_cad_admin.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CadAdmins extends StatefulWidget {
  @override
  _CadAdminsState createState() => _CadAdminsState();
}

class _CadAdminsState extends State<CadAdmins> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '店铺名称', 'key': 'name'},
    {'title': '状态', 'key': 'state'},
    {'title': '备注', 'key': 'comments'},
    {'title': '创建日期', 'key': 'create_date'},
    {'title': '操作', 'key': 'option'},
  ];

  void _onRefresh() async {
    setState(() {
      param['curr_page'] = 1;
      getData(isRefresh: true);
    });
  }

  Map state = {'all': '全部', '1': '在用', '0': '冻结'};

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
    ajax('Adminrelas-shopsManage-cadAdminsList', {'param': jsonEncode(param)}, true, (res) {
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

  getPage(page) {if (loading) return;
    param['curr_page'] += page;
    getData();
  }

  dialog(data) {
    showDialog<void>(
      context: _context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${data['name']} 修改',
            style: TextStyle(fontSize: CFFontSize.topTitle),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width - 100,
                  child: TextField(
                    controller: TextEditingController(text: '${data['comments']}'),
                    maxLines: 5,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15)),
                    onChanged: (String val) {
                      setState(() {
//                              param['loginName'] = val;
                      });
                    },
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
              textColor: CFColors.white,
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

  stateDialog(item) {
    showDialog<void>(
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
                  child: Text('确定 ${item['state'] == '1' ? '冻结' : '解冻'}' '${item['name']} 店铺?'),
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
              textColor: CFColors.white,
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

  getDateTime(val) {
    setState(() {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WEB_CAD管理员'),
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
                  label: '店铺名称',
                  onChanged: (String val) {
                    setState(() {
                      if (val == '') {
                        param.remove('shop_name');
                      } else {
                        param['shop_name'] = val;
                      }
                    });
                  }),
              Select(
                selectOptions: state,
                selectedValue: param['if_state'] ?? 'all',
                label: '状态',
                onChanged: (String newValue) {
                  setState(() {
                    if (newValue == 'all') {
                      param.remove('if_state');
                    } else {
                      param['if_state'] = newValue;
                    }
                  });
                },
              ),
              DateSelectPlugin(onChanged: getDateTime,label: '创建时间',),
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
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          child: Text('搜索')),
                    ),
                    SizedBox(
                      height: 30,
                      child: PrimaryButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              new MaterialPageRoute(builder: (context) => new CreateCadAdmin()),
                            );
                          },
                          child: Text('新增CAD管理员')),
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
                                    decoration: BoxDecoration(border: Border.all(color: Color(0xffdddddd), width: 1)),
                                    margin: EdgeInsets.only(bottom: 10),
                                    padding: EdgeInsets.only(top: 5, bottom: 5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: columns.map<Widget>((col) {
                                        Widget con = Text('${item[col['key']] ?? ''}');
                                        switch (col['key']) {
                                          case 'state':
                                            con = Text('${state[item['state']]}');
                                            break;
                                          case 'option':
                                            con = Wrap(
                                              runSpacing: 10,
                                              spacing: 10,
                                              children: <Widget>[
                                                Container(
                                                  height: 30,
                                                  child: PrimaryButton(
                                                    onPressed: () {
                                                      dialog(item);
                                                    },
                                                    child: Text('修改'),
                                                  ),
                                                ),
                                                Container(
                                                  height: 30,
                                                  child: PrimaryButton(
                                                    onPressed: () {
                                                      stateDialog(item);
                                                    },
                                                    child: Text('${item['state']}' == '1' ? '冻结' : '解冻'),
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
                                    ));
                              }).toList(),
                            ),
                    ),
              Container(
                child: PagePlugin(
                    current: param['curr_page'], total: count, pageSize: param['page_count'], function: getPage),
              ),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: toTop,
        child: Icon(Icons.keyboard_arrow_up),
      ),
    );
  }
}
