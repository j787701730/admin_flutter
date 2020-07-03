import 'package:flutter/material.dart';
import 'package:admin_flutter/utils.dart';
import 'package:admin_flutter/style.dart';

class ErrorPage extends StatefulWidget {
  @override
  _ErrorPageState createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '页面找不到了',
          style: TextStyle(fontSize: CFFontSize.topTitle),
        ),
      ),
      body: Center(
        child: Image.network('${baseUrl}Public/images/error/err_page.png'),
      ),
    );
  }
}
