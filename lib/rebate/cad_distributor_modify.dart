import 'dart:convert';
import 'dart:io';

import 'package:admin_flutter/primary_button.dart';
import 'package:admin_flutter/style.dart';
import 'package:admin_flutter/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_luban/flutter_luban.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CADDistributorModify extends StatefulWidget {
  final props;

  CADDistributorModify(this.props);

  @override
  _CADDistributorModifyState createState() => _CADDistributorModifyState();
}

class _CADDistributorModifyState extends State<CADDistributorModify> {
  Map data;
  BuildContext _context;
  bool picLoading = false;
  bool logoLoading = false;
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    _context = context;
    data = jsonDecode(jsonEncode(widget.props['item']));
    data['show_text'] = data['show_text'] ?? '';
    data['show_phone'] = data['show_phone'] ?? '';
    isChecked = widget.props['item']['if_show'] == '1';
  }

  @override
  void dispose() {
    super.dispose();
  }

  unFocus() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  getImage(type) async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    if (image == null) return;
    if (type == 'logo') {
      setState(() {
        logoLoading = true;
      });
    } else {
      setState(() {
        picLoading = true;
      });
    }
    String filename = image.path.substring(image.path.lastIndexOf('/') + 1, image.path.length);

    // 压缩图片
    final tempDir = await getTemporaryDirectory();
    CompressObject compressObject = CompressObject(
      imageFile: File(image.path), //image
      path: tempDir.path, //compress to path
      quality: 85, //first compress quality, default 80
      step: 9, //compress quality step, The bigger the fast, Smaller is more accurate, default 6
//      mode: CompressMode.LARGE2SMALL,//default AUTO
    );
    Luban.compressImage(compressObject).then((_path) {
//        compressedFile = File(_path);
      upload(_path, type, filename);
    });
  }

  upload(_path, type, filename) async {
    FormData formData = FormData.fromMap(
      {'file': await MultipartFile.fromFile("$_path", filename: '$filename'), 'imgType': '$type'},
    );
    ajaxSimple('Rebate-uploadWebCadImg', formData, (res) {
      if ('${res['err_code']}' == '0') {
        if (type == 'logo') {
          setState(() {
            data['show_logo'] = res['images']['path'];
          });
        } else {
          setState(() {
            data['show_pic'] = res['images']['path'];
          });
        }
      }
      if (type == 'logo') {
        setState(() {
          logoLoading = false;
        });
      } else {
        setState(() {
          picLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.props['item']['login_name']}(${widget.props['item']['user_phone']}) 修改'),
      ),
      body: GestureDetector(
        onTap: () {
          unFocus();
        },
        behavior: HitTestBehavior.opaque,
        child: ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 80,
                    alignment: Alignment.centerRight,
                    child: Text('开通费用:'),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      style: TextStyle(fontSize: CFFontSize.content),
                      controller: TextEditingController.fromValue(TextEditingValue(
                        text: '${data['amount']}',
                        selection: TextSelection.fromPosition(
                          TextPosition(
                            affinity: TextAffinity.downstream,
                            offset: '${data['amount']}'.length,
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
                      onChanged: (String val) {
                        setState(() {
                          data['amount'] = val;
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
                    width: 80,
                    alignment: Alignment.centerRight,
                    child: Text('是否展示:'),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                          value: data['if_show'] == '1',
                          onChanged: (val) {
                            unFocus();
                            setState(() {
                              data['if_show'] = val ? '1' : '0';
                            });
                          },
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
                    width: 80,
                    alignment: Alignment.centerRight,
                    child: Column(
                      children: <Widget>[
                        Text('是否logo:'),
                        Text(
                          '50X50像素',
                          style: TextStyle(fontSize: 10, color: Colors.red),
                        )
                      ],
                    ),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            getImage('logo');
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
                                    : data['show_logo'] == '' || data['show_logo'] == null
                                        ? Icon(
                                            Icons.image,
                                            color: Colors.grey,
                                            size: 50,
                                          )
                                        : Image.network(
                                            '$baseUrl${data['show_logo']}',
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
                                      data['show_logo'] = '';
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
                    padding: EdgeInsets.only(top: 12),
                    width: 80,
                    alignment: Alignment.centerRight,
                    child: RichText(
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(text: isChecked ? '* ' : '', style: TextStyle(color: Colors.red)),
                        TextSpan(text: '展示文字:')
                      ], style: TextStyle(color: Color(0xff333333))),
                    ),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextField(
                          style: TextStyle(fontSize: CFFontSize.content),
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text: '${data['show_text']}',
                              selection: TextSelection.fromPosition(
                                TextPosition(
                                  affinity: TextAffinity.downstream,
                                  offset: '${data['show_text']}'.length,
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
                              )),
                          onChanged: (String val) {
                            setState(() {
                              data['show_text'] = val;
                            });
                          },
                        ),
                        isChecked && (data['show_text'] == '' || data['show_text'] == null)
                            ? Text(
                                '展示文字不能为空',
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              )
                            : Container(
                                width: 0,
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
                    padding: EdgeInsets.only(top: 12),
                    width: 80,
                    alignment: Alignment.centerRight,
                    child: RichText(
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(text: isChecked ? '* ' : '', style: TextStyle(color: Colors.red)),
                        TextSpan(text: '展示电话:')
                      ], style: TextStyle(color: Color(0xff333333))),
                    ),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextField(
                          style: TextStyle(fontSize: CFFontSize.content),
                          controller: TextEditingController.fromValue(TextEditingValue(
                            text: '${data['show_phone']}',
                            selection: TextSelection.fromPosition(
                              TextPosition(
                                affinity: TextAffinity.downstream,
                                offset: '${data['show_phone']}'.length,
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
                          onChanged: (String val) {
                            setState(() {
                              data['show_phone'] = val;
                            });
                          },
                        ),
                        isChecked && (data['show_phone'] == '' || data['show_phone'] == null)
                            ? Text(
                                '展示电话不能为空',
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              )
                            : Container(
                                width: 0,
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
                    width: 80,
                    alignment: Alignment.centerRight,
                    child: Column(
                      children: <Widget>[
                        RichText(
                          text: TextSpan(children: <TextSpan>[
                            TextSpan(text: isChecked ? '* ' : '', style: TextStyle(color: CFColors.danger)),
                            TextSpan(text: '展示图片:')
                          ], style: TextStyle(color: CFColors.text)),
                        ),
                        Text(
                          '600X200像素',
                          style: TextStyle(fontSize: 10, color: CFColors.danger),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                getImage('pic');
                                unFocus();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                ),
                                height: (width - 100) / 3,
                                width: width - 100,
                                child: picLoading
                                    ? CupertinoActivityIndicator()
                                    : data['show_pic'] == '' || data['show_pic'] == null
                                        ? Icon(
                                            Icons.image,
                                            size: width * 0.15,
                                            color: Colors.grey,
                                          )
                                        : Image.network('$baseUrl${data['show_pic']}'),
                              ),
                            ),
                            Positioned(
                              right: 1,
                              bottom: 1,
                              child: InkWell(
                                onTap: () {
                                  unFocus();
                                  setState(() {
                                    data['show_pic'] = '';
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
                        isChecked && (data['show_pic'] == '' || data['show_pic'] == null)
                            ? Text(
                                '展示图片不能为空',
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              )
                            : Container(
                                width: 0,
                              )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              alignment: Alignment.center,
              child: PrimaryButton(
                onPressed: () {
                  print(data);
                  unFocus();
                },
                child: Text('保存'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
