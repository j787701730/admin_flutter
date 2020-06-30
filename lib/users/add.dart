import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/city_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/shop/industry_supply_class_select.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/material.dart';

class UsersAdd extends StatefulWidget {
  @override
  _UsersAddState createState() => _UsersAddState();
}

class _UsersAddState extends State<UsersAdd> {
  String name = '';
  String realname = '';
  String phone = '';
  String password = '';
  String confirmPassword = '';
  String shopname = '';
  Map shopArea = {
    'province': '14',
    'city': '14001',
    'region': '14001001',
  };
  String shopaddress = '';
  String company_name = '';
  String tax_no = '';
  DateTime eff_date = DateTime.now();
  DateTime exp_date = DateTime(2030);
  TimeOfDay eff_time = TimeOfDay(hour: 00, minute: 00);
  TimeOfDay exp_time = TimeOfDay(hour: 23, minute: 59);
  String mail = '';
  String city = '';
  String gender = '';
  List interest = [];
  String date = '';
  String time = '';
  String desc = '';
  List rolesList = [];
  List servicesList = [];
  List right_flag = [];
  String present = '';
  Map roles = {};
  Map services = {};
  List multiselectUserType = [];
  Map sigleselectUserType = {};
  Map regPresent = {};
  List industryClass = []; // 行业分类
  List selectIndustryClass = []; // 选择的行业分类
  Map industryClassData = {}; // 数据匹配用的
  List supplyClass = []; // 供应分类
  List selectSupplyClass = []; // 选择的供应分类
  Map supplyClassData = {}; // 数据匹配用的
  getArea(val) {
    if (val != null) {
      shopArea = jsonDecode(jsonEncode(val));
    }
  }

  BuildContext _context;

  @override
  void initState() {
    super.initState();
    _context = context;
    Timer(Duration(milliseconds: 200), () {
      getParamData();
      getSupplyClass();
      getIndustryClass();
    });
  }

  getParamData() {
    ajax('Adminrelas-Api-addUserData', {}, true, (data) {
      if (mounted) {
        setState(() {
          multiselectUserType = data['multiselectUserType'];
          regPresent = data['reg_present']['present'];
          roles = data['roles'];
          services = data['services'];
          sigleselectUserType = data['sigleselectUserType'];
        });
      }
    }, () {}, _context);
  }

  getIndustryClass() {
    ajax('Adminrelas-shopsManage-getIndustryClass', {}, true, (data) {
      if (mounted) {
        industryClass = data['data'];
        for (var o in data['data']) {
          industryClassData[o['class_id']] = {'class_name': o['class_name'], 'parent_class_id': o['parent_class_id']};
          if (o['children'] != '') {
            for (var p in o['children']) {
              industryClassData[p['class_id']] = {
                'class_name': p['class_name'],
                'parent_class_id': p['parent_class_id']
              };
            }
          }
        }
      }
    }, () {}, _context);
  }

