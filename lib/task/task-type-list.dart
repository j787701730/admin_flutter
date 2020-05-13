import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TaskTypeList extends StatefulWidget {
  @override
  _TaskTypeListState createState() => _TaskTypeListState();
}

class _TaskTypeListState extends State<TaskTypeList> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [
    {
      "type_id": "104",
      "type_name": "设计任务",
      "type_en_name": "TASK_TYPE_DESIGN",
      "web_confirm": "0",
      "comment": "",
      "childs": [
        {
          "class_id": "2",
          "class_name": "CAD拆单",
          "sort": "1",
          "create_date": "2017-09-14 09:19:32",
          "update_date": "2017-09-19 16:48:00",
          "task_type": "104",
          "comments": ""
        },
        {
          "class_id": "1",
          "class_name": "CAD设计",
          "sort": "2",
          "create_date": "2017-09-14 09:19:32",
          "update_date": "2017-09-19 16:48:00",
          "task_type": "104",
          "comments": ""
        },
        {
          "class_id": "4",
          "class_name": "13213213",
          "sort": "3",
          "create_date": "2017-09-19 16:57:03",
          "update_date": null,
          "task_type": "104",
          "comments": "555"
        },
        {
          "class_id": "5",
          "class_name": "7",
          "sort": "4",
          "create_date": "2017-09-19 17:01:26",
          "update_date": "2017-10-17 15:14:43",
          "task_type": "104",
          "comments": ""
        },
        {
          "class_id": "6",
          "class_name": "认ewrw",
          "sort": "5",
          "create_date": "2017-09-19 17:01:26",
          "update_date": "2017-10-23 15:44:46",
          "task_type": "104",
          "comments": ""
        },
        {
          "class_id": "7",
          "class_name": "555",
          "sort": "6",
          "create_date": "2017-09-19 17:07:18",
          "update_date": null,
          "task_type": "104",
          "comments": ""
        },
        {
          "class_id": "8",
          "class_name": "666",
          "sort": "7",
          "create_date": "2017-09-19 17:07:51",
          "update_date": null,
          "task_type": "104",
          "comments": ""
        }
      ]
    }
  ];
  int count = 0;
  bool loading = false;

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
//      getData();
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
    ajax('Adminrelas-goodsConfig-getAttrByClassID', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'] ?? [];
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
    param['curr_page'] += page;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('任务类型'),
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
                                margin: EdgeInsets.only(
                                  bottom: 10,
                                ),
                                padding: EdgeInsets.only(
                                  top: 5,
                                ),
                                child: Column(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          item['isExpanded'] = item['isExpanded'] == null ? true : null;
                                        });
                                      },
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color:
                                                  item['isExpanded'] == null ? Colors.transparent : Color(0xffdddddd),
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            AnimatedSwitcher(
                                              duration: const Duration(milliseconds: 300),
                                              transitionBuilder: (Widget child, Animation<double> animation) {
                                                return ScaleTransition(child: child, scale: animation);
                                              },
                                              child: Icon(
                                                item['isExpanded'] == null
                                                    ? Icons.arrow_drop_down
                                                    : Icons.arrow_drop_up,
                                                size: 30,
                                                key: ValueKey<int>(item['isExpanded'] == null ? 1 : 0),
                                              ),
                                            ),
                                            Text('${item['type_name']}'),
                                            Checkbox(
                                              value: item['web_confirm'] == '1',
                                              onChanged: (val) {
                                                setState(() {
                                                  item['web_confirm'] = val ? '1' : '0';
                                                });
                                              },
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            Text('${item['type_en_name']}'),
                                          ],
                                        ),
                                      ),
                                    ),
                                    AnimatedCrossFade(
                                      firstChild: Container(
                                        height: 0,
                                      ),
                                      secondChild: Container(
                                        padding: EdgeInsets.only(
                                          left: 30,
                                          right: 10,
                                          top: 6,
                                          bottom: 6,
                                        ),
                                        child: Column(
                                          children: item['childs'].map<Widget>(
                                            (child) {
                                              return Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text('${child['class_name']}'),
                                                  ),
                                                  Text('${child['sort']}'),
                                                ],
                                              );
                                            },
                                          ).toList(),
                                        ),
                                      ),
                                      crossFadeState: item['isExpanded'] == null
                                          ? CrossFadeState.showFirst
                                          : CrossFadeState.showSecond,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                    )
                                  ],
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
