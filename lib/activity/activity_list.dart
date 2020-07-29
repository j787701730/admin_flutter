import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/search-bar-plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ActivityList extends StatefulWidget {
  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  Map drawType = {
    'all': '全部',
    '1': '转盘抽奖',
    '2': '九宫格',
  };
  List columns = [
    {'title': '活动名称', 'key': 'activity_name'},
    {'title': '活动URL', 'key': 'url'},
    {'title': '抽奖类型', 'key': 'draw_type'},
    {'title': '抽奖规则', 'key': 'activity_rules'},
    {'title': '背景图', 'key': 'background_pic'},
    {'title': '奖品', 'key': 'prizes'},
    {'title': '创建时间', 'key': 'create_date'},
    {'title': '起始时间', 'key': 'eff_date'},
    {'title': '截止时间', 'key': 'exp_date'},
    {'title': '备注', 'key': 'comments'},
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
    ajax('Adminrelas-LuckyDraw-getActivitysAjax', {'param': jsonEncode(param)}, true, (res) {
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
    param['curr_page'] = page;
    getData();
  }

  ruleDialog(item) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${item['activity_name']} 抽奖规则',
          ),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width - 100,
              child: Text('${item['activity_rules']}'),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('关闭'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Map prizeType = {
    "all": "全部",
    "1": "金钱类",
    "2": "服务类",
    "3": "实物类",
  };
  List prizeColumn = [
    {'title': '奖品名称', 'key': 'prize_name'},
    {'title': '奖品图片', 'key': 'prize_pic'},
    {'title': '奖品类型', 'key': 'prize_type'},
    {'title': '奖品数量', 'key': 'all_nums'},
    {'title': '奖品值', 'key': 'prize_value'},
    {'title': '奖品概率(%)', 'key': 'prize_rate'},
  ];

  prizeDialog(item) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${item['activity_name']} 奖品',
          ),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width - 100,
              child: Column(
                children: item['prizes'].map<Widget>((item) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    padding: EdgeInsets.only(top: 6),
                    margin: EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: prizeColumn.map<Widget>((col) {
                        Widget con = Text('${item[col['key']] ?? ''}');
                        switch (col['key']) {
                          case 'prize_type':
                            con = Text('${prizeType[item['prize_type']]['type_ch_name']}');
                            break;
                          case 'prize_pic':
                            con = Container(
                              alignment: Alignment.centerLeft,
                              width: 70,
                              height: 70,
                              child: Image.network(
                                '$baseUrl${item['prize_pic']}',
                                fit: BoxFit.contain,
                              ),
                            );
                            break;
                        }
                        return Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 120,
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
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('关闭'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  closeDialog(item) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '提示',
          ),
          content: SingleChildScrollView(
            child: Container(
              // width: MediaQuery.of(context).size.width - 100,
              child: Text('确认关闭 ${item['activity_name']} 抽奖活动?'),
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
              child: Text('确认'),
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  getDateTime(val) {
    if (val['min'] == null) {
      param.remove('create_time_l');
    } else {
      param['create_time_l'] = val['min'].toString().substring(0, 10);
    }
    if (val['max'] == null) {
      param.remove('create_time_r');
    } else {
      param['create_time_r'] = val['max'].toString().substring(0, 10);
    }
  }

  getDateTime2(val) {
    if (val['min'] == null) {
      param.remove('eff_date');
    } else {
      param['eff_date'] = val['min'].toString().substring(0, 10);
    }
    if (val['max'] == null) {
      param.remove('exp_date');
    } else {
      param['exp_date'] = val['max'].toString().substring(0, 10);
    }
  }

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'activity_name': '活动名称 升序',
    'activity_name desc': '活动名称 降序',
    'draw_type': '抽奖类型 升序',
    'draw_type desc': '抽奖类型 降序',
    'create_date': '创建时间 升序',
    'create_date desc': '创建时间 降序',
    'eff_date': '起始时间 升序',
    'eff_date desc': '起始时间 降序',
    'exp_date': '截止时间 升序',
    'exp_date desc': '截止时间 降序',
  };

  orderBy(val) {
    if (val == 'all') {
      param.remove('order');
    } else {
      param['order'] = val;
    }
    param['curr_page'] = 1;
    defaultVal = val;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('活动列表'),
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
            SearchBarPlugin(
              secondChild: Column(children: <Widget>[
                Input(
                  label: '活动名称',
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('activity_name');
                    } else {
                      param['activity_name'] = val;
                    }
                  },
                ),
                Select(
                  selectOptions: drawType,
                  selectedValue: param['draw_type'] ?? 'all',
                  label: '抽奖类型',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('draw_type');
                    } else {
                      param['draw_type'] = val;
                    }
                  },
                ),
                DateSelectPlugin(onChanged: getDateTime, label: '创建时间'),
                DateSelectPlugin(onChanged: getDateTime2, label: '有效时间'),
                Input(
                  label: '备注',
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('comments');
                    } else {
                      param['comments'] = val;
                    }
                  },
                ),
                Select(
                  selectOptions: selects,
                  selectedValue: defaultVal,
                  label: '排序',
                  onChanged: orderBy,
                ),
              ]),
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
                      FocusScope.of(context).requestFocus(FocusNode());
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
                                      case 'draw_type':
                                        con = Text('${drawType[item['draw_type']]}');
                                        break;
                                      case 'background_pic':
                                        con = Container(
                                          alignment: Alignment.centerLeft,
                                          width: 70,
                                          height: 70,
                                          child: Image.network(
                                            '$baseUrl${item['background_pic']}',
                                            fit: BoxFit.contain,
                                          ),
                                        );
                                        break;
                                      case 'activity_rules':
                                        con = InkWell(
                                          onTap: () {
                                            ruleDialog(item);
                                          },
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(minHeight: 10, maxHeight: 70),
                                            child: Text(
                                              '${item['activity_rules']}',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              style: TextStyle(color: Colors.blue),
                                            ),
                                          ),
                                        );
                                        break;
                                      case 'prizes':
                                        con = InkWell(
                                          onTap: () {
                                            prizeDialog(item);
                                          },
                                          child: Text(
                                            '奖品',
                                            style: TextStyle(color: Colors.blue),
                                          ),
                                        );
                                        break;
                                      case 'option':
                                        con = Wrap(
                                          runSpacing: 10,
                                          spacing: 10,
                                          children: <Widget>[
//                                                Container(
//                                                  height: 32,
//                                                  child: PrimaryButton(
//                                                    onPressed: () {},
//                                                    child: Text('修改'),
//                                                  ),
//                                                ),
                                            PrimaryButton(
                                              onPressed: () {
                                                closeDialog(item);
                                              },
                                              child: Text('关闭'),
                                              type: BtnType.danger,
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
