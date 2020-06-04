import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
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

class RebateDistributor extends StatefulWidget {
  @override
  _RebateDistributorState createState() => _RebateDistributorState();
}

class _RebateDistributorState extends State<RebateDistributor> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  bool isExpandedFlag = true;
  List columns = [
    {'title': '用户', 'key': 'login_name'},
    {'title': '联系人', 'key': 'user_name'},
    {'title': '联系电话', 'key': 'user_phone'},
    {'title': '申请内容', 'key': 'apply_content'},
    {'title': '申请类型', 'key': 'user_type'},
    {'title': '审核备注', 'key': 'audit_content'},
    {'title': '申请时间', 'key': 'create_date'},
    {'title': '审核时间', 'key': 'update_date'},
    {'title': '申请状态', 'key': 'state'},
    {'title': '联系地址', 'key': 'user_address'},
//    {'title': '操作', 'key': 'option'},
  ];

  Map applyType = {
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
    }
  };

  Map state = {
    "all": "全部",
    "-1": "审核失败",
    "0": "待审核",
    "1": "审核通过",
  };

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
    ajax('Adminrelas-RebateManage-distributorLists', {'param': jsonEncode(param)}, true, (res) {
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
    if (loading) return;
    param['curr_page'] += page;
    selectDistributor.clear();
    getData();
  }

  getDateTime(val) {
    if (val['min'] == null) {
      param.remove('create_date_min');
    } else {
      param['create_date_min'] = val['min'].toString().substring(0, 10);
    }
    if (val['max'] == null) {
      param.remove('create_date_max');
    } else {
      param['create_date_max'] = val['max'].toString().substring(0, 10);
    }
  }

  getDateTime2(val) {
    if (val['min'] == null) {
      param.remove('update_date_min');
    } else {
      param['update_date_min'] = val['min'].toString().substring(0, 10);
    }
    if (val['max'] == null) {
      param.remove('update_date_max');
    } else {
      param['update_date_max'] = val['max'].toString().substring(0, 10);
    }
  }

  List selectDistributor = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('经销商'),
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
                  label: '用户',
                  onChanged: (String val) {
                    setState(() {
                      if (val == '') {
                        param.remove('user_name');
                      } else {
                        param['user_name'] = val;
                      }
                    });
                  },
                ),
                Select(
                    selectOptions: state,
                    selectedValue: param['state'] ?? 'all',
                    label: '状态',
                    onChanged: (val) {
                      if (val) {
                        param.remove('state');
                      } else {
                        param['state'] = val;
                      }
                    }),
                DateSelectPlugin(onChanged: getDateTime, label: '申请时间'),
                DateSelectPlugin(onChanged: getDateTime2, label: '审核时间'),
              ]),
              crossFadeState: isExpandedFlag ? CrossFadeState.showFirst : CrossFadeState.showSecond,
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
                      selectDistributor.clear();
                      getData();
                      FocusScope.of(context).requestFocus(
                        FocusNode(),
                      );
                    },
                    child: Text('搜索'),
                  ),
                  PrimaryButton(
                    onPressed: () {
                      FocusScope.of(context).requestFocus(
                        FocusNode(),
                      );
                      List arr = [];
                      for (var o in ajaxData) {
                        arr.add(o['apply_id']);
                      }
                      setState(() {
                        selectDistributor = arr;
                      });
                    },
                    child: Text('全选'),
                  ),
                  PrimaryButton(
                    onPressed: () {
                      FocusScope.of(context).requestFocus(
                        FocusNode(),
                      );
                    },
                    child: Text('审核成功'),
                  ),
                  PrimaryButton(
                    type: 'error',
                    onPressed: () {
                      FocusScope.of(context).requestFocus(
                        FocusNode(),
                      );
                    },
                    child: Text('审核失败'),
                  ),
                  PrimaryButton(
                    color: CFColors.success,
                    onPressed: () {
                      setState(() {
                        isExpandedFlag = !isExpandedFlag;
                      });
                    },
                    child: Text('${isExpandedFlag ? '展开' : '收缩'}选项'),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: ajaxData.map<Widget>((item) {
                              return Stack(
                                children: <Widget>[
                                  Container(
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
                                          case 'state':
                                            con = Text('${state[item['state']]}');
                                            break;
                                          case 'user_type':
                                            con = Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text('${applyType[item['user_type']]['type_ch_name']}'),
                                            );
                                            break;
                                          case 'option':
                                            con = Wrap(
                                              runSpacing: 10,
                                              spacing: 10,
                                              children: <Widget>[
                                                Container(
                                                  height: 30,
                                                  child: PrimaryButton(
                                                    onPressed: () {},
                                                    child: Text('修改'),
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
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: Checkbox(
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        value: selectDistributor.indexOf(item['apply_id']) > -1,
                                        onChanged: (val) {
                                          setState(() {
                                            if (selectDistributor.contains(item['apply_id'])) {
                                              selectDistributor.remove(item['apply_id']);
                                            } else {
                                              selectDistributor.add(item['apply_id']);
                                            }
                                          });
                                        }),
                                  ),
                                ],
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
