import 'package:admin_flutter/cf-provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends StatefulWidget {
  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  int type;

  _setThemeMode(type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', type);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    type = context.watch<CFProvider>().themeMode == ThemeMode.dark ? 1 : 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: <Widget>[
          ListTile(
            title: Text('${context.watch<CFProvider>().themeMode == ThemeMode.dark ? '浅色模式' : '深色模式'}'),
            onTap: () {
              context.read<CFProvider>().changeThemeMode(type == 1 ? 0 : 1);
              _setThemeMode(type == 1 ? 0 : 1);
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
