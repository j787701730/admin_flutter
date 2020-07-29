import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SiteMapModifyThree extends StatefulWidget {
  final props;

  SiteMapModifyThree(this.props);

  @override
  _SiteMapModifyThreeState createState() => _SiteMapModifyThreeState();
}

class _SiteMapModifyThreeState extends State<SiteMapModifyThree> {
  ScrollController _controller;

  Map param = {};
  Map parentMenu = {};
  Map mapType = {
    '0': "无热度",
    '1': "热搜",
    '2': "常用",
  };
  Map targetType = {'0': "当前页打开", '1': "新页面打开"};

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    if (widget.props != null) {
      param = {
        'map_ch_name': widget.props['item']['mnm'],
        'map_en_name': widget.props['item']['menm'],
        'map_sort': widget.props['item']['mst'],
        'comments': widget.props['item']['cm'],
        'map_type': widget.props['item']['map_type'],
        'target': widget.props['item']['tg'],
        'map_url': widget.props['item']['mul'],
        'parent_map_id': '${widget.props['pmid']}',
      };

      for (var o in widget.props['data']) {
        for (var oo in o['c']) {
          parentMenu['${oo['mid']}'] = oo['mnm'];
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  toTop() {
    _controller.animateTo(
      0,
      duration: new Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.props == null ? '添加三级菜单' : '${widget.props['item']['mnm']} 修改'),
      ),
      body: ListView(
        controller: _controller,
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Input(
            label: '菜单中文名',
            onChanged: (val) => param['map_ch_name'] = val,
            value: param['map_ch_name'],
            labelWidth: 90,
          ),
          Input(
            label: '菜单英文名',
            onChanged: (val) => param['map_en_name'] = val,
            value: param['map_en_name'],
            labelWidth: 90,
          ),
          Select(
            selectOptions: parentMenu,
            selectedValue: param['parent_map_id'] ?? '',
            label: '父菜单',
            onChanged: (String newValue) {
              setState(() {
                param['parent_map_id'] = newValue;
              });
            },
            labelWidth: 90,
          ),
          Input(
            label: '链接地址',
            onChanged: (val) => param['map_url'] = val,
            value: param['map_url'],
            labelWidth: 90,
          ),
          Select(
            selectOptions: mapType,
            selectedValue: param['map_type'] ?? '',
            label: '热度',
            onChanged: (String newValue) {
              setState(() {
                param['map_type'] = newValue;
              });
            },
            labelWidth: 90,
          ),
          Select(
            selectOptions: targetType,
            selectedValue: param['target'] ?? '',
            label: '打开方式',
            onChanged: (String newValue) {
              setState(() {
                param['target'] = newValue;
              });
            },
            labelWidth: 90,
          ),
          Input(
            label: '排序',
            onChanged: (val) => param['map_sort'] = val,
            value: param['map_sort'],
            labelWidth: 90,
          ),
          Input(
            label: '备注',
            onChanged: (val) => param['comments'] = val,
            value: param['comments'],
            labelWidth: 90,
            maxLines: 4,
            marginTop: 4,
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                PrimaryButton(
                  onPressed: () {
                    print(param);
                  },
                  child: Text('确认保存'),
                )
              ],
            ),
          )
        ],
      ),
      floatingActionButton: CFFloatingActionButton(
        onPressed: toTop,
        child: Icon(Icons.keyboard_arrow_up),
      ),
      floatingActionButtonAnimator: ScalingAnimation(),
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(
        FloatingActionButtonLocation.endFloat,
        floatingActionButtonOffsetX,
        floatingActionButtonOffsetY,
      ),
    );
  }
}
