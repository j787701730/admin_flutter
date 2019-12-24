import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:flutter/material.dart';

class BoardCutConfigsModify extends StatefulWidget {
  final props;

  BoardCutConfigsModify(this.props);

  @override
  _BoardCutConfigsModifyState createState() => _BoardCutConfigsModifyState();
}

class _BoardCutConfigsModifyState extends State<BoardCutConfigsModify> {
  Map param = {
    'type_id': '1',
    'if_charge': '0',
  };
  Map type = {
    "1": "机台配置",
    "2": "标签配置",
    "3": "样式配置",
    "4": "机器设备",
    "5": "新版机器设备",
  };
  Map ifCharge = {
    "1": "是",
    "0": "否",
  };

  @override
  void initState() {
    super.initState();
    if (widget.props != null) {
      param['config_name'] = widget.props['config_name'];
      param['type_id'] = widget.props['type_id'];
      param['brand'] = widget.props['brand'];
      param['version'] = widget.props['version'];
      param['config_json'] = widget.props['config_json'];
      param['comments'] = widget.props['comments'];
      param['if_charge'] = widget.props['if_charge'];
      param['sort'] = widget.props['sort'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.props == null ? "新增开料配置" : '${widget.props['config_name']} 开料配置修改',
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 100,
                  margin: EdgeInsets.only(right: 10),
                  alignment: Alignment.centerRight,
                  height: 34,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('配置名称'),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 34,
                    child: TextField(
                      style: TextStyle(fontSize: CFFontSize.content),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: '${param['config_name'] ?? ''}',
                          selection: TextSelection.fromPosition(
                            TextPosition(
                              affinity: TextAffinity.downstream,
                              offset: '${param['config_name'] ?? ''}'.length,
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
                          param['config_name'] = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Select(
            labelWidth: 100,
            selectOptions: type,
            selectedValue: param['type_id'],
            label: '配置类型',
            onChanged: (val) {
              setState(() {
                param['type_id'] = val;
              });
            },
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 100,
                  margin: EdgeInsets.only(right: 10),
                  alignment: Alignment.centerRight,
                  height: 34,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('品牌'),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 34,
                    child: TextField(
                      style: TextStyle(fontSize: CFFontSize.content),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: '${param['brand'] ?? ''}',
                          selection: TextSelection.fromPosition(
                            TextPosition(affinity: TextAffinity.downstream, offset: '${param['brand'] ?? ''}'.length),
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
                          param['brand'] = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 100,
                  margin: EdgeInsets.only(right: 10),
                  alignment: Alignment.centerRight,
                  height: 34,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text('规格'),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 34,
                    child: TextField(
                      style: TextStyle(fontSize: CFFontSize.content),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: '${param['version'] ?? ''}',
                          selection: TextSelection.fromPosition(
                            TextPosition(affinity: TextAffinity.downstream, offset: '${param['version'] ?? ''}'.length),
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
                          param['version'] = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 100,
                  margin: EdgeInsets.only(right: 10),
                  alignment: Alignment.centerRight,
                  height: 34,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '* ',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('配置内容'),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: TextField(
                      maxLines: 4,
                      style: TextStyle(fontSize: CFFontSize.content),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: '${param['config_json'] ?? ''}',
                          selection: TextSelection.fromPosition(
                            TextPosition(
                                affinity: TextAffinity.downstream, offset: '${param['config_json'] ?? ''}'.length),
                          ),
                        ),
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                          left: 15,
                          right: 15,
                        ),
                      ),
                      onChanged: (String val) {
                        setState(() {
                          param['config_json'] = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 100,
                  margin: EdgeInsets.only(right: 10),
                  alignment: Alignment.centerRight,
                  height: 34,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text('备注'),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: TextField(
                      maxLines: 4,
                      style: TextStyle(fontSize: CFFontSize.content),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: '${param['comments'] ?? ''}',
                          selection: TextSelection.fromPosition(
                            TextPosition(
                                affinity: TextAffinity.downstream, offset: '${param['comments'] ?? ''}'.length),
                          ),
                        ),
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                          left: 15,
                          right: 15,
                        ),
                      ),
                      onChanged: (String val) {
                        setState(() {
                          param['comments'] = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Select(
            selectOptions: ifCharge,
            selectedValue: param['if_charge'],
            label: '是否收费',
            onChanged: (val) {
              setState(() {
                param['if_charge'] = val;
              });
            },
            labelWidth: 100,
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 100,
                  margin: EdgeInsets.only(right: 10),
                  alignment: Alignment.centerRight,
                  height: 34,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text('排序'),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 34,
                    child: TextField(
                      style: TextStyle(fontSize: CFFontSize.content),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: '${param['sort'] ?? ''}',
                          selection: TextSelection.fromPosition(
                            TextPosition(affinity: TextAffinity.downstream, offset: '${param['sort'] ?? ''}'.length),
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
                          param['sort'] = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 100,
                  margin: EdgeInsets.only(right: 10),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 34,
                        child: PrimaryButton(
                          onPressed: () {},
                          child: Text('保存'),
                        ),
                      ),
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
