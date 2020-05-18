import 'dart:async';

import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UsersCert extends StatefulWidget {
  @override
  _UsersCertState createState() => _UsersCertState();
}

class _UsersCertState extends State<UsersCert> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"currPage": 1, "pageCount": 15, "state": 'all'};
  List ajaxData = [];
  int count = 0;
  bool loading = false;

  Map userSex = {
    '1': '男',
    '2': '女',
  };

  Map auditState = {
    'all': "全部",
    '0': '待审核',
    '1': '审核通过',
    '-1': '审核失败',
  };

  List columns = [
    {'title': '用户名', 'key': 'login_name'},
    {'title': '真实名字', 'key': 'full_name'},
    {'title': '证件号', 'key': 'cert_id'},
    {'title': '证件类型', 'key': 'cert_type'},
    {'title': '性别', 'key': 'user_sex'},
    {'title': '证件正面', 'key': 'id_up_url'},
    {'title': '证件反面', 'key': 'id_down_url'},
    {'title': '联系方式', 'key': 'user_phone'},
    {'title': '地址', 'key': 'province'},
    {'title': '申请时间', 'key': 'create_date'},
    {'title': '审核状态', 'key': 'audit_state'},
    {'title': '审核时间', 'key': 'audit_date'},
    {'title': '审核描述', 'key': 'audit_desc'},
  ];

  void _onRefresh() async {
    setState(() {
      param['currPage'] = 1;
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
    ajax('Adminrelas-Certify-certifyRecord', param, true, (res) {
      if (mounted) {
        setState(() {
          ajaxData = res['data'];
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
    param['currPage'] += page;
    getData();
  }

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'company_name': '用户名 升序',
    'company_name desc': '用户名 降序',
    'tax_no': '真实名字 升序',
    'tax_no desc': '真实名字 降序',
    'collect_times': '证件号 升序',
    'collect_times desc': '证件号 降序',
    'create_date': '证件类型 升序',
    'create_date desc': '证件类型 降序',
    'update_date': '联系方式 升序',
    'update_date desc': '联系方式 降序',
    'state': '申请时间 升序',
    'state desc': '申请时间 降序',
    'state': '审核状态 升序',
    'state desc': '审核状态 降序',
    'state': '审核时间 升序',
    'state desc': '审核时间 降序',
    'state': '审核描述 升序',
    'state desc': '审核描述 降序',
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
        title: Text('实名认证'),
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
            Select(
              selectOptions: auditState,
              selectedValue: param['state'] ?? 'all',
              label: '审核状态',
              onChanged: (String newValue) {
                setState(() {
                  param['state'] = newValue;
                });
              },
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
                          param['currPage'] = 1;
                          getData();
                        },
                        child: Text('搜索')),
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
                ? CupertinoActivityIndicator()
                : Container(
                    child: Column(
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
                                  case 'province':
                                    con = Text('${item['province']}${item['city']}${item['region']}');
                                    break;
                                  case 'user_sex':
                                    con = Text('${userSex['${item['user_sex']}']}');
                                    break;
                                  case 'audit_state':
                                    con = Text('${auditState['${item['audit_state']}']}');
                                    break;
                                  case 'if_charge':
                                    con = Container(
                                      alignment: Alignment.centerLeft,
                                      child: '${item[col['key']]}' == '1'
                                          ? Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            )
                                          : Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            ),
                                    );
                                    break;
                                  case 'option':
                                    con = Text('在用');
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
                current: param['currPage'],
                total: count,
                pageSize: param['pageCount'],
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
