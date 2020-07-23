import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserPrizes extends StatefulWidget {
  @override
  _UserPrizesState createState() => _UserPrizesState();
}

class _UserPrizesState extends State<UserPrizes> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  bool isExpandedFlag = true;
  Map state = {
    'all': '全部',
    '0': '待兑奖',
    '1': '已兑奖',
  };

  Map prizeType = {
    "all": "全部",
    "1": "金钱类",
    "2": "服务类",
    "3": "实物类",
  };

  List columns = [
    {'title': '用户名称', 'key': 'login_name'},
    {'title': '活动名称', 'key': 'activity_name'},
    {'title': '奖项名称', 'key': 'prize_name'},
    {'title': '奖项图片', 'key': 'prize_pic'},
    {'title': '抽奖类型', 'key': 'type_ch_name'},
    {'title': '兑奖状态', 'key': 'state'},
    {'title': '创建时间', 'key': 'create_date'},
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
    ajax('Adminrelas-LuckyDraw-getUserPrizes', {'param': jsonEncode(param)}, true, (res) {
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

  prizeDialog(item) {
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
              child: Text(
                '确认兑换 ${item['login_name']} 奖品?',
                style: TextStyle(fontSize: CFFontSize.content),
              ),
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

  String defaultVal = 'all';

  Map selects = {
    //
    'all': '无',
    'login_name': '用户名称 升序',
    'login_name desc': '用户名称 降序',
    'activity_name': '活动名称 升序',
    'activity_name desc': '活动名称 降序',
    'prize_name': '奖项名称 升序',
    'prize_name desc': '奖项名称 降序',
    'dt.type_id': '抽奖类型 升序',
    'dt.type_id desc': '抽奖类型 降序',
    'state': '兑奖状态 升序',
    'state desc': '兑奖状态 降序',
    'up.create_date': '创建时间 升序',
    'up.create_date desc': '创建时间 降序',
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
        title: Text('中奖列表'),
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
              duration: const Duration(
                milliseconds: 300,
              ),
              firstChild: Placeholder(
                fallbackHeight: 0.1,
                color: Colors.transparent,
              ),
              secondChild: Column(children: <Widget>[
                Input(
                  label: '用户名称',
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('login_name');
                    } else {
                      param['login_name'] = val;
                    }
                  },
                ),
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
                Input(
                  label: '奖项名称',
                  onChanged: (String val) {
                    if (val == '') {
                      param.remove('prize_name');
                    } else {
                      param['prize_name'] = val;
                    }
                  },
                ),
                Select(
                  selectOptions: prizeType,
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
                Select(
                  selectOptions: state,
                  selectedValue: param['state'] ?? 'all',
                  label: '兑奖状态',
                  onChanged: (val) {
                    if (val == 'all') {
                      param.remove('state');
                    } else {
                      param['state'] = val;
                    }
                  },
                ),
                DateSelectPlugin(onChanged: getDateTime, label: '创建时间'),
                Select(selectOptions: selects, selectedValue: defaultVal, label: '排序', onChanged: orderBy),
              ]),
              crossFadeState: isExpandedFlag ? CrossFadeState.showFirst : CrossFadeState.showSecond,
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
                  PrimaryButton(
                    color: CFColors.success,
                    onPressed: () {
                      setState(() {
                        isExpandedFlag = !isExpandedFlag;
                      });
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text('${isExpandedFlag ? '展开' : '收缩'}选项'),
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
                                      case 'state':
                                        con = Text('${state[item['state']]}');
                                        break;
                                      case 'prize_pic':
                                        con = Container(
                                          width: 70,
                                          height: 70,
                                          alignment: Alignment.centerLeft,
                                          child: Image.network(
                                            '$baseUrl${item['prize_pic']}',
                                            fit: BoxFit.contain,
                                          ),
                                        );
                                        break;
                                      case 'option':
                                        con = Wrap(
                                          runSpacing: 10,
                                          spacing: 10,
                                          children: <Widget>[
                                            '${item['state']}' == '0'
                                                ? PrimaryButton(
                                                    onPressed: () {
                                                      prizeDialog(item);
                                                    },
                                                    child: Text('兑奖'),
                                                  )
                                                : Container()
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
