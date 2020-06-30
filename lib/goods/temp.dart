import 'dart:async';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class $1$ extends StatefulWidget {
  final props;

  $1$(this.props);

  @override
  _$1$State createState() => _$1$State();
}

class _$1$State extends State<$1$> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '余额类型', 'key': 'balance_type_ch_name'},
    {'title': '余额类型', 'key': 'amount'},
    {'title': '预占金额', 'key': 'pre_amount'},
    {'title': '状态', 'key': 'state'},
    {'title': '生效日期', 'key': 'eff_date'},
    {'title': '失效日期', 'key': 'exp_date'},
    {'title': '创建日期', 'key': 'create_date'},
    {'title': '更新日期', 'key': 'update_date'},
    {'title': '稽核结果', 'key': 'balance_check_name'},
    {'title': '稽核时间', 'key': 'check_time'},
    {'title': '充值', 'key': 'if_charge'},
    {'title': '提取', 'key': 'if_extract'},
    {'title': '转账', 'key': 'if_transfer'},
    {'title': '操作', 'key': 'option'},
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
    ajax('Adminrelas-goodsConfig-getAttrByClassID', {'class_id': widget.props['classID']}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'];
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

  getPage(page) {
    if (loading) return;
    param['curr_page'] += page;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
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
            loading
                ? Container(
                    alignment: Alignment.center,
                    child: CupertinoActivityIndicator(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Input(
                        label: '用户名',
                        onChanged: (String val) {
                          setState(() {
                            param['loginName'] = val;
                          });
                        },
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
                        child: NumberBar(count: count),
                      ),
                      ajaxData.isEmpty
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
                                          case 'state':
                                            con = '${item[col['key']]}' == '1' ? Text('在用') : Text('停用');
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
                      Container(
                        child: PagePlugin(
                          current: param['curr_page'],
                          total: count,
                          pageSize: param['page_count'],
                          function: getPage,
                        ),
                      )
                    ],
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
