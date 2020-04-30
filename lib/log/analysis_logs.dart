import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/log/components/log_card.dart';
import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AnalysisLogs extends StatefulWidget {
  @override
  _AnalysisLogsState createState() => _AnalysisLogsState();
}

class _AnalysisLogsState extends State<AnalysisLogs> {
  Map param = {'curr_page': 1, 'page_count': 20};
  Map param2 = {'curr_page': 1, 'page_count': 20};
  List logs = [];
  List logs2 = [];
  int count = 0;
  int count2 = 0;
  BuildContext _context;
  ScrollController _controller;
  List columns = [
    {'title': '日志来源', 'key': 'log_source'},
    {'title': '接口名称', 'key': 'name'},
    {'title': '调用次数', 'key': 'log_times'},
    {'title': '调用日期', 'key': 'log_day'},
  ];
  bool isExpandedFlag = true;
  Map url = {
    "all": "全部",
    "1": "商品明细 (/CS-getGoodsDetail)",
    "2": "心跳包 (/CS-heart)",
    "3": "登录 (/CS-login)",
    "4": "注销 (/CS-logout)",
    "5": "心跳包 (//Opt-heart)",
    "6": "登录 (//Opt-login)",
    "7": "上传 (//Opt-upload)",
    "8": "下载配置 (/opt-downLoadCfg)",
    "9": "心跳包 (/opt-heart)",
    "10": "登录 (/opt-login)",
    "11": "注销 (/opt-logout)",
    "12": "上传 (/opt-upload)",
    "13": " (/yangxb-login)",
    "14": "登录 (//Erp-login)",
    "15": "增值服务 (/Erp-addedService)",
    "16": "所有员工 (/Erp-allStaff)",
    "17": "所有用户 (/erp-allUsers)",
    "18": "拆单配置 (/Erp-boardCut)",
    "19": "拆单配置明细 (/Erp-boradCutConf)",
    "20": "CRM列表 (/erp-crmList)",
    "21": "入库 (/Erp-depotIn)",
    "22": "文件删除 (/Erp-fileDelete)",
    "23": "文件上传 (/Erp-fileUpload)",
    "24": "主帐号 (/Erp-getMasterUser)",
    "25": "商品列表 (/erp-goodsList)",
    "26": "令牌登录 (/Erp-JWTLogin)",
    "27": "登录 (/Erp-login)",
    "28": "订单创建 (/erp-orderCreate)",
    "29": "订单删除 (/erp-orderDelete)",
    "30": "订单明细 (/Erp-orderDetail)",
    "31": "订单明细 (/Erp-orderDetail?tdsourcetag=s_pcqq_aiomsg)",
    "32": "订单列表 (/Erp-orderList)",
    "33": "订单流程 (/erp-orderProcess)",
    "34": "订单更新 (/erp-orderUpdate)",
    "35": "拆单扣款 (/Erp-payout)",
    "36": "拆单预扣款 (/Erp-prePayout)",
    "37": "报价 (/Erp-pricingProposal)",
    "38": "会话鉴权 (/Erp-sessionAuth)",
    "39": "任务确认 (/Erp-taskConfirm)",
    "40": "任务完成 (/Erp-taskFinish)",
    "41": "语音合成 (/Erp-Voice)",
    "42": " (/yangxb-chenlh)",
    "43": " (/yangxb-test)",
    "44": "配置更新 (/CAD-cfgEdit)",
    "45": "配置查询 (/CAD-cfgQuery)",
    "46": "短信验证 (/CAD-checkCode)",
    "47": "是否注册 (/CAD-checkRegUser)",
    "48": "目录创建 (/CAD-dirCreate)",
    "49": "目录删除 (/CAD-dirDelete)",
    "50": "目录查询 (/CAD-dirQuery)",
    "51": "目录更新 (/CAD-dirUpdate)",
    "52": "文件创建 (/CAD-fileCreate)",
    "53": "文件删除 (/CAD-fileDelete)",
    "54": "文件明细 (/CAD-fileDetail)",
    "55": "文件列表 (/CAD-fileList)",
    "56": "文件更新 (/CAD-fileUpdate)",
    "57": "商品列表 (/CAD-goodsList)",
    "58": "心跳包 (/CAD-heart)",
    "59": "图片删除 (/CAD-imageDelete)",
    "60": "图片列表 (/CAD-imageList)",
    "61": "图片上传 (/CAD-imageUpload)",
    "62": "登录 (/CAD-login)",
    "63": "注销 (/CAD-loginOut)",
    "64": "登录状态 (/CAD-loginStatus)",
    "65": "封面山川 (/CAD-logoUpload)",
    "66": "材质创建 (/CAD-materialCreate)",
    "67": "材质删除 (/CAD-materialDelete)",
    "68": "材质明细 (/CAD-materialDetail)",
    "69": "材质列表 (/CAD-materialList)",
    "70": "材质更新 (/CAD-materialUpdate)",
    "71": "模板创建 (/CAD-moduleCreate)",
    "72": "模板删除 (/CAD-moduleDelete)",
    "73": "模板明细 (/CAD-moduleDetail)",
    "74": "模板列表 (/CAD-moduleList)",
    "75": "模板更新 (/CAD-moduleUpdate)",
    "76": "注册 (/CAD-reg)",
    "77": "顶线创建 (/CAD-toplineCreate)",
    "78": "顶线明细 (/CAD-toplineDetail)",
    "79": "顶线列表 (/CAD-toplineList)",
    "80": "空间查询 (/CAD-zoneQuery)",
    "85": " (/CAD-fileMove)",
    "86": " (/CAD-heart?tdsourcetag=s_pctim_aiomsg)",
    "87": " (/CAD-toplineDelete)",
    "88": " (/CAD-toplineUpdate)",
    "89": " (/CAD-materialMove)",
    "90": " (/CAD-moduleMove)",
    "91": " (/CAD-toplineMove)",
    "92": " (/CAD-dirQuery?tdsourcetag=s_pctim_aiomsg)",
  };

