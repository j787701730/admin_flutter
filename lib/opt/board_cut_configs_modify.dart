import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
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
          Input(
            label: '配置名称',
            require: true,
            onChanged: (val) {
              param['config_name'] = val;
            },
            value: '${param['config_name'] ?? ''}',
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
          Input(
            label: '品牌',
            require: true,
            onChanged: (val) {
              param['brand'] = val;
            },
            value: '${param['brand'] ?? ''}',
          ),
          Input(
            label: '规格',
            onChanged: (val) {
              param['version'] = val;
            },
            value: '${param['version'] ?? ''}',
          ),
          Input(
            label: '配置内容',
            require: true,
            onChanged: (val) {
              param['config_json'] = val;
            },
            value: '${param['config_json'] ?? ''}',
          ),
          Input(
            label: '备注',
            marginTop: 4.0,
            onChanged: (val) {
              param['comments'] = val;
            },
            value: '${param['comments'] ?? ''}',
            maxLines: 4,
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
          Input(
            label: '排序',
            onChanged: (val) {
              param['sort'] = val;
            },
            value: '${param['sort'] ?? ''}',
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
                      PrimaryButton(
                        onPressed: () {},
                        child: Text('保存'),
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
