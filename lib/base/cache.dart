import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BaseCache extends StatefulWidget {
  @override
  _BaseCacheState createState() => _BaseCacheState();
}

class _BaseCacheState extends State<BaseCache> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [
    {
      "id": "1",
      "cache_name": "GoodsClass_getGoodsAttr_C",
      "cache_name_ch": "所有商品的属性",
      "time_desc": "永久",
      "match_all": "1",
      "detail": "0",
      "redisdb": "0"
    },
    {
      "id": "2",
      "cache_name": "admin_menu_tree_grouprigh",
      "cache_name_ch": "后台权限主菜单",
      "time_desc": "永久",
      "match_all": "1",
      "detail": "0",
      "redisdb": "0"
    },
    {
      "id": "3",
      "cache_name": "goods_class_level_1,2,3",
      "cache_name_ch": "前台首页商品栏目",
      "time_desc": "永久",
      "match_all": "0",
      "detail": "0",
      "redisdb": "0"
    },
    {
      "id": "4",
      "cache_name": "goods_class",
      "cache_name_ch": "商品栏目",
      "time_desc": "永久",
      "match_all": "0",
      "detail": "0",
      "redisdb": "0"
    },
    {
      "id": "5",
      "cache_name": "admin_groups_",
      "cache_name_ch": "后台岗位权限",
      "time_desc": "永久",
      "match_all": "1",
      "detail": "0",
      "redisdb": "0"
    }
  ];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '英文名称', 'key': 'cache_name'},
    {'title': '中文名称', 'key': 'cache_name_ch'},
    {'title': '时间', 'key': 'time_desc'},
    {'title': 'redis库', 'key': 'redisdb'},
    {'title': '描述', 'key': 'detail'},
    {'title': '操作', 'key': 'option'},
  ];

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
      loading = false;
      count = ajaxData.length;
    });
//    ajax('Adminrelas-goodsConfig-getAttrByClassID', {'param': jsonEncode(param)}, true, (res) {
//      if (mounted) {
//        setState(() {
//          loading = false;
//          ajaxData = res['data'];
//          count = int.tryParse(res['count']);
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
      duration: new Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  getPage(page) {if (loading) return;
    param['curr_page'] += page;
    getData();
  }

  Map type = {"name": '名称', 'redisdb': 'redis库'};
  String typeName = 'name';
  List selectType = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('缓存管理'),
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
              loading
                  ? Container(
                      alignment: Alignment.center,
                      child: CupertinoActivityIndicator(),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Select(selectOptions: type, selectedValue: typeName, label: '关键字', onChanged: (String newValue) {
                          setState(() {
                            typeName = newValue;
                          });
                        }),
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
                                    },
                                    child: Text('搜索')),
                              ),
                              SizedBox(
                                height: 30,
                                child: PrimaryButton(
                                    color: Colors.green,
                                    onPressed: () {
                                      print(selectType);
                                    },
                                    child: Text('批量清除缓存')),
                              )
                            ],
                          ),
                          margin: EdgeInsets.only(bottom: 10),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          alignment: Alignment.centerRight,
                          child: NumberBar(count: count),
                        ),
                        Container(
                          child: ajaxData.isEmpty
                              ? Container(
                                  alignment: Alignment.center,
                                  child: Text('无数据'),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: ajaxData.map<Widget>((item) {
                                    return Container(
                                        decoration:
                                            BoxDecoration(border: Border.all(color: Color(0xffdddddd), width: 1)),
                                        margin: EdgeInsets.only(bottom: 10),
                                        padding: EdgeInsets.only(top: 10, bottom: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: columns.map<Widget>((col) {
                                            Widget con = Text('${item[col['key']] ?? ''}');
                                            switch (col['key']) {
                                              case 'cache_name':
                                                con = Wrap(
                                                  crossAxisAlignment: WrapCrossAlignment.center,
                                                  runSpacing: 10,
                                                  children: <Widget>[
                                                    Text('${item[col['key']] ?? ''}'),
                                                    Checkbox(
                                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                        value: selectType.indexOf(item['id']) > -1,
                                                        onChanged: (val) {
                                                          if (selectType.indexOf(item['id']) > -1) {
                                                            setState(() {
                                                              selectType.remove(item['id']);
                                                            });
                                                          } else {
                                                            setState(() {
                                                              selectType.add(item['id']);
                                                            });
                                                          }
                                                        })
                                                  ],
                                                );
                                                break;
                                              case 'option':
                                                con = Row(
                                                  children: <Widget>[
                                                    Container(
                                                      height: 30,
                                                      child: PrimaryButton(
                                                        onPressed: () {},
                                                        child: Text('清除缓存'),
                                                      ),
                                                    )
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
                                        ));
                                  }).toList(),
                                ),
                        ),
                        Container(
                          child: PagePlugin(
                              current: param['curr_page'],
                              total: count,
                              pageSize: param['page_count'],
                              function: getPage),
                        )
                      ],
                    )
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: toTop,
        child: Icon(Icons.keyboard_arrow_up),
      ),
    );
  }
}
