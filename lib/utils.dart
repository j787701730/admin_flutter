import 'dart:convert';
import 'dart:io';

import 'package:admin_flutter/login.dart';
import 'package:admin_flutter/style.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

final baseUrl = 'http://192.168.1.213/';

ajaxMini(url, data) {
  Dio dio = Dio();
  return dio.post(
    "$baseUrl$url",
    data: data,
    options: Options(
      contentType: Headers.formUrlEncodedContentType,
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
      },
    ),
  );
}

ajaxSimple(String url, data, Function fun, {Function netError}) async {
  var dio = Dio();
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  CookieJar cookieJar = new PersistCookieJar(dir: tempPath);
  dio.interceptors.add(CookieManager(cookieJar));
  try {
    Response res = await dio.post(
      "$baseUrl$url",
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
        },
      ),
    );
    fun(res.data);
  } on DioError catch (e) {
    if (netError != null) {
      netError(e);
    }
//    print(e);
    Fluttertoast.showToast(
      backgroundColor: CFColors.secondary,
      textColor: CFColors.white,
      msg: '$e',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
    if (e.response != null) {
//        print(e.response.data);
//        print(e.response.headers);
//        print(e.response.request);
//        print(e.response.statusCode);
      //  this.data,
      //  this.headers,
      //  this.request,
      //  this.isRedirect,
      //  this.statusCode,
      //  this.statusMessage,
      //  this.redirects,
      //  this.extra,
    } else {
      // Something happened in setting up or sending the request that triggered an Error
//       print(e.request.connectTimeout);
//       print(e.message);
    }

    // Toast.show('$e', _context, duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
  }
}

