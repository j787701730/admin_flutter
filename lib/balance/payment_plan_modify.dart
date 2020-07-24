import 'dart:convert';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/material.dart';

class PaymentPlanModify extends StatefulWidget {
  final props;

  PaymentPlanModify(this.props);

  @override
  _PaymentPlanModifyState createState() => _PaymentPlanModifyState();
}

class _PaymentPlanModifyState extends State<PaymentPlanModify> {
  Map paymentMethod = {};
  Map planType = {};
  Map balanceType = {};
  Map param = {'payment_plan_type': '1', 'payment_method': '1', 'balance_type_id': '1'};
  BuildContext _context;

  @override
  void initState() {
    super.initState();
    _context = context;
    getParamData();
    if (widget.props != null) {
      param = {
        'payment_plan_type': '${widget.props['payment_plan_type']}',
        'payment_plan_id': '${widget.props['payment_plan_id']}',
        'payment_method': '${widget.props['payment_method']}',
        'balance_type_id': '${widget.props['balance_type_id']}',
        'balance_sort': '${widget.props['balance_sort']}',
        'comments': '${widget.props['comments'] ?? ''}',
      };
    }
  }

  getParamData() {
    ajax('Adminrelas-Api-paymentPlan', {}, true, (data) {
      if (mounted) {
        Map paymentMethodTemp = {};
        for (var o in data['payment_method'].keys.toList()) {
          paymentMethodTemp[o] = data['payment_method'][o]['payment_method_ch_name'];
        }
        Map planTypeTemp = {};
        for (var o in data['plan_type'].keys.toList()) {
          planTypeTemp[o] = data['plan_type'][o]['type_ch_name'];
        }
        Map balanceTypeTemp = {};
        for (var o in data['balance_type'].keys.toList()) {
          balanceTypeTemp[o] = data['balance_type'][o]['balance_type_ch_name'];
        }
        setState(() {
          paymentMethod.addAll(paymentMethodTemp);
          planType.addAll(planTypeTemp);
          balanceType.addAll(balanceTypeTemp);
        });
      }
    }, () {}, _context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props == null ? '添加支付方案' : '修改支付方案'}'),
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
            },
          ),
          Select(
            selectOptions: paymentMethod,
            selectedValue: param['payment_method'],
            label: '支付方式',
            onChanged: (val) {
              setState(() {
                param['payment_method'] = val;
              });
            },
          ),
          Select(
            selectOptions: balanceType,
            selectedValue: param['balance_type_id'],
            label: '资金类型',
            onChanged: (val) {
              setState(() {
                param['balance_type_id'] = val;
              });
            },
          ),
          Input(
            label: '支付顺序',
            onChanged: (val) {
              param['balance_sort'] = val;
            },
            value: '${param['balance_sort'] ?? ''}',
          ),
          Input(
            label: '调账备注',
            onChanged: (val) {
              param['comments'] = val;
            },
            value: '${param['comments'] ?? ''}',
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
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
                            String url = 'adminrelas-Balance-payMentPlansAdd';
                            if (param['payment_plan_id'] != null) {
                              url = 'adminrelas-Balance-payMentPlansAlter';
                            }
                            ajax(url, {'data': jsonEncode(param)}, true, (data) {
                              Navigator.pop(context, true);
                            }, () {}, _context);
                          },
                          child: Text('保存'),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
