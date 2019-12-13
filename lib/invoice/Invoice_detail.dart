import 'dart:async';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class InvoiceDetail extends StatefulWidget {
  final props;

  InvoiceDetail(this.props);

  @override
  _InvoiceDetailState createState() => _InvoiceDetailState();
}

class _InvoiceDetailState extends State<InvoiceDetail> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map ajaxData = {};

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
    ajax('Adminrelas-Invoice-detail', {'invoice_id': widget.props['invoice_id']}, true, (res) {
      if (mounted) {
        setState(() {
          ajaxData = res['data'];
          toTop();
        });
        if (isRefresh) {
          _refreshController.refreshCompleted();
        }
      }
    }, () {}, _context);
  }

  toTop() {
    _controller.animateTo(
      0,
      duration: Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('申请人：${widget.props['login_name']} 申请企业：${widget.props['shop_name']}'),
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
              ajaxData.isEmpty
                  ? Container(width: 0,)
                  : Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          child: Text('发票信息'),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 120,
                                alignment: Alignment.centerRight,
                                child: Text('发票类型:'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(flex: 1, child: Text('${ajaxData['invoice_info']['invoice_type_name']}'))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 120,
                                alignment: Alignment.centerRight,
                                child: Text('开票日期:'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(flex: 1, child: Text('${ajaxData['invoice']['issue_date'] ?? ''}'))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 120,
                                alignment: Alignment.centerRight,
                                child: Text('发票抬头:'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(flex: 1, child: Text('${ajaxData['invoice_info']['invoice_header']}'))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 120,
                                alignment: Alignment.centerRight,
                                child: Text('开具类型:'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(flex: 1, child: Text('${ajaxData['invoice_info']['issue_type_name']}'))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 120,
                                alignment: Alignment.centerRight,
                                child: Text('纳税人识别号:'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(flex: 1, child: Text('${ajaxData['invoice_info']['tax_no']}'))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 120,
                                alignment: Alignment.centerRight,
                                child: Text('注册固定电话:'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(flex: 1, child: Text('${ajaxData['invoice_info']['phone']}'))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 120,
                                alignment: Alignment.centerRight,
                                child: Text('企业地址:'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(flex: 1, child: Text('${ajaxData['invoice_info']['address']}'))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 120,
                                alignment: Alignment.centerRight,
                                child: Text('银行:'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(flex: 1, child: Text('${ajaxData['invoice_info']['bank_name']}'))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 120,
                                alignment: Alignment.centerRight,
                                child: Text('银行账号:'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(flex: 1, child: Text('${ajaxData['invoice_info']['bank_no']}'))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 120,
                                alignment: Alignment.centerRight,
                                child: Text('金额:'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(flex: 1, child: Text('￥${ajaxData['invoice']['amount']}'))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 120,
                                alignment: Alignment.centerRight,
                                child: Text('申请时间:'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(flex: 1, child: Text('${ajaxData['invoice_info']['create_ate'] ?? ''}'))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 120,
                                alignment: Alignment.centerRight,
                                child: Text('更新时间:'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(flex: 1, child: Text('${ajaxData['invoice_info']['update_date'] ?? ''}'))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 120,
                                alignment: Alignment.centerRight,
                                child: Text('邮编:'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(flex: 1, child: Text('${ajaxData['invoice_info']['postcode']}'))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 120,
                                alignment: Alignment.centerRight,
                                child: Text('收件人:'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(flex: 1, child: Text('${ajaxData['invoice_info']['receiver']}'))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 120,
                                alignment: Alignment.centerRight,
                                child: Text('收件人手机:'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(flex: 1, child: Text('${ajaxData['invoice_info']['telephone']}'))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 120,
                                alignment: Alignment.centerRight,
                                child: Text('邮箱:'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(flex: 1, child: Text('${ajaxData['invoice_info']['mail'] ?? ''}'))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 120,
                                alignment: Alignment.centerRight,
                                child: Text('收件地址:'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Expanded(flex: 1, child: Text('${ajaxData['invoice_info']['addr']}'))
                            ],
                          ),
                        ),
                        widget.props['invoice_state'] == '1'
                            ? Column(
                                children: <Widget>[
                                  Input(
                                      label: '发票号:',
                                      require: true,
                                      labelWidth: 120,
                                      onChanged: (String val) {
                                        setState(() {
//                              param['loginName'] = val;
                                        });
                                      }),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          width: 120,
                                          alignment: Alignment.centerRight,
                                          child: Text('开具备注:'),
                                          margin: EdgeInsets.only(right: 10),
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: TextField(
                                              maxLines: 4,
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15)),
                                              onChanged: (String val) {
                                                setState(() {
//                              param['loginName'] = val;
                                                });
                                              },
                                            ))
                                      ],
                                    ),
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[PrimaryButton(onPressed: () {}, child: Text('确认开票'))],
                                      ))
                                ],
                              )
                            : Column(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          width: 120,
                                          alignment: Alignment.centerRight,
                                          child: Text('发票号:'),
                                          margin: EdgeInsets.only(right: 10),
                                        ),
                                        Expanded(flex: 1, child: Text('${ajaxData['invoice']['invoice_no']}'))
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          width: 120,
                                          alignment: Alignment.centerRight,
                                          child: Text('开具备注:'),
                                          margin: EdgeInsets.only(right: 10),
                                        ),
                                        Expanded(flex: 1, child: Text('${ajaxData['invoice']['comments'] ?? ''}'))
                                      ],
                                    ),
                                  )
                                ],
                              ),
                        ajaxData['acct_item'].isEmpty
                            ? Container(width: 0,)
                            : Container(
                                child: Text('项目详细数据'),
                              ),
                        ajaxData['acct_item'].isEmpty
                            ? Container(width: 0,)
                            : Container(
                                width: MediaQuery.of(context).size.width - 20,
                                child: DataTable(
                                  columnSpacing: 10,
                                  columns: <DataColumn>[
                                    const DataColumn(
                                      label: Text('名称'),
                                    ),
                                    DataColumn(
                                      label: const Text('金额(元)'),
                                    ),
                                  ],
                                  rows: ajaxData['acct_item'].map<DataRow>((item) {
                                    return DataRow(
                                      cells: <DataCell>[
                                        DataCell(
                                          Text('${item['item_type_name']}'),
                                        ),
                                        DataCell(
                                          Text('${item['amount']}'),
                                        )
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
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
