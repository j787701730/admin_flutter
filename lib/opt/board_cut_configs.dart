import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/opt/board_cut_configs_modify.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BoardCutConfigs extends StatefulWidget {
  @override
  _BoardCutConfigsState createState() => _BoardCutConfigsState();
}

class _BoardCutConfigsState extends State<BoardCutConfigs> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  bool isExpandedFlag = true;
  Map type = {
    "all": "全部",
    "1": "机台配置",
    "2": "标签配置",
    "3": "样式配置",
    "4": "机器设备",
    "5": "新版机器设备",
  };
  Map ifCharge = {
    "all": "全部",
    "1": "是",
    "0": "否",
  };
  List columns = [
    {'title': '配置名称', 'key': 'config_name'},
    {'title': '配置类型', 'key': 'type_id'},
    {'title': '品牌', 'key': 'brand'},
    {'title': '规格', 'key': 'version'},
    {'title': '备注', 'key': 'comments'},
    {'title': '是否收费', 'key': 'if_charge'},
    {'title': '排序', 'key': 'sort'},
    {'title': '操作', 'key': 'option'},
  ];

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
    ajax('Adminrelas-BoardCut-confLists', {'param': jsonEncode(param)}, true, (res) {
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
    param['curr_page'] += page;
    getData();
  }

  delDialog(data) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '信息',
            style: TextStyle(fontSize: CFFontSize.topTitle),
          ),
          content: SingleChildScrollView(
            child: Container(
//                width: MediaQuery.of(context).size.width - 100,
              child: Text(
                '确认删除 ${data['config_name']} 配置?',
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
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('提交'),
              onPressed: () {
                Navigator.of(context).pop();
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
        builder: (context) => BoardCutConfigsModify(item),
      ),
    );
  }

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'type_id': '配置类型 升序',
    'type_id desc': '配置类型 降序',
    'brand': '品牌 升序',
    'brand desc': '品牌 降序',
    'version': '规格 升序',
    'version desc': '规格 降序',
    'if_charge': '是否收费 升序',
    'if_charge desc': '是否收费 降序',
    'sort': '排序 升序',
    'sort desc': '排序 降序',
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
        title: Text('开料配置'),
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
            AnimatedCrossFade(
              duration: const Duration(
                milliseconds: 300,
              ),
              firstChild: Container(),
              secondChild: Column(children: <Widget>[
                Input(
                  label: '配置名称',
                  onChanged: (String val) {
                    setState(() {
                      if (val == '') {
                        param.remove('config_name');
                      } else {
                        param['config_name'] = val;
                      }
                    });
                  },
                ),
                Input(
                  label: '品牌',
                  onChanged: (String val) {
                    setState(() {
                      if (val == '') {
                        param.remove('brand');
                      } else {
                        param['brand'] = val;
                      }
                    });
                  },
                ),
                Select(
                  selectOptions: type,
                  selectedValue: param['type_id'] ?? 'all',
                  label: '配置类型',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('type_id');
                    } else {
                      param['type_id'] = val;
                    }
                  },
                ),
                Select(
                  selectOptions: ifCharge,
                  selectedValue: param['if_charge'] ?? 'all',
                  label: '是否收费',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('if_charge');
                    } else {
                      param['if_charge'] = val;
                    }
                  },
                ),
                Select(
                  selectOptions: selects,
                  selectedValue: defaultVal,
                  label: '排序',
                  onChanged: orderBy,
                ),
              ]),
              crossFadeState: isExpandedFlag ? CrossFadeState.showFirst : CrossFadeState.showSecond,
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
                      child: Text('搜索'),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: PrimaryButton(
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        turnTo(null);
                      },
                      child: Text('新增'),
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
                                      case 'type_id':
                                        con = Text('${type[item['type_id']]}');
                                        break;
                                      case 'if_charge':
                                        con = Text('${ifCharge[item['if_charge']]}');
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
                                                  FocusScope.of(context).requestFocus(FocusNode());
                                                  turnTo(item);
                                                },
                                                child: Text('修改'),
                                              ),
                                            ),
                                            Container(
                                              height: 30,
                                              child: PrimaryButton(
                                                type: 'error',
                                                onPressed: () {
                                                  delDialog(item);
                                                },
                                                child: Text('删除'),
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
