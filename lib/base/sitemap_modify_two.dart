import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SiteMapModifyTwo extends StatefulWidget {
  final props;

  SiteMapModifyTwo(this.props);

  @override
  _SiteMapModifyTwoState createState() => _SiteMapModifyTwoState();
}

class _SiteMapModifyTwoState extends State<SiteMapModifyTwo> {
  ScrollController _controller;

  Map param = {};
  Map parentMenu = {};

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
        'parent_map_id': widget.props['item']['pmid'],
        'map_icon': widget.props['item']['mio'],
      };

      for (var o in widget.props['data']) {
        parentMenu[o['mid']] = o['mnm'];
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
        title: Text(widget.props == null ? '添加二级菜单' : '${widget.props['item']['mnm']} 修改'),
      ),
      body: ListView(
        controller: _controller,
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Input(
            label: '菜单图标',
            onChanged: (val) => param['map_icon'] = val,
            value: param['map_icon'],
            labelWidth: 90,
          ),
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
            labelWidth: 90,
            onChanged: (String newValue) {
              setState(() {
                param['parent_map_id'] = newValue;
              });
            },
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
