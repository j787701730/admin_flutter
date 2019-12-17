import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:flutter/material.dart';

class PaymentPlanModify extends StatefulWidget {
  final props;

  PaymentPlanModify(this.props);

  @override
  _PaymentPlanModifyState createState() => _PaymentPlanModifyState();
}

class _PaymentPlanModifyState extends State<PaymentPlanModify> {
  Map paymentMethod = {"1": "现金支付"};
  Map planType = {"1": "平台购物", "2": "云端计费", "3": "任务扣费", "4": "ERP订单"};
  Map balanceType = {"1": "商城现金", "2": "商城红包", "3": "云端计费", "4": "云端计费-赠送", "5": "经销商", "6": "丰收贷"};
  Map param = {'payment_plan_type': '1', 'payment_method': '1', 'balance_type_id': '1'};

  @override
  void initState() {
    super.initState();
    if (widget.props != null) {
      param = {
        'payment_plan_type': '${widget.props['payment_plan_type']}',
        'payment_method': '${widget.props['payment_method']}',
        'balance_type_id': '${widget.props['balance_type_id']}',
        'balance_sort': '${widget.props['balance_sort']}',
        'comments': '${widget.props['comments'] ?? ''}',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props == null ? '添加支付方案' : ' 修改'}'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Select(
              selectOptions: planType,
              selectedValue: param['payment_plan_type'],
              label: '支付方案',
              onChanged: (val) {
                setState(() {
                  param['payment_plan_type'] = val;
                });
              }),
          Select(
              selectOptions: paymentMethod,
              selectedValue: param['payment_method'],
              label: '支付方式',
              onChanged: (val) {
                setState(() {
                  param['payment_method'] = val;
                });
              }),
          Select(
              selectOptions: balanceType,
              selectedValue: param['balance_type_id'],
              label: '资金类型',
              onChanged: (val) {
                setState(() {
                  param['balance_type_id'] = val;
                });
              }),
          Container(
              margin: EdgeInsets.only(bottom: 10),
              height: 34,
              child: Row(children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  child: Text('支付顺序'),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: TextEditingController.fromValue(TextEditingValue(
                        text: '${param['balance_sort'] ?? ''}',
                        selection: TextSelection.fromPosition(TextPosition(
                            affinity: TextAffinity.downstream, offset: '${param['balance_sort'] ?? ''}'.length)))),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 15)),
                    onChanged: (String val) {
                      setState(() {
                        param['balance_sort'] = val;
                      });
                    },
                  ),
                ),
              ])),
          Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  child: Text('调账备注'),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    maxLines: 4,
                    controller: TextEditingController.fromValue(TextEditingValue(
                        text: '${param['comments'] ?? ''}',
                        selection: TextSelection.fromPosition(TextPosition(
                            affinity: TextAffinity.downstream, offset: '${param['comments'] ?? ''}'.length)))),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15)),
                    onChanged: (String val) {
                      setState(() {
                        param['comments'] = val;
                      });
                    },
                  ),
                ),
              ])),
          Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(children: <Widget>[
                Container(
                  width: 80,
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 34,
                        child: PrimaryButton(
                            onPressed: () {
                              print(param);
                            },
                            child: Text('保存')),
                      )
                    ],
                  ),
                ),
              ])),
        ],
      ),
    );
  }
}
