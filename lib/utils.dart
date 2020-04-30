import 'dart:convert';
import 'dart:io';

import 'package:admin_flutter/login.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

final baseUrl = 'http://192.168.1.213/';

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
          msg: '${res.data['err_msg']}'.length > 15 ? '成功' : '${res.data['err_msg']}',
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
