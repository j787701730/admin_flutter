import 'dart:convert';

import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/user_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/material.dart';

import 'pricing_data.dart';

class PricePlan extends StatefulWidget {
  final props;

  PricePlan(this.props);

  @override
  _PricePlanState createState() => _PricePlanState();
}

class _PricePlanState extends State<PricePlan> {
  Map selectUsersData = {};
  String pricingClassId = pricingClass.keys.toList()[0].toString();
  String pricingStrategyId;
  Map pricingStrategySel = {};
  String newRenew = '1';
  bool pricingMonthShow = false; // 月基本费
  bool pricingMonthlyShow = false; // 月封顶费
  bool monthlyFlag = false; // 是否包月
  DateTime startDateNew;
  DateTime endDateNew;
  BuildContext _context;
  Map pricingStrategyData = {};
  Map constTemplate = {
    'quota': "1", // 定额计价
    'month': "2", // 阶梯计价(月)
    'onetime': "3", // 一次买断
    'monthly': "4", // 包月计价(月扣)
  };

  @override
  void initState() {
    super.initState();
    _context = context;
    if (widget.props == null) {
      getPricingStrategy();
    } else {
      getPrincePlan();
    }
  }

  getPrincePlan() async {
    ajax('Adminrelas-Balance-prinPlanceByUid', {'pricing_id': '${widget.props['item']['pricing_id']}'}, false, (res) {
      if (mounted) {
        setState(() {
          newRenew = res['data'][0]['renew_months'];
          pricingClassId = res['data'][0]['pricing_class'];
          pricingStrategyId = res['data'][0]['pricing_strategy_id'];
          getPricingStrategy();
          pricingStrategyData = {
            "pricing_strategy":
                res['data'][0]['pricing_strategy'] == '' ? '' : jsonDecode(res['data'][0]['pricing_strategy']),
            "limit_fee": res['data'][0]['limit_fee'],
          };
          startDateNew = res['data'][0]['start_date'] == null ? null : DateTime.parse(res['data'][0]['start_date']);
          endDateNew = res['data'][0]['end_date'] == null ? null : DateTime.parse(res['data'][0]['end_date']);
        });
      }
    }, () {}, _context);
  }

  getPricingStrategy() {
    pricingStrategyId = pricingStrategy[jsonDecode(pricingClass[pricingClassId]['pricing_strategy_ids'])[0].toString()]
        ['pricing_strategy_id'];
    pricingStrategySel.clear();
    for (var o in jsonDecode(pricingClass[pricingClassId]['pricing_strategy_ids'])) {
      setState(() {
        pricingStrategySel[o.toString()] = pricingStrategy[o.toString()];
      });
    }
    setPricingStrategy();
  }

  setPricingStrategy() {
    setState(() {
      pricingMonthShow = pricingStrategyId == constTemplate['quota'] ||
          pricingStrategyId == constTemplate['month'] ||
          pricingStrategyId == constTemplate['onetime'];
      pricingMonthlyShow = pricingStrategyId != constTemplate['quota'] && pricingStrategyId != constTemplate['month'];
      monthlyFlag = pricingStrategy[pricingStrategyId]['monthly_flag'] == '0';
      pricingStrategyData = jsonDecode(jsonEncode(pricingStrategy[pricingStrategyId]));
    });
  }

