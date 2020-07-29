import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/search-bar-plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/plugin/user_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class OptList extends StatefulWidget {
  @override
  _OptListState createState() => _OptListState();
}

class _OptListState extends State<OptList> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  Map selectUser = {};

  List columns = [
    {'title': '订单号', 'key': 'order_no'},
    {'title': '用户', 'key': 'user_name'},
    {'title': '店铺', 'key': 'shop_name'},
    {'title': '总面积(m2)', 'key': 'size'},
    {'title': '异形面积(m2)', 'key': 'size_yx'},
    {'title': '造型板面积(m2)', 'key': 'size_zx'},
    {'title': '板数(张)', 'key': 'counts'},
    {'title': '异形板数(张)', 'key': 'count_yx'},
    {'title': '造型板数(张)', 'key': 'count_zx'},
    {'title': '大板数(张)', 'key': 'board_count'},
    {'title': '平均利用率(%)', 'key': 'lyl_avg'},
    {'title': '前几张利用率(%)', 'key': 'lyl_nolast'},
    {'title': '最后一张利用率(%)', 'key': 'lyl_last'},
    {'title': '时间', 'key': 'create_date'},
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
    if (selectUser.isEmpty) {
      param.remove('user_id');
    } else {
      param['user_id'] = selectUser.keys.toList()[0];
    }
    ajax('Adminrelas-Opt-optData', {'param': jsonEncode(param)}, true, (res) {
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

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'order_no': '订单号 升序',
    'order_no desc': '订单号 降序',
    'shop_name': '店铺 升序',
    'shop_name desc': '店铺 降序',
    'size': '总面积 升序',
    'size desc': '总面积 降序',
    'size_yx': '异形面积 升序',
    'size_yx desc': '异形面积 降序',
    'size_zx': '造型板面积 升序',
    'size_zx desc': '造型板面积 降序',
    'counts': '板数 升序',
    'counts desc': '板数 降序',
    'count_yx': '异形板数 升序',
    'count_yx desc': '异形板数 降序',
    'count_zx': '造型板数 升序',
    'count_zx desc': '造型板数 降序',
    'board_count': '大板数 升序',
    'board_count desc': '大板数 降序',
    'lyl_avg': '平均利用率 升序',
    'lyl_avg desc': '平均利用率 降序',
    'lyl_nolast': '前几张利用率 升序',
    'lyl_nolast desc': '前几张利用率 降序',
    'lyl_last': '最后一张利用率 升序',
    'lyl_last desc': '最后一张利用率 降序',
    'create_date': '时间 升序',
    'create_date desc': '时间 降序',
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
        title: Text('优化数据'),
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
                  label: '订单号',
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('order_no');
                    } else {
                      param['order_no'] = val;
                    }
                  },
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 80,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[Text('用户')],
                        ),
                        margin: EdgeInsets.only(right: 10),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                          ),
                          height: 30,
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            children: selectUser.keys.toList().map<Widget>((key) {
                              return Container(
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(right: 20),
                                      child: Text(
                                        '${selectUser[key]['login_name']}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        color: Color(0xffeeeeee),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectUser.remove(key);
                                            });
                                          },
                                          child: Icon(
                                            Icons.clear,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      PrimaryButton(
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserPlugin(
                                userCount: 1,
                                selectUsersData: jsonDecode(
                                  jsonEncode(selectUser),
                                ),
                              ),
                            ),
                          ).then((val) {
                            if (val != null) {
                              setState(() {
                                selectUser = jsonDecode(jsonEncode(val));
                              });
                            }
                          });
                        },
                        child: Text('选择'),
                      ),
                    ],
                  ),
                ),
                DateSelectPlugin(
                  onChanged: getDateTime,
                  label: '时间区间',
                ),
                Select(
                  selectOptions: selects,
                  selectedValue: defaultVal,
                  label: '排序',
                  onChanged: orderBy,
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
                ],
              ),
              margin: EdgeInsets.only(bottom: 10),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 6),
              alignment: Alignment.centerRight,
              child: NumberBar(
                count: count,
              ),
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
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            width: 130,
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
