import 'package:admin_flutter/primary_button.dart';
import 'package:flutter/material.dart';

class IndustryClassSelect extends StatefulWidget {
  final selectClass;
  final classData;

  IndustryClassSelect({this.selectClass, this.classData});

  @override
  _IndustryClassSelectState createState() => _IndustryClassSelectState();
}

class _IndustryClassSelectState extends State<IndustryClassSelect> {
  List openClass = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('行业分类'),
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
                onPressed: () {},
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
                  return Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.keyboard_arrow_down),
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
                                onTap: () {},
                                child: Row(
                                  children: <Widget>[
                                    Checkbox(
                                      value: true,
                                      onChanged: (v) {},
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
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
                                            setState(() {
                                              if (widget.selectClass.indexOf(children['class_id']) == -1) {
                                                widget.selectClass.add(children['class_id']);
                                              } else {
                                                widget.selectClass.remove(children['class_id']);
                                              }
                                            });
                                          },
                                          child: Row(
                                            children: <Widget>[
                                              Checkbox(
                                                value: widget.selectClass.indexOf(children['class_id']) > -1,
                                                onChanged: (v) {},
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
