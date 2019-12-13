import 'dart:async';

import 'package:admin_flutter/goods/class_attribute.dart';
import 'package:admin_flutter/goods/goods_class_data.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class GoodsClass extends StatefulWidget {
  @override
  _GoodsClassState createState() => _GoodsClassState();
}

class _GoodsClassState extends State<GoodsClass> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  List ajaxData = [1];

  void _onRefresh() async {
    setState(() {
      getData(isRefresh: true);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _context = context;
    Timer(Duration(milliseconds: 200), () {
//      getData();
      buildNode();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getData({isRefresh: false}) async {
    ajax('Adminrelas-GoodsConfig-getGClassMenu', {}, true, (res) {
      if (mounted) {
        setState(() {
          ajaxData = res['data'];
          toTop();
        });
        if (isRefresh) {
          _refreshController.refreshCompleted();
        }
      }
    }, () {}, _context);
  }

  toTop() {
    _controller.animateTo(
      0,
      duration: new Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  List<Node> expand = new List();

  ///保存所有数据的List
  List<Node> list = new List();
  List<int> mark = new List();

  ///构建元素
  List<Widget> _buildNode(List<Node> nodes) {
//    print('buildNode:' + nodes.length.toString());
    List<Widget> widgets = List();
    if (nodes != null && nodes.length > 0) {
      for (Node node in nodes) {
        widgets.add(GestureDetector(
          child: ImageText(24.0 * (node.depth - 1), node.object.toString(), node.expand, node.isHasChildren, node),
          onTap: () {
            if (node.isHasChildren) {
              if (node.expand) {
                //之前是扩展状态，收起列表
                node.expand = false;
                _collect(node.nodeId);
              } else {
                //之前是收起状态，扩展列表
                node.expand = true;
                _expand(node.nodeId);
              }
              setState(() {});
            }
          },
        ));
      }
    }
    return widgets;
  }

  ///第一个节点的index
  int nodeId = 1;

  ///扩展机构树：id代表被点击的机构id
  /// 做法是遍历整个list列表，将直接挂在该机构下面的节点增加到一个临时列表中，
  ///然后将临时列表插入到被点击的机构下面
  void _expand(int id) {
    //保存到临时列表
    List<Node> tmp = new List();
    for (Node node in list) {
      if (node.fatherId == id) {
        tmp.add(node);
      }
    }
    //找到插入点
    int index = -1;
    int length = expand.length;
    for (int i = 0; i < length; i++) {
      if (id == expand[i].nodeId) {
        index = i + 1;
        break;
      }
    }
    //插入
    expand.insertAll(index, tmp);
  }

  ///收起机构树：id代表被点击的机构id
  /// 做法是遍历整个expand列表，将直接和间接挂在该机构下面的节点标记，
  ///将这些被标记节点删除即可，此处用到的是将没有被标记的节点加入到新的列表中
  void _collect(int id) {
    //清楚之前的标记
    mark.clear();
    //标记
    _mark(id);
    //重新对expand赋值
    List<Node> tmp = new List();
    for (Node node in expand) {
      if (mark.indexOf(node.nodeId) < 0) {
        tmp.add(node);
      } else {
        node.expand = false;
      }
    }
    expand.clear();
    expand.addAll(tmp);
    setState(() {});
  }

  ///标记，在收起机构树的时候用到
  void _mark(int id) {
    for (Node node in expand) {
      if (id == node.fatherId) {
        if (node.isHasChildren) {
          _mark(node.nodeId);
        }
        mark.add(node.nodeId);
      }
    }
  }

  void buildNode() {
    for (var o in goodsClassData) {
      //this.expand, this.depth, this.nodeId, this.fatherId, this.object, this.isHasChildren
      bool flag = false;
      for (var oo in goodsClassData) {
        if (oo['parent_class_id'] == o['class_id']) {
          flag = true;
          break;
        }
      }

      Node<String> node = new Node(false, int.parse(o['class_level']), int.parse(o['class_id']),
          int.parse(o['parent_class_id']), o['class_name'], flag);
      if (o['class_level'] == '1') {
        expand.add(node);
      }
      list.add(node);
    }
    setState(() {});
//    print('创建数据：' + expand.length.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('商品类目'),
      ),
      body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
//          onLoading: _onLoading,
          child: ListView(
            controller: _controller,
            padding: EdgeInsets.all(10),
            children: <Widget>[
              ajaxData.isEmpty
                  ? CupertinoActivityIndicator()
                  : Column(
                      children: _buildNode(expand),
                    )
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: toTop,
        child: Icon(Icons.keyboard_arrow_up),
      ),
    );
  }
}

class ImageText extends StatelessWidget {
  double margin = 0;
  String str = '';
  bool isExpand = false;
  bool isHasChildren = false;
  Node node;

  ImageText(double margin, String str, bool isExpand, bool isHasChildren, node) {
    this.margin = margin;
    this.str = str;
    this.isExpand = isExpand;
    this.isHasChildren = isHasChildren;
    this.node = node;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      width: double.infinity,
      height: 34,
      margin: EdgeInsets.only(left: margin),
      child: Row(
        children: <Widget>[
          Visibility(
            visible: isHasChildren,
            child: Icon(
              isExpand ? Icons.remove : Icons.add,
              color: Colors.blue,
            ),
          ),
          Container(
            width: isHasChildren ? 0 : 20,
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new ClassAttribute({'classID': node.nodeId, 'className': node.object})),
                );
              },
              child: Text(
                str,
                style: TextStyle(fontSize: 14),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Node<T> {
  bool expand; //是否展开
  int depth; //深度

  int nodeId; //id
  int fatherId; //父类id
  T object; //
  bool isHasChildren; //是否有孩子节点

  Node(this.expand, this.depth, this.nodeId, this.fatherId, this.object, this.isHasChildren);
}
