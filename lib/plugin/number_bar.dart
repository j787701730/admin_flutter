import 'package:admin_flutter/style.dart';
import 'package:flutter/material.dart';

class NumberBar extends StatelessWidget {
  final int count;

  NumberBar({@required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('共 '),
        Text(
          '$count',
          style: TextStyle(color: CFColors.danger),
        ),
        Text(' 记录')
      ],
    );
  }
}
