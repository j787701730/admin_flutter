import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/log/components/log_card.dart';
import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SmsLogs extends StatefulWidget {
  @override
  _SmsLogsState createState() => _SmsLogsState();
}

class _SmsLogsState extends State<SmsLogs> {
  Map param = {'curr_page': 1, 'page_count': 20};
  List logs = [];
  int count = 0;
  BuildContext _context;
  ScrollController _controller;
  Map searchData = {'user_name': '', 'acc_nbr': '', 'in_param': '', 'err_code': ''};
  Map searchName = {'user_name': '用户', 'acc_nbr': '手机号', 'in_param': '发送参数', 'err_code': '错误码'};
  List columns = [
    {'title': '用户', 'key': 'user_name'},
    {'title': '手机号', 'key': 'acc_nbr'},
    {'title': '短信模板', 'key': 'sms_template'},
    {'title': '发送模板', 'key': 'sms_param', 'event': true, 'lines': 4},
    {'title': '错误码', 'key': 'err_code'},
    {'title': '出参参数', 'key': 'err_msg'},
    {'title': '创建时间', 'key': 'create_date'},
  ];

  Map smsTemplate = {
    'all': '全部',
    '1': '用户注册(SMS_9721536)',
    '3': '用户登录(SMS_9721538)',
    '4': '身份认证(SMS_9721540)',
    '5': '信息变更(SMS_9721533)',
    '6': '密码变更(SMS_9721534)',
    '7': '工厂授权(SMS_173473094)',
  };

  Map smsTemplate2 = {
    'all': '全部',
    'SMS_9721536': '用户注册(SMS_9721536)',
    'SMS_9721538': '用户登录(SMS_9721538)',
    'SMS_9721540': '身份认证(SMS_9721540)',
    'SMS_9721533': '信息变更(SMS_9721533)',
    'SMS_9721534': '密码变更(SMS_9721534)',
    'SMS_173473094': '工厂授权(SMS_173473094)',
  };

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
    ajax('Adminrelas-logs-smsLogs', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        List temp = [];
        if (res['data'] != null && res['data'].isNotEmpty) {
          for (var o in res['data']) {
            o['sms_template'] = smsTemplate2[o['sms_template']];
            temp.add(jsonDecode(jsonEncode(o)));
          }
        }

        setState(() {
          logs = temp;
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

  getPage(page) {if (loading) return;
    param['curr_page'] += page;
    getData();
  }

  getDateTime(val) {
    setState(() {
      create_date_min = val['min'];
      create_date_max = val['max'];
    });
  }

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'acc_nbr': '手机号 升序',
    'acc_nbr desc': '手机号 降序',
    'sms_template': '短信模板 升序',
    'sms_template desc': '短信模板 降序',
    'in_param': '发送模板 升序',
    'in_param desc': '发送模板 降序',
    'err_code': '错误码 升序',
    'err_code desc': '错误码 降序',
    'err_msg': '出参参数 升序',
    'err_msg desc': '出参参数 降序',
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
//    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('短信日志'),
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
              Column(
                children: searchData.keys.map<Widget>((key) {
                  return Input(
                      label: '${searchName[key]}',
                      onChanged: (String val) {
                        setState(() {
                          searchData[key] = val;
                        });
                      });
                }).toList(),
              ),
              Select(
                  selectOptions: smsTemplate,
                  selectedValue: param['template_id'] ?? 'all',
                  label: '短信模板',
                  onChanged: (String newValue) {
                    setState(() {
                      if (newValue == 'all') {
                        param.remove('template_id');
                      } else {
                        param['template_id'] = newValue;
                      }
                    });
                  }),
              DateSelectPlugin(
                onChanged: getDateTime,
                label: '操作日期',
              ),
              Select(
                selectOptions: selects,
                selectedValue: defaultVal,
                onChanged: orderBy,
                label: '排序',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  PrimaryButton(
                    onPressed: () {
                      setState(() {
                        param['curr_page'] = 1;
                        getData();
                      });
                    },
                    child: Text('搜索'),
                  )
                ],
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
                    current: param['curr_page'], total: count, pageSize: param['page_count'], function: getPage),
              )
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: toTop,
        child: Icon(Icons.keyboard_arrow_up),
      ),
    );
  }
}
