import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SiteMapModifyTwo extends StatefulWidget {
  final props;

  SiteMapModifyTwo(this.props);

  @override
  _SiteMapModifyTwoState createState() => _SiteMapModifyTwoState();
}

class _SiteMapModifyTwoState extends State<SiteMapModifyTwo> {
  BuildContext _context;
  ScrollController _controller;

  Map param = {};
  Map parentMenu = {};

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _context = context;
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
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 90,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Text('菜单图标'),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    style: TextStyle(fontSize: CFFontSize.content),
                    controller: TextEditingController.fromValue(TextEditingValue(
                      text: '${param['map_icon'] ?? ''}',
                      selection: TextSelection.fromPosition(
                        TextPosition(
                          affinity: TextAffinity.downstream,
                          offset: '${param['map_icon'] ?? ""}'.length,
                        ),
                      ),
                    )),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15,right: 15,)),
                    onChanged: (val) {
                      setState(() {
                        param['map_icon'] = val;
                      });
                    },
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
                  width: 90,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Text('菜单中文名'),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    style: TextStyle(fontSize: CFFontSize.content),
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: '${param['map_ch_name'] ?? ''}',
                        selection: TextSelection.fromPosition(
                          TextPosition(
                            affinity: TextAffinity.downstream,
                            offset: '${param['map_ch_name'] ?? ""}'.length,
                          ),
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
                        param['map_ch_name'] = val;
                      });
                    },
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
                  width: 90,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Text('菜单英文名'),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    style: TextStyle(fontSize: CFFontSize.content),
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: '${param['map_en_name'] ?? ''}',
                        selection: TextSelection.fromPosition(
                          TextPosition(
                            affinity: TextAffinity.downstream,
                            offset: '${param['map_en_name'] ?? ''}'.length,
                          ),
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
                        param['map_en_name'] = val;
                      });
                    },
                  ),
                )
              ],
            ),
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
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 90,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Text('排序'),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    style: TextStyle(fontSize: CFFontSize.content),
                    controller: TextEditingController.fromValue(TextEditingValue(
                      text: '${param['map_sort'] ?? ''}',
                      selection: TextSelection.fromPosition(
                        TextPosition(
                          affinity: TextAffinity.downstream,
                          offset: '${param['map_sort'] ?? ''}'.length,
                        ),
                      ),
                    )),
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
                        param['map_sort'] = val;
                      });
                    },
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
                  width: 90,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10),
                  child: Text('备注'),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    style: TextStyle(fontSize: CFFontSize.content),
                    maxLines: 4,
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: '${param['comments'] ?? ''}',
                        selection: TextSelection.fromPosition(
                          TextPosition(
                            affinity: TextAffinity.downstream,
                            offset: '${param['comments'] ?? ''}'.length,
                          ),
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
                        param['comments'] = val;
                      });
                    },
                  ),
                )
              ],
            ),
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
    );
  }
}
