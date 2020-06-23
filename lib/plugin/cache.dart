import 'dart:convert';
import 'package:admin_flutter/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cache {
  String key;
  int expire;

  Cache(String key, {int expire: 3600}) {
    this.key = key;
    this.expire = expire * 1000;
  }

  _setData(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  set(value) {
    int currentTime = new DateTime.now().millisecondsSinceEpoch;
    String cache = jsonEncode({'data': value, 'expire': currentTime});
    _setData(cache);
  }

  getData(url, data) async {
    return ajaxMini(url, data);
  }

  get(url, params) async {
    var val = await _getData();
    var cache = val == null ? null : jsonDecode(val);
    if (cache == null ||
        cache['data'] == null ||
        cache['expire'] == null ||
        new DateTime.now().millisecondsSinceEpoch - cache['expire'] > this.expire) {
      var res = await getData(url, params);
      this.set(res.data);
      return res.data;
    }
    return cache['data'];
  }
}
