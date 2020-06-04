import 'dart:async';

import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TaskRuleModify extends StatefulWidget {
  final props;

  TaskRuleModify(this.props);

  @override
  _TaskRuleModifyState createState() => _TaskRuleModifyState();
}

class _TaskRuleModifyState extends State<TaskRuleModify> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  List ajaxData = [];
  bool loading = true;
  Map levelLog = {
    "ROLE_TYPE_PUBLISH": {
      "1": "Public/images/tasks/fb1.png",
      "2": "Public/images/tasks/fb2.png",
      "3": "Public/images/tasks/fb3.png",
      "4": "Public/images/tasks/fb4.png",
      "5": "Public/images/tasks/fb5.png"
    },
    "ROLE_TYPE_DESIGNER": {
      "1": "Public/images/tasks/sj1.png",
      "2": "Public/images/tasks/sj2.png",
      "3": "Public/images/tasks/sj3.png",
      "4": "Public/images/tasks/sj4.png",
      "5": "Public/images/tasks/sj5.png"
    },
    "ROLE_TYPE_CONSTRUCTION": {
      "1": "Public/images/tasks/az1.png",
      "2": "Public/images/tasks/az2.png",
      "3": "Public/images/tasks/az3.png",
      "4": "Public/images/tasks/az4.png",
      "5": "Public/images/tasks/az5.png"
    },
    "ROLE_TYPE_STORE": {
      "1": "Public/images/tasks/az1.png",
      "2": "Public/images/tasks/az2.png",
      "3": "Public/images/tasks/az3.png",
      "4": "Public/images/tasks/az4.png",
      "5": "Public/images/tasks/az5.png"
    },
    "ROLE_TYPE_SUPPLIER": {
      "1": "Public/images/tasks/az1.png",
      "2": "Public/images/tasks/az2.png",
      "3": "Public/images/tasks/az3.png",
      "4": "Public/images/tasks/az4.png",
      "5": "Public/images/tasks/az5.png"
    },
    "ROLE_TYPE_SHOP_STAFF": {
      "1": "Public/images/tasks/az1.png",
      "2": "Public/images/tasks/az2.png",
      "3": "Public/images/tasks/az3.png",
      "4": "Public/images/tasks/az4.png",
      "5": "Public/images/tasks/az5.png"
    }
  };

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
    ajax('Adminrelas-TaskManage-getGrowthRules', {'role_id': widget.props['role_id']}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'] ?? [];

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

  levelLogoDialog(item) {
    Map levelLogs = levelLog[widget.props['role_en_name']];
    return showDialog<void>(
      context: _context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context1, state) {
          return AlertDialog(
            title: Text(
              '等级图片',

            ),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width - 100,
                child: levelLogs != null
                    ? Column(
                        children: levelLogs.keys.toList().map<Widget>(
                        (key) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 6),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  item['level_logo'] = '${levelLogs[key]}';
                                });
                                state(() {
                                  item['level_logo'] = '${levelLogs[key]}';
                                });
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: '${levelLogs[key]}' == item['level_logo'] ? Colors.blue : Colors.grey),
                                ),
                                height: 34,
                                padding: EdgeInsets.only(top: 4, bottom: 4),
                                child: Image.network(
                                  '$baseUrl${levelLogs[key]}',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      ).toList())
                    : Container(
                        child: Text('无数据'),
                      ),
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props['role_ch_name']} 成长规则修改'),
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
                            children: ajaxData.map<Widget>((item) {
                              int index = ajaxData.indexOf(item);
                              return Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(
                                  bottom: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xffdddddd),
                                  ),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: <Widget>[
                                          Text('从 '),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              height: 34,
                                              width: 60,
                                              child: TextField(
                                                style: TextStyle(fontSize: CFFontSize.content),
                                                controller: TextEditingController.fromValue(
                                                  TextEditingValue(
                                                    text: '${ajaxData[index]['left_value'] ?? ''}',
                                                    selection: TextSelection.fromPosition(
                                                      TextPosition(
                                                        affinity: TextAffinity.downstream,
                                                        offset: '${ajaxData[index]['left_value'] ?? ''}'.length,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  contentPadding: EdgeInsets.only(
                                                    top: 0,
                                                    bottom: 0,
                                                    left: 10,
                                                    right: 10,
                                                  ),
                                                ),
                                                onChanged: (String val) {
                                                  setState(() {
                                                    ajaxData[index]['left_value'] = val;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 20,
                                            alignment: Alignment.center,
                                            child: Text('-'),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              height: 34,
                                              width: 60,
                                              child: TextField(
                                                style: TextStyle(fontSize: CFFontSize.content),
                                                controller: TextEditingController.fromValue(
                                                  TextEditingValue(
                                                    text: '${ajaxData[index]['right_value'] ?? ''}',
                                                    selection: TextSelection.fromPosition(
                                                      TextPosition(
                                                        affinity: TextAffinity.downstream,
                                                        offset: '${ajaxData[index]['right_value'] ?? ''}'.length,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  contentPadding: EdgeInsets.only(
                                                    top: 0,
                                                    bottom: 0,
                                                    left: 10,
                                                    right: 10,
                                                  ),
                                                ),
                                                onChanged: (String val) {
                                                  setState(() {
                                                    ajaxData[index]['right_value'] = val;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          Text(' 分(含)'),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            '等级数字：',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              height: 34,
                                              child: TextField(
                                                style: TextStyle(fontSize: CFFontSize.content),
                                                controller: TextEditingController.fromValue(
                                                  TextEditingValue(
                                                    text: '${ajaxData[index]['level'] ?? ''}',
                                                    selection: TextSelection.fromPosition(
                                                      TextPosition(
                                                        affinity: TextAffinity.downstream,
                                                        offset: '${ajaxData[index]['level'] ?? ''}'.length,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  contentPadding: EdgeInsets.only(
                                                    top: 0,
                                                    bottom: 0,
                                                    left: 10,
                                                    right: 10,
                                                  ),
                                                ),
                                                onChanged: (String val) {
                                                  setState(() {
                                                    ajaxData[index]['level'] = val;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            '等级名称：',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              height: 34,
                                              child: TextField(
                                                style: TextStyle(fontSize: CFFontSize.content),
                                                controller: TextEditingController.fromValue(
                                                  TextEditingValue(
                                                    text: '${ajaxData[index]['level_name'] ?? ''}',
                                                    selection: TextSelection.fromPosition(
                                                      TextPosition(
                                                        affinity: TextAffinity.downstream,
                                                        offset: '${ajaxData[index]['level_name'] ?? ''}'.length,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  contentPadding: EdgeInsets.all(10),
                                                ),
                                                onChanged: (String val) {
                                                  setState(() {
                                                    ajaxData[index]['level_name'] = val;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            '等级图片：',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              alignment: Alignment.centerLeft,
                                              height: 34,
                                              child: item['level_logo'] == null || item['level_logo'] == ''
                                                  ? Container()
                                                  : Image.network(
                                                      '$baseUrl${item['level_logo']}',
                                                      fit: BoxFit.contain,
                                                    ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              levelLogoDialog(item);
                                              FocusScope.of(_context).requestFocus(FocusNode());
                                            },
                                            child: Container(
                                              height: 34,
                                              padding: EdgeInsets.only(
                                                left: 6,
                                                right: 6,
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                '更改图片',
                                                style: TextStyle(color: Colors.blue),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            width: 34,
                                            height: 34,
                                            child: IconButton(
                                              padding: EdgeInsets.all(0),
                                              icon: Icon(
                                                Icons.delete,
                                                size: 20,
                                                color: CFColors.danger,
                                              ),
                                              onPressed: () {
                                                FocusScope.of(context).requestFocus(FocusNode());
                                                setState(() {
                                                  ajaxData.removeAt(index);
                                                  if (ajaxData.length == 0) {
                                                    ajaxData.add({
                                                      'left_value': '',
                                                      'right_value': '',
                                                      'topic': '',
                                                      'detail': '',
                                                    });
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                          Container(
                                            width: 34,
                                            height: 34,
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.add,
                                                size: 20,
                                                color: CFColors.success,
                                              ),
                                              onPressed: () {
                                                FocusScope.of(context).requestFocus(FocusNode());
                                                setState(() {
                                                  if (ajaxData.length == 5) {
                                                    Fluttertoast.showToast(
                                                      msg: '最多只能配置5条规则',
                                                      gravity: ToastGravity.CENTER,
                                                    );
                                                  } else {
                                                    setState(() {
                                                      ajaxData.insert(index + 1, {
                                                        'left_value': '',
                                                        'right_value': '',
                                                        'level': '',
                                                        'level_name': '',
                                                        'level_logo': '',
                                                      });
                                                    });
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
            loading
                ? Container()
                : Row(
                    children: <Widget>[
                      Container(
                        height: 30,
                        child: PrimaryButton(
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            if (ajaxData.length == 5) {
                              Fluttertoast.showToast(
                                msg: '最多只能配置5条规则',
                                gravity: ToastGravity.CENTER,
                              );
                            } else {
                              setState(() {
                                ajaxData.insert(ajaxData.length, {
                                  'left_value': '',
                                  'right_value': '',
                                  'level': '',
                                  'level_name': '',
                                  'level_logo': '',
                                });
                              });
                            }
                          },
                          child: Text('添加规则'),
                        ),
                      )
                    ],
                  ),
            Container(
              margin: EdgeInsets.only(
                bottom: 10,
                top: 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                      right: 6,
                    ),
                    child: Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: CFColors.danger,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '1、第一个最小值要等于1；最后一个最大值要等于999999999；',
                          style: TextStyle(
                            color: CFColors.danger,
                          ),
                        ),
                        Text(
                          '2、每行规则有空行或者空值，该行将无效；',
                          style: TextStyle(
                            color: CFColors.danger,
                          ),
                        ),
                        Text(
                          '3、规则区间之间的值必须是连续性。',
                          style: TextStyle(
                            color: CFColors.danger,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            loading
                ? Container()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 30,
                        child: PrimaryButton(
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          child: Text('保存'),
                        ),
                      )
                    ],
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
