import 'dart:async';

import 'package:admin_flutter/goods/class_attribute_select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'goods_class_data.dart';

class ClassAttribute extends StatefulWidget {
  final props;

  ClassAttribute(this.props);

  @override
  _ClassAttributeState createState() => _ClassAttributeState();
}

class _ClassAttributeState extends State<ClassAttribute> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  List ajaxData = [];
  bool loading = true;

  List columns = [
    {'title': '属性归属', 'key': 'attr_owner'},
    {'title': '资源属性对象', 'key': 'attr_object_id'},
    {'title': '属性英文名称', 'key': 'attr_en_name'},
    {'title': '属性中文名称', 'key': 'attr_ch_name'},
    {'title': '属性单位', 'key': 'attr_unit'},
    {'title': '属性值类型', 'key': 'attr_value_type'},
    {'title': '属性长度', 'key': 'attr_length'},
    {'title': '属性精度', 'key': 'attr_accuracy'},
    {'title': '是否搜索属性', 'key': 'attr_search'},
    {'title': '属性排序', 'key': 'map_sort'},
  ];

  void _onRefresh() async {
    setState(() {
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
    ajax('Adminrelas-goodsConfig-getAttrByClassID', {'class_id': widget.props['classID']}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'];
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

  turnTo(val) {
    Navigator.push(
      _context,
      MaterialPageRoute(builder: (context) => ClassAttributeSelect(val)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props['className']} 商品分类和商品属性关联'),
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
                : Container(
                    child: ajaxData.isEmpty
                        ? Container(
                            alignment: Alignment.center,
                            child: Text('无项目'),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: ajaxData.map<Widget>((item) {
                              return GestureDetector(
                                onTap: () {
                                  turnTo({'attrID': item['attr_id'], 'attrOwner': item['attr_owner']});
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Color(0xffdddddd), width: 1),
                                      color: item['attr_owner'] == '自身属性' ? Color(0xffCCFFcc) : Colors.white),
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
                                              '${attrValuesType[int.tryParse(item['attr_value_type'])]['resource_attr_value_type_ch_name']}');
                                          break;
                                        case 'attr_search':
                                          con = Text('${attrSearch[item['attr_search']]['desc']}');
                                          break;
                                      }

                                      return Container(
                                        margin: EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              width: 110,
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                '${col['title']}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              margin: EdgeInsets.only(right: 10),
                                            ),
                                            Expanded(flex: 1, child: con)
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
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