ajax(String url, data, bool toast, Function fun, Function fun2, BuildContext _context, {Function netError}) async {
  var dio = Dio();
  //  var cookieJar = CookieJar();
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  CookieJar cookieJar = new PersistCookieJar(dir: tempPath);
  //  print(cookieJar.loadForRequest(Uri.parse(baseUrl)));
  dio.interceptors.add(CookieManager(cookieJar));
  try {
    Response res = await dio.post(
      "$baseUrl$url",
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
        },
      ),
    );
    if (res.data['err_code'] == 0) {
      if (toast == true) {
        Fluttertoast.showToast(
          backgroundColor: CFColors.secondary,
          textColor: CFColors.white,
          msg: res.data['err_msg'] is String ? res.data['err_msg'] : '请求成功',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
      fun(res.data);
    } else if ('${res.data['err_code']}' == '88888') {
      //      if (toast == true) {
      //        Toast.show('${res.data['err_code']}: ${res.data['err_msg']}', _context,
      //            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      //      }
      //      Navigator.pushNamed(_context, '/login').then((backVal) {
      //        print('登录返回信息: $backVal');
      //        if (backVal != null) {
      //          ajax(url, data, toast, fun, fun2, _context);
      //        }
      //      });
      Navigator.pushAndRemoveUntil(
        _context,
        MaterialPageRoute(
          builder: (context) => Login(),
        ),
        (route) => route == null,
      );
    } else {
      if (toast == true) {
        Fluttertoast.showToast(
          backgroundColor: CFColors.secondary,
          textColor: CFColors.white,
          msg: '${res.data['err_code']}: ${res.data['err_msg']}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
      fun2();
    }
  } on DioError catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (netError != null) {
      netError(e);
    }
    if (e.response != null) {
      //  print(e.response.data);
      //  print(e.response.headers);
      //  print(e.response.request);
      //  print(e.response.statusCode);
      //  this.data,
      //  this.headers,
      //  this.request,
      //  this.isRedirect,
      //  this.statusCode,
      //  this.statusMessage,
      //  this.redirects,
      //  this.extra,
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      // print(e.request);
      // print(e.message);
    }
    // print(e);
    Fluttertoast.showToast(
      backgroundColor: CFColors.secondary,
      textColor: CFColors.white,
      msg: '$e',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }
}

jsonMsg(data) {
  String str = '';
  try {
    var obj = jsonDecode('$data'.replaceAll(RegExp(r"\n", multiLine: true), ''));
    if (obj.runtimeType.toString() != 'String') {
      str += '<div><i>{</i></div><div>';
      if (obj.runtimeType.toString().substring(0, 4) == 'List') {
        for (var o in obj) {
          str += '<p>';
          str += '<em>"<span>${obj.indexOf(o)}'
              '</span>"</em><span> : </span><strong>'
              '${jsonMsg(jsonEncode(obj[obj.indexOf(o)]))}'
              '</strong>';
          str += '</p>';
        }
      } else {
        for (var key in obj.keys) {
          str += '<p>';
          str += '<em>"<span>$key'
              '</span>"</em><span> : </span><strong>'
              '${jsonMsg(jsonEncode(obj[key]))}'
              '</strong>';
          str += '</p>';
        }
      }
      str += '</div><div><i>},</i></div>';
    } else {
      str += '<span><strong>"$obj"</strong><i>,</i></span>';
    }
  } catch (error) {
    str = data;
  }
  return str;
}

// 格式化文件大小
fileFormatSize(size) {
  int i;
  size = double.parse('$size');
  var unit = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  for (i = 0; i < unit.length && size >= 1024; i++) {
    size /= 1024;
  }
//  return (math.round(size * 100) / 100 || 0) + unit[i];
  return '${(double.tryParse('$size') * 100).round() / 100}${unit[i]}';
}

///  在build 初始化 SizeFit.initialize(context);  使用 SizeFit.setPx(200),
class SizeFit {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double rpx;
  static double px;

  static void initialize(BuildContext context, {double standardWidth = 750}) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    rpx = screenWidth / standardWidth;
    px = screenWidth / standardWidth * 2;
  }

  // 按照px来设置
  static double setPx(double size) {
    return SizeFit.rpx * size * 2;
  }

  // 按照rpx来设置
  static double setRpx(double size) {
    return SizeFit.rpx * size;
  }
}

enum NumberType { float, int }

clearNoInt(String value) {
  if (value == null || value.trim() == '') {
    return '';
  }
  RegExp intReg = new RegExp(r"\d");
  Iterable<Match> matches = intReg.allMatches(value);
  List arr = [];
  for (Match m in matches) {
    arr.add(m.group(0));
  }
  String val = arr.join('');
  return val.isEmpty ? '' : '${int.parse(val)}';
}

clearNoNum(String value, {int decimal: 2, String sign: '+'}) {
  if (value == null || value.trim() == '') {
    return '';
  }
  RegExp intReg = new RegExp(r"\d|\.|\-");
  Iterable<Match> matches = intReg.allMatches(value);
  List arr = [];
  for (Match m in matches) {
    arr.add(m.group(0));
  }
  if (arr.isEmpty) {
    return '';
  }
  int count = 0;
  List returnArr = [];
  for (var i = 0; i < arr.length; ++i) {
    if (returnArr.isEmpty && sign == '-' && arr[i] == '-') {
      returnArr.add('-');
    } else if (arr[i] != '-') {
      if (arr[i] == '.') {
        if (returnArr.contains('-') && returnArr.length > 1 && !returnArr.contains('.')) {
          returnArr.add('.');
        } else if (!returnArr.contains('-') && returnArr.length > 0 && !returnArr.contains('.')) {
          returnArr.add('.');
        }
      } else {
        if (returnArr.contains('.') && count < decimal && arr[i] != '.') {
          returnArr.add(arr[i]);
          count += 1;
        } else if (!returnArr.contains('.')) {
          returnArr.add(arr[i]);
        }
      }
    }
  }

  if (returnArr.isEmpty) {
    return '';
  } else if (returnArr.join('') == '-') {
    return '-';
  }
  List newArr = returnArr.join('').split('.');
  String preSign = '${newArr[0]}';
  String str = '${int.parse(newArr[0])}';
  if (preSign.contains('-') && str == '0') {
    str = '-$str';
  }
  if (newArr.length == 2) {
    str = '$str.${newArr[1]}';
  }
  return str;
}
