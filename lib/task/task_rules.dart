import 'dart:async';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/task/task_rule_modify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TaskRules extends StatefulWidget {
  @override
  _TaskRulesState createState() => _TaskRulesState();
}

class _TaskRulesState extends State<TaskRules> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [
    {
      "role_id": 0,
      "role_en_name": "ROLE_TYPE_PUBLISH",
      "role_ch_name": "发布师",
      "can_apply": 0,
      "comments": "发布任务",
    },
    {
      "role_id": "101",
      "role_en_name": "ROLE_TYPE_STORE",
      "role_ch_name": "销售门店",
      "can_apply": "1",
      "comments": "提供全方位的销售定制门店",
      "icon": "icon-shopping-cart"
    },
    {
      "role_id": "102",
      "role_en_name": "ROLE_TYPE_SUPPLIER",
      "role_ch_name": "供货商",
      "can_apply": "1",
      "comments": "提供五金建材的供货服务",
      "icon": "icon-truck"
    },
    {
      "role_id": "103",
      "role_en_name": "ROLE_TYPE_FACTORY",
      "role_ch_name": "加工工厂",
      "can_apply": "1",
      "comments": "提供定价加工服务",
      "icon": "icon-gears"
    },
    {
      "role_id": "104",
      "role_en_name": "ROLE_TYPE_DESIGNER",
      "role_ch_name": "设计师",
      "can_apply": "1",
      "comments": "提供设计、测量等服务",
      "icon": "icon-male"
    },
    {
      "role_id": "105",
      "role_en_name": "ROLE_TYPE_CONSTRUCTION",
      "role_ch_name": "工程施工",
      "can_apply": "1",
      "comments": "提供上门施工服务",
      "icon": "icon-wrench"
    }
  ];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '', 'key': ''},
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
    if (isRefresh) {
      _refreshController.refreshCompleted();
    }
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
      duration: Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  getPage(page) {
    getData();
  }

  turnTo(item) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (context) => TaskRuleModify(item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('成长规则'),
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
            Input(
              label: '',
              onChanged: (String val) {
                setState(() {
                  if (val == '') {
                    param.remove('login_name');
                  } else {
                    param['login_name'] = val;
                  }
                });
              },
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
                ],
              ),
              margin: EdgeInsets.only(bottom: 10),
            ),
//            Container(
//              margin: EdgeInsets.only(bottom: 6),
//              alignment: Alignment.centerRight,
//              child: NumberBar(
//                count: count,
//              ),
//            ),
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
                              return InkWell(
                                onTap: () {
                                  turnTo(item);
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
//                                decoration: BoxDecoration(
//                                  border: Border.all(
//                                    color: Color(0xffdddddd),
//                                  ),
//                                ),
                                  height: 34,
                                  child: RichText(
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: '${item['role_ch_name']}',
                                        ),
                                        TextSpan(
                                            text: '(${item['comments']})',
                                            style: TextStyle(
                                              fontSize: CFFontSize.tabBar,
                                              color: Color(0xff999999),
                                            )),
                                      ],
                                      style: TextStyle(color: Colors.blue, fontSize: CFFontSize.content),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
//            Container(
//              child: PagePlugin(
//                current: param['curr_page'],
//                total: count,
//                pageSize: param['page_count'],
//                function: getPage,
//              ),
//            ),
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
