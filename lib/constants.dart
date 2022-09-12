import 'package:flutter/material.dart';

class Constants {
  // Safe Area Padding
  static double SAFE_AREA_PADDING = 0;
  static const String SAVE_AUDIO_PATH = 'raw_recorded_data';
  static String SAVE_AUDIO_PATH_FOLDER = '';
  static String LOCAL_HOST = '192.168.1.2:8080';
  static String REAL_HOST = '194.59.170.180:8080';

  // Assets
  static const String REEL_PLACE_HOLDER_IMAGE =
      'assets/images/reel-place-holder.png';
  static const String HASHTAG_IMAGE =
      'assets/images/hashtag-image.png';
  static const String NORC_IMAGE =
      'assets/images/NORC_TRAN.png';
  // Text Size
  static const double VERY_SMALL_SMALL_TEXT_FONT_SIZE = 11;
  static const double SMALL_TEXT_FONT_SIZE = 13;
  static const double MEDIUM_TEXT_FONT_SIZE = 15;
  static const double LARGE_TEXT_FONT_SIZE = 18;

  // Roundness
  static const double IMAGE_ROUNDNESS = 3;
  static const double APP_ROUNDNESS = 5;
  static const double TEXT_INPUT_ROUNDNESS = 10;
  static const double MAX_ROUNDNESS = 100;

  // STRINGS
  static const String SERVER_ERROR=   "خطا در دسترسی به سرور";
  static const String MODEL_ERROR=   "خطا در بارگزاری مدل";
  static const String CONNECTION_ERROR=   "اینترنت وصل نیست";

  // Validator
  static String? validatePassword(String? value) {
    if(value==null){
      return null;
    }
    if (!(value.length > 4) && value.isNotEmpty) {
      return "رمز عبور حداقل باید ۴ حرف باشد";
    }
    else if(value.isEmpty){
      return "رمز عبور نباید خالی باشد";
    }
  }
  static String? validatePhoneNumber(String? value) {
    if(value==null){
      return null;
    }
    if (!(value.length > 10) && value.isNotEmpty) {
      return "شماره تلفن باید ۱۱ عدد باشد";
    }
    else if(value.isEmpty){
      return "شماره تلفن نباید خالی باشد";
    }
  }
  static String? validateEmail(String? value) {
    if(value==null){
      return null;
    }
    if (!(value.length > 4) && value.isNotEmpty&&!value.contains('@')) {
      return "فرمت ایمل غلط است";
    }
    else if(value.isEmpty){
      return "ایمل نباید خالی باشد";
    }
  }
  static String? validateTypical(String? value) {
    if(value==null){
      return null;
    }
    if (value.isEmpty) {
      return "اینجا نباید خالی باشد";
    }

  }
  static String? validateUsername(String? value) {
    if(value==null){
      return null;
    }
    if (value.isEmpty) {
      return "نام کاربری نباید خالی باشد";
    }

  }
  // TextStyle
  static const TextStyle TEXT_STYLE_BLACK_SMALL = TextStyle(
      color: COLOR_MAIN_DARK,
      fontSize: SMALL_TEXT_FONT_SIZE,
      fontWeight: FontWeight.normal,
      fontFamily: 'iranyekan');

  static const TextStyle TEXT_STYLE_BLACK_MEDIUM = TextStyle(
      color: COLOR_MAIN_DARK,
      fontSize: MEDIUM_TEXT_FONT_SIZE,
      fontWeight: FontWeight.normal,
      fontFamily: 'iranyekan');

  static const TextStyle TEXT_STYLE_BLACK_TITLE = TextStyle(
      color: COLOR_MAIN_DARK,
      fontSize: LARGE_TEXT_FONT_SIZE,
      fontWeight: FontWeight.normal,
      fontFamily: 'iranyekan');

  static const TextStyle TEXT_STYLE_BLACK_SMALL_BOLD = TextStyle(
      color: COLOR_MAIN_DARK,
      fontSize: SMALL_TEXT_FONT_SIZE,
      fontWeight: FontWeight.bold,
      fontFamily: 'iranyekan');

  static const TextStyle TEXT_STYLE_BLACK_MEDIUM_BOLD = TextStyle(
      color: COLOR_MAIN_DARK,
      fontSize: MEDIUM_TEXT_FONT_SIZE,
      fontWeight: FontWeight.bold,
      fontFamily: 'iranyekan');

  static const TextStyle TEXT_STYLE_BLACK_TITLE_BOLD = TextStyle(
      color: COLOR_MAIN_DARK,
      fontSize: LARGE_TEXT_FONT_SIZE,
      fontWeight: FontWeight.bold,
      fontFamily: 'iranyekan');

  static const TextStyle TEXT_STYLE_WHITE_SMALL = TextStyle(
      color: COLOR_WHITE_MAIN,
      fontSize: SMALL_TEXT_FONT_SIZE,
      fontWeight: FontWeight.normal,
      fontFamily: 'iranyekan');

  static const TextStyle TEXT_STYLE_WHITE_MEDIUM = TextStyle(
      color: COLOR_WHITE_MAIN,
      fontSize: MEDIUM_TEXT_FONT_SIZE,
      fontWeight: FontWeight.normal,
      fontFamily: 'iranyekan');

  static const TextStyle TEXT_STYLE_WHITE_TITLE = TextStyle(
      color: COLOR_WHITE_MAIN,
      fontSize: LARGE_TEXT_FONT_SIZE,
      fontWeight: FontWeight.normal,
      fontFamily: 'iranyekan');


