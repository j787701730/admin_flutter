import 'dart:async';
import 'dart:convert';

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

class CourseEvaluate extends StatefulWidget {
  @override
  _CourseEvaluateState createState() => _CourseEvaluateState();
}

class _CourseEvaluateState extends State<CourseEvaluate> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  Map scoreSelect = {
    '0': '全部',
    '1': '1分',
    '2': '2分',
    '3': '3分',
    '4': '4分',
    '5': '5分',
  };
  Map order = {
    'all': '无',
    'login_name': '用户 升序',
    'login_name desc': '用户 降序',
    'article_topic': '教程标题 升序',
    'article_topic desc': '教程标题 降序',
    'score': '评分分值 升序',
    'score desc': '评分分值 降序',
    'create_date': '评价内容 升序',
    'comments desc': '评价内容 降序',
  };
  String defaultVal = 'all';

  orderBy(val) {
    if (val == 'all') {
      param.remove('order');
    } else {
      param['order'] = val;
    }
    param['page'] = 1;
    defaultVal = val;
    getData();
  }

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
    ajax('Adminrelas-articleManage-ajaxCourseEvaluate', {'param': jsonEncode(param)}, true, (res) {
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
        title: Text(''),
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
              secondChild: Column(
                children: <Widget>[
                  Input(
                    label: '用户',
                    onChanged: (String val) {
                      if (val == '') {
                        param.remove('user');
                      } else {
                        param['user'] = val;
                      }
                    },
                  ),
                  Input(
                    label: '教程标题',
                    onChanged: (String val) {
                      if (val == '') {
                        param.remove('article');
                      } else {
                        param['article'] = val;
                      }
                    },
                  ),
                  Select(
                    selectOptions: scoreSelect,
                    selectedValue: param['score'] ?? '0',
                    label: '评价分值',
                    onChanged: (val) {
                      if (val == '0') {
                        param.remove('score');
                      } else {
                        param['score'] = val;
                      }
                    },
                  ),
                  Select(
                    selectOptions: order,
                    selectedValue: defaultVal,
                    label: '排序',
                    onChanged: orderBy,
                  ),
                ],
              ),
            ),
            Container(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  SizedBox(
                    height: 30,
                    child: PrimaryButton(
                      onPressed: () {
                        param['curr_page'] = 1;
                        getData();
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: Text('搜索'),
                    ),
                  ),
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
                : ajaxData.isEmpty
                    ? Container(
                        alignment: Alignment.center,
                        child: Text('无数据'),
                      )
                    : CourseEvaluateContent(
                        ajaxData: ajaxData,
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

class CourseEvaluateContent extends StatefulWidget {
  final List ajaxData;

  CourseEvaluateContent({this.ajaxData});

  @override
  _CourseEvaluateContentState createState() => _CourseEvaluateContentState();
}

class _CourseEvaluateContentState extends State<CourseEvaluateContent> {
  @override
  Widget build(BuildContext context) {
    List columns = [
      {'title': '用户', 'key': 'login_name'},
      {'title': '教程标题', 'key': 'article_topic'},
      {'title': '评分分值', 'key': 'score'},
      {'title': '评价内容', 'key': 'comments'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.ajaxData.map<Widget>((item) {
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
                case 'option':
                  con = Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    children: <Widget>[
                      PrimaryButton(
                        onPressed: () {},
                        child: Text('修改'),
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
    );
  }
}