  getSupplyClass() {
    ajax('Adminrelas-shopsManage-getSupplyClass', {}, true, (data) {
      if (mounted) {
        supplyClass = data['data'];
        for (var o in data['data']) {
          supplyClassData[o['class_id']] = {'class_name': o['class_name'], 'parent_class_id': o['parent_class_id']};
          if (o['children'] != '') {
            for (var p in o['children']) {
              supplyClassData[p['class_id']] = {'class_name': p['class_name'], 'parent_class_id': p['parent_class_id']};
            }
          }
        }
      }
    }, () {}, _context);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('用户添加'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xffdddddd), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  width: width,
                  height: 34,
                  padding: EdgeInsets.only(left: 15),
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
//                    color: Color(0xffF2F2F2),
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xffdddddd),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    '用户信息',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 10),
                  child: Column(
                    children: <Widget>[
                      Input(
                        label: '用户名',
                        onChanged: (String val) {
                          setState(() {
                            name = val;
                          });
                        },
                        require: true,
                        labelWidth: 90,
                      ),
                      Input(
                        label: '真实名字',
                        onChanged: (String val) {
                          setState(() {
                            realname = val;
                          });
                        },
                        require: true,
                        labelWidth: 90,
                      ),
                      Input(
                        label: '手机',
                        onChanged: (String val) {
                          setState(() {
                            phone = val;
                          });
                        },
                        require: true,
                        labelWidth: 90,
                      ),
                      Input(
                        label: '密码',
                        onChanged: (String val) {
                          setState(() {
                            password = val;
                          });
                        },
                        require: true,
                        labelWidth: 90,
                      ),
                      Input(
                        label: '确认密码',
                        onChanged: (String val) {
                          setState(() {
                            confirmPassword = val;
                          });
                        },
                        require: true,
                        labelWidth: 90,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xffdddddd), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  width: width,
                  height: 34,
                  padding: EdgeInsets.only(left: 15),
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
//                    color: Color(0xffF2F2F2),
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xffdddddd),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    '店铺信息',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 10),
                  child: Column(
                    children: <Widget>[
                      Input(
                        label: '店铺名称',
                        onChanged: (String val) {
                          setState(() {
                            shopname = val;
                          });
                        },
                        require: true,
                        labelWidth: 90,
                      ),
                      CitySelectPlugin(
                        getArea: getArea,
                        linkage: true,
                        initArea: shopArea,
                        label: '联系地址',
                        require: true,
                        labelWidth: 90,
                      ),
                      Input(
                        label: '详细地址',
                        onChanged: (String val) {
                          setState(() {
                            shopaddress = val;
                          });
                        },
                        require: true,
                        labelWidth: 90,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.centerRight,
                              margin: EdgeInsets.only(right: 10, top: 10),
                              width: 90,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    '* ',
                                    style: TextStyle(color: CFColors.danger),
                                  ),
                                  Text('可选角色')
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Wrap(
                                spacing: 15,
                                children: roles.keys.toList().map<Widget>((item) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (rolesList.indexOf(item) == -1) {
                                        setState(() {
                                          rolesList.add(item);
                                        });
                                      } else {
                                        setState(() {
                                          rolesList.remove(item);
                                        });
                                      }
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Checkbox(
                                              value: rolesList.indexOf(item) > -1,
                                              onChanged: (val) {
                                                if (rolesList.indexOf(item) == -1) {
                                                  setState(() {
                                                    rolesList.add(item);
                                                  });
                                                } else {
                                                  setState(() {
                                                    rolesList.remove(item);
                                                  });
                                                }
                                              }),
                                          Text('${roles[item]['role_ch_name']}')
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 10, right: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.centerRight,
                              margin: EdgeInsets.only(right: 10, top: 10),
                              width: 90,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    '* ',
                                    style: TextStyle(color: CFColors.danger),
                                  ),
                                  Text('可选服务')
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Wrap(
                                    spacing: 15,
                                    children: multiselectUserType.map<Widget>((item) {
                                      return GestureDetector(
                                        onTap: () {
                                          if (right_flag.indexOf(item) == -1) {
                                            setState(() {
                                              right_flag.add(item);
                                            });
                                          } else {
                                            setState(() {
                                              right_flag.remove(item);
                                            });
                                          }
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Container(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Checkbox(
                                                  value: right_flag.indexOf(item) > -1,
                                                  onChanged: (val) {
                                                    if (right_flag.indexOf(item) == -1) {
                                                      setState(() {
                                                        right_flag.add(item);
                                                      });
                                                    } else {
                                                      setState(() {
                                                        right_flag.remove(item);
                                                      });
                                                    }
                                                  }),
                                              Text('${item['type_ch_name']}')
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: sigleselectUserType.keys.toList().map<Widget>((item) {
                                      return Container(
                                        width: width,
                                        decoration: BoxDecoration(
                                            border: Border(top: BorderSide(color: Color(0xffdddddd), width: 1))),
                                        child: Wrap(
                                          spacing: 15,
                                          children: sigleselectUserType[item].map<Widget>((type) {
                                            return GestureDetector(
                                              onTap: () {
                                                bool flag = true;
                                                String id = '';
                                                for (var o in sigleselectUserType[item]) {
                                                  if (right_flag.indexOf(o['type_id']) > -1) {
                                                    flag = false;
                                                    id = o['type_id'];
                                                  }
                                                }
                                                if (flag) {
                                                  setState(() {
                                                    right_flag.add(type['type_id']);
                                                  });
                                                } else {
                                                  if (id == type['type_id']) {
                                                    setState(() {
                                                      right_flag.remove(type['type_id']);
                                                    });
                                                  } else {
                                                    setState(() {
                                                      right_flag.remove(id);
                                                      right_flag.add(type['type_id']);
                                                    });
                                                  }
                                                }
                                              },
                                              behavior: HitTestBehavior.opaque,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Radio(
                                                      value: type['type_id'],
                                                      groupValue: right_flag.indexOf(type['type_id']) > -1
                                                          ? right_flag[right_flag.indexOf(type['type_id'])]
                                                          : '',
                                                      onChanged: (val) {
                                                        bool flag = true;
                                                        String id = '';
                                                        for (var o in sigleselectUserType[item]) {
                                                          if (right_flag.indexOf(o['type_id']) > -1) {
                                                            flag = false;
                                                            id = o['type_id'];
                                                          }
                                                        }
                                                        if (flag) {
                                                          setState(() {
                                                            right_flag.add(type['type_id']);
                                                          });
                                                        } else {
                                                          if (id == type['type_id']) {
                                                            setState(() {
                                                              right_flag.remove(type['type_id']);
                                                            });
                                                          } else {
                                                            setState(() {
                                                              right_flag.remove(id);
                                                              right_flag.add(type['type_id']);
                                                            });
                                                          }
                                                        }
                                                      }),
                                                  Text('${type['type_ch_name']}')
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    }).toList(),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Offstage(
                        offstage:
                            !(rolesList.contains('101') || rolesList.contains('104') || rolesList.contains('105')),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 100,
                                alignment: Alignment.centerRight,
                                margin: EdgeInsets.only(right: 10, top: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[Text('行业分类')],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      child: Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: selectIndustryClass.map<Widget>(
                                            (item) {
                                              String text = '';
                                              Map obj = industryClassData[item];
                                              if (obj['parent_class_id'] != '0') {
                                                text = '${industryClassData[obj['parent_class_id']]['class_name']}/'
                                                    '${industryClassData[item]['class_name']}';
                                              }
                                              return Container(
                                                color: Colors.grey[300],
                                                padding: EdgeInsets.all(4),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text(text),
                                                    InkWell(
                                                      child: Icon(
                                                        Icons.close,
                                                        size: 20,
                                                        color: CFColors.danger,
                                                      ),
                                                      onTap: () {
                                                        setState(() {
                                                          selectIndustryClass.remove(item);
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ).toList()),
                                    ),
                                    PrimaryButton(
                                      onPressed: () {
                                        Navigator.push(
                                          _context,
                                          MaterialPageRoute(
                                            builder: (context) => IndustryClassSelect(
                                              selectClass: selectIndustryClass,
                                              classData: industryClass,
                                              title: '行业分类',
                                            ),
                                          ),
                                        ).then((value) {
                                          if (value != null) {
                                            setState(() {
                                              selectIndustryClass = jsonDecode(jsonEncode(value));
                                            });
                                          }
                                        });
                                      },
                                      child: Text('添加'),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Offstage(
                        offstage: !(!(rolesList.contains('101') && rolesList.length == 1) ||
                                rolesList.contains('102') ||
                                rolesList.contains('103') ||
                                rolesList.contains('104') ||
                                rolesList.contains('105')) ||
                            rolesList.isEmpty,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 100,
                                alignment: Alignment.centerRight,
                                margin: EdgeInsets.only(right: 10, top: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[Text('供应分类')],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      child: Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: selectSupplyClass.map<Widget>(
                                            (item) {
                                              String text = '';
                                              Map obj = supplyClassData[item];
                                              if (obj['parent_class_id'] != '0') {
                                                text = '${supplyClassData[obj['parent_class_id']]['class_name']}/'
                                                    '${supplyClassData[item]['class_name']}';
                                              }
                                              return Container(
                                                color: Colors.grey[300],
                                                padding: EdgeInsets.all(4),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text(text),
                                                    InkWell(
                                                      child: Icon(
                                                        Icons.close,
                                                        size: 20,
                                                        color: CFColors.danger,
                                                      ),
                                                      onTap: () {
                                                        setState(() {
                                                          selectSupplyClass.remove(item);
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ).toList()),
                                    ),
                                    PrimaryButton(
                                      onPressed: () {
                                        Navigator.push(
                                          _context,
                                          MaterialPageRoute(
                                            builder: (context) => IndustryClassSelect(
                                              selectClass: selectSupplyClass,
                                              classData: supplyClass,
                                              title: '供应分类',
                                            ),
                                          ),
                                        ).then((value) {
                                          if (value != null) {
                                            setState(() {
                                              selectSupplyClass = jsonDecode(jsonEncode(value));
                                            });
                                          }
                                        });
                                      },
                                      child: Text('添加'),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Input(
                        label: '公司名称',
                        onChanged: (String val) {
                          setState(() {
                            company_name = val;
                          });
                        },
                        labelWidth: 90,
                      ),
                      Input(
                        label: '纳税识别号',
                        onChanged: (String val) {
                          setState(() {
                            tax_no = val;
                          });
                        },
                        labelWidth: 90,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          // 有效时间
          Container(
            margin: EdgeInsets.only(top: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xffdddddd), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  width: width,
                  height: 34,
                  padding: EdgeInsets.only(left: 15),
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
//                    color: Color(0xffF2F2F2),
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xffdddddd),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text('有效时间'),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10, right: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 10),
                        width: 90,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '* ',
                              style: TextStyle(color: CFColors.danger),
                            ),
                            Text('生效时间')
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          child: Container(
                            height: 34,
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 1)),
                            padding: EdgeInsets.only(left: 10, right: 10),
                            alignment: Alignment.centerLeft,
                            child: Text('${eff_date == null ? '' : eff_date.toString().substring(0, 10)}'),
                          ),
                          onTap: () {
                            showDatePicker(
                              context: context,
                              initialDate: eff_date ?? DateTime.now(),
                              firstDate: DateTime(2018),
                              lastDate: DateTime(2030),
                            ).then((date) {
                              if (date == null) return;
                              setState(() {
                                eff_date = date;
                              });
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          child: Container(
                            height: 34,
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 1)),
                            padding: EdgeInsets.only(left: 10, right: 10),
                            alignment: Alignment.centerLeft,
                            child: Text('${eff_time == null ? '' : '${eff_time.hour}:${eff_time.minute}:00'}'),
                          ),
                          onTap: () {
                            showTimePicker(
                              context: context,
                              initialTime: eff_time ?? TimeOfDay.now(),
                            ).then((val) {
                              if (val == null) return;
                              setState(() {
                                eff_time = val;
                              });
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10, right: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 10),
                        width: 90,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '* ',
                              style: TextStyle(color: CFColors.danger),
                            ),
                            Text('失效时间')
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          child: Container(
                            height: 34,
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 1)),
                            padding: EdgeInsets.only(left: 10, right: 10),
                            alignment: Alignment.centerLeft,
                            child: Text('${exp_date == null ? '' : exp_date.toString().substring(0, 10)}'),
                          ),
                          onTap: () {
                            showDatePicker(
                              context: context,
                              initialDate: exp_date ?? DateTime.now(),
                              firstDate: DateTime(2018),
                              lastDate: DateTime(2030),
                            ).then((date) {
                              if (date == null) return;
                              setState(() {
                                exp_date = date;
                              });
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          child: Container(
                            height: 34,
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 1)),
                            padding: EdgeInsets.only(left: 10, right: 10),
                            alignment: Alignment.centerLeft,
                            child: Text('${exp_time == null ? '' : '${exp_time.hour}:${exp_time.minute}:00'}'),
                          ),
                          onTap: () {
                            showTimePicker(
                              context: context,
                              initialTime: exp_time ?? TimeOfDay.now(),
                            ).then((val) {
                              if (val == null) return;
                              setState(() {
                                exp_time = val;
                              });
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xffdddddd), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  width: width,
                  height: 34,
                  padding: EdgeInsets.only(left: 15),
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
//                    color: Color(0xffF2F2F2),
                    border: Border(
                      bottom: BorderSide(color: Color(0xffdddddd), width: 1),
                    ),
                  ),
                  child: Text('注册礼物'),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10, right: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 10, top: 10),
                        width: 90,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '* ',
                              style: TextStyle(color: CFColors.danger),
                            ),
                            Text('选择礼物')
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Wrap(
                          spacing: 15,
                          children: regPresent.keys.toList().map<Widget>((item) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  present = item;
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Radio(
                                      // 设置大小
                                      value: item,
                                      groupValue: present,
                                      onChanged: (val) {
                                        setState(() {
                                          present = val;
                                        });
                                      }),
                                  Text('${regPresent[item]['ch_na']}')
                                ],
                              ),
                            );
                          }).toList(),
                        ),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                PrimaryButton(
                  onPressed: () {},
                  child: Text('提交'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
