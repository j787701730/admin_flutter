import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:admin_flutter/plugin/city_select_plugin.dart';
import 'package:admin_flutter/plugin/input.dart';
import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/shop/industry_supply_class_select.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ShopModify extends StatefulWidget {
  final props;

  ShopModify({this.props});

  @override
  _ShopModifyState createState() => _ShopModifyState();
}

class _ShopModifyState extends State<ShopModify> {
  BuildContext _context;
  double width;

  @override
  void initState() {
    super.initState();
    _context = context;
    Timer(Duration(milliseconds: 200), () {
      getIndustryClass();
      getSupplyClass();
      if (widget.props != null) {
        getData();
      }
    });
  }

  Map shopInfo = {};
  Map userRole = {};
  Map serviceType = {};
  List rolesList = [];
  List serviceTypeDisabled = [];
  Map shopAddress = {
    'province': null,
    'city': null,
    'region': null,
  };
  List industryClass = []; // 行业分类
  List selectIndustryClass = []; // 选择的行业分类
  Map industryClassData = {}; // 数据匹配用的
  List supplyClass = []; // 供应分类
  List selectSupplyClass = []; // 选择的供应分类
  Map supplyClassData = {}; // 数据匹配用的
  unFocus() {
    FocusScope.of(_context).requestFocus(FocusNode());
  }

  getData() {
    ajax('Adminrelas-Api-editShopShow-shopId-${widget.props['shop_id']}', {}, true, (data) {
      if (mounted) {
        List arr = [];
        for (var key in data['serviceType'].keys) {
          if (data['serviceType'][key]['check'] == '1') {
            arr.add(key);
          }
        }
        List arrRole = [];
        for (var key in data['userRole'].keys) {
          if ('${data['userRole'][key]['check']}' == '1') {
            arrRole.add(key);
          }
        }

        setState(() {
          shopInfo = data['data'];
          userRole = data['userRole'];
          rolesList = arrRole;
          serviceType = data['serviceType'];
          shopAddress = {
            'province': data['data']['shop_province'],
            'city': data['data']['shop_city'],
            'region': data['data']['shop_region'],
          };
          serviceTypeDisabled = arr;
          if (data['data']['supply_class'] != null) {
            for (var o in data['data']['supply_class'].keys.toList()) {
              for (var d in data['data']['supply_class'][o]) {
                selectSupplyClass.add(d['class_id']);
              }
            }
          }
          if (data['data']['industry_class'] != null) {
            for (var o in data['data']['industry_class'].keys.toList()) {
              for (var d in data['data']['industry_class'][o]) {
                selectIndustryClass.add(d['class_id']);
              }
            }
          }
        });
      }
    }, () {}, _context);
  }

  getIndustryClass() {
    ajax('Adminrelas-shopsManage-getIndustryClass', {}, true, (data) {
      if (mounted) {
        industryClass = data['data'];
        for (var o in data['data']) {
          industryClassData[o['class_id']] = {'class_name': o['class_name'], 'parent_class_id': o['parent_class_id']};
          if (o['children'] != '') {
            for (var p in o['children']) {
              industryClassData[p['class_id']] = {
                'class_name': p['class_name'],
                'parent_class_id': p['parent_class_id']
              };
            }
          }
        }
      }
    }, () {}, _context);
  }

  getSupplyClass() {
    ajax('Adminrelas-shopsManage-getSupplyClass', {}, true, (data) {
      if (mounted) {
        supplyClass = data['data'];
        for (var o in data['data']) {
          supplyClassData[o['class_id']] = {'class_name': o['class_name'], 'parent_class_id': o['parent_class_id']};
          if (o['children'] != '') {
            for (var p in o['children']) {
              supplyClassData[p['class_id']] = {'class_name': p['class_name'], 'parent_class_id': p['parent_class_id']};
            }
          }
        }
      }
    }, () {}, _context);
  }

  bool logoLoading = false;

  image2Base64(String path) async {
    File file = new File(path);
    List<int> imageBytes = await file.readAsBytes();

    setState(() {
      shopInfo['shop_logo'] = 'data:image/png;base64,${base64Encode(imageBytes)}';
    });

//    return 'data:image/png;base64,${base64Encode(imageBytes)}';
  }

  uploadShopLogo() async {
    setState(() {
      logoLoading = true;
    });
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      logoLoading = false;
    });
    if (image == null) return;

//    String filename = image.path.substring(image.path.lastIndexOf('/') + 1, image.path.length);
    image2Base64(image.path);
    // 压缩图片
