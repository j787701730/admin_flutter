import 'dart:convert';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/plugin/shop_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/material.dart';

class FinancialLoanModify extends StatefulWidget {
  final props;

  FinancialLoanModify(this.props);

  @override
  _FinancialLoanModifyState createState() => _FinancialLoanModifyState();
}

class _FinancialLoanModifyState extends State<FinancialLoanModify> {
  Map param = {};
  Map state = {'1': '审核中', '2': '审核失败', '3': '审核通过', '4': '已冻结', '5': '已关闭'};

  @override
  void initState() {
    super.initState();
    if (widget.props != null) {
      param = {
        'apply_desc': widget.props['item']['apply_desc'],
        'state': widget.props['item']['state'],
        'amount': widget.props['item']['amount'],
        'shop_id': widget.props['item']['shop_id'],
        'shop_name': widget.props['item']['shop_name'],
        'apply_files': jsonDecode(widget.props['item']['apply_files'])
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props == null ? '创建丰收贷' : '${param['shop_name']} 丰收贷修改'}'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          widget.props == null
              ? Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 90,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '* ',
                              style: TextStyle(color: CFColors.danger),
                            ),
                            Text('店铺:')
                          ],
                        ),
                        margin: EdgeInsets.only(right: 10),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 34,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.all(
                              Radius.circular(6),
                            ),
                          ),
                          child: Text('${param['shop_name'] ?? ''}'),
                        ),
                      ),
                      Container(
                        width: 70,
                        height: 34,
                        child: PrimaryButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            Map data = {};
                            if (param['shop_id'] != null) {
                              data = {
                                param['shop_id']: {'shop_id': param['shop_id'], 'shop_name': param['shop_name']}
                              };
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShopPlugin(
                                  shopCount: 1,
                                  selectShopsData: data,
                                ),
                              ),
                            ).then((val) {
                              if (val != null) {
                                setState(() {
                                  param['shop_id'] = val.keys.toList()[0];
                                  param['shop_name'] = val[param['shop_id']]['shop_name'];
                                });
                              }
                            });
                          },
                          child: Text('店铺'),
                        ),
                      )
                    ],
                  ),
                )
              : Container(
                  width: 0,
                ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 90,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger, fontSize: CFFontSize.content),
                      ),
                      Text(
                        '金融金额:',
                        style: TextStyle(fontSize: CFFontSize.content),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 34,
                    child: TextField(
                      style: TextStyle(fontSize: CFFontSize.content),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: '${param['amount'] ?? ''}',
                          selection: TextSelection.fromPosition(
                            TextPosition(
                              affinity: TextAffinity.downstream,
                              offset: '${param['amount'] ?? ''}'.length,
                            ),
                          ),
                        ),
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.only(
                          top: 0,
                          bottom: 0,
                          left: 15,
                          right: 15,
                        ),
                      ),
                      onChanged: (String val) {
                        setState(() {
                          param['amount'] = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Select(
            selectOptions: state,
            selectedValue: param['state'] ?? '3',
            label: '金融状态:',
            onChanged: (String newValue) {
              setState(() {
                param['state'] = newValue;
              });
            },
            labelWidth: 90,
            require: true,
          ),
          Input(
            label: '申请说明:',
            onChanged: (String val) {
              setState(() {
                param['apply_desc'] = val;
              });
            },
            labelWidth: 90,
            maxLines: 4,
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 90,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('申请附件:')
                    ],
                  ),
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        width: width - 80 - 20,
                        padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: param['apply_files'] == null || param['apply_files'].isEmpty
                            ? Container(
                                height: (width - 90 - 70) / 3,
                              )
                            : Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: param['apply_files'].map<Widget>((item) {
                                  return Stack(
                                    children: <Widget>[
                                      Container(
                                        width: (width - 90 - 70) / 3,
                                        height: (width - 90 - 70) / 3,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey, width: 1),
                                        ),
                                        child: Image.network(
                                          '$baseUrl${item['file_path']}',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      Positioned(
                                        top: 1,
                                        right: 1,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              param['apply_files'].remove(item);
                                            });
                                          },
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            child: Icon(
                                              Icons.clear,
                                              color: CFColors.danger,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                      ),
                      PrimaryButton(
                        onPressed: () {},
                        child: Text('添加附件'),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 90,
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      PrimaryButton(
                        onPressed: () {},
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
    );
  }
}
