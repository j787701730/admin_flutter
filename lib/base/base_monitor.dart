import 'dart:async';

import 'package:admin_flutter/base/cpu_chart.dart';
import 'package:admin_flutter/base/io_chart.dart';
import 'package:admin_flutter/base/mem_chart.dart';
import 'package:admin_flutter/base/net_chart.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BaseMonitor extends StatefulWidget {
  @override
  _BaseMonitorState createState() => _BaseMonitorState();
}

class _BaseMonitorState extends State<BaseMonitor> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  List ajaxCpu = [];
  List ajaxMem = [];
  List ajaxIO = [];
  List ajaxNet = [];
  Map cpuParam = {'hostID': '11', 'startTime': '2019-11-11 12:26:54', 'endTime': '2019-11-11 14:26:54'};
  int timeFlag = 1;
  int count = 0;

  void _onRefresh() {
    setState(() {
      getData(isRefresh: true);
      getData2(isRefresh: true);
      getData3(isRefresh: true);
      getData4(isRefresh: true);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _context = context;
    Timer(Duration(milliseconds: 200), () {
      getData();
      getData2();
      getData3();
      getData4();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getData({isRefresh: false}) {
    ajaxSimple('Adminrelas-Monitor-getCpu', cpuParam, (res) {
      if (mounted) {
        if (res.runtimeType.toString().substring(0, 4) == 'List') {
          setState(() {
            ajaxCpu = res;
            toTop();
          });
        } else {
          Fluttertoast.showToast(
            msg: '${res['err_msg']}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
        }
        if (isRefresh) {
          _refreshController.refreshCompleted();
        }
      }
    });
  }

  getData2({isRefresh: false}) {
    ajaxSimple('Adminrelas-Monitor-getMem', cpuParam, (res) {
      if (mounted) {
        if (res.runtimeType.toString().substring(0, 4) == 'List') {
          setState(() {
            ajaxMem = res;
            toTop();
          });
        }
        if (isRefresh) {
          _refreshController.refreshCompleted();
        }
      }
    });
  }

  getData3({isRefresh: false}) {
    ajaxSimple('Adminrelas-Monitor-getIO', cpuParam, (res) {
      if (mounted) {
        if (res.runtimeType.toString().substring(0, 4) == 'List') {
          setState(() {
            ajaxIO = res;
            toTop();
          });
        }
        if (isRefresh) {
          _refreshController.refreshCompleted();
        }
      }
    });
  }

  getData4({isRefresh: false}) {
    ajaxSimple('Adminrelas-Monitor-getNet', cpuParam, (res) {
      if (mounted) {
        if (res.runtimeType.toString().substring(0, 4) == 'List') {
          setState(() {
            ajaxNet = res;
            toTop();
          });
        }
        if (isRefresh) {
          _refreshController.refreshCompleted();
        }
      }
    });
  }

  toTop() {
    _controller.animateTo(
      0,
      duration: new Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  String formatDateTime(time) {
    return '${time.year}-${time.month}-${time.day} ${time.hour}:${time.minute}:${time.second}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('主机监控'),
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
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Wrap(
                spacing: 15,
                runSpacing: 10,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      DateTime a = DateTime.now();
                      DateTime b = a.subtract(Duration(hours: 1));
                      setState(() {
                        timeFlag = 1;
                        cpuParam['startTime'] = formatDateTime(b);
                        cpuParam['endTime'] = formatDateTime(a);
                        getData();
                        getData2();
                        getData3();
                        getData4();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15, top: 4, bottom: 4),
                      color: timeFlag == 1 ? Colors.blue : Colors.white,
                      child: Text(
                        '1小时',
                        style: TextStyle(
                          color: timeFlag == 1 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      DateTime a = DateTime.now();
                      DateTime b = a.subtract(Duration(hours: 3));
                      setState(() {
                        timeFlag = 3;
                        cpuParam['startTime'] = formatDateTime(b);
                        cpuParam['endTime'] = formatDateTime(a);
                        getData();
                        getData2();
                        getData3();
                        getData4();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15, top: 4, bottom: 4),
                      color: timeFlag == 3 ? Colors.blue : Colors.white,
                      child: Text(
                        '3小时',
                        style: TextStyle(
                          color: timeFlag == 3 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      DateTime a = DateTime.now();
                      DateTime b = a.subtract(Duration(hours: 6));
                      setState(() {
                        timeFlag = 6;
                        cpuParam['startTime'] = formatDateTime(b);
                        cpuParam['endTime'] = formatDateTime(a);
                        getData();
                        getData2();
                        getData3();
                        getData4();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15, top: 4, bottom: 4),
                      color: timeFlag == 6 ? Colors.blue : Colors.white,
                      child: Text(
                        '6小时',
                        style: TextStyle(
                          color: timeFlag == 6 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      DateTime a = DateTime.now();
                      DateTime b = a.subtract(Duration(hours: 12));
                      setState(() {
                        timeFlag = 12;
                        cpuParam['startTime'] = formatDateTime(b);
                        cpuParam['endTime'] = formatDateTime(a);
                        getData();
                        getData2();
                        getData3();
                        getData4();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15, top: 4, bottom: 4),
                      color: timeFlag == 12 ? Colors.blue : Colors.white,
                      child: Text(
                        '12小时',
                        style: TextStyle(
                          color: timeFlag == 12 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      DateTime a = DateTime.now();
                      DateTime b = a.subtract(Duration(days: 1));
                      setState(() {
                        timeFlag = 24;
                        cpuParam['startTime'] = formatDateTime(b);
                        cpuParam['endTime'] = formatDateTime(a);
                        getData();
                        getData2();
                        getData3();
                        getData4();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15, top: 4, bottom: 4),
                      color: timeFlag == 24 ? Colors.blue : Colors.white,
                      child: Text(
                        '1天',
                        style: TextStyle(
                          color: timeFlag == 24 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      DateTime a = DateTime.now();
                      DateTime b = a.subtract(Duration(days: 3));
                      setState(() {
                        timeFlag = 24 * 3;
                        cpuParam['startTime'] = formatDateTime(b);
                        cpuParam['endTime'] = formatDateTime(a);
                        getData();
                        getData2();
                        getData3();
                        getData4();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15, top: 4, bottom: 4),
                      color: timeFlag == 24 * 3 ? Colors.blue : Colors.white,
                      child: Text(
                        '3天',
                        style: TextStyle(
                          color: timeFlag == 24 * 3 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      DateTime a = DateTime.now();
                      DateTime b = a.subtract(Duration(days: 7));
                      setState(() {
                        timeFlag = 24 * 7;
                        cpuParam['startTime'] = formatDateTime(b);
                        cpuParam['endTime'] = formatDateTime(a);
                        getData();
                        getData2();
                        getData3();
                        getData4();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15, top: 4, bottom: 4),
                      color: timeFlag == 24 * 7 ? Colors.blue : Colors.white,
                      child: Text(
                        '7天',
                        style: TextStyle(
                          color: timeFlag == 24 * 7 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      DateTime a = DateTime.now();
                      DateTime b = a.subtract(Duration(days: 14));
                      setState(() {
                        timeFlag = 24 * 14;
                        cpuParam['startTime'] = formatDateTime(b);
                        cpuParam['endTime'] = formatDateTime(a);
                        getData();
                        getData2();
                        getData3();
                        getData4();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15, top: 4, bottom: 4),
                      color: timeFlag == 24 * 14 ? Colors.blue : Colors.white,
                      child: Text(
                        '14天',
                        style: TextStyle(
                          color: timeFlag == 24 * 14 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Wrap(
                spacing: 15,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      setState(() {
                        cpuParam['hostID'] = '11';
                        getData();
                        getData2();
                        getData3();
                        getData4();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15, top: 4, bottom: 4),
                      color: cpuParam['hostID'] == '11' ? Colors.blue : Colors.white,
                      child: Text(
                        '主机11',
                        style: TextStyle(
                          color: cpuParam['hostID'] == '11' ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        cpuParam['hostID'] = '12';
                        getData();
                        getData2();
                        getData3();
                        getData4();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15, top: 4, bottom: 4),
                      color: cpuParam['hostID'] == '12' ? Colors.blue : Colors.white,
                      child: Text(
                        '主机12',
                        style: TextStyle(
                          color: cpuParam['hostID'] == '12' ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20, bottom: 6),
              alignment: Alignment.center,
              child: Text('CPU'),
            ),
            ajaxCpu.isEmpty
                ? Container(
                    height: 300,
                  )
                : Container(
                    child: CpuChart({'ajaxCpu': ajaxCpu}),
                  ),
            Container(
              margin: EdgeInsets.only(top: 20, bottom: 6),
              alignment: Alignment.center,
              child: Text('内存'),
            ),
            ajaxMem.isEmpty
                ? Container(
                    height: 300,
                  )
                : Container(
                    child: MemChart({'ajaxMem': ajaxMem}),
                  ),
            Container(
              margin: EdgeInsets.only(top: 20, bottom: 6),
              alignment: Alignment.center,
              child: Text('磁盘'),
            ),
            ajaxIO.isEmpty
                ? Container(
                    height: 300,
                  )
                : Container(
                    child: IOChart({'ajaxIO': ajaxIO}),
                  ),
            ajaxNet.isEmpty
                ? Container(
                    height: 300,
                  )
                : Container(
                    child: NETChart({'ajaxNet': ajaxNet}),
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
