import 'dart:convert';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PhoneMenuAddModify extends StatefulWidget {
  final item;
  final parentMenuID;
  final menuID;

  PhoneMenuAddModify({this.item, this.parentMenuID, this.menuID});

  @override
  _PhoneMenuAddModifyState createState() => _PhoneMenuAddModifyState();
}

class _PhoneMenuAddModifyState extends State<PhoneMenuAddModify> {
  Map param = {};
  BuildContext _context;

  @override
  void initState() {
    super.initState();
    _context = context;
    if (widget.item != null) {
      param = {
        'menu_icon': widget.item['mio'] ?? '',
        'menu_ch_name': widget.item['mnm'] ?? '',
        'menu_en_name': widget.item['mnm_en'] ?? '',
        'menu_url': widget.item['mul'] ?? '',
        'menu_sort': widget.item['mst'] ?? '',
        'menu_type': widget.item['mt'] ?? '',
        'target': widget.item['tg'] ?? '',
        'if_head': widget.item['ih'] ?? '0',
        'comments': widget.item['cm'] ?? '',
      };
    }
    if (widget.menuID != null) {
      param['menu_id'] = widget.menuID;
    }
    if (widget.parentMenuID != null) {
      param['parent_menu_id'] = widget.parentMenuID;
    }
  }

  save() {
    FocusScope.of(context).requestFocus(FocusNode());
    bool flag = true;
    List msg = [];
    Map data = jsonDecode(jsonEncode(param));
    String url = 'Adminrelas-WebSysConfig-addPhoneMenus';
    if (widget.menuID != null) {
      url = 'Adminrelas-WebSysConfig-alterPhoneMenus';
    }
    if (data['parent_menu_id'] == '0') {
      data.remove('parent_menu_id');
    } else {
      if (data['menu_icon'] == null || '${data['menu_icon']}'.trim() == '') {
        msg.add('图标');
        flag = false;
      }
      if (data['menu_url'] == null || '${data['menu_url']}'.trim() == '') {
        msg.add('url地址');
        flag = false;
      }
    }

    if (data['menu_ch_name'] == null || '${data['menu_ch_name']}'.trim() == '') {
      msg.add('中文名');
      flag = false;
    }
    if (data['menu_en_name'] == null || '${data['menu_en_name']}'.trim() == '') {
      msg.add('英文名');
      flag = false;
    }

    if (data['menu_sort'] == null || '${data['menu_sort']}'.trim() == '') {
      msg.add('排序');
      flag = false;
    }
    print({'data': jsonEncode(data)});
    print(url);

    if (flag) {
      ajax(url, {'data': jsonEncode(data)}, true, (data) {
        Navigator.of(context).pop(true);
      }, () {}, _context);
    } else {
      Fluttertoast.showToast(
        msg: '请填写 ${msg.join(', ')}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.menuID == null ? '新增' : ' ${widget.item['mnm']} 修改'}'),
      ),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: <Widget>[
          Input(
            label: '图标',
            require: widget.parentMenuID != '0',
            onChanged: (val) {
              setState(() {
                param['menu_icon'] = val;
              });
              FocusScope.of(context).requestFocus(FocusNode());
            },
            value: param['menu_icon'],
          ),
          Input(
            label: '中文名',
            require: true,
            onChanged: (val) {
              setState(() {
                param['menu_ch_name'] = val;
              });
              FocusScope.of(context).requestFocus(FocusNode());
            },
            value: param['menu_ch_name'],
          ),
          Input(
            label: '英文名',
            require: true,
            onChanged: (val) {
              setState(() {
                param['menu_en_name'] = val;
              });
              FocusScope.of(context).requestFocus(FocusNode());
            },
            value: param['menu_en_name'],
          ),
          Input(
            label: 'URL地址',
            require: widget.parentMenuID != '0',
            onChanged: (val) {
              setState(() {
                param['menu_url'] = val;
              });
              FocusScope.of(context).requestFocus(FocusNode());
            },
            value: param['menu_url'],
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10, top: 3),
                  child: Text('是否常用'),
                ),
                Expanded(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ['2', '1'].map<Widget>(
                      (item) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              param['menu_type'] = item;
                            });
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Checkbox(
                                  value: item == param['menu_type'],
                                  onChanged: (val) {
                                    setState(() {
                                      param['menu_type'] = item;
                                    });
                                    FocusScope.of(context).requestFocus(FocusNode());
                                  }),
                              Text('${item == '2' ? '卖家' : '买家'}'),
                            ],
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
            ),
          ),
          Input(
            label: '排序',
            require: true,
            onChanged: (val) {
              setState(() {
                param['menu_sort'] = val;
              });
              FocusScope.of(context).requestFocus(FocusNode());
            },
            value: param['menu_sort'],
          ),
          Input(
            label: 'target',
            onChanged: (val) {
              setState(() {
                param['target'] = val;
              });
              FocusScope.of(context).requestFocus(FocusNode());
            },
            value: param['target'],
            marginTop: 8.0,
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10, top: 3),
                  child: Text('是否常用'),
                ),
                Expanded(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ['0', '1'].map<Widget>(
                      (item) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              param['if_head'] = item;
                            });
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Checkbox(
                                value: item == param['if_head'],
                                onChanged: (val) {
                                  setState(() {
                                    param['if_head'] = item;
                                  });
                                  FocusScope.of(context).requestFocus(FocusNode());
                                },
                              ),
                              Text('${item == '1' ? '是' : '否'}'),
                            ],
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
            ),
          ),
          Input(
            label: '备注',
            onChanged: (val) {
              setState(() {
                param['comments'] = val;
              });
              FocusScope.of(context).requestFocus(FocusNode());
            },
            value: param['comments'],
            maxLines: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              PrimaryButton(
                onPressed: save,
                child: Text('保存'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
