import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/render-software/attribute-add-modify.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:admin_flutter/work-orders/work-orders-detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RenderClassEdit extends StatefulWidget {
  final props;
  final ajaxData;

  RenderClassEdit(this.props, this.ajaxData);

  @override
  _RenderClassEditState createState() => _RenderClassEditState();
}

class _RenderClassEditState extends State<RenderClassEdit> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {
    'page_count': 15,
    'curr_page': 1,
  };
  List ajaxData = [];
  int count = 0;
  bool loading = true;

  void _onRefresh() {
    setState(() {
      param['curr_page'] = 1;
      getData(isRefresh: true);
    });
  }

  Map submitData = {};
  List paramOwner = [];

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _context = context;
    print(widget.props);
    submitData['class_id'] = widget.props['class_id'];
    submitData['param'] = {};
    for (var o in widget.ajaxData) {
      submitData['param'][o['param_id']] = o['param_name'];
      if (o['param_owner'] != '自身属性') {
        paramOwner.add(o['param_id']);
      }
    }
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
    print(param);
    ajax('Adminrelas-RenderSoftware-getAllParams', {'data': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          ajaxData = res['data'] ?? [];
          count = int.tryParse('${res['count'] ?? 0}');
          loading = false;
          toTop();
        });
        if (isRefresh) {
          _refreshController.refreshCompleted();
        }
      }
    }, () {
      setState(() {
        loading = false;
      });
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
    if (loading) return;
    param['curr_page'] += page;
    getData();
  }

  delDialog(item) {
    return showDialog<void>(
      context: _context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '系统提示',
          ),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(_context).size.width * 0.8,
              child: Text('确认删除 ${item['param_name']} ?'),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('确定'),
              onPressed: () {
                ajax('Adminrelas-RenderSoftware-delParams', {'param_id': item['param_id']}, true, (data) {
                  getData();
                  Navigator.of(context).pop();
                }, () {}, _context);
              },
            ),
          ],
        );
      },
    );
  }

  paramDialog() {
    return showDialog<void>(
      context: _context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context1, state) {
          return AlertDialog(
            title: Text(
              '拥有的资源属性',
            ),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(_context).size.width * 0.8,
                child: Column(
                  children: submitData['param'].keys.toList().map<Widget>(
                    (item) {
                      return paramOwner.contains(item)
                          ? Container()
                          : Container(
                              margin: EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text('${submitData['param'][item]}'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        submitData['param'].remove('$item');
                                      });
                                      state(() {
                                        submitData['param'].remove('$item');
                                      });
                                    },
                                    child: Icon(
                                      Icons.restore_from_trash,
                                      color: CFColors.danger,
                                    ),
                                  ),
                                ],
                              ),
                            );
                    },
                  ).toList(),
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('取消'),
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: Text('确认保存'),
                onPressed: () {
                  Map data = {'class_id': submitData['class_id'], 'param': []};
                  for (var o in submitData['param'].keys.toList()) {
                    if (!paramOwner.contains(o)) {
                      data['param'].add({'param_id': o});
                    }
                  }
                  ajax('Adminrelas-RenderSoftware-alterClassParam', {'data': jsonEncode(data)}, true, (data) {
                    Navigator.of(context)..pop()..pop(true);
                  }, () {}, _context);
                },
              ),
            ],
          );
        });
      },
    );
  }

  turnTo(item) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (context) => WorkOrdersDetail(item),
      ),
    );
  }

  bool isExpandedFlag = true;

  attributeModify(item) {
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (context) => AttributeAddModify(item),
      ),
    ).then((value) {
      if (value == true) {
        getData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props['class_name']}-资源属性配置'),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: ListView(
          controller: _controller,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          padding: EdgeInsets.all(15),
          children: <Widget>[
            AnimatedCrossFade(
              duration: const Duration(
                milliseconds: 300,
              ),
              firstChild: Placeholder(
                fallbackHeight: 0.1,
                color: Colors.transparent,
              ),
              secondChild: Column(
                children: <Widget>[
                  Input(
                    label: '属性名称',
                    onChanged: (String val) {
                      if (val == null || val.trim() == '') {
                        param.remove('param_name');
                      } else {
                        param['param_name'] = val;
                      }
                    },
                  ),
                ],
              ),
              crossFadeState: isExpandedFlag ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            ),
            Container(
              margin: EdgeInsets.only(
                bottom: 15,
              ),
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
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      attributeModify(null);
                    },
                    child: Text('添加属性'),
                  ),
                  PrimaryButton(
                    onPressed: paramDialog,
                    child: Text('拥有属性'),
                  ),
                  PrimaryButton(
                    color: CFColors.success,
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          isExpandedFlag = !isExpandedFlag;
                        });
                        FocusScope.of(context).requestFocus(FocusNode());
                      }
                    },
                    child: Text('${isExpandedFlag ? '展开' : '收缩'}选项'),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              alignment: Alignment.centerRight,
              child: NumberBar(count: count),
            ),
            Container(
              padding: EdgeInsets.all(6),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 90,
                    child: Text('属性ID'),
                  ),
                  Expanded(
                    child: Container(
                      child: Text('属性名称'),
                    ),
                  ),
                  Container(
                    width: 120,
                    child: Text('操作'),
                  ),
                ],
              ),
              color: Color(0xffeeeeee),
            ),
            Column(
              children: <Widget>[
                loading
                    ? Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: CupertinoActivityIndicator(),
                      )
                    : ajaxData.isEmpty
                        ? Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            height: 40,
                            child: Text('无数据'),
                          )
                        : Column(
                            children: ajaxData.map<Widget>(
                              (item) {
                                return Container(
                                  padding: EdgeInsets.all(6),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        width: 90,
                                        child: Text('${item['param_id']}'),
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Text('${item['param_name']}'),
                                        ),
                                      ),
                                      Container(
                                        width: 120,
                                        child: Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: <Widget>[
                                            InkWell(
                                              onTap: () {
                                                attributeModify(item);
                                              },
                                              child: Text(
                                                '编辑',
                                                style: TextStyle(
                                                  color: CFColors.primary,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                delDialog(item);
                                              },
                                              child: Text(
                                                '删除',
                                                style: TextStyle(
                                                  color: CFColors.primary,
                                                ),
                                              ),
                                            ),
                                            paramOwner.contains('${item['param_id']}')
                                                ? Text('')
                                                : InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (submitData['param']['${item['param_id']}'] == null) {
                                                          submitData['param']['${item['param_id']}'] =
                                                              item['param_name'];
                                                        } else {
                                                          submitData['param'].remove('${item['param_id']}');
                                                        }
                                                      });
                                                    },
                                                    child: Text(
                                                      submitData['param']['${item['param_id']}'] == null ? '添加' : '移除',
                                                      style: TextStyle(
                                                        color: CFColors.primary,
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ).toList(),
                          ),
              ],
            ),
            Container(
              child: PagePlugin(
                current: param['curr_page'],
                total: count,
                pageSize: param['page_count'],
                function: getPage,
              ),
            )
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
