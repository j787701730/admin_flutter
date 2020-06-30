import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/photo-view-plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ZoneFiles extends StatefulWidget {
  @override
  _ZoneFilesState createState() => _ZoneFilesState();
}

class _ZoneFilesState extends State<ZoneFiles> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"currPage": 1, "pageCount": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  bool isExpandedFlag = true;
  List columns = [
    {'title': '文件名称', 'key': 'name'},
    {'title': '文件大小', 'key': 'file_size'},
    {'title': '上传时间', 'key': 'create_date'},
    {'title': '状态', 'key': 'state'},
    {'title': '店铺', 'key': 'shop_name'},
    {'title': '操作', 'key': 'option'},
  ];

  void _onRefresh() {
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

  getData({isRefresh: false}) {
    setState(() {
      loading = true;
    });
    ajax('Adminrelas-zoneFiles-lists',
        {'param': jsonEncode(param), 'curr_page': param['currPage'], 'page_count': param['pageCount']}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['file_module'] ?? [];
          count = int.tryParse('${res['count'] ?? 0}');
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

  getPage(page) {
    param['currPage'] += page;
    getData();
  }

  getDateTime2(val) {
    setState(() {
      if (val['min'] == null) {
        param.remove('create_date_min');
      } else {
        param['create_date_min'] = val['min'].toString().substring(0, 10);
      }
      if (val['max'] == null) {
        param.remove('create_date_max');
      } else {
        param['create_date_max'] = val['max'].toString().substring(0, 10);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('空间文件'),
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
            AnimatedCrossFade(
              firstChild: Container(),
              secondChild: Column(
                children: <Widget>[
                  Input(
                    label: '文件名称',
                    onChanged: (String val) {
                      setState(() {
                        if (val == '') {
                          param.remove('file_name');
                        } else {
                          param['file_name'] = val;
                        }
                      });
                    },
                  ),
                  Input(
                    label: '店铺名字',
                    onChanged: (String val) {
                      setState(() {
                        if (val == '') {
                          param.remove('shop_name');
                        } else {
                          param['shop_name'] = val;
                        }
                      });
                    },
                  ),
                  DateSelectPlugin(
                    onChanged: getDateTime2,
                    label: '上传时间',
                  ),
                ],
              ),
              crossFadeState: isExpandedFlag ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: const Duration(
                milliseconds: 300,
              ),
            ),
            Container(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  PrimaryButton(
                    onPressed: () {
                      param['currPage'] = 1;
                      getData();
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text('搜索'),
                  ),
                  PrimaryButton(
                    color: CFColors.success,
                    onPressed: () {
                      setState(() {
                        isExpandedFlag = !isExpandedFlag;
                      });
                    },
                    child: Text('${isExpandedFlag ? '展开' : '收缩'}选项'),
                  )
                ],
              ),
              margin: EdgeInsets.only(bottom: 10),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 6),
              alignment: Alignment.centerRight,
              child: NumberBar(
                count: count,
              ),
            ),
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
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xffdddddd),
                                  ),
                                ),
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: columns.map<Widget>((col) {
                                    Widget con = Text('${item[col['key']] ?? ''}');
                                    switch (col['key']) {
                                      case 'file_size':
                                        con = Text(item['file_size']);
                                        break;
                                      case 'name':
                                        con = Row(
                                          children: <Widget>[
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  _context,
                                                  MaterialPageRoute(
                                                    builder: (context) => PhotoViewPlugin([
                                                      '$baseUrl${item['real_path']}',
                                                    ]),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: 60,
                                                height: 60,
                                                margin: EdgeInsets.only(
                                                  right: 10,
                                                ),
                                                child: Hero(
                                                  tag: '$baseUrl${item['real_path']}',
                                                  child: Image.network('$baseUrl${item['path']}'),
                                                ),
                                              ),
                                            ),
                                            Text(item['name']),
                                          ],
                                        );
                                        break;
                                      case 'state':
                                        con = Text('${item['state'].toString() == '1' ? '正常' : '屏蔽'}');
                                        break;
                                      case 'option':
                                        con = Wrap(
                                          runSpacing: 10,
                                          spacing: 10,
                                          children: <Widget>[
                                            PrimaryButton(
                                              onPressed: () {},
                                              child: Text('修改'),
                                            ),
                                            PrimaryButton(
                                              onPressed: () {},
                                              child: Text('${item['state'].toString() == '1' ? '下架' : '上架'}'),
                                            ),
                                            PrimaryButton(
                                              onPressed: () {},
                                              child: Text('${item['state'].toString() == '1' ? '冻结' : '解冻'}'),
                                            ),
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
                                          Expanded(
                                            flex: 1,
                                            child: con,
                                          )
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
                current: param['currPage'],
                total: count,
                pageSize: param['pageCount'],
                function: getPage,
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
