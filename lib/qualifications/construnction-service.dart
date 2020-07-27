import 'dart:async';
import 'dart:ui';

import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/search-bar-plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ConstrunctionService extends StatefulWidget {
  @override
  _ConstrunctionServiceState createState() => _ConstrunctionServiceState();
}

class _ConstrunctionServiceState extends State<ConstrunctionService> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {
    'id': 15,
    'type': '0',
  };
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  Map type = {'0': '待审核', '1': '审核通过', '2': '审核失败'};
  List columns = [
    {'title': '用户', 'key': 'username'},
    {'title': '店铺名称', 'key': 'shopname'},
    {'title': '归属组织', 'key': 'SERVICE_HOME_ORGANIZATION'},
    {'title': '一寸照片', 'key': 'SERVICE_PHOTO'},
    {'title': '行业经验', 'key': 'SERVICE_WORK_EXP'},
    {'title': '组织名称', 'key': 'SERVICE_ORGANIZATION_NAME'},
    {'title': '经营范围', 'key': 'SERVICE_SHOP_BUSINESS_SCOPE'},
    {'title': '其他材料', 'key': 'SERVICE_OTHER_MATERIALS'},
    {'title': '申请时间', 'key': 'create_date'},
    {'title': '审核时间', 'key': 'audit_date'},
    {'title': '审核状态', 'key': 'audit_state'},
    {'title': '审核人员', 'key': 'audit_user_id'},
    {'title': '操作', 'key': 'option'},
  ];

  Map order = {
    'all': '无',
    'company_name': '公司名称 升序',
    'company_name desc': '公司名称 降序',
    'tax_no': '信用代码 升序',
    'tax_no desc': '信用代码 降序',
    'collect_times': '收藏次数 升序',
    'collect_times desc': '收藏次数 降序',
    'create_date': '创建时间 升序',
    'create_date desc': '创建时间 降序',
    'update_date': '更新时间 升序',
    'update_date desc': '更新时间 降序',
    'state': '状态 升序',
    'state desc': '状态 降序',
  };
  String defaultVal = 'all';

  orderBy(val) {
    if (val == 'all') {
      param.remove('order');
    } else {
      param['order'] = val;
    }
    param['page'] = 1;
    defaultVal = val;
    getData();
  }

  void _onRefresh() {
    setState(() {
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
    ajax('Adminrelas-Qualifications-ShopServices', param, true, (res) {
      if (mounted) {
        setState(() {
          ajaxData = res['data'] is List ? res['data'] : [];
          count = ajaxData.length;
          loading = false;
          toTop();
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
      duration: Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  operaDialog(item) {
    return showDialog<void>(
      context: _context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '系统提示',
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '确定要 ${item['state'] == '1' || item['state'] == '-1' ? '冻结' : '解冻'} ${item['login_name']} 账号?',
                  style: TextStyle(fontSize: CFFontSize.content),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  roleDialog() {
    return showDialog<void>(
      context: _context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context1, state) {
          /// 这里的state就是setState
          return AlertDialog(
            title: Text(
              '权限管理',
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[],
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
        }); //
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('施工服务'),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: ListView(
          controller: _controller,
          padding: EdgeInsets.all(15),
          children: <Widget>[
            SearchBarPlugin(
              secondChild: Column(
                children: <Widget>[
//                  Select(
//                    selectOptions: order,
//                    selectedValue: defaultVal,
//                    onChanged: orderBy,
//                    label: "排序",
//                  ),
                  Select(
                    selectOptions: type,
                    selectedValue: param['type'],
                    label: '审核状态',
                    onChanged: (val) {
                      param['type'] = val;
                      getData();
                    },
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                bottom: 15,
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  PrimaryButton(
                    onPressed: () {
                      param['page'] = 1;
                      getData();
                      FocusScope.of(context).requestFocus(
                        FocusNode(),
                      );
                    },
                    child: Text('搜索'),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              alignment: Alignment.centerRight,
              child: NumberBar(count: count),
            ),
            loading
                ? Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: CupertinoActivityIndicator(),
                  )
                : ajaxData.isEmpty
                    ? Container(
                        alignment: Alignment.center,
                        height: 40,
                        child: Text('无数据'),
                      )
                    : Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: ajaxData.map<Widget>((item) {
                            return Container(
                              padding: EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xffeeeeee),
                                ),
                              ),
                              margin: EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: columns.map<Widget>((col) {
                                  Widget con = Text('${item[col['key']] ?? ''}');
                                  switch (col['key']) {
                                    case 'option':
                                      con = Row(
                                        children: <Widget>[
//                                          PrimaryButton(
//                                            type: item['state'] == '1' || item['state'] == '-1' ? 'error' : null,
//                                            onPressed: () {
//                                              operaDialog(item);
//                                            },
//                                            child: Text(item['state'] == '1' || item['state'] == '-1' ? '冻结' : '解冻'),
//                                          ),
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
                                        Expanded(flex: 1, child: con),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          }).toList(),
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
