import 'dart:async';

import 'package:admin_flutter/goods/class_attribute_select_child.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ClassAttributeSelect extends StatefulWidget {
  final props;

  ClassAttributeSelect(this.props);

  @override
  _ClassAttributeSelectState createState() => _ClassAttributeSelectState();
}

class _ClassAttributeSelectState extends State<ClassAttributeSelect> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map ajaxData = {};
  bool loading = true;

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
    ajax('Adminrelas-goodsConfig-getEnumValByAttrID', {'attr_id': widget.props['attrID']}, true, (res) {
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
      MaterialPageRoute(builder: (context) => ClassAttributeSelectChild(val)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${ajaxData.isEmpty ? '' : ajaxData['option'].isEmpty ? '商品属性搜索串' : '商品属性选项'}'),
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
                  : ajaxData.isEmpty
                      ? Container(
                          width: 0,
                        )
                      : Column(
                          children: <Widget>[
                            Offstage(
                              offstage: ajaxData['option'].isEmpty,
                              child: Container(
                                width: MediaQuery.of(context).size.width - 20,
                                child: DataTable(
                                  columnSpacing: 10,
                                  columns: <DataColumn>[
                                    const DataColumn(
                                      label: Text('枚举中文名称'),
                                    ),
                                    DataColumn(
                                      label: const Text('选项图标/图像'),
                                    ),
                                    DataColumn(
                                      label: const Text('排序'),
                                    ),
                                  ],
                                  rows: ajaxData['option'].map<DataRow>((dessert) {
                                    return DataRow(
                                      cells: <DataCell>[
                                        DataCell(
                                          Row(
                                            children: <Widget>[
                                              Text(dessert['attr_option_ch_value']),
                                              dessert['children'].isNotEmpty
                                                  ? InkWell(
                                                      onTap: () {
                                                        turnTo({'items': dessert['children']});
                                                      },
                                                      child: Container(
                                                        child: Icon(
                                                          Icons.add,
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      width: 0,
                                                    )
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Text('${dessert['attr_option_pic_url'] ?? ''}'),
                                        ),
                                        DataCell(
                                          Text('${dessert['attr_option_sort'] ?? ''}'),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            Offstage(
                              offstage: ajaxData['search_list'].isEmpty,
                              child: Container(
                                width: MediaQuery.of(context).size.width - 20,
                                child: DataTable(
                                  columnSpacing: 10,
                                  columns: <DataColumn>[
                                    DataColumn(
                                      label: Text('搜索串描述'),
                                    ),
                                    DataColumn(
                                      label: Text('搜索左值'),
                                    ),
                                    DataColumn(
                                      label: Text('搜索右值'),
                                    ),
                                    DataColumn(
                                      label: Text('排序'),
                                    ),
                                  ],
                                  rows: ajaxData['search_list'].map<DataRow>((dessert) {
                                    return DataRow(
                                      cells: <DataCell>[
                                        DataCell(
                                          Text(dessert['attr_search_desc']),
                                        ),
                                        DataCell(
                                          Text('${dessert['left_value'] ?? ''}'),
                                        ),
                                        DataCell(
                                          Text('${dessert['right_value'] ?? ''}'),
                                        ),
                                        DataCell(
                                          Text('${dessert['search_sort'] ?? ''}'),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
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
