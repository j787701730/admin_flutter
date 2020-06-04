import 'dart:async';
import 'dart:convert';

import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/plugin/number_bar.dart';
import 'package:admin_flutter/plugin/page_plugin.dart';
import 'package:admin_flutter/plugin/select.dart';
import 'package:admin_flutter/plugin/user_plugin.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 充值卡
class ChargeCard extends StatefulWidget {
  @override
  _ChargeCardState createState() => _ChargeCardState();
}

class _ChargeCardState extends State<ChargeCard> {
  BuildContext _context;
  ScrollController _controller;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map param = {"curr_page": 1, "page_count": 20, 'param': {}};
  List ajaxData = [];
  int count = 0;
  bool loading = false;

  List columns = [
    {'title': '卡号', 'key': 'card_no'},
    {'title': '密码', 'key': 'card_pass'},
    {'title': '面值', 'key': 'card_value'},
    {'title': '卡类型', 'key': 'card_type'},
    {'title': '创建人', 'key': 'make_user_name'},
    {'title': '创建时间', 'key': 'create_date'},
    {'title': '状态', 'key': 'state'},
    {'title': '拥有者', 'key': 'owner_user_name'},
    {'title': '使用时间', 'key': 'state_date'},
    {'title': '使用人', 'key': 'charge_user_name'},
    {'title': '操作', 'key': 'option'},
  ];

  Map state = {'': '全部', "0": "可用", "1": "已使用", "-1": "作废"};

  Map cardType = {
    "1": {
      "type_id": "1",
      "type_en_name": "CHARGE_CARD_TYPE_CF",
      "type_ch_name": "晨丰充值卡",
      "card_prefix": "CF",
      "balance_type": "[4]",
      "comments": ""
    }
  };

  Map cardValue = {
    "50": '50元面额',
    "100": '100元面额',
    "200": "200元面额",
    "500": "500元面额",
    "1000": "1000元面额",
  };

  Map selectCards = {};

  String selectCardValue = '50';
  String selectCardType = '1';
  String setCardCount = '';

  Map selectUser = {};

