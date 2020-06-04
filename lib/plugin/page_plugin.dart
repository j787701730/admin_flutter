import 'package:admin_flutter/primary_button.dart';
import 'package:flutter/material.dart';

class PagePlugin extends StatelessWidget {
  final int current;
  final int total;
  final int pageSize;
  final Function function;

  PagePlugin({@required this.current, @required this.total, @required this.pageSize, @required this.function});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('第 $current 页'),
        Container(
          width: (total / pageSize).ceil() > 1.0 ? 10 : 0,
        ),
        current > 1
            ? PrimaryButton(
                onPressed: () {
                  function(-1);
                },
                child: Text('上一页'),
              )
            : Container(
                width: 0,
              ),
        Container(
          width: current == 1 || current == (total / pageSize).ceil() ? 0 : 10,
        ),
        current < (total / pageSize).ceil()
            ? PrimaryButton(
                onPressed: () {
                  function(1);
                },
                child: Text('下一页'),
              )
            : Container(
                width: 0,
              )
      ],
    );
  }
}
