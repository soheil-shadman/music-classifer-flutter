import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mood_classifer/routs.dart';
import 'package:mood_classifer/widgets/splash-screen.dart';


import 'api/api.dart';
import 'constants.dart';

void main() {
  API.Init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static void gotoPageWithoutBack(BuildContext context, String route) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(route, (Route<dynamic> route) => false);
  }



  static void gotoPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  static void showSnackBar(BuildContext context,
      {String content = "تست", bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor:
          isError ? Constants.COLOR_RED_ERROR : Constants.COLOR_MAIN_DARK,
      content: Text(
        content,
        style: Constants.TEXT_STYLE_WHITE_SMALL_BOLD,
      ),
    ));
  }

  static void disposeSnackBar(
    BuildContext context,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  static void backTo(BuildContext context) {
    Navigator.pop(context);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Classifer',
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("fa", "IR"), // OR Locale('ar', 'AE') OR Other RTL locales
      ],
      locale: const Locale("fa", "IR"),
      theme: ThemeData(
        fontFamily: "iranyekan",
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
      ),
      routes: Routes.routes,
      home: SplashScreen(),
    );
  }
}
