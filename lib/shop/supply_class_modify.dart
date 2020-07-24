import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:flutter/material.dart';

class SupplyClassModify extends StatefulWidget {
  final props;

  SupplyClassModify(this.props);

  @override
  _SupplyClassModifyState createState() => _SupplyClassModifyState();
}

class _SupplyClassModifyState extends State<SupplyClassModify> {
  Map param = {};

  @override
  void initState() {
    super.initState();
    if (widget.props['item'] != null) {
      param = widget.props['item'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.props['item'] == null ? '新增供应商分类' : '${widget.props['item']['goods-class-name']} 修改'),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Select(
            selectOptions: widget.props['industryClass'],
            selectedValue: param['parent-class'] ?? '0',
            label: '上级分类',
            onChanged: (String newValue) {
              setState(() {
                param['parent-class'] = newValue;
              });
            },
            labelWidth: 90,
          ),
          Input(
            labelWidth: 90,
            label: '分类名称',
            require: true,
            onChanged: (val) {
              param['goods-class-name'] = val;
            },
            value: param['goods-class-name'] ?? '',
          ),
          Input(
            labelWidth: 90,
            label: '分类排序',
            require: true,
            onChanged: (val) {
              param['class-sort'] = val;
            },
            value: param['class-sort'] ?? '',
          ),
          Input(
            labelWidth: 90,
            label: '备注',
            require: true,
            onChanged: (val) {
              param['class-comment'] = val;
            },
            value: param['class-comment'] ?? '',
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
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      PrimaryButton(
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          print(param);
                        },
                        child: Text('确认提交'),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