  static const TextStyle TEXT_STYLE_WHITE_SMALL_BOLD = TextStyle(
      color: COLOR_WHITE_MAIN,
      fontSize: SMALL_TEXT_FONT_SIZE,
      fontWeight: FontWeight.bold,
      fontFamily: 'iranyekan');

  static const TextStyle TEXT_STYLE_WHITE_MEDIUM_BOLD = TextStyle(
      color: COLOR_WHITE_MAIN,
      fontSize: MEDIUM_TEXT_FONT_SIZE,
      fontWeight: FontWeight.bold,
      fontFamily: 'iranyekan');
  static const TextStyle TEXT_STYLE_WHITE_TITLE_BOLD = TextStyle(
      color: COLOR_WHITE_MAIN,
      fontSize: LARGE_TEXT_FONT_SIZE,
      fontWeight: FontWeight.bold,
      fontFamily: 'iranyekan');

  static const TextStyle TEXT_STYLE_GRAY_VERY_SMALL = TextStyle(
      color: COLOR_BUTTON_OVERLAY,
      fontSize: VERY_SMALL_SMALL_TEXT_FONT_SIZE,
      fontWeight: FontWeight.normal,
      fontFamily: 'iranyekan');
  static const TextStyle TEXT_STYLE_GRAY_VERY_SMALL_BOLD = TextStyle(
      color: COLOR_BUTTON_OVERLAY,
      fontSize: VERY_SMALL_SMALL_TEXT_FONT_SIZE,
      fontWeight: FontWeight.bold,
      fontFamily: 'iranyekan');
  static const TextStyle TEXT_STYLE_GRAY_SMALL_BOLD = TextStyle(
      color: COLOR_BUTTON_OVERLAY,
      fontSize: SMALL_TEXT_FONT_SIZE,
      fontWeight: FontWeight.bold,
      fontFamily: 'iranyekan');
  static const TextStyle TEXT_STYLE_GRAY_SMALL_BOLD_UNDERLINED = TextStyle(
      color: COLOR_BUTTON_OVERLAY,
      fontSize: SMALL_TEXT_FONT_SIZE,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
      fontFamily: 'iranyekan');
  static const TextStyle TEXT_STYLE_ERROR_VERY_SMALL = TextStyle(
      color: COLOR_RED_ERROR,
      fontSize: VERY_SMALL_SMALL_TEXT_FONT_SIZE,
      fontWeight: FontWeight.normal,
      fontFamily: 'iranyekan');
  static const TextStyle TEXT_STYLE_ERROR_SMALL = TextStyle(
      color: COLOR_RED_ERROR,
      fontSize: SMALL_TEXT_FONT_SIZE,
      fontWeight: FontWeight.normal,
      fontFamily: 'iranyekan');
  static const TextStyle TEXT_STYLE_ERROR_MEDIUM = TextStyle(
      color: COLOR_RED_ERROR,
      fontSize: MEDIUM_TEXT_FONT_SIZE,
      fontWeight: FontWeight.normal,
      fontFamily: 'iranyekan');
  static const TextStyle TEXT_STYLE_LIGHT_GRAY_VERY_SMALL = TextStyle(
      color: COLOR_LIGHT_GRAY,
      fontSize: VERY_SMALL_SMALL_TEXT_FONT_SIZE,
      fontWeight: FontWeight.normal,
      fontFamily: 'iranyekan');
  static const TextStyle TEXT_STYLE_LIGHT_GRAY_VERY_SMALL_BOLD = TextStyle(
      color: COLOR_LIGHT_GRAY,
      fontSize: VERY_SMALL_SMALL_TEXT_FONT_SIZE,
      fontWeight: FontWeight.bold,
      fontFamily: 'iranyekan');
  static const TextStyle TEXT_STYLE_LIGHT_GRAY_SMALL_BOLD = TextStyle(
      color: COLOR_LIGHT_GRAY,
      fontSize: SMALL_TEXT_FONT_SIZE,
      fontWeight: FontWeight.bold,
      fontFamily: 'iranyekan');
  static const TextStyle TEXT_STYLE_LIGHT_GRAY_SMALL_BOLD_UNDERLINED = TextStyle(
      color: COLOR_LIGHT_GRAY,
      fontSize: SMALL_TEXT_FONT_SIZE,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
      fontFamily: 'iranyekan');

  static const TextStyle TEXT_STYLE_BLUE_MOOD_SMALL = TextStyle(
      color: COLOR_BLUE,
      fontSize: SMALL_TEXT_FONT_SIZE,
      fontWeight: FontWeight.bold,
      fontFamily: 'iranyekan');
  static const TextStyle TEXT_STYLE_GREEN_MOOD_SMALL = TextStyle(
      color: COLOR_GREE,
      fontSize: SMALL_TEXT_FONT_SIZE,
      fontWeight: FontWeight.bold,
      fontFamily: 'iranyekan');


  // Colors
  static const Color COLOR_MAIN_DARK = Color.fromRGBO(0, 0, 0, 1);
  static const Color COLOR_BUTTON_OVERLAY = Color.fromRGBO(58, 58, 58, 1);
  static const Color COLOR_NAVIGATION_UNSELECTED = Color.fromRGBO(120, 120, 120, 1);
  static const Color COLOR_LIGHT_GRAY = Color.fromRGBO(160, 160, 160, 1);
  static const Color COLOR_WHITE_MAIN = Color.fromRGBO(255, 255, 255, 1);
  static const Color COLOR_RED_ERROR = Color.fromRGBO(175, 0, 0, 1);
  static const Color COLOR_BACKGROUND = Color.fromRGBO(29, 34, 38, 1);
  static const Color COLOR_BLUE = Colors.blueAccent;
  static const Color COLOR_GREE = Colors.green;


}