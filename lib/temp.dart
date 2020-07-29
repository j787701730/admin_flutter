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

/// 模板文件
class $1$ extends StatefulWidget {
  @override
  _$1$State createState() => _$1$State();
}

class _$1$State extends State<$1$> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  Map order = {
    'all': '无',
    'login_name': '用户 升序',
    'login_name desc': '用户 降序',
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
    param['curr_page'] = page;
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
                    : $1$Content(
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

class $1$Content extends StatefulWidget {
  final List ajaxData;

  $1$Content({this.ajaxData});

  @override
  _$1$ContentState createState() => _$1$ContentState();
}

class _$1$ContentState extends State<$1$Content> {
  @override
  Widget build(BuildContext context) {
    List columns = [
      {'title': '用户', 'key': 'login_name'},
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
