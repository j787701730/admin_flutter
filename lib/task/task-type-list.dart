import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
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
  Map ajaxData = {};
  int count = 0;
  bool loading = false;

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
    ajax('Adminrelas-Api-taskType', {}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['types'] ?? {};
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
    param['curr_page'] = page;
    getData();
  }

  addAndModifyDialog(item) {
    Map temp = item == null ? {'comments': '', 'class_name': '', 'sort': ''} : jsonDecode(jsonEncode(item));
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${item == null ? '新增' : '${temp['class_name']} 修改'}',
          ),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width - 100,
              child: Column(
                children: <Widget>[
                  Input(
                    label: '任务名称',
                    onChanged: (val) {
                      setState(() {
                        temp['class_name'] = val;
                      });
                    },
                    value: '${temp['class_name']}',
                  ),
                  Input(
                    label: '排序',
                    onChanged: (val) {
                      setState(() {
                        temp['sort'] = val;
                      });
                    },
                    value: '${temp['sort']}',
                  ),
                  Input(
                    label: '备注',
                    maxLines: 5,
                    onChanged: (val) {
                      setState(() {
                        temp['comments'] = val;
                      });
                    },
                    value: '${temp['comments']}',
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('关闭'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              color: CFColors.primary,
              child: Text('保存'),
              onPressed: () {
                print(temp);
//                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  modifyDialog(item) {
    Map temp = jsonDecode(jsonEncode(item));
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context1, state) {
          return AlertDialog(
            title: Text(
              '${temp['type_name']} 修改',
            ),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width - 100,
                child: Column(
                  children: <Widget>[
                    Input(
                      label: '任务名称',
                      onChanged: (val) {
                        setState(() {
                          temp['type_name'] = val;
                        });
                      },
                      value: '${temp['type_name']}',
                    ),
                    Input(
                      label: '英文名称',
                      onChanged: (val) {
                        setState(() {
                          temp['type_en_name'] = val;
                        });
                      },
                      value: '${temp['type_en_name']}',
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 80,
                            margin: EdgeInsets.only(right: 10),
                            child: Text('web端确认'),
                          ),
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Checkbox(
                                  value: temp['web_confirm'] == '1',
                                  onChanged: (val) {
                                    state(() {
                                      temp['web_confirm'] = temp['web_confirm'] == '1' ? '0' : '1';
                                    });
                                  },
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Input(
                      label: '备注',
                      maxLines: 5,
                      onChanged: (val) {
                        setState(() {
                          temp['comment'] = val;
                        });
                      },
                      value: '${temp['comment']}',
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('关闭'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                color: CFColors.primary,
                child: Text('保存'),
                onPressed: () {
                  print(temp);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
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
                            children: ajaxData.keys.toList().map<Widget>((key) {
                              Map item = ajaxData[key];
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
                                              onChanged: null,
                                            ),
                                            Text('${item['type_en_name']}'),
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                size: 20,
                                                color: CFColors.primary,
                                              ),
                                              onPressed: () {
                                                modifyDialog(item);
                                              },
                                            ),
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
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Column(
                                              children: item['childs'].map<Widget>(
                                                (child) {
                                                  return Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Text('${child['class_name']}'),
                                                      ),
                                                      Text('${child['sort']}'),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.edit,
                                                          size: 20,
                                                          color: CFColors.primary,
                                                        ),
                                                        onPressed: () {
                                                          addAndModifyDialog(child);
                                                        },
                                                      )
                                                    ],
                                                  );
                                                },
                                              ).toList(),
                                            ),
                                            PrimaryButton(
                                              onPressed: () {
                                                addAndModifyDialog(null);
                                              },
                                              child: Text('添加子任务类型'),
                                            ),
                                          ],
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
      floatingActionButtonAnimator: ScalingAnimation(),
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(
        FloatingActionButtonLocation.endFloat,
        floatingActionButtonOffsetX,
        floatingActionButtonOffsetY,
      ),
    );
  }
}
