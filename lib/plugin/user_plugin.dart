import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserPlugin extends StatefulWidget {
  final userCount; // 0 无限选择, 1 单选, >1 限制个数选择
  final selectUsersData;

  UserPlugin({this.userCount, this.selectUsersData});

  @override
  _UserPluginState createState() => _UserPluginState(userCount, selectUsersData);
}

class _UserPluginState extends State<UserPlugin> {
  final userCount;
  final selectUsersData;

  _UserPluginState(this.userCount, this.selectUsersData);

  BuildContext _context;

  List shopsData = [];
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _context = context;
    fetchShop();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  int count = 0;

  Map param = {
    'pageCount': 10,
    'currPage': 1,
    'loginName': '',
    'userPhone': '',
    'province': '',
    'city': '',
    'region': '',
    'roleType': '',
    'userSex': '',
  };

  List columns = [
    {'title': '用户名', 'key': 'login_name'},
    {'title': '手机号', 'key': 'user_phone'},
    {'title': '真名', 'key': 'full_name'},
    {'title': '角色', 'key': 'user_role'},
    {'title': '地区', 'key': 'province_name'},
  ];

  fetchShop() async {
    ajax('Adminrelas-CrmSearch-fetchUser', param, true, (data) {
      if (mounted) {
        setState(() {
          shopsData = data['user'] ?? [];
          count = int.tryParse(data['userCount']);
          toTop();
        });
      }
    }, () {}, _context);
  }

  selectOrCancel(item) {
    FocusScope.of(context).requestFocus(FocusNode());
    if (userCount > 1 && selectUsersData.keys.length == userCount && !selectUsersData.keys.contains(item['user_id'])) {
      Fluttertoast.showToast(
        msg: '最多选择 $userCount 个用户',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    setState(() {
      if (selectUsersData.keys.contains(item['user_id'])) {
        selectUsersData.remove(item['user_id']);
      } else {
        if (userCount == 1) {
          selectUsersData.clear();
        }
        selectUsersData[item['user_id']] = item;
      }
    });
  }

  shopsBox() {
    showModalBottomSheet(
      context: _context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context1, state) {
            /// 这里的state就是setState
            return Container(
              height: MediaQuery.of(_context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.only(top: 20),
              child: ListView(
                children: selectUsersData.keys.map<Widget>((key) {
                  return Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 4,
                      bottom: 4,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${selectUsersData[key]['login_name']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            state(() {
                              selectUsersData.remove(key);
                            });
                            setState(() {
                              selectUsersData.remove(key);
                            });
                          },
                          child: Container(
                            width: 40,
                            child: Icon(Icons.close),
                          ),
                        )
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  toTop() {
    _controller.animateTo(
      0,
      duration: new Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  getPage(page) {
    param['currPage'] += page;
    fetchShop();
  }

  Map serviceType = {0: '全部', 101: '销售门店', 102: '供货商', 103: '加工工厂', 104: '设计师', 105: '工程施工', 106: '店铺员工'};

  Widget searchWidget() {
    return Column(
      children: <Widget>[
        Input(
          label: '用户名',
          onChanged: (String val) {
            setState(() {
              param['loginName'] = val;
            });
          },
        ),
        Input(
          label: '手机',
          onChanged: (String val) {
            setState(() {
              param['userPhone'] = val;
            });
          },
        ),
        Select(
          selectOptions: serviceType,
          selectedValue: param['roleType'] == '' ? '0' : param['roleType'],
          label: '角色类型',
          onChanged: (String newValue) {
            setState(() {
              param['roleType'] = newValue;
            });
          },
        ),
        Select(
          selectOptions: {'0': '全部', '1': '男', '2': '女'},
          selectedValue: param['userSex'] == '' ? '0' : param['userSex'],
          onChanged: (String newValue) {
            setState(() {
              param['userSex'] = newValue == '0' ? '' : newValue;
            });
          },
          label: '用户性别',
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
//    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('用户选择'),
      ),
      body: ListView(
        controller: _controller,
        padding: EdgeInsets.all(10),
        children: <Widget>[
          searchWidget(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              PrimaryButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  param['currPage'] = 1;
                  fetchShop();
                },
                child: Text('搜索'),
              ),
              Container(
                width: 10,
              ),
              PrimaryButton(
                onPressed: () {
                  Navigator.pop(context, selectUsersData);
                },
                child: Text('确定'),
              )
            ],
          ),
          Container(
            height: 10,
          ),
          Column(
            children: shopsData.map<Widget>((item) {
              return Container(
                margin: EdgeInsets.only(bottom: 15),
                child: InkWell(
                  onTap: () => selectOrCancel(item),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xffdddddd), width: 1),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Center(
                            child: userCount == 1
                                ? Radio(
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    value: item['user_id'],
                                    groupValue: selectUsersData.keys.isEmpty ? '' : selectUsersData.keys.toList()[0],
                                    onChanged: (val) => selectOrCancel(item),
                                  )
                                : Checkbox(
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    value: selectUsersData.keys.toList().indexOf(item['user_id']) != -1,
                                    onChanged: (val) => selectOrCancel(item),
                                  ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.only(left: 6, right: 6, top: 8, bottom: 8),
                            child: Column(
                              children: columns.map<Widget>((col) {
                                return Row(
                                  children: <Widget>[
                                    Container(
                                      width: 60,
                                      alignment: Alignment.centerRight,
                                      child: Text('${col['title']}'),
                                      margin: EdgeInsets.only(right: 10),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        child: col['key'] == 'area'
                                            ? Text(
                                                '${item['province_name']} ${item['city_name']} ${item['region_name']}')
                                            : Text(
                                                '${item[col['key']]}',
                                              ),
                                      ),
                                    )
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          Container(
            child: PagePlugin(
              current: param['currPage'],
              total: count,
              pageSize: param['pageCount'],
              function: getPage,
            ),
          )
        ],
      ),
      floatingActionButton: CFFloatingActionButton(
        child: Icon(Icons.add_shopping_cart),
        onPressed: () => shopsBox(),
      ),
    );
  }
}