  void _onRefresh() async {
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
      getData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getData({isRefresh: false}) async {
    setState(() {
      loading = true;
    });
    if (param['param']['state'] == '') {
      param['param'].remove('state');
    }
    ajax(
        'Adminrelas-ChargeCard-cardlists',
        {'curr_page': param['curr_page'], 'page_count': param['page_count'], 'param': jsonEncode(param['param'])},
        true, (res) {
      if (mounted) {
        setState(() {
          ajaxData = res['data'];
          count = int.tryParse('${res['count'] ?? 0}');
          toTop();
          loading = false;
        });
        if (isRefresh) {
          _refreshController.refreshCompleted();
        }
      }
    }, () {
      setState(() {
        loading = false;
      });
    }, _context);
  }

  // 选中的充值卡
  cardCart() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: _context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context1, state) {
            /// 这里的state就是setState
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  color: Colors.white),
              padding: EdgeInsets.only(top: 20),
              height: MediaQuery.of(_context).size.height * 0.6,
              child: ListView(
                children: selectCards.keys.map<Widget>((key) {
                  return Container(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            flex: 1,
                            child: Text(
                              '${selectCards[key]['card_no']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                        InkWell(
                          onTap: () {
                            state(() {
                              selectCards.remove(key);
                            });
                            setState(() {
                              selectCards.remove(key);
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
          });
        });
  }

  toTop() {
    _controller.animateTo(
      0,
      duration: Duration(milliseconds: 300), // 300ms
      curve: Curves.bounceIn, // 动画方式
    );
  }

  getPage(page) {
    if (loading) return;
    param['curr_page'] += page;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('充值卡'),
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
            Input(
              label: '用户名',
              onChanged: (String val) {
                setState(() {
                  param['loginName'] = val;
                });
              },
            ),
            Select(
              selectOptions: state,
              selectedValue: param['param']['state'] ?? '',
              onChanged: (String newValue) {
                setState(() {
                  param['param']['state'] = newValue;
                });
              },
              label: '状态',
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  PrimaryButton(
                    onPressed: () {
                      setState(() {
                        param['curr_page'] = 1;
                        getData();
                      });
                    },
                    child: Text(
                      '搜索',
                    ),
                  ),
                  PrimaryButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false, // user must tap button!
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder: (context1, state) {
                            /// 这里的state就是setState
                            return AlertDialog(
                              title: Text(
                                '充值卡制作',
                              ),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Container(
                                      width: width - 100,
                                      margin: EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            width: 90,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              '卡类型:',
                                              style: TextStyle(fontSize: CFFontSize.content),
                                            ),
                                            margin: EdgeInsets.only(right: 10),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey),
                                                  borderRadius: BorderRadius.all(Radius.circular(4))),
                                              height: 34,
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                elevation: 1,
                                                underline: Container(),
                                                value: selectCardType,
                                                onChanged: (String newValue) {
                                                  setState(() {
                                                    selectCardType = newValue;
                                                  });

                                                  state(() {
                                                    selectCardType = newValue;
                                                  });
                                                },
                                                items: cardType.keys.toList().map<DropdownMenuItem<String>>((item) {
                                                  return DropdownMenuItem(
                                                    value: '$item',
                                                    child: Container(
                                                      padding: EdgeInsets.only(left: 10),
                                                      child: Text(
                                                        '${cardType[item]['type_ch_name']}',
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(fontSize: CFFontSize.content),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width - 100,
                                      child: Select(
                                        selectOptions: cardValue,
                                        selectedValue: selectCardValue,
                                        label: '面值类型:',
                                        onChanged: (String newValue) {
                                          setState(() {
                                            selectCardValue = newValue;
                                          });

                                          state(() {
                                            selectCardValue = newValue;
                                          });
                                        },
                                        labelWidth: 90,
                                      ),
                                    ),
                                    Container(
                                      width: width - 100,
                                      margin: EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            width: 90,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              '生成数量:',
                                              style: TextStyle(fontSize: CFFontSize.content),
                                            ),
                                            margin: EdgeInsets.only(right: 10),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              height: 34,
                                              child: TextField(
                                                style: TextStyle(fontSize: CFFontSize.content),
                                                controller: TextEditingController(text: setCardCount),
                                                decoration: InputDecoration(
                                                    border: OutlineInputBorder(),
                                                    contentPadding: EdgeInsets.only(
                                                      top: 6,
                                                      bottom: 6,
                                                      left: 15,
                                                      right: 15,
                                                    )),
                                                onChanged: (String val) {
                                                  setState(() {
                                                    setCardCount = val;
                                                  });
                                                },
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
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
                                    print([selectCardType, selectCardValue, setCardCount]);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          }); //
                        },
                      );
                    },
                    color: Colors.green,
                    child: Text(
                      '制作充值卡',
                    ),
                  ),
                  PrimaryButton(
                    onPressed: () {},
                    child: Text(
                      '批量激活',
                    ),
                  ),
                  PrimaryButton(
                    type: 'error',
                    onPressed: () {},
                    child: Text(
                      '批量作废',
                    ),
                  ),
                  PrimaryButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false, // user must tap button!
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (context1, state) {
                              /// 这里的state就是setState
                              return AlertDialog(
                                title: Text(
                                  '赠送充值卡',
                                ),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Container(
                                        width: width - 100,
                                        margin: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              width: 60,
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                '用户:',
                                                style: TextStyle(fontSize: CFFontSize.content),
                                              ),
                                              margin: EdgeInsets.only(right: 10),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                height: 30,
                                                alignment: Alignment.centerLeft,
                                                padding: EdgeInsets.only(left: 10, right: 10),
                                                decoration: BoxDecoration(
                                                    border: Border.all(color: Color(0xffdddddd), width: 1)),
                                                child: Wrap(
                                                  children: selectUser.keys.toList().map<Widget>((key) {
                                                    return Container(
                                                      child: Stack(
                                                        children: <Widget>[
                                                          Container(
                                                            padding: EdgeInsets.only(right: 20),
                                                            child: Text(
                                                              '${selectUser[key]['login_name']}',
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: 0,
                                                            right: 0,
                                                            child: Container(
                                                              color: Color(0xffeeeeee),
                                                              child: InkWell(
                                                                onTap: () {
                                                                  setState(() {
                                                                    selectUser.remove(key);
                                                                  });
                                                                },
                                                                child: Icon(
                                                                  Icons.clear,
                                                                  color: Colors.red,
                                                                  size: 20,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 10),
                                              child: PrimaryButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => UserPlugin(
                                                        userCount: 1,
                                                        selectUsersData: selectUser,
                                                      ),
                                                    ),
                                                  ).then((val) {
                                                    if (val != null) {
                                                      setState(() {
                                                        selectUser = jsonDecode(jsonEncode(val));
                                                      });
                                                      state(() {
                                                        selectUser = jsonDecode(jsonEncode(val));
                                                      });
                                                    }
                                                  });
                                                },
                                                child: Text('选择用户'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          ); //
                        },
                      );
                    },
                    child: Text(
                      '赠送充值卡',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 6),
              alignment: Alignment.centerRight,
              child: NumberBar(count: count),
            ),
            loading
                ? CupertinoActivityIndicator()
                : Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ajaxData.map<Widget>((item) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xffdddddd), width: 1),
                          ),
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: columns.map<Widget>((col) {
                              Widget con = Text('${item[col['key']] ?? ''}');
                              switch (col['key']) {
                                case 'state':
                                  con = Text('${state[item['state']]}');
                                  break;
                                case 'card_type':
                                  con = Text('${cardType[item['card_type']]['type_ch_name']}');
                                  break;
                                case 'option':
                                  if (item['state'] == '-1') {
                                    con = Row(
                                      children: <Widget>[
                                        PrimaryButton(
                                          onPressed: () {},
                                          child: Text('激活'),
                                          type: 'error',
                                        ),
                                      ],
                                    );
                                  } else if (item['state'] == '0') {
                                    con = Row(
                                      children: <Widget>[
                                        PrimaryButton(
                                          onPressed: () {},
                                          child: Text('作废'),
                                          type: 'error',
                                        ),
                                      ],
                                    );
                                  }
                                  break;
                              }

                              return Container(
                                margin: EdgeInsets.only(
                                  bottom: col['key'] == 'card_no' && item['state'] != '1' ? 0 : 6,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: 80,
                                      alignment: Alignment.centerRight,
                                      child: col['key'] == 'card_no' && item['state'] != '1'
                                          ? Row(
                                              children: <Widget>[
                                                Checkbox(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: selectCards[item['card_id']] != null,
                                                  onChanged: (val) {
                                                    if (selectCards[item['card_id']] == null) {
                                                      setState(() {
                                                        selectCards[item['card_id']] = jsonDecode(jsonEncode(item));
                                                      });
                                                    } else {
                                                      setState(() {
                                                        selectCards.remove(item['card_id']);
                                                      });
                                                    }
                                                  },
                                                ),
                                                Text('${col['title']}')
                                              ],
                                            )
                                          : Text('${col['title']}'),
                                      margin: EdgeInsets.only(right: 10),
                                    ),
                                    Expanded(flex: 1, child: con)
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
            Container(
              child: PagePlugin(
                current: param['curr_page'],
                total: count,
                pageSize: param['page_count'],
                function: getPage,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          CFFloatingActionButton(
            heroTag: 'card_cart',
            onPressed: () => cardCart(),
            child: Icon(Icons.add_shopping_cart),
          ),
          CFFloatingActionButton(
            heroTag: 'card_top',
            onPressed: toTop,
            child: Icon(Icons.keyboard_arrow_up),
          ),
        ],
      ),
    );
  }
}
