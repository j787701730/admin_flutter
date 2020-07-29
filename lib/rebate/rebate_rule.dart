import 'dart:async';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RebateRule extends StatefulWidget {
  @override
  _RebateRuleState createState() => _RebateRuleState();
}

class _RebateRuleState extends State<RebateRule> {
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '', 'key': ''},
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
      duration: Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  getPage(page) {
    if (loading) return;
    param['curr_page'] = page;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('经销商规则'),
      ),
      body: SmartRefresher(
        enablePullDown: false,
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
              label: '最小充值金额(元)',
              labelWidth: 140,
              onChanged: (val) => param['min_charge'] = val,
              value: param['min_charge'],
              type: NumberType.float,
            ),
            Input(
              label: '加价金额(元)',
              labelWidth: 140,
              onChanged: (val) => param['plus_charge'] = val,
              value: param['plus_charge'],
              type: NumberType.float,
            ),
            Input(
              label: '最大充值金额(元)',
              labelWidth: 140,
              onChanged: (val) => param['max_charge'] = val,
              value: param['max_charge'],
              type: NumberType.float,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10, left: 150),
              child: Text(
                '最大充值金额 = 最小充值金额 + 加价金额 x n倍',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Input(
              label: '每日封顶比例(%)',
              labelWidth: 140,
              onChanged: (val) => param['day_limit'] = val,
              value: param['day_limit'],
              type: NumberType.float,
            ),
            Select(
              selectOptions: {'1': '是', '0': '否'},
              selectedValue: param['direct_minus'] ?? '1',
              label: '直接推荐人扣除',
              onChanged: (val) {
                setState(() {
                  param['direct_minus'] = val;
                });
              },
              labelWidth: 140,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              height: 34,
              child: Row(children: <Widget>[
                Container(
                  width: 140,
                  child: Text(''),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      PrimaryButton(
                        onPressed: () {},
                        child: Text('保存'),
                      )
                    ],
                  ),
                ),
              ]),
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
