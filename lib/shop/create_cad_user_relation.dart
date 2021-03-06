import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/plugin/shop_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:flutter/material.dart';

class CreateCadUserRelation extends StatefulWidget {
  final props;

  CreateCadUserRelation(this.props);

  @override
  _CreateCadUserRelationState createState() => _CreateCadUserRelationState();
}

class _CreateCadUserRelationState extends State<CreateCadUserRelation> {
  Map param = {'a-shops': {}, 'z-shops': {}};
  Map ifDefault = {'1': '默认', '0': '非默认'};

  @override
  void initState() {
    super.initState();
    if (widget.props != null) {
      param = {
        'a-shops': {
          '${widget.props['item']['a_shop_id']}': {
            'shop_id': '${widget.props['item']['a_shop_id']}',
            'shop_name': '${widget.props['item']['a_shop_name']}',
          }
        },
        'z-shops': {
          '${widget.props['item']['z_shop_id']}': {
            'shop_id': '${widget.props['item']['z_shop_id']}',
            'shop_name': '${widget.props['item']['z_shop_name']}',
          }
        },
        'if_default': '${widget.props['item']['if_default']}',
        'comments': '${widget.props['item']['comments']}',
        'eff_date': '${widget.props['item']['eff_date']}',
        'exp_date': '${widget.props['item']['exp_date']}',
      };
    }
  }

  getDateTime(val) {
    if (val['min'] == null) {
      param.remove('eff_date');
    } else {
      param['eff_date'] = val['min'].toString().substring(0, 10);
    }
    if (val['max'] == null) {
      param.remove('exp_date');
    } else {
      param['exp_date'] = val['max'].toString().substring(0, 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props == null ? '新增CAD用户关系' : '${widget.props['item']['a_shop_name']} 修改'}'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 90,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('发送方店铺')
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    padding: EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
                    height: 34,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: param['a-shops'].keys.toList().map<Widget>((key) {
                        return Container(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(right: 20),
                                child: Text(
                                  '${param['a-shops'][key]['shop_name']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              widget.props == null
                                  ? Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        color: Color(0xffeeeeee),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              param['a-shops'].remove(key);
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
                                  : Container(
                                      width: 0,
                                    )
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                widget.props == null
                    ? Container(
                        width: 70,
                        child: PrimaryButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShopPlugin(
                                  shopCount: 1,
                                  selectShopsData: param['a-shops'],
                                ),
                              ),
                            ).then((val) {
                              if (val != null) {
                                param['a-shops'] = val;
                              }
                            });
                          },
                          child: Text('店铺'),
                        ),
                      )
                    : Container(
                        width: 0,
                      )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 90,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('接收方店铺')
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    padding: EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    height: widget.props == null ? 340 : 50,
                    child: ListView(
                      children: <Widget>[
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: param['z-shops'].keys.toList().map<Widget>((key) {
                            return Container(
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(right: 20),
                                    child: Text(
                                      '${param['z-shops'][key]['shop_name']}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  widget.props == null
                                      ? Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            color: Color(0xffeeeeee),
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  param['z-shops'].remove(key);
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
                                      : Container(
                                          width: 0,
                                        )
                                ],
                              ),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  ),
                ),
                widget.props == null
                    ? Container(
                        width: 70,
                        child: PrimaryButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShopPlugin(
                                  shopCount: 0,
                                  selectShopsData: param['z-shops'],
                                ),
                              ),
                            ).then((val) {
                              if (val != null) {
                                param['z-shops'] = val;
                              }
                            });
                          },
                          child: Text('店铺'),
                        ),
                      )
                    : Container(
                        width: 0,
                      )
              ],
            ),
          ),
          DateSelectPlugin(
            onChanged: getDateTime,
            label: '有效时间',
            require: true,
            labelWidth: 90,
            min: param['eff_date'],
            max: param['exp_date'],
          ),
          Offstage(
            offstage: widget.props == null,
            child: Select(
                selectOptions: ifDefault,
                selectedValue: param['if_default'] ?? '1',
                label: '设置默认',
                labelWidth: 90,
                onChanged: (String newValue) {
                  setState(() {
                    if (newValue == 'all') {
                      param.remove('if_default');
                    } else {
                      param['if_default'] = newValue;
                    }
                  });
                }),
          ),
          Input(
            label: '备注',
            onChanged: (String val) {
              param['comments'] = val;
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
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: Wrap(
                    children: <Widget>[
                      PrimaryButton(
                        onPressed: () {
                          print(param);
                        },
                        child: Text('保存'),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
