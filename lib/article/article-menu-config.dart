import 'dart:async';

import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ArticleMenuConfig extends StatefulWidget {
  @override
  _ArticleMenuConfigState createState() => _ArticleMenuConfigState();
}

class _ArticleMenuConfigState extends State<ArticleMenuConfig> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  List ajaxData = [];
  bool loading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _onRefresh() {
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
      getData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  int selectMenuIndex = 0;
  List menu = [
    {'typeId': '1', 'name': '帮助中心', 'level': '2'},
    {'typeId': '3', 'name': '视频专辑', 'level': '2'},
    {'typeId': '4', 'name': '知识库', 'level': '2'},
    {'typeId': '5', 'name': '软件教程', 'level': '3'},
    {'typeId': '6', 'name': '装修教程', 'level': '3'},
    {'typeId': '7', 'name': '软件功能介绍', 'level': '2'},
    {'typeId': '8', 'name': '装修中心', 'level': '2'},
  ];
  List classTrees = [];
  String selectClassTree = '';
  String selectClassTreeName = '';
  String selectClassTreeLevel = '';

  recursionTreeData(list) {
    classTrees.add({
      'class_id': list['class_id'],
      'parent_class_id': list['parent_class_id'],
      'class_name': list['class_name'],
      'class_level': '${list['level'] + 1}',
      'class_type': '${list['class_type']}',
    });
    if (list['children'] != null && list['children'].isNotEmpty) {
      for (var o in list['children']) {
        recursionTreeData(o);
      }
    }
  }

  List<Node> expand = new List();

  ///保存所有数据的List
  List<Node> list = new List();
  List<int> mark = new List();

  getData({isRefresh: false}) {
    setState(() {
      loading = true;
    });

    ajax(
      'Adminrelas-ArticleManage-ajaxGetNavTree',
      {'classTypeId': menu[selectMenuIndex]['typeId']},
      true,
      (res) {
        if (mounted) {
          classTrees = [];
          expand = new List();
          list = new List();
          mark = new List();
          nodeId = 1;
          for (var value in res['data']) {
            recursionTreeData(value);
          }
          setState(() {
            loading = false;
            selectClassTree = classTrees[0]['class_id'];
            selectClassTreeName = classTrees[0]['class_name'];
            selectClassTreeLevel = classTrees[0]['class_level'];
            buildNode();
            toTop();
          });
          if (isRefresh) {
            _refreshController.refreshCompleted();
          }
        }
      },
      () {},
      _context,
    );
  }

  ///构建元素
  List<Widget> _buildNode(List<Node> nodes) {
    List<Widget> widgets = List();
    if (nodes != null && nodes.length > 0) {
      for (Node node in nodes) {
        widgets.add(
          GestureDetector(
            child: Container(
              alignment: Alignment.centerLeft,
              width: double.infinity,
              height: 44,
              margin: EdgeInsets.only(left: 24.0 * (node.depth - 1)),
              child: Row(
                children: <Widget>[
                  Visibility(
                    visible: node.isHasChildren,
                    child: Icon(
                      node.expand ? Icons.remove : Icons.add,
                      color: Colors.blue,
                    ),
                  ),
                  Container(
                    width: node.isHasChildren ? 0 : 20,
                  ),
                  Expanded(
                    flex: 1,
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectClassTree = node.nodeId.toString();
                            selectClassTreeName = node.object.toString();
                            selectClassTreeLevel = '${node.depth}';
//                            getData();
//                            Navigator.pop(context);
                          });
                        },
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Text(
                                node.object.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: selectClassTree == node.nodeId.toString() ? CFColors.primary : CFColors.text,
                                ),
                              ),
                              menu[selectMenuIndex]['level'] == null ||
                                      node.depth == int.parse(menu[selectMenuIndex]['level'])
                                  ? Container()
                                  : Container(
                                      margin: EdgeInsets.only(left: 10),
                                      child: PrimaryButton(
                                        onPressed: () {},
                                        child: Text('添加子分类'),
                                      ),
                                    ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 10,
                  ),
                ],
              ),
            ),
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
          ),
        );
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
    for (var o in classTrees) {
      //this.expand, this.depth, this.nodeId, this.fatherId, this.object, this.isHasChildren
      bool flag = false;
      for (var oo in classTrees) {
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
  }

  toTop() {
    _controller.animateTo(
      0,
      duration: Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  stateDialog(data, {del = false}) {
    String text = '确认修改 ${data['article_topic']} 状态为 ${data['state'] == '1' ? '保存到草稿箱' : '发布'} ?';
    if (del) {
      text = '确认删除 ${data['article_topic']} ?';
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '提示',
          ),
          content: SingleChildScrollView(
            child: Container(
//                width: MediaQuery.of(context).size.width - 100,
              child: Text(
                text,
                style: TextStyle(fontSize: CFFontSize.content),
              ),
            ),
          ),
          actions: <Widget>[
            PrimaryButton(
              type: BtnType.Default,
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            PrimaryButton(
              child: Text('提交'),
              onPressed: () {
                ajax(
                    'Adminrelas-ArticleManage-articlestate',
                    {'state': del ? '0' : data['state'] == '1' ? '2' : '1', 'articleid': data['article_id']},
                    true, (data) {
                  getData();
                  Navigator.of(context).pop();
                }, () {}, _context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
//    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('栏目管理'),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        // onLoading: _onLoading,
        child: ListView(
          controller: _controller,
          padding: EdgeInsets.all(10),
          children: <Widget>[
            Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CFColors.secondary,
                  ),
                ),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: menu.map<Widget>(
                  (item) {
                    int index = menu.indexOf(item);
                    return InkWell(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: selectMenuIndex == index ? CFColors.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                              '${item['name']}',
                              style: TextStyle(
                                color: selectMenuIndex == index ? CFColors.primary : CFColors.text,
                              ),
                            ),
                            selectMenuIndex == index
                                ? IconButton(
                                    color: CFColors.primary,
                                    iconSize: 20,
                                    icon: Icon(Icons.mode_edit),
                                    onPressed: () {},
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectMenuIndex = index;
                          getData();
                        });
                      },
                    );
                  },
                ).toList(),
              ),
            ),
            loading
                ? Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: CupertinoActivityIndicator(),
                  )
                : classTrees.isEmpty
                    ? Container(
                        alignment: Alignment.center,
                        child: Text('无数据'),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: PrimaryButton(
                              onPressed: () {},
                              child: Text('添加分类'),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 10),
                          ),
                          Column(
                            children: _buildNode(expand),
                          )
                        ],
                      ),
          ],
        ),
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

class Node<T> {
  bool expand; //是否展开
  int depth; //深度
  int nodeId; //id
  int fatherId; //父类id
  T object; //
  bool isHasChildren; //是否有孩子节点

  Node(this.expand, this.depth, this.nodeId, this.fatherId, this.object, this.isHasChildren);
}
