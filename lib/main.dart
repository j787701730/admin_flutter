import 'package:admin_flutter/cf-provider.dart';
import 'package:admin_flutter/error.dart';
import 'package:admin_flutter/localizations.dart';
import 'package:admin_flutter/my_home_page.dart';
import 'package:admin_flutter/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CFProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeData _buildDarkTheme() {
    final ThemeData base = ThemeData(
      brightness: Brightness.dark,
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      platform: TargetPlatform.iOS,
      textTheme: TextTheme(
        subtitle2: TextStyle(
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
    );
    return base;
  }

  ThemeData _buildLightTheme() {
    final ThemeData base = ThemeData(
      brightness: Brightness.light,
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: Brightness.light,
      ),
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      platform: TargetPlatform.iOS,
      textTheme: TextTheme(
        subtitle2: TextStyle(
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
    );
    return base;
  }

  int themeMode;

  _getThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int themeMode = prefs.getInt('themeMode') ?? 0;
    context.read<CFProvider>().changeThemeMode(themeMode);
  }

  @override
  void initState() {
    super.initState();
    _getThemeMode();
  }

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        context.watch<CFProvider>().colorFilter,
        BlendMode.color,
      ),
      child: MaterialApp(
        title: '后台管理系统',
        themeMode: context.watch<CFProvider>().themeMode,
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
        routes: routes,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          // 自己要补个文件 localizations.dart
          ChineseCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en', 'US'),
          Locale('zh', 'CH'),
        ],
        onUnknownRoute: (RouteSettings settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => ErrorPage(),
        ),
      ),
    );
  }
}
