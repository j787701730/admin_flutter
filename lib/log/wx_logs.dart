import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/log/components/log_card.dart';
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

class WXLogs extends StatefulWidget {
  @override
  _WXLogsState createState() => _WXLogsState();
}

class _WXLogsState extends State<WXLogs> {
  Map param = {'curr_page': 1, 'page_count': 20};
  List logs = [];
  int count = 0;
  BuildContext _context;
  ScrollController _controller;
  Map searchData = {'user_name': '', 'shop_name': '', 'err_code': '', 'wx_param': ''};
  Map searchName = {'user_name': '用户', 'shop_name': '店铺', 'err_code': '错误码', 'wx_param': '发送参数'};
  List columns = [
    {'title': '用户', 'key': 'user_name'},
    {'title': '店铺', 'key': 'shop_name'},
    {'title': '消息标识', 'key': 'msg_id'},
    {'title': '微信模板', 'key': 'wx_template'},
    {'title': '发送参数', 'key': 'wx_param', 'event': true, 'lines': 4},
    {'title': '错误码', 'key': 'err_code'},
    {'title': '返回信息', 'key': 'err_msg'},
    {'title': '用户接收状态', 'key': 'receive_status'},
    {'title': '错误码', 'key': 'create_date'},
    {'title': '返回信息', 'key': 'update_date'},
  ];
  bool isExpandedFlag = true;

  DateTime create_date_min;
  DateTime create_date_max;
  bool loading = true;

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

  getData({isRefresh: false}) async {
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
    ajax('Adminrelas-Logs-wxLogs', {'param': jsonEncode(param)}, true, (res) {
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
    setState(() {
      create_date_min = val['min'];
      create_date_max = val['max'];
    });
  }

  getDateTime2(val) {
    setState(() {
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
    });
  }

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'msg_id': '消息标识 升序',
    'msg_id desc': '消息标识 降序',
    'wx_template': '微信模版 升序',
    'wx_template desc': '微信模版 降序',
    'wx_param': '发送参数 升序',
    'wx_param desc': '发送参数 降序',
    'err_code': '错误码 升序',
    'err_code desc': '错误码 降序',
    'err_msg': '返回信息 升序',
    'err_msg desc': '返回信息 降序',
    'receive_status': '用户接收状态 升序',
    'receive_status desc': '用户接收状态 降序',
    'create_date': '创建时间 升序',
    'create_date desc': '创建时间 降序',
    'update_date': '更新时间 升序',
    'update_date desc': '更新时间 降序',
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
//    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('微信日志'),
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
            AnimatedCrossFade(
              duration: const Duration(
                milliseconds: 300,
              ),
              firstChild: Container(),
              secondChild: Column(children: <Widget>[
                Column(
                  children: searchData.keys.map<Widget>((key) {
                    return Input(
                      label: '${searchName[key]}',
                      onChanged: (String val) {
                        setState(() {
                          searchData[key] = val;
                        });
                      },
                    );
                  }).toList(),
                ),
                DateSelectPlugin(
                  onChanged: getDateTime,
                  label: '创建时间',
                ),
                DateSelectPlugin(
                  onChanged: getDateTime2,
                  label: '更新时间',
                ),
                Select(
                  selectOptions: selects,
                  selectedValue: defaultVal,
                  onChanged: orderBy,
                  label: '排序',
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
              margin: EdgeInsets.only(bottom: 8),
              alignment: Alignment.centerRight,
              child: NumberBar(count: count),
            ),
            loading
                ? Container(
                    child: CupertinoActivityIndicator(),
                  )
                : logs.isEmpty
                    ? Container(
                        alignment: Alignment.topCenter,
                        child: Text('无数据'),
                      )
                    : LogCard(
                        columns,
                        logs,
                        labelWidth: 110.0,
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
