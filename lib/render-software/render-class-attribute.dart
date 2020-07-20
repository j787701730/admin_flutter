import 'package:flutter/material.dart';

class RenderClassAttribute extends StatelessWidget {
  final props;

  RenderClassAttribute(this.props);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${props['param_name']} 模型属性选项'),
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(6),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  child: Text('#'),
                ),
                Expanded(
                  child: Container(
                    child: Text('枚举名称'),
                  ),
                )
              ],
            ),
            color: Color(0xffeeeeee),
          ),
          (props['param_enums'] is List)
              ? Column(
                  children: props['param_enums'].map<Widget>(
                    (item) {
                      return Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xffcccccc),
                            ),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 80,
                              child: Text('${props['param_enums'].indexOf(item) + 1}'),
                            ),
                            Expanded(
                              child: Container(
                                child: Text('$item'),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ).toList(),
                )
              : Container(
                  alignment: Alignment.center,
                  child: Text('无数据'),
                )
        ],
      ),
    );
  }
}
