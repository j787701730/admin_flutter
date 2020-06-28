import 'package:admin_flutter/primary_button.dart';
import 'package:flutter/material.dart';

class IndustryClassSelect extends StatefulWidget {
  final selectClass;
  final classData;
  final title;

  IndustryClassSelect({this.selectClass, this.classData, this.title});

  @override
  _IndustryClassSelectState createState() => _IndustryClassSelectState();
}

class _IndustryClassSelectState extends State<IndustryClassSelect> {
  List openClass = [];

  classSelectAll(item, checked) {
    if (item['children'].length > 0) {
      for (var child in item['children']) {
        setState(() {
          if (checked) {
            widget.selectClass.remove(child['class_id']);
          } else {
            widget.selectClass.add(child['class_id']);
          }
        });
      }
    }
  }

  classSelectSingle(children) {
    setState(() {
      if (widget.selectClass.indexOf(children['class_id']) == -1) {
        widget.selectClass.add(children['class_id']);
      } else {
        widget.selectClass.remove(children['class_id']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              alignment: Alignment.center,
              child: PrimaryButton(
                onPressed: () {
                  Navigator.of(context).pop(widget.selectClass);
                },
                child: Text('添加'),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            bottom: 0,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              children: widget.classData.map<Widget>(
                (item) {
                  bool checked = true;
                  if (item['children'].length > 0) {
                    for (var child in item['children']) {
                      if (widget.selectClass.indexOf(child['class_id']) == -1) {
                        checked = false;
                      }
                    }
                  }
                  return Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                icon: Icon(openClass.indexOf(item['class_id']) > -1
                                    ? Icons.keyboard_arrow_down
                                    : Icons.keyboard_arrow_right),
                                onPressed: () {
                                  setState(() {
                                    if (openClass.indexOf(item['class_id']) == -1) {
                                      openClass.add(item['class_id']);
                                    } else {
                                      openClass.remove(item['class_id']);
                                    }
                                  });
                                },
                              ),
                              InkWell(
                                onTap: () {
                                  classSelectAll(item, checked);
                                },
                                child: Row(
                                  children: <Widget>[
                                    item['children'].length > 0
                                        ? Checkbox(
                                            value: checked,
                                            onChanged: (v) {
                                              classSelectAll(item, checked);
                                            },
                                          )
                                        : Container(),
                                    Text('${item['class_name']}'),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        AnimatedCrossFade(
                          duration: const Duration(
                            milliseconds: 300,
                          ),
                          firstChild: Container(),
                          secondChild: item['children'] == ''
                              ? Container()
                              : Container(
                                  padding: EdgeInsets.only(left: 60),
                                  child: Column(
                                    children: item['children'].map<Widget>(
                                      (children) {
                                        return InkWell(
                                          onTap: () {
                                            classSelectSingle(children);
                                          },
                                          child: Row(
                                            children: <Widget>[
                                              Checkbox(
                                                value: widget.selectClass.indexOf(children['class_id']) > -1,
                                                onChanged: (v) {
                                                  classSelectSingle(children);
                                                },
                                              ),
                                              Text('${children['class_name']}')
                                            ],
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                          crossFadeState: openClass.indexOf(item['class_id']) == -1
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                        )
                      ],
                    ),
                  );
                },
              ).toList(),
            ),
          )
        ],
      ),
    );
  }
}
