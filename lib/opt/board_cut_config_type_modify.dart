import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:flutter/material.dart';

class BoardCutConfigTypeModify extends StatefulWidget {
  final props;

  BoardCutConfigTypeModify(this.props);

  @override
  _BoardCutConfigTypeModifyState createState() => _BoardCutConfigTypeModifyState();
}

class _BoardCutConfigTypeModifyState extends State<BoardCutConfigTypeModify> {
  Map param = {};

  @override
  void initState() {
    super.initState();
    if (widget.props != null) {
      param['type_ch_name'] = widget.props['type_ch_name'];
      param['type_en_name'] = widget.props['type_en_name'];
      param['comments'] = widget.props['comments'];
      param['sort'] = widget.props['sort'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.props == null ? "新增开料配置类型" : '${widget.props['type_ch_name']} 开料配置类型修改',
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Input(
            label: '类型中文名：',
            onChanged: (val) => param['type_ch_name'],
            require: true,
            value: param['type_ch_name'],
            labelWidth: 100,
          ),
          Input(
            label: '类型英文名：',
            onChanged: (val) => param['type_en_name'],
            require: true,
            value: param['type_en_name'],
            labelWidth: 100,
          ),
          Input(
            label: '备注：',
            onChanged: (val) => param['comments'],
            require: true,
            value: param['comments'],
            labelWidth: 100,
            maxLines: 4,
          ),
          Input(
            label: '排序：',
            onChanged: (val) => param['sort'],
            require: true,
            value: param['sort'],
            labelWidth: 100,
            maxLines: 4,
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 100,
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      Container(
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