  getDateTime(val) {
    setState(() {
      startDateNew = val['min'];
      endDateNew = val['max'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.props == null ? '新用户定价计划' : '${widget.props['item']['login_name']} 定价计划修改'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Column(
            children: <Widget>[
              widget.props == null
                  ? Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 80,
                            alignment: Alignment.centerRight,
                            child: Text('用户:'),
                            margin: EdgeInsets.only(right: 10),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin: EdgeInsets.only(right: 10),
                              padding: EdgeInsets.only(left: 10, right: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              height: 30,
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                children: selectUsersData.keys.toList().map<Widget>(
                                  (key) {
                                    return Container(
                                      child: Stack(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.only(right: 20),
                                            child: Text(
                                              '${selectUsersData[key]['login_name']}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                              color: Color(0xffeeeeee),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    selectUsersData.remove(key);
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.clear,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            height: 30,
                            child: PrimaryButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserPlugin(
                                      userCount: 1,
                                      selectUsersData: jsonDecode(
                                        jsonEncode(selectUsersData),
                                      ),
                                    ),
                                  ),
                                ).then((val) {
                                  if (val != null) {
                                    setState(() {
                                      selectUsersData = jsonDecode(jsonEncode(val));
                                    });
                                  }
                                });
                              },
                              child: Text('选择'),
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
                  children: <Widget>[
                    Container(
                      width: 80,
                      alignment: Alignment.centerRight,
                      child: Text('扣费类型:'),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(
                            Radius.circular(4),
                          ),
                        ),
                        height: 34,
                        child: DropdownButton<String>(
                          isExpanded: true,
                          elevation: 1,
                          underline: Container(),
                          value: pricingClassId,
                          onChanged: (String newValue) {
                            setState(() {
                              pricingClassId = newValue;
                              getPricingStrategy();
                            });
                          },
                          items: pricingClass.keys.toList().map<DropdownMenuItem<String>>(
                            (item) {
                              return DropdownMenuItem(
                                value: '$item',
                                child: Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    '${pricingClass[item]['class_ch_name']}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: CFFontSize.content),
                                  ),
                                ),
                              );
                            },
                          ).toList(),
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
                      width: 80,
                      alignment: Alignment.centerRight,
                      child: Text('定价类型:'),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(
                            Radius.circular(4),
                          ),
                        ),
                        height: 34,
                        child: DropdownButton<String>(
                          isExpanded: true,
                          elevation: 1,
                          underline: Container(),
                          value: pricingStrategyId,
                          onChanged: (String newValue) {
                            setState(() {
                              pricingStrategyId = newValue;
                              setPricingStrategy();
                            });
                          },
                          items: pricingStrategySel.keys.toList().map<DropdownMenuItem<String>>(
                            (item) {
                              return DropdownMenuItem(
                                value: '$item',
                                child: Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    '${pricingStrategySel[item]['ch_name']}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: CFFontSize.content),
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Offstage(
                offstage: pricingMonthShow,
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 80,
                        padding: EdgeInsets.only(top: 12),
                        alignment: Alignment.centerRight,
                        child: Text('月基本费:'),
                        margin: EdgeInsets.only(right: 10),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      newRenew = '1';
                                    });
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Radio(
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        value: '1',
                                        groupValue: newRenew,
                                        onChanged: (val) {
                                          setState(() {
                                            newRenew = '1';
                                          });
                                        },
                                      ),
                                      Text('自动续费')
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      newRenew = '0';
                                    });
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Radio(
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        value: '0',
                                        groupValue: newRenew,
                                        onChanged: (val) {
                                          setState(() {
                                            newRenew = '0';
                                          });
                                        },
                                      ),
                                      Text('取消续费')
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: pricingStrategy.keys.toList().map<Widget>((key) {
                                return pricingStrategy[key]['monthly_flag'] == '1'
                                    ? Offstage(
                                        offstage: pricingStrategyId != pricingStrategy[key]['pricing_strategy_id'],
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: Colors.grey, width: 1),
                                                    ),
                                                    child: Text(
                                                      '时长',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    alignment: Alignment.center,
                                                    height: 26,
                                                  ),
                                                  flex: 1,
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    child: Text(
                                                      '金额',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        right: BorderSide(
                                                          color: Colors.grey,
                                                        ),
                                                        bottom: BorderSide(
                                                          color: Colors.grey,
                                                        ),
                                                        top: BorderSide(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                    height: 26,
                                                    alignment: Alignment.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: pricingStrategy[key]['pricing_strategy']
                                                  .keys
                                                  .toList()
                                                  .map<Widget>((keyChild) {
                                                Map item = pricingStrategy[key]['pricing_strategy'][keyChild];
                                                return Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          border: Border(
                                                            right: BorderSide(
                                                              color: Colors.grey,
                                                            ),
                                                            bottom: BorderSide(
                                                              color: Colors.grey,
                                                            ),
                                                            left: BorderSide(
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                        child: Text('${item['name']}'),
                                                        height: 26,
                                                        alignment: Alignment.center,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          border: Border(
                                                            right: BorderSide(
                                                              color: Colors.grey,
                                                            ),
                                                            bottom: BorderSide(
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          '${item['price']}',
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        height: 26,
                                                        alignment: Alignment.center,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                            )
                                          ],
                                        ),
                                      )
                                    : Container(
                                        width: 0,
                                      );
                              }).toList(),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Offstage(
                offstage: monthlyFlag,
                child: DateSelectPlugin(
                  onChanged: getDateTime,
                  label: '包月时间:',
                ),
              ),
              Offstage(
                offstage: pricingMonthlyShow,
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 80,
                        alignment: Alignment.centerRight,
                        child: Text('月封顶费:'),
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
                                text: '${pricingStrategyData['limit_fee']}',
                                selection: TextSelection.fromPosition(
                                  TextPosition(
                                      affinity: TextAffinity.downstream,
                                      offset: '${pricingStrategyData['limit_fee']}'.length),
                                ),
                              ),
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.only(
                                top: 6,
                                bottom: 6,
                                left: 15,
                                right: 15,
                              ),
                            ),
                            onChanged: (val) {
                              setState(() {
                                pricingStrategyData['limit_fee'] = val;
                              });
                            },
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text('元'),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 80,
                      padding: EdgeInsets.only(top: 12),
                      alignment: Alignment.centerRight,
                      child: Text('定价规则:'),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          /// 定额计价
                          Offstage(
                            offstage: pricingStrategyId != constTemplate['quota'],
                            child: pricingStrategyId == constTemplate['quota']
                                ? Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    runAlignment: WrapAlignment.center,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        width: 120,
                                        height: 34,
                                        child: TextField(
                                          style: TextStyle(fontSize: CFFontSize.content),
                                          controller: TextEditingController.fromValue(
                                            TextEditingValue(
                                              text: '${pricingStrategyData['pricing_strategy']['pricing_amount']}',
                                              selection: TextSelection.fromPosition(
                                                TextPosition(
                                                  affinity: TextAffinity.downstream,
                                                  offset: '${pricingStrategyData['pricing_strategy']['pricing_amount']}'
                                                      .length,
                                                ),
                                              ),
                                            ),
                                          ),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 10),
                                          ),
                                          onChanged: (val) {
                                            setState(() {
                                              pricingStrategyData['pricing_strategy']['pricing_amount'] = val;
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        child: Text('元/'),
                                      ),
                                      Container(
                                        width: 120,
                                        height: 34,
                                        child: TextField(
                                          style: TextStyle(fontSize: CFFontSize.content),
                                          controller: TextEditingController.fromValue(
                                            TextEditingValue(
                                              text: '${pricingStrategyData['pricing_strategy']['pricing_nums']}',
                                              selection: TextSelection.fromPosition(
                                                TextPosition(
                                                    affinity: TextAffinity.downstream,
                                                    offset: '${pricingStrategyData['pricing_strategy']['pricing_nums']}'
                                                        .length),
                                              ),
                                            ),
                                          ),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 10),
                                          ),
                                          onChanged: (val) {
                                            setState(() {
                                              pricingStrategyData['pricing_strategy']['pricing_nums'] = val;
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: 100,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(4),
                                          ),
                                        ),
                                        height: 34,
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          elevation: 1,
                                          underline: Container(),
                                          value: '${pricingStrategyData['pricing_strategy']['pricing_unit']}',
                                          onChanged: (String newValue) {
                                            setState(() {
                                              pricingStrategyData['pricing_strategy']['pricing_unit'] = newValue;
                                            });
                                          },
                                          items: unit.keys.toList().map<DropdownMenuItem<String>>(
                                            (item) {
                                              return DropdownMenuItem(
                                                value: '$item',
                                                child: Container(
                                                  padding: EdgeInsets.only(left: 10),
                                                  child: Text(
                                                    '${unit[item]['attr_unit_ch_name']}',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(fontSize: CFFontSize.content),
                                                  ),
                                                ),
                                              );
                                            },
                                          ).toList(),
                                        ),
                                      )
                                    ],
                                  )
                                : Container(
                                    width: 0,
                                  ),
                          ),

                          /// 阶梯计价(月)
                          Offstage(
                            offstage: pricingStrategyId != constTemplate['month'],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                pricingStrategyId != constTemplate['month']
                                    ? Container(
                                        width: 0,
                                      )
                                    : Column(
                                        children: pricingStrategyData['pricing_strategy'].map<Widget>((item) {
                                          return Container(
                                            margin: EdgeInsets.only(bottom: 10),
                                            padding: EdgeInsets.only(bottom: 4),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(width: 1, color: Colors.grey),
                                              ),
                                            ),
                                            child: Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              runAlignment: WrapAlignment.center,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 120,
                                                  height: 34,
                                                  child: TextField(
                                                    style: TextStyle(fontSize: CFFontSize.content),
                                                    controller: TextEditingController.fromValue(
                                                      TextEditingValue(
                                                        text: '${item['lower_limit']}',
                                                        selection: TextSelection.fromPosition(
                                                          TextPosition(
                                                              affinity: TextAffinity.downstream,
                                                              offset: '${item['lower_limit']}'.length),
                                                        ),
                                                      ),
                                                    ),
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                      contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 10),
                                                    ),
                                                    onChanged: (val) {
                                                      setState(() {
                                                        item['lower_limit'] = val;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Container(
                                                  child: Text('-'),
                                                ),
                                                Container(
                                                  width: 120,
                                                  height: 34,
                                                  child: TextField(
                                                    style: TextStyle(fontSize: CFFontSize.content),
                                                    controller: TextEditingController.fromValue(
                                                      TextEditingValue(
                                                        text: '${item['upper_limit']}',
                                                        selection: TextSelection.fromPosition(
                                                          TextPosition(
                                                              affinity: TextAffinity.downstream,
                                                              offset: '${item['upper_limit']}'.length),
                                                        ),
                                                      ),
                                                    ),
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                      contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 10),
                                                    ),
                                                    onChanged: (val) {
                                                      setState(() {
                                                        item['upper_limit'] = val;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(' (含)区间 '),
                                                ),
                                                Container(
                                                  width: 120,
                                                  height: 34,
                                                  child: TextField(
                                                    style: TextStyle(fontSize: CFFontSize.content),
                                                    controller: TextEditingController.fromValue(
                                                      TextEditingValue(
                                                        text: '${item['pricing_amount']}',
                                                        selection: TextSelection.fromPosition(
                                                          TextPosition(
                                                              affinity: TextAffinity.downstream,
                                                              offset: '${item['pricing_amount']}'.length),
                                                        ),
                                                      ),
                                                    ),
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                      contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 10),
                                                    ),
                                                    onChanged: (val) {
                                                      setState(() {
                                                        item['pricing_amount'] = val;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Container(
                                                  child: Text('元/'),
                                                ),
                                                Container(
                                                  width: 120,
                                                  height: 34,
                                                  child: TextField(
                                                    style: TextStyle(fontSize: CFFontSize.content),
                                                    controller: TextEditingController.fromValue(
                                                      TextEditingValue(
                                                        text: '${item['pricing_nums']}',
                                                        selection: TextSelection.fromPosition(
                                                          TextPosition(
                                                              affinity: TextAffinity.downstream,
                                                              offset: '${item['pricing_nums']}'.length),
                                                        ),
                                                      ),
                                                    ),
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                      contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 10),
                                                    ),
                                                    onChanged: (val) {
                                                      setState(() {
                                                        item['pricing_nums'] = val;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Container(
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.grey),
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(4),
                                                    ),
                                                  ),
                                                  height: 34,
                                                  child: DropdownButton<String>(
                                                    isExpanded: true,
                                                    elevation: 1,
                                                    underline: Container(),
                                                    value: '${item['pricing_unit']}',
                                                    onChanged: (String newValue) {
                                                      for (var o in pricingStrategyData['pricing_strategy']) {
                                                        setState(() {
                                                          o['pricing_unit'] = newValue;
                                                        });
                                                      }
                                                    },
                                                    items: unit.keys.toList().map<DropdownMenuItem<String>>((item) {
                                                      return DropdownMenuItem(
                                                        value: '$item',
                                                        child: Container(
                                                          padding: EdgeInsets.only(left: 10),
                                                          child: Text(
                                                            '${unit[item]['attr_unit_ch_name']}',
                                                            style: TextStyle(fontSize: CFFontSize.content),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    if (pricingStrategyData['pricing_strategy'].length == 1) {
                                                      setState(() {
                                                        pricingStrategyData['pricing_strategy'][0]['lower_limit'] = '';
                                                        pricingStrategyData['pricing_strategy'][0]['upper_limit'] = '';
                                                        pricingStrategyData['pricing_strategy'][0]['pricing_amount'] =
                                                            '';
                                                      });
                                                    } else {
                                                      setState(() {
                                                        pricingStrategyData['pricing_strategy'].removeAt(
                                                          pricingStrategyData['pricing_strategy'].indexOf(item),
                                                        );
                                                      });
                                                    }
                                                  },
                                                  child: Tooltip(
                                                    message: '删除本行定价规则',
                                                    child: Icon(
                                                      Icons.clear,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Map line = jsonDecode(jsonEncode(item));
                                                    line['lower_limit'] = '';
                                                    line['upper_limit'] = '';
                                                    line['pricing_amount'] = '';
                                                    setState(() {
                                                      pricingStrategyData['pricing_strategy'].insert(
                                                          pricingStrategyData['pricing_strategy'].indexOf(item) + 1,
                                                          line);
                                                    });
                                                  },
                                                  child: Tooltip(
                                                    message: '添加一行定价规则',
                                                    child: Icon(
                                                      Icons.add,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      height: 30,
                                      child: PrimaryButton(
                                        onPressed: () {
                                          Map line = jsonDecode(jsonEncode(pricingStrategyData['pricing_strategy'][0]));
                                          line['lower_limit'] = '';
                                          line['upper_limit'] = '';
                                          line['pricing_amount'] = '';
                                          setState(() {
                                            pricingStrategyData['pricing_strategy'].add(line);
                                          });
                                        },
                                        child: Text('添加阶梯'),
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(right: 6, top: 3),
                                          child: Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                '1、最后一个上限值要等于99999999；',
                                                style: TextStyle(color: Colors.red),
                                              ),
                                              Text(
                                                '2、阶梯计价有空行或者空值，该行将无效；',
                                                style: TextStyle(color: Colors.red),
                                              ),
                                              Text(
                                                '3、阶梯价格区间必须是连续性。',
                                                style: TextStyle(color: Colors.red),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          /// 阶梯计价(月)
                          Offstage(
                            offstage: pricingStrategyId == constTemplate['month'] ||
                                pricingStrategyId == constTemplate['quota'],
                            child: Container(
                              height: 40,
                              alignment: Alignment.centerLeft,
                              child: Text('无规则'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 80,
                      alignment: Alignment.centerRight,
                      child: Text(''),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: 30,
                            child: PrimaryButton(
                              onPressed: () {
                                print(pricingStrategyData);
                              },
                              child: Text('确认提交'),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
