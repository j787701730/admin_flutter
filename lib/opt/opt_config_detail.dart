import 'dart:async';

import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class OptConfigDetail extends StatefulWidget {
  final props;

  OptConfigDetail(this.props);

  @override
  _OptConfigDetailState createState() => _OptConfigDetailState();
}

class _OptConfigDetailState extends State<OptConfigDetail> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  List configVar = [];
  List configPoint = [];
  bool loading = true;

  List columnsVar = [
    {'title': 'ID', 'key': 'var_id'},
    {'title': '名称', 'key': 'var_ch_name'},
    {'title': '变量', 'key': 'var_en_name'},
  ];

  List columnsPoint = [
    {'title': 'X坐标', 'key': 'x'},
    {'title': 'Y坐标', 'key': 'y'},
    {'title': 'Z坐标', 'key': 'z'},
    {'title': '点阵类型', 'key': 'lx'},
    {'title': '点阵值', 'key': 'lxv'},
    {'title': '点阵顺序', 'key': 'sh'},
  ];
  List columnsPoint2 = [
    {'title': 'X坐标', 'key': 'x'},
    {'title': 'Y坐标', 'key': 'y'},
    {'title': 'Z坐标', 'key': 'z'},
    {'title': '点阵类型', 'key': 'lx'},
    {'title': '点阵值', 'key': 'lxv'},
    {'title': '刀头', 'key': 'dt'},
    {'title': '刀头值', 'key': 'lxv1'},
  ];
  Map optPointType = {
    "0": {"val": 0, "ch_name": "直线"},
    "2": {"val": 2, "ch_name": "外凸"},
    "3": {"val": 3, "ch_name": "内凹"},
    "8": {"val": 8, "ch_name": "提刀"},
  };

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
    ajax('adminrelas-opt-getVarAndPointByCID', {'config_id': widget.props['config_id']}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          configVar = res['config_var'] ?? [];
          configPoint = res['config_point'] ?? [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props['config_name']}'),
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
            loading
                ? Container(
                    alignment: Alignment.center,
                    child: CupertinoActivityIndicator(),
                  )
                : Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xffF0F0F0),
                          border: Border.all(
                            color: Color(0xff5D6C7A),
                          ),
                        ),
                        child: Text('变量配置'),
                      ),
                      Container(
                        height: 34,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xffdddddd),
                            ),
                          ),
                        ),
                        child: Row(
                          children: columnsVar.map<Widget>(
                            (item) {
                              return Expanded(
                                flex: 1,
                                child: Text(item['title']),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                      Container(
                        child: configVar.isEmpty
                            ? Container(
                                alignment: Alignment.center,
                                child: Text('无数据'),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: configVar.map<Widget>((item) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color(0xffdddddd),
                                        ),
                                      ),
                                    ),
                                    height: 34,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: columnsVar.map<Widget>((col) {
                                        Widget con = Text('${item[col['key']] ?? ''}');
                                        return Expanded(flex: 1, child: con);
                                      }).toList(),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          bottom: 10,
                          top: 10,
                        ),
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xffF0F0F0),
                          border: Border.all(
                            color: Color(0xff5D6C7A),
                          ),
                        ),
                        child: Text('示意图/点阵'),
                      ),
                      Container(
                        child: configPoint.isEmpty
                            ? Container(
                                alignment: Alignment.center,
                                child: Text('无数据'),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: configPoint.map<Widget>((item) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xffdddddd),
                                      ),
                                    ),
                                    margin: EdgeInsets.only(bottom: 10),
                                    padding: EdgeInsets.only(top: 5, bottom: 5),
                                    child: widget.props['config_type'] == '1'
                                        ? Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: columnsPoint.map<Widget>((col) {
                                              Widget con = Text('${item[col['key']] ?? ''}');
                                              switch (col['key']) {
                                                case 'lx':
                                                  con = Text('${optPointType[item['lx']]['ch_name']}');
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
                                          )
                                        : Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: columnsPoint2.map<Widget>((col) {
                                              Widget con = Text('${item[col['key']] ?? ''}');
                                              switch (col['key']) {
                                                case 'lx':
                                                  con = Text('${optPointType[item['lx']]['ch_name']}');
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
                      )
                    ],
                  ),
          ],
        ),
      ),
      floatingActionButton: CFFloatingActionButton(
        onPressed: toTop,
        child: Icon(Icons.keyboard_arrow_up),
      ),
      floatingActionButtonAnimator: ScalingAnimation(),
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(
        FloatingActionButtonLocation.endFloat,
        floatingActionButtonOffsetX,
        floatingActionButtonOffsetY,
      ),
    );
  }
}
