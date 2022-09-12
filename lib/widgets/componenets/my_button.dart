import 'package:flutter/material.dart';
import 'package:mood_classifer/constants.dart';
import 'package:mood_classifer/widgets/componenets/custom_loading_indicator.dart';

class MyButton extends StatelessWidget {
  Function callBack;

  bool isLoading;

  String buttonText;
  String? icon;
  TextStyle buttonTextStyle;

  double width;
  Color buttonColor;
  Color overlayColor;
  Color indicatorColor;

  double height;

  MyButton(
      {required this.callBack,
      this.isLoading = false,
      this.buttonText = "تست",
      this.icon,
      this.buttonTextStyle = Constants.TEXT_STYLE_WHITE_MEDIUM_BOLD,
      this.buttonColor = Constants.COLOR_MAIN_DARK,
      this.overlayColor = Constants.COLOR_BUTTON_OVERLAY,
      this.width = 200,
      this.indicatorColor = Constants.COLOR_WHITE_MAIN,
      this.height = 45});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: ElevatedButton(
          onPressed: () {
            if (!isLoading) {
              callBack();
            }
          },
          style: ButtonStyle(
            shadowColor: MaterialStateProperty.all<Color>(
                Constants.COLOR_MAIN_DARK.withOpacity(0.75)),
            overlayColor: MaterialStateProperty.all<Color>(overlayColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.APP_ROUNDNESS),
              //    side: BorderSide(color: Colors.red)
            )),
            backgroundColor: MaterialStateProperty.all(buttonColor),
          ),
          child: !isLoading
              ? Text(
                  buttonText,
                  style: buttonTextStyle,
                )
              : CustomLoadingIndicator(indicatorColor: indicatorColor,)),
    );
  }
}
