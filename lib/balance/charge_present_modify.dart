import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/material.dart';
import 'package:rounded_flutter_datetime_picker/rounded_flutter_datetime_picker.dart';

class ChargePresentModify extends StatefulWidget {
  final props;

  ChargePresentModify(this.props);

  @override
  _ChargePresentModifyState createState() => _ChargePresentModifyState();
}

class _ChargePresentModifyState extends State<ChargePresentModify> {
  Map balanceType = {"1": "商城现金", "3": "云端计费", "5": "经销商"};
  Map chargeType = {"2": "支付宝", "3": "微信"};
  Map presentType = {"1": "满x送x", "2": "按比例送"};
  Map userType = {"1": "买家", "2": "卖家"};
  Map presentBalance = {"2": "商城红包", "4": "云端计费-赠送", "6": "丰收贷"};
  Map param = {
    'balance_type': '1',
    'charge_type': '2',
    'user_type': '2',
    'present_type': '1',
    'present_balance_type': '2',
  };

  @override
  void initState() {
    super.initState();
    if (widget.props != null) {
      param = {
        'balance_type': '${widget.props['balance_type']}',
        'charge_type': '${widget.props['charge_type']}',
        'user_type': '${widget.props['user_type']}',
        'present_type': '${widget.props['present_type']}',
        'present_balance_type': '${widget.props['present_balance_type']}',
        'charge_limit': '${widget.props['charge_limit']}',
        'present_value': '${widget.props['present_value']}',
        'eff_date': DateTime.tryParse('${widget.props['eff_date']}'),
        'exp_date': DateTime.tryParse('${widget.props['exp_date']}'),
        'rule_name': '${widget.props['rule_name']}',
        'comments': '${widget.props['comments'] ?? ''}',
      };
    }
  }

  msgChange() {
    String str = '';
    print(param);
    if (param['user_type'] == '1') {
      str += '消费者';
    } else {
      str += '商家';
    }
    str += chargeType[param['charge_type']] + '充值满';
    str += param['charge_limit'] == null || param['charge_limit'].trim() == '' ? 'X' : param['charge_limit'];
    if (param['present_type'] == '1') {
      str += '送';
    } else {
      str += '返';
    }
    str += param['present_value'] == null || param['present_value'].trim() == '' ? 'X' : param['present_value'];
    if (param['present_type'] == '1') {
//      str += '';
    } else {
      str += '%';
    }
    setState(() {
      param['rule_name'] = str;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props == null ? '新增充值赠送规则' : '${widget.props['rule_name']} 修改'}'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            Select(
              labelWidth: 100,
              selectOptions: balanceType,
              selectedValue: param['balance_type'] ?? '1',
              label: '账本类型',
              onChanged: (val) {
                param['balance_type'] = val;
              },
            ),
            Select(
              labelWidth: 100,
              selectOptions: chargeType,
              selectedValue: param['charge_type'] ?? '2',
              label: '充值类型',
              onChanged: (val) {
                param['charge_type'] = val;
                msgChange();
              },
            ),
            Select(
              labelWidth: 100,
              selectOptions: userType,
              selectedValue: param['user_type'] ?? '1',
              label: '用户类型',
              onChanged: (val) {
                param['user_type'] = val;
                msgChange();
              },
            ),
            Select(
              labelWidth: 100,
              selectOptions: presentType,
              selectedValue: param['present_type'] ?? '1',
              label: '赠送类型',
              onChanged: (val) {
                param['present_type'] = val;
                msgChange();
              },
            ),
            Select(
              labelWidth: 100,
              selectOptions: presentBalance,
              selectedValue: param['present_balance_type'] ?? '2',
              label: '赠送账本类型',
              onChanged: (val) {
                param['present_balance_type'] = val;
                msgChange();
              },
            ),
            Input(
              label: '充值上限',
              onChanged: (val) {
                param['charge_limit'] = val;
                msgChange();
              },
              labelWidth: 100,
              type: NumberType.float,
              value: param['charge_limit'] ?? '',
            ),
            Input(
              label: '赠送额度',
              onChanged: (val) {
                param['present_value'] = val;
                msgChange();
              },
              labelWidth: 100,
              type: NumberType.float,
              value: param['present_value'] ?? '',
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 100,
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[Text('生效日期')],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        DatePicker.showDateTimePicker(
                          context,
                          showTitleActions: true,
                          minTime: DateTime.now(),
                          maxTime: DateTime(2099, 12, 31),
                          onChanged: (date) {
                            print('change $date');
                          },
                          onConfirm: (date) {
                            param['eff_date'] = date;
                          },
                          currentTime: param['eff_date'] ?? DateTime.now(),
                          locale: LocaleType.zh,
                        );
                      },
                      child: Container(
                        height: 34,
                        padding: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          param['eff_date'] == null ? '' : '${param['eff_date']}'.substring(0, 19),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 100,
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[Text('失效日期')],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        DatePicker.showDateTimePicker(
                          context,
                          showTitleActions: true,
                          minTime: DateTime.now(),
                          maxTime: DateTime(2099, 12, 31),
                          onChanged: (date) {
                            print('change $date');
                          },
                          onConfirm: (date) {
                            param['exp_date'] = date;
                          },
                          currentTime: param['exp_date'] ?? DateTime.now(),
                          locale: LocaleType.zh,
                        );
                      },
                      child: Container(
                        height: 34,
                        padding: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(param['exp_date'] == null ? '' : '${param['exp_date']}'.substring(0, 19)),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Input(
              label: '规则名称',
              onChanged: (val) {
                param['rule_name'] = val;
              },
              value: '${param['rule_name'] ?? ''}',
              labelWidth: 100,
            ),
            Input(
              label: '规则备注',
              onChanged: (val) {
                param['comments'] = val;
              },
              value: '${param['comments'] ?? ''}',
              maxLines: 6,
              marginTop: 4.0,
              labelWidth: 100,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 6),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 100,
                    alignment: Alignment.centerRight,
                    child: Text(''),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        PrimaryButton(
                          onPressed: () {
                            print(param);
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          child: Text('保存'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
