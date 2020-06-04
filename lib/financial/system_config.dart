import 'dart:async';

import 'package:admin_flutter/primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SystemConfig extends StatefulWidget {
  @override
  _SystemConfigState createState() => _SystemConfigState();
}

class _SystemConfigState extends State<SystemConfig> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [
    {
      "config_id": "1",
      "config_type": "3",
      "config_define": "FINANCIAL_PLAT_EARN_RATE",
      "config_label": "平台盈利",
      "config_value": "0.50",
      "create_date": "2019-02-27 11:19:18",
      "comments": "平台赚取的盈利部分 + 平台的成本(含税收、利息等)，默认为订单抽取金额的50%",
      "config_ch": "金融配置",
      "login_name": "yangxb",
      "update_date": "2019-03-12 00:00:00"
    },
    {
      "config_id": "2",
      "config_type": "3",
      "config_define": "FINANCIAL_SMALL_LIMIT_LOWER",
      "config_label": "小红包下限",
      "config_value": "0.20",
      "create_date": "2019-02-27 11:19:18",
      "comments": "平台发放小红包占订单抽取金额的最小比例，默认为20%",
      "config_ch": "金融配置",
      "login_name": "yangxb",
      "update_date": "2019-03-12 00:00:00"
    },
    {
      "config_id": "3",
      "config_type": "3",
      "config_define": "FINANCIAL_SMALL_LIMIT_UPPER",
      "config_label": "小红包上限",
      "config_value": "0.40",
      "create_date": "2019-02-27 11:19:18",
      "comments": "平台发放小红包占订单抽取金额的最大比例，默认为40%",
      "config_ch": "金融配置",
      "login_name": "yangxb",
      "update_date": "2019-03-12 00:00:00"
    },
    {
      "config_id": "4",
      "config_type": "3",
      "config_define": "FINANCIAL_BIG_THRESHOLD",
      "config_label": "大红包阀值",
      "config_value": "200",
      "create_date": "2019-02-27 11:19:18",
      "comments": "平台可用盈利累积到一定金额，发放大红包的阀值",
      "config_ch": "金融配置",
      "login_name": "yangxb",
      "update_date": "2019-03-14 00:00:00"
    },
    {
      "config_id": "5",
      "config_type": "3",
      "config_define": "FINANCIAL_ORDER_DISCOUNT",
      "config_label": "订单折扣率",
      "config_value": "0.05",
      "create_date": "2019-02-27 11:19:18",
      "comments": "",
      "config_ch": "金融配置",
      "login_name": "yangxb",
      "update_date": ""
    },
    {
      "config_id": "6",
      "config_type": "3",
      "config_define": "FINANCIAL_ORDER_EXTRACT",
      "config_label": "订单提现率",
      "config_value": "0.5",
      "create_date": "2019-02-27 11:19:18",
      "comments": "",
      "config_ch": "金融配置",
      "login_name": "yangxb",
      "update_date": "2019-03-14 00:00:00"
    },
    {
      "config_id": "7",
      "config_type": "3",
      "config_define": "FINANCIAL_ORDER_PAY_ONLINE",
      "config_label": "在线支付",
      "config_value": "0",
      "create_date": "2019-02-27 11:19:18",
      "comments": "",
      "config_ch": "金融配置",
      "login_name": "yangxb",
      "update_date": "2019-03-14 00:00:00"
    }
  ];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '配置类型', 'key': 'config_ch'},
    {'title': '配置宏', 'key': 'config_define'},
    {'title': '配置名称', 'key': 'config_label'},
    {'title': '配置值', 'key': 'config_id'},
    {'title': '修改人', 'key': 'login_name'},
    {'title': '创建时间', 'key': 'create_date'},
    {'title': '更新时间', 'key': 'update_date'},
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
      loading = false;
    });
//    ajax('Adminrelas-goodsConfig-getAttrByClassID', {'param': jsonEncode(param)}, true, (res) {
//      if (mounted) {
//        setState(() {
//          loading = false;
//          ajaxData = res['data'] ?? [];
//          count = int.tryParse('${res['count'] ?? 0}');
//          toTop();
//        });
//        if (isRefresh) {
//          _refreshController.refreshCompleted();
//        }
//      }
//    }, () {
//      if (mounted) {
//        setState(() {
//          loading = false;
//        });
//      }
//    }, _context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('金融配置'),
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
//              Container(
//                margin: EdgeInsets.only(bottom: 10),
//                child: Row(
//                  children: <Widget>[
//                    Container(
//                      width: 80,
//                      alignment: Alignment.centerRight,
//                      margin: EdgeInsets.only(right: 10),
//                      child: Text('用户名'),
//                    ),
//                    Expanded(
//                      flex: 1,
//                      child: TextField(
//                        decoration: InputDecoration(
//                            border: OutlineInputBorder(),
//                            contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 15,right: 15,)),
//                        onChanged: (String val) {
//                          setState(() {
//                            if (val == '') {
//                              param.remove('login_name');
//                            } else {
//                              param['login_name'] = val;
//                            }
//                          });
//                        },
//                      ),
//                    )
//                  ],
//                ),
//              ),
//              Container(
//                child: Wrap(
//                  alignment: WrapAlignment.center,
//                  spacing: 10,
//                  runSpacing: 10,
//                  children: <Widget>[
//                    SizedBox(
//                      height: 32,
//                      child: PrimaryButton(
//                          onPressed: () {
//                            param['curr_page'] = 1;
//                            getData();
//                            FocusScope.of(context).requestFocus(FocusNode());
//                          },
//                          child: Text('搜索')),
//                    ),
//                  ],
//                ),
//                margin: EdgeInsets.only(bottom: 10),
//              ),
//              Container(
//                margin: EdgeInsets.only(bottom: 6),
//                alignment: Alignment.centerRight,
//                child: NumberBar(count: count),
//              ),
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
                                      case 'config_id':
                                        if ('${item['config_id']}' == '7') {
                                          con = Text('${item[col['key']] == '1' ? '是' : '否'}');
                                        } else {
                                          con = Text('${item['config_value']}');
                                        }
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
//              Container(
//                child: PagePlugin(
//                    current: param['curr_page'], total: count, pageSize: param['page_count'], function: getPage,),
//              ),
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