//    final tempDir = await getTemporaryDirectory();
//    CompressObject compressObject = CompressObject(
//      imageFile: File(image.path), //image
//      path: tempDir.path, //compress to path
//      quality: 85, //first compress quality, default 80
//      step: 9, //compress quality step, The bigger the fast, Smaller is more accurate, default 6
////      mode: CompressMode.LARGE2SMALL,//default AUTO
//    );
//    Luban.compressImage(compressObject).then((_path) {
////        compressedFile = File(_path);
//      upload(_path, type, filename);
//    });
  }

  uploadShopPics() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    if (image == null) return;

    String filename = image.path.substring(image.path.lastIndexOf('/') + 1, image.path.length);
    FormData formData = FormData.fromMap(
      {'file': await MultipartFile.fromFile("${image.path}", filename: '$filename'), 'imgType': 'image'},
    );
    ajaxSimple('Adminrelas-ShopsManage-shopPic-shopID-${widget.props['shop_id']}', formData, (res) {
      if ('${res['err_code']}' == '0') {
        setState(() {
          shopInfo['shop_pics'].add(res['img']);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.props == null ? '新增店铺' : '${widget.props['shop_name']} 修改'),
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: <Widget>[
          Input(
            labelWidth: 100,
            label: '店铺名称',
            onChanged: (val) {
              setState(() {
                shopInfo['shop_name'] = val;
              });
            },
            value: shopInfo['shop_name'],
            require: true,
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 100,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10, top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '*',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('角色选择')
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Wrap(
                    children: userRole.keys.toList().map<Widget>(
                      (item) {
                        return Container(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (rolesList.contains(item)) {
                                  rolesList.remove(item);
                                } else {
                                  rolesList.add(item);
                                }
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Checkbox(
                                  value: rolesList.contains(item),
                                  onChanged: (val) {
                                    setState(() {
                                      if (rolesList.contains(item)) {
                                        rolesList.remove(item);
                                      } else {
                                        rolesList.add(item);
                                      }
                                    });
                                  },
                                ),
                                Text('${userRole[item]['role_ch_name']}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 100,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10, top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '*',
                        style: TextStyle(color: CFColors.danger),
                      ),
                      Text('服务提供')
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Wrap(
                    children: serviceType.keys.toList().map<Widget>(
                      (item) {
                        return Container(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (serviceTypeDisabled.indexOf(item) == -1) {
                                  serviceType[item]['check'] = serviceType[item]['check'] == '1' ? '0' : '1';
                                }
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Checkbox(
                                  value: serviceType[item]['check'] == '1',
                                  onChanged: (val) {
                                    setState(() {
                                      if (serviceTypeDisabled.indexOf(item) == -1) {
                                        serviceType[item]['check'] = serviceType[item]['check'] == '1' ? '0' : '1';
                                      }
                                    });
                                  },
                                  activeColor: serviceTypeDisabled.indexOf(item) > -1
                                      ? CFColors.secondary
                                      : Theme.of(context).toggleableActiveColor,
                                ),
                                Text('${serviceType[item]['service_type_ch_name']}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                )
              ],
            ),
          ),
          Input(
            label: '公司名称',
            labelWidth: 100,
            onChanged: (val) {
              setState(() {
                shopInfo['company_name'] = val;
              });
            },
            value: shopInfo['company_name'],
          ),
          Input(
            label: '纳税识别号',
            labelWidth: 100,
            onChanged: (val) {
              setState(() {
                shopInfo['tax_no'] = val;
              });
            },
            value: shopInfo['tax_no'],
          ),
          userRole.isNotEmpty
              ? Offstage(
                  offstage: !(rolesList.contains('101') || rolesList.contains('104') || rolesList.contains('105')),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 100,
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 10, top: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[Text('行业分类')],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(bottom: 10),
                                child: Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: selectIndustryClass.map<Widget>(
                                      (item) {
                                        String text = '';
                                        Map obj = industryClassData[item];
                                        if (obj['parent_class_id'] != '0') {
                                          text = '${industryClassData[obj['parent_class_id']]['class_name']}/'
                                              '${industryClassData[item]['class_name']}';
                                        }
                                        return Container(
                                          color: Colors.grey[300],
                                          padding: EdgeInsets.all(4),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(text),
                                              InkWell(
                                                child: Icon(
                                                  Icons.close,
                                                  size: 20,
                                                  color: CFColors.danger,
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    selectIndustryClass.remove(item);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ).toList()),
                              ),
                              PrimaryButton(
                                onPressed: () {
                                  Navigator.push(
                                    _context,
                                    MaterialPageRoute(
                                      builder: (context) => IndustryClassSelect(
                                        selectClass: selectIndustryClass,
                                        classData: industryClass,
                                        title: '行业分类',
                                      ),
                                    ),
                                  ).then((value) {
                                    if (value != null) {
                                      setState(() {
                                        selectIndustryClass = jsonDecode(jsonEncode(value));
                                      });
                                    }
                                  });
                                },
                                child: Text('添加'),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Container(),
          userRole.isNotEmpty
              ? Offstage(
                  offstage: !(!(rolesList.contains('101') && rolesList.length == 1) ||
                          rolesList.contains('102') ||
                          rolesList.contains('103') ||
                          rolesList.contains('104') ||
                          rolesList.contains('105')) ||
                      rolesList.isEmpty,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 100,
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 10, top: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[Text('供应分类')],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(bottom: 10),
                                child: Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: selectSupplyClass.map<Widget>(
                                    (item) {
                                      String text = '';
                                      Map obj = supplyClassData[item];
                                      if (obj['parent_class_id'] != '0') {
                                        text = '${supplyClassData[obj['parent_class_id']]['class_name']}/'
                                            '${supplyClassData[item]['class_name']}';
                                      }
                                      return Container(
                                        color: Colors.grey[300],
                                        padding: EdgeInsets.all(4),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(text),
                                            InkWell(
                                              child: Icon(
                                                Icons.close,
                                                size: 20,
                                                color: CFColors.danger,
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  selectSupplyClass.remove(item);
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                              PrimaryButton(
                                onPressed: () {
                                  Navigator.push(
                                    _context,
                                    MaterialPageRoute(
                                      builder: (context) => IndustryClassSelect(
                                        selectClass: selectSupplyClass,
                                        classData: supplyClass,
                                        title: '供应分类',
                                      ),
                                    ),
                                  ).then((value) {
                                    if (value != null) {
                                      setState(() {
                                        selectSupplyClass = jsonDecode(jsonEncode(value));
                                      });
                                    }
                                  });
                                },
                                child: Text('添加'),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Container(),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 100,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10, top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[Text('店铺图标')],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          uploadShopLogo();
                          unFocus();
                        },
                        child: Stack(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1),
                              ),
                              width: 80,
                              height: 80,
                              child: logoLoading
                                  ? CupertinoActivityIndicator()
                                  : shopInfo['shop_logo'] == '' || shopInfo['shop_logo'] == null
                                      ? Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                          size: 50,
                                        )
                                      : shopInfo['shop_logo'].split(',').length == 2
                                          ? Image.memory(
                                              base64Decode(shopInfo['shop_logo'].split(',')[1]),
                                              fit: BoxFit.contain,
                                            )
                                          : Image.network(
                                              '$baseUrl${shopInfo['shop_logo']}',
                                              fit: BoxFit.contain,
                                            ),
                            ),
                            Positioned(
                              right: 1,
                              bottom: 1,
                              child: InkWell(
                                onTap: () {
                                  unFocus();
                                  setState(() {
                                    shopInfo['shop_logo'] = '';
                                  });
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  color: Color(0xffeeeeee),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 100,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 10, top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[Text('店铺图片')],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      shopInfo['shop_pics'] == null
                          ? Container()
                          : Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: shopInfo['shop_pics'].map<Widget>(
                                (item) {
                                  return Stack(
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey, width: 1),
                                        ),
                                        width: 80,
                                        height: 80,
                                        child: Image.network(
                                          '$baseUrl$item',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      Positioned(
                                        right: 1,
                                        bottom: 1,
                                        child: InkWell(
                                          onTap: () {
                                            unFocus();
                                            setState(() {
                                              shopInfo['shop_pics'].remove(item);
                                            });
                                          },
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            color: Color(0xffeeeeee),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                },
                              ).toList(),
                            ),
                      Container(
                        height: 10,
                      ),
                      PrimaryButton(
                        onPressed: () {
                          uploadShopPics();
                          unFocus();
                        },
                        child: Text('添加图片'),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Input(
            label: '店铺简介',
            labelWidth: 100,
            onChanged: (val) {
              setState(() {
                shopInfo['shop_desc'] = val;
              });
            },
            value: shopInfo['shop_desc'],
            maxLines: 6,
          ),
          CitySelectPlugin(
            getArea: (val) {
              shopAddress = jsonDecode(jsonEncode(val));
            },
            initArea: shopAddress,
            linkage: true,
            label: '联系地址',
            labelWidth: 100,
            require: true,
          ),
          Input(
            label: '详细地址',
            labelWidth: 100,
            onChanged: (val) {
              setState(() {
                shopInfo['shop_address'] = val;
              });
            },
            value: shopInfo['shop_address'],
            require: true,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              PrimaryButton(
                onPressed: () {},
                child: Text('确认修改'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
