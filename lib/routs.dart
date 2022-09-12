import 'package:flutter/material.dart';

import 'widgets/home-page.dart';

class Routes {
  static const String ROOT = '/';
  static const String HOME = '/home';
  static const String LOGIN = '/login';
  static const String SIGNUP = '/signup';
  static const String MAIN_NAVIGATION = '/main-navigation';
  static const String EXPLORE = '/explore';
  static const String PROFILE = '/profile';

  static final Map<String, WidgetBuilder> routes = {
    // ROOT: (context) => LandingPage(),
    HOME: (context) => HomePage(),
    // CHOOSE_AUTH: (context) => ChooseAuth(),
    // LOGIN: (context) => Login(),
    // SIGNUP: (context) => Signup(),
    // MAIN_NAVIGATION: (context) => MainNavigation(),
    // EXPLORE: (context) => ExploreView(),
    // PROFILE: (context) => ProfilePage.withUserName("null"),
  };
}