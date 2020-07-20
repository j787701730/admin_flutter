import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/style.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class WorkOrdersDetail extends StatefulWidget {
  final props;

  WorkOrdersDetail(this.props);

  @override
  _WorkOrdersDetailState createState() => _WorkOrdersDetailState();
}

class _WorkOrdersDetailState extends State<WorkOrdersDetail> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {};
  List ajaxData = [];
  List sLog = [];
  bool loading = true;
  String exe;

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
    param['order_no'] = widget.props['order_no'];
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
    ajax('Adminrelas-WorkOrders-getDataLog', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res['data'] ?? [];
          sLog = res['sLog'] ?? [];
          exe = '${res['exe']}';
//          toTop();
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
    getData();
  }

  send() {
    print(param);
    if (param['log_content'] == null || '${param['log_content']}'.trim() == '') {
      Fluttertoast.showToast(
        msg: '请输入内容',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }
    ajax('Adminrelas-WorkOrders-addL', {'data': jsonEncode(param)}, true, (data) {
      getData();
    }, () {}, _context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props['order_topic']} 工单查看'),
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
            Container(
              child: Text(
                '${widget.props['order_topic']} 沟通记录',
                style: TextStyle(
                  fontSize: CFFontSize.title,
                ),
              ),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: CFColors.primary, width: 3),
                ),
              ),
              padding: EdgeInsets.only(left: 10),
              margin: EdgeInsets.only(bottom: 15),
            ),
            loading
                ? Container(
                    alignment: Alignment.center,
                    child: CupertinoActivityIndicator(),
                  )
                : Column(
                    children: <Widget>[
                      sLog.isEmpty
                          ? Container(
                              alignment: Alignment.center,
                              child: Text('无数据'),
                            )
                          : Column(
                              children: sLog.map<Widget>(
                                (item) {
                                  Widget left = Container(
                                    width: 13,
                                    height: 13,
                                    decoration: BoxDecoration(
                                      color: CFColors.text,
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    margin: EdgeInsets.only(left: 3, top: 7),
                                  );
                                  int index = sLog.indexOf(item);
                                  if (exe != '0') {
                                    if (index == sLog.length - 1) {
                                      left = Container(
                                        width: 21,
                                        height: 21,
                                        margin: EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                          color: CFColors.primary,
                                          borderRadius: BorderRadius.circular(21),
                                        ),
                                        child: Icon(
                                          Icons.arrow_downward,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      );
                                    }
                                  }

                                  return Container(
                                    padding: EdgeInsets.only(bottom: 20),
                                    child: Stack(
                                      overflow: Overflow.visible,
                                      children: <Widget>[
                                        index == sLog.length - 1
                                            ? '$exe' == '0'
                                                ? Container()
                                                : Positioned(
                                                    left: 9,
                                                    top: 10,
                                                    bottom: -28,
                                                    child: Container(
                                                      width: 1,
                                                      color: Color(0xffeeeeee),
                                                    ),
                                                  )
                                            : Positioned(
                                                left: 9,
                                                top: 10,
                                                bottom: -28,
                                                child: Container(
                                                  width: 1,
                                                  color: CFColors.text,
                                                ),
                                              ),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              child: left,
                                              margin: EdgeInsets.only(right: 10),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text('${item['state_log']}'),
                                                  Text(
                                                    '${item['create_date']}',
                                                    style: TextStyle(
                                                      color: CFColors.secondary,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ).toList(),
                            ),
                      exe != '0'
                          ? Container(
                              padding: EdgeInsets.only(bottom: 20),
                              child: Stack(
                                overflow: Overflow.visible,
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        child: Container(
                                          width: 13,
                                          height: 13,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(13),
                                            border: Border.all(
                                              color: Color(0xff999999),
                                            ),
                                            color: Colors.white,
                                          ),
                                          margin: EdgeInsets.only(left: 3, top: 7),
                                        ),
                                        margin: EdgeInsets.only(right: 10),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text('工单结单'),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      Divider(),
                      ajaxData.isEmpty
                          ? Container(
                              alignment: Alignment.center,
                              child: Text('无数据'),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: ajaxData.map<Widget>((item) {
                                return Container(
//                                  decoration: BoxDecoration(
//                                    border: Border.all(
//                                      color: Color(0xffdddddd),
//                                    ),
//                                  ),
                                  margin: EdgeInsets.only(top: 10),
                                  padding: EdgeInsets.only(top: 5, bottom: 5),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: 40,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.all(int.parse(item['user_id']) >= 27 ? 4 : 0),
                                            decoration: BoxDecoration(
                                              color: int.parse(item['user_id']) >= 27
                                                  ? CFColors.primary
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            margin: EdgeInsets.only(right: 10),
                                            child: Image.network(
                                              int.parse(item['user_id']) >= 27
                                                  ? '${baseUrl}Public/images/user.png'
                                                  : '${baseUrl}Public/images/cf.jpg',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  Text('${item['user_name']}:'),
                                                  MediaQuery(
                                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
                                                    child: Html(
                                                      shrinkWrap: true,
                                                      data: '${item['log_content']}',
                                                      style: {
//                                                        'html': Style(
//                                                          display: Display.BLOCK,
//                                                          fontSize: FontSize(CFFontSize.content),
//                                                        ),
                                                        'p': Style(
                                                          fontSize: FontSize(CFFontSize.title),
                                                        ),
                                                        'span': Style(
                                                          fontSize: FontSize(CFFontSize.title),
                                                        ),
                                                      },
                                                      customRender: {
                                                        "img": (RenderContext context, Widget child, attributes, _) {
                                                          return Image.network(
                                                            '$baseUrl${attributes['src']}',
                                                            fit: BoxFit.contain,
                                                          );
                                                        },
                                                      },
                                                    ),
                                                  ),
                                                  Text(
                                                    '${item['create_date']}',
                                                    style: TextStyle(
                                                      color: CFColors.secondary,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                      '$exe' == '1'
                          ? Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Input(
                                    label: '回复内容',
                                    require: true,
                                    onChanged: (val) {
                                      param['log_content'] = val;
                                    },
                                    maxLines: 5,
                                    marginTop: 4.0,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 90),
                                    child: PrimaryButton(
                                      onPressed: send,
                                      child: Text('提交'),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container()
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
