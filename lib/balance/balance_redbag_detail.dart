import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/balance/balance_detail.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BalanceRedBagDetail extends StatefulWidget {
  final props;

  BalanceRedBagDetail(this.props);

  @override
  _BalanceRedBagDetailState createState() => _BalanceRedBagDetailState();
}

class _BalanceRedBagDetailState extends State<BalanceRedBagDetail> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = false;
  List columns = [
    {'title': '可用余额', 'key': 'amount'},
    {'title': '预占金额', 'key': 'pre_amount'},
    {'title': '生效日期', 'key': 'eff_date'},
    {'title': '失效日期', 'key': 'exp_date'},
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
    param['user_id'] = widget.props['item']['user_id'];
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
    ajax('Adminrelas-Balance-getRedenvelope', {'param': jsonEncode(param)}, true, (res) {
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
    param['curr_page'] += page;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props['item']['login_name']} 商城红包明细'),
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
                ? CupertinoActivityIndicator()
                : Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ajaxData.map<Widget>((item) {
                        return Container(
                          decoration: BoxDecoration(border: Border.all(color: Color(0xffeeeeee), width: 1)),
                          margin: EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: columns.map<Widget>((col) {
                              Widget con = Text('${item[col['key']] ?? ''}');
                              switch (col['key']) {
                                case 'option':
                                  con = Wrap(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 30,
                                        child: PrimaryButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => BalanceDetail({
                                                  'login_name': '${widget.props['item']['login_name']}',
                                                  'balance_type_ch_name':
                                                      '${widget.props['item']['balance_type_ch_name']}',
                                                  'acct_balance_id': '${widget.props['item']['acct_balance_id']}',
                                                }),
                                              ),
                                            );
                                          },
                                          child: Text('详情'),
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
