import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/cf-provider.dart';
import 'package:admin_flutter/plugin/date_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/search-bar-plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RenderSoftwareList extends StatefulWidget {
  @override
  _RenderSoftwareListState createState() => _RenderSoftwareListState();
}

class _RenderSoftwareListState extends State<RenderSoftwareList> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 15};
  List ajaxData = [];
  int count = 0;
  bool loading = true;
  List selectModules = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Map type = {'0': '全部', "1": "模型", "2": "材质", "3": "户型"};

  void _onRefresh() {
    setState(() {
      param['curr_page'] = 1;
      getData(isRefresh: true);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _context = context;
    Timer(Duration(milliseconds: 200), () {
      getTree();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  List classTrees = [];
  String selectClassTree = '';
  String selectClassTreeName = '';
  String selectClassTreeLevel = '';

  recursionTreeData(list) {
    classTrees.add({
      'class_id': list['class_id'],
      'parent_class_id': list['parent_class_id'],
      'class_name': list['class_name'],
      'class_level': list['class_level'],
    });
    if (list['children'] != null && list['children'].isNotEmpty) {
      for (var o in list['children']) {
        recursionTreeData(o);
      }
    }
  }

  getTree() {
    ajax('Adminrelas-RenderSoftware-getRenderClass', {'params': 1}, true, (data) {
      if (mounted) {
        for (var value in data['data']) {
          recursionTreeData(value);
        }
        setState(() {
          classTrees = classTrees;
          selectClassTree = classTrees[0]['class_id'];
          selectClassTreeName = classTrees[0]['class_name'];
          selectClassTreeLevel = classTrees[0]['class_level'];
          buildNode();
          getData();
        });
      }
    }, () {}, _context);
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
        widgets.add(
          GestureDetector(
            child: Container(
              alignment: Alignment.centerLeft,
              width: double.infinity,
              height: 34,
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
                            param['class_id'] = node.nodeId;
                            getData();
                            Navigator.pop(context);
                          });
                        },
                        child: Container(
                          child: Text(
                            node.object.toString(),
                            style: TextStyle(
                                fontSize: 14,
                                color: selectClassTree == node.nodeId.toString() ? CFColors.primary : CFColors.text),
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
                  _collect(node.nodeId, node.classType);
                } else {
                  //之前是收起状态，扩展列表
                  node.expand = true;
                  _expand(node.nodeId, node.classType);
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
  void _expand(int id, int classType) {
    //保存到临时列表
    List<Node> tmp = new List();
    for (Node node in list) {
      if (node.fatherId == id && classType == node.classType) {
        tmp.add(node);
      }
    }
    //找到插入点
    int index = -1;
    int length = expand.length;
    for (int i = 0; i < length; i++) {
      if (id == expand[i].nodeId && classType == expand[i].classType) {
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
  void _collect(int id, int classType) {
    //清楚之前的标记
    mark.clear();
    //标记
    _mark(id, classType);
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
  void _mark(int id, int classType) {
    for (Node node in expand) {
      if (id == node.fatherId && classType == node.classType) {
        if (node.isHasChildren) {
          _mark(node.nodeId, node.classType);
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

  getData({isRefresh: false}) {
    setState(() {
      loading = true;
    });
    ajax('Adminrelas-RenderSoftware-getModules', {'param': jsonEncode(param)}, true, (res) {
      if (mounted) {
        setState(() {
          loading = false;
          ajaxData = res is Map ? res['data'] ?? [] : [];
          count = res is Map ? int.tryParse('${res['count'] ?? 0}') : 0;
          selectModules = [];
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
      duration: Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  getPage(page) {
    param['curr_page'] += page;
    getData();
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
            FlatButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
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
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(selectClassTreeName == '' ? '模型素材' : '$selectClassTreeName 模型素材'),
        leading: BackButton(),
      ),
      drawer: Container(
        width: width * 0.85,
        decoration: BoxDecoration(
          color: context.watch<CFProvider>().themeMode == ThemeMode.dark ? CFColors.dark : Colors.white,
        ),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
        child: ListView(
          children: <Widget>[
            classTrees.isEmpty
                ? CupertinoActivityIndicator()
                : Column(
                    children: _buildNode(expand),
                  )
          ],
        ),
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
            SearchBarPlugin(
              secondChild: Column(
                children: <Widget>[
                  Input(
                    label: '模型名称',
                    onChanged: (val) {
                      if (val == '') {
                        param.remove('name');
                      } else {
                        param['name'] = val;
                      }
                    },
                  ),
                  Select(
                    selectOptions: type,
                    selectedValue: param['type'] ?? '0',
                    label: '素材类型',
                    onChanged: (val) {
                      if (val == '0') {
                        param.remove('type');
                      } else {
                        param['type'] = val;
                      }
                    },
                  ),
                  DateSelectPlugin(
                    label: '创建时间',
                    onChanged: (val) {
                      if (val['min'] == null) {
                        param.remove('create_dateL');
                      } else {
                        param['create_dateL'] = val['min'].toString().substring(0, 10);
                      }
                      if (val['max'] == null) {
                        param.remove('create_dateU');
                      } else {
                        param['create_dateU'] = val['max'].toString().substring(0, 10);
                      }
                    },
                  ),
                  DateSelectPlugin(
                    label: '更新日期',
                    onChanged: (val) {
                      if (val['min'] == null) {
                        param.remove('update_dateL');
                      } else {
                        param['update_dateL'] = val['min'].toString().substring(0, 10);
                      }
                      if (val['max'] == null) {
                        param.remove('update_dateU');
                      } else {
                        param['update_dateU'] = val['max'].toString().substring(0, 10);
                      }
                    },
                  ),
                ],
              ),
            ),
            Container(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  PrimaryButton(
                    onPressed: () {
                      param['curr_page'] = 1;
                      getData();
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text('搜索'),
                  ),
                  PrimaryButton(
                    onPressed: () {
                      _scaffoldKey.currentState.openDrawer();
                    },
                    child: Text('模型目录'),
                  ),
                  PrimaryButton(
                    type: BtnType.primary,
                    onPressed: () {
                      print(selectModules);
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text('批量删除'),
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: 10),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 6),
              alignment: Alignment.centerRight,
              child: NumberBar(count: count),
            ),
            loading
                ? Container(
                    alignment: Alignment.center,
                    child: CupertinoActivityIndicator(),
                  )
                : Container(
                    child: ajaxData.isEmpty
                        ? Container(
                            alignment: Alignment.center,
                            child: Text('无数据'),
                          )
                        : Container(
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: ajaxData.map<Widget>((item) {
                                double w = (width - 20) / 2 - 5;
                                return Container(
                                  width: w,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(0xffeeeeee),
                                    ),
                                  ),
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Stack(
                                        children: <Widget>[
                                          Container(
                                            width: w,
                                            height: w,
                                            child: Image.network(
                                              '$baseUrl/${item['logo']}',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          Positioned(
                                            left: 1,
                                            top: 1,
                                            child: Checkbox(
                                              value: selectModules.contains(item['module_id']),
                                              onChanged: (val) {
                                                setState(() {
                                                  if (selectModules.contains(item['module_id'])) {
                                                    selectModules.remove(item['module_id']);
                                                  } else {
                                                    selectModules.add(item['module_id']);
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(
                                          '${item['name']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(
                                          '文件大小: ${fileFormatSize(item['size'])}',
                                          style: TextStyle(
                                            color: CFColors.secondary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(
                                          '文件版本: ${item['version']}',
                                          style: TextStyle(
                                            color: CFColors.secondary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(
                                          '素材类型: ${type[item['type']]}',
                                          style: TextStyle(
                                            color: CFColors.secondary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(
                                          '创建时间: ${item['create_date']}',
                                          style: TextStyle(
                                            color: CFColors.secondary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(bottom: 6),
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(
                                          '更新时间: ${item['update_date']}',
                                          style: TextStyle(
                                            color: CFColors.secondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                  ),
            Container(
              child: PagePlugin(
                current: param['curr_page'],
                total: count,
                pageSize: param['page_count'],
                function: getPage,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CFFloatingActionButton(
        onPressed: toTop,
        child: Icon(Icons.keyboard_arrow_up),
      ),
    );
  }
}

class Node<T> {
  bool expand; //是否展开
  int depth; //深度
  int nodeId; //id
  int fatherId; //父类id
  int classType; //父类id
  T object; //
  bool isHasChildren; //是否有孩子节点

  Node(this.expand, this.depth, this.nodeId, this.fatherId, this.object, this.isHasChildren);
}
