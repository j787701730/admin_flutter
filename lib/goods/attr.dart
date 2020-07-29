import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/goods/goods_class_data.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class GoodsAttribute extends StatefulWidget {
  @override
  _GoodsAttributeState createState() => _GoodsAttributeState();
}

class _GoodsAttributeState extends State<GoodsAttribute> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"currPage": 1, "pageCount": 15, 'attr_obj_id': 7};
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  List columns = [
    {'title': '资源属性对象', 'key': 'attr_object_id'},
    {'title': '属性英文名称', 'key': 'attr_en_name'},
    {'title': '属性中文名称', 'key': 'attr_ch_name'},
    {'title': '属性单位', 'key': 'attr_unit'},
    {'title': '属性值类型', 'key': 'attr_value_type'},
    {'title': '属性长度', 'key': 'attr_length'},
    {'title': '属性精度', 'key': 'attr_accuracy'},
    {'title': 'web元素', 'key': 'attr_html_id'},
    {'title': '是否搜索属性', 'key': 'attr_search'},
    {'title': '属性状态', 'key': 'state'},
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
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      loading = true;
    });
    ajax('Adminrelas-goodsConfig-GoodsAttr', {'data': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'];
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
      duration: new Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  getPage(page) {
    if (loading) return;
    param['currPage'] = page;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('类目属性'),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Input(
                  label: '属性中文名称',
                  labelWidth: 110,
                  onChanged: (String val) {
                    setState(() {
                      param['attr_ch_name'] = val;
                    });
                  },
                ),
                Container(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      SizedBox(
                        height: 32,
                        child: InkWell(
                          onTap: () {
                            param['attr_obj_id'] = 7;
                            param['currPage'] = 1;
                            getData();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Radio(
                                value: 7,
                                groupValue: param['attr_obj_id'],
                                onChanged: (val) {
                                  param['attr_obj_id'] = 7;
                                  param['currPage'] = 1;
                                  getData();
                                },
                              ),
                              Text('商品参数')
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 32,
                        child: InkWell(
                          onTap: () {
                            param['attr_obj_id'] = 6;
                            param['currPage'] = 1;
                            getData();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Radio(
                                value: 6,
                                groupValue: param['attr_obj_id'],
                                onChanged: (val) {
                                  param['attr_obj_id'] = 6;
                                  param['currPage'] = 1;
                                  getData();
                                },
                              ),
                              Text('商品规格')
                            ],
                          ),
                        ),
                      ),
                      PrimaryButton(
                        onPressed: () {
                          param['currPage'] = 1;
                          getData();
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
                        height: 400,
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
                                      border: Border.all(color: Color(0xffdddddd), width: 1),
                                    ),
                                    margin: EdgeInsets.only(bottom: 10),
                                    padding: EdgeInsets.only(top: 5, bottom: 5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: columns.map<Widget>((col) {
                                        Widget con = Text('${item[col['key']] ?? ''}');
                                        switch (col['key']) {
                                          case 'attr_object_id':
                                            con = Text(
                                                '${attrObject[item['attr_object_id']]['resource_attr_object_name']}');
                                            break;
                                          case 'attr_unit':
                                            con = item['attr_unit'] == '0'
                                                ? Text('')
                                                : Text('${attrValuesUnit[item['attr_unit']]['attr_unit_ch_name']}');
                                            break;
                                          case 'attr_value_type':
                                            con = Text(
                                                '${attrValuesType[int.parse(item['attr_value_type'])]['resource_attr_value_type_ch_name']}');
                                            break;
                                          case 'attr_html_id':
                                            con = Text('${attrHtml[item['attr_html_id']]['html_desc']}');
                                            break;
                                          case 'attr_search':
                                            con = Text('${attrSearch[item['attr_search']]['desc']}');
                                            break;
                                          case 'state':
                                            con = Text('${attrState[item['state']]['desc']}');
                                            break;
                                        }

                                        return Container(
                                          margin: EdgeInsets.only(bottom: 6),
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                width: 110,
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
                    current: param['currPage'],
                    total: count,
                    pageSize: param['pageCount'],
                    function: getPage,
                  ),
                )
              ],
            )
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