  Map logSource = {
    'all': '全部',
    '1': '客户端日志',
    '2': '优化日志',
    '3': 'ERP日志',
    '4': 'WebCad日志',
  };

  DateTime create_date_min;
  DateTime create_date_max;
  bool loading = true;
  int tabType = 1; // 1: 日志明细 2: 日志汇总
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    setState(() {
      param['curr_page'] = 1;
      param2['curr_page'] = 1;
      getData(isRefresh: true);
      getData2(isRefresh: true);
    });
  }

//  void _onLoading() async{
//    // monitor network fetch
//    await Future.delayed(Duration(milliseconds: 1000));
//    // if failed,use loadFailed(),if no data return,use LoadNodata()
////    items.add((items.length+1).toString());
//    if(mounted)
//      setState(() {
//
//      });
//    _refreshController.loadComplete();
//  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _context = context;
    Timer(Duration(milliseconds: 200), () {
      getData();
      getData2();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getData({isRefresh: false}) async {
    if (create_date_min != null) {
      param['log_dayL'] = create_date_min.toString().substring(0, 10);
    } else {
      param.remove('log_dayL');
    }

    if (create_date_max != null) {
      param['log_dayR'] = create_date_max.toString().substring(0, 10);
    } else {
      param.remove('log_dayR');
    }

    ajax('Adminrelas-Logs-logsDetail', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        List temp = [];
        if (res['data'] != null && res['data'].isNotEmpty) {
          for (var o in res['data']) {
            o['log_source'] = logSource[o['log_source']];
            temp.add(jsonDecode(jsonEncode(o)));
          }
        }
        setState(() {
          logs = temp;
          count = int.tryParse('${res['count'] ?? 0}');
          toTop();
          loading = false;
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

  getData2({isRefresh: false}) async {
    if (create_date_min != null) {
      param2['log_dayL'] = create_date_min.toString().substring(0, 10);
    } else {
      param2.remove('log_dayL');
    }

    if (create_date_max != null) {
      param2['log_dayR'] = create_date_max.toString().substring(0, 10);
    } else {
      param2.remove('log_dayR');
    }

    param2['group'] = true;
    ajax('Adminrelas-Logs-logsDetail', {'param': jsonEncode(param2)}, true, (res) {
      if (mounted) {
        List temp = [];
        if (res['data'] != null && res['data'].isNotEmpty) {
          for (var o in res['data']) {
            o['log_source'] = logSource[o['log_source']];
            temp.add(jsonDecode(jsonEncode(o)));
          }
        }
        setState(() {
          logs2 = temp;
          count2 = int.tryParse('${res['count'] ?? 0}');
          toTop();
          loading = false;
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
      duration: new Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  getPage(page) {
    if (loading) return;
    if (tabType == 1) {
      param['curr_page'] += page;
      getData();
    } else {
      param2['curr_page'] += page;
      getData2();
    }
  }

  getDateTime(val) {
    setState(() {
      create_date_min = val['min'];
      create_date_max = val['max'];
    });
  }

  String defaultVal = 'all';

  Map selects = {
    'all': '无',
    'log_source': '日志来源 升序',
    'log_source desc': '日志来源 降序',
    'name': '接口名称 升序',
    'name desc': '接口名称 降序',
    'log_times': '调用次数 升序',
    'log_times desc': '调用次数 降序',
    'log_day': '调用日期 升序',
    'log_day desc': '调用日期 降序',
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
    getData2();
  }

  @override
  Widget build(BuildContext context) {
//    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('日志分析'),
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
            AnimatedCrossFade(
              duration: const Duration(
                milliseconds: 300,
              ),
              firstChild: Container(),
              secondChild: Column(children: <Widget>[
                Select(
                  selectOptions: logSource,
                  selectedValue: param['log_source'] ?? 'all',
                  label: '日志来源',
                  onChanged: (String newValue) {
                    setState(() {
                      if (newValue == 'all') {
                        param.remove('log_source');
                        param2.remove('log_source');
                      } else {
                        param['log_source'] = newValue;
                        param2['log_source'] = newValue;
                      }
                    });
                  },
                ),
                Select(
                  selectOptions: url,
                  selectedValue: param['url_id'] ?? 'all',
                  label: '接口名称',
                  onChanged: (String newValue) {
                    setState(() {
                      if (newValue == 'all') {
                        param.remove('url_id');
                        param2.remove('url_id');
                      } else {
                        param['url_id'] = newValue;
                        param2['url_id'] = newValue;
                      }
                    });
                  },
                ),
                DateSelectPlugin(
                  onChanged: getDateTime,
                  label: '操作日期',
                ),
                Select(
                  selectOptions: selects,
                  selectedValue: defaultVal,
                  label: '排序',
                  onChanged: orderBy,
                ),
              ]),
              crossFadeState: isExpandedFlag ? CrossFadeState.showFirst : CrossFadeState.showSecond,
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
                        param2['curr_page'] = 1;
                        getData();
                        getData2();
                        FocusScope.of(context).requestFocus(
                          FocusNode(),
                        );
                      },
                      child: Text('搜索'),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: PrimaryButton(
                      color: CFColors.success,
                      onPressed: () {
                        setState(() {
                          isExpandedFlag = !isExpandedFlag;
                        });
                      },
                      child: Text('${isExpandedFlag ? '展开' : '收缩'}选项'),
                    ),
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: 10),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(),
              height: 34,
              child: Row(
                children: <Widget>[
                  Container(
                    height: 34,
                    width: 15,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xffff4400),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        tabType = 1;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: tabType == 1 ? Color(0xffff4400) : Colors.transparent, width: 2),
                          left: BorderSide(color: tabType == 1 ? Color(0xffff4400) : Colors.transparent, width: 1),
                          right: BorderSide(color: tabType == 1 ? Color(0xffff4400) : Colors.transparent, width: 1),
                          bottom: BorderSide(color: tabType == 2 ? Color(0xffff4400) : Colors.transparent, width: 1),
                        ),
                      ),
                      height: 34,
                      child: Center(
                        child: Text(
                          '日志明细',
                          style: TextStyle(color: tabType == 1 ? Color(0xffff4400) : CFColors.text),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        tabType = 2;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      height: 34,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: tabType == 2 ? Color(0xffff4400) : Colors.transparent, width: 2),
                          left: BorderSide(color: tabType == 2 ? Color(0xffff4400) : Colors.transparent, width: 1),
                          right: BorderSide(color: tabType == 2 ? Color(0xffff4400) : Colors.transparent, width: 1),
                          bottom: BorderSide(color: tabType == 1 ? Color(0xffff4400) : Colors.transparent, width: 1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '日志汇总',
                          style: TextStyle(color: tabType == 2 ? Color(0xffff4400) : CFColors.text),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 34,
                      width: 15,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xffff4400), width: 1),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            loading
                ? Container(
                    child: CupertinoActivityIndicator(),
                  )
                : Column(
                    children: <Widget>[
                      Offstage(
                        offstage: tabType != 1,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(bottom: 8),
                              alignment: Alignment.centerRight,
                              child: NumberBar(count: count),
                            ),
                            logs.isEmpty
                                ? Container(
                                    alignment: Alignment.topCenter,
                                    child: Text('无数据'),
                                  )
                                : LogCard(
                                    columns,
                                    logs,
                                    labelWidth: 110.0,
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
                      Offstage(
                        offstage: tabType != 2,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(bottom: 8),
                              alignment: Alignment.centerRight,
                              child: NumberBar(count: count2),
                            ),
                            logs2.isEmpty
                                ? Container(
                                    alignment: Alignment.topCenter,
                                    child: Text('无数据'),
                                  )
                                : LogCard(
                                    columns,
                                    logs2,
                                    labelWidth: 110.0,
                                  ),
                            Container(
                              child: PagePlugin(
                                current: param2['curr_page'],
                                total: count2,
                                pageSize: param2['page_count'],
                                function: getPage,
                              ),
                            )
                          ],
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
