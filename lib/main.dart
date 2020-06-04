import 'dart:io';

import 'package:admin_flutter/cf-provider.dart';
import 'package:admin_flutter/error.dart';
import 'package:admin_flutter/localizations.dart';
import 'package:admin_flutter/my_home_page.dart';
import 'package:admin_flutter/routes.dart';
import 'package:admin_flutter/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
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
        bodyText2: TextStyle(
          fontSize: 14,
        ),
        button: TextStyle(
          fontSize: 14,
        ),
        subtitle1: TextStyle(
          // listtitle
          fontSize: 14,
        ),
      ),
      buttonTheme: ButtonThemeData(
        minWidth: 44,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color.fromARGB(55, 255, 255, 255),
        foregroundColor: DarkColor.text,
      ),
      appBarTheme: AppBarTheme(
        textTheme: TextTheme(
          headline6: TextStyle(
            fontSize: CFFontSize.topTitle,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          fontSize: 14,
        ),
        focusedBorder: OutlineInputBorder(
//          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: DarkColor.border),
        ),
        prefixStyle: TextStyle(
          color: DarkColor.text,
          backgroundColor: DarkColor.text,
        ),
        suffixStyle: TextStyle(
          color: DarkColor.text,
          backgroundColor: DarkColor.text,
        ),
      ),
      dialogTheme: DialogTheme(
        titleTextStyle: TextStyle(
          fontSize: CFFontSize.title,
          color: DarkColor.title,
        ),
        contentTextStyle: TextStyle(
          fontSize: CFFontSize.content,
          color: DarkColor.title,
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
        bodyText2: TextStyle(
          fontSize: 14,
        ),
        button: TextStyle(
          fontSize: 14,
        ),
        subtitle1: TextStyle(
          // listtitle
          fontSize: 14,
        ),
      ),
      buttonTheme: ButtonThemeData(
        minWidth: 44,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color.fromARGB(55, 0, 0, 0),
      ),
      appBarTheme: AppBarTheme(
        textTheme: TextTheme(
          headline6: TextStyle(
            fontSize: CFFontSize.topTitle,
          ),
        ),
        elevation: 1,
        color: Colors.blue,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          fontSize: 14,
        ),
      ),
      dialogTheme: DialogTheme(
        titleTextStyle: TextStyle(
          fontSize: CFFontSize.title,
          color: CFColors.text,
        ),
        contentTextStyle: TextStyle(
          fontSize: CFFontSize.content,
          color: LightColor.title,
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
