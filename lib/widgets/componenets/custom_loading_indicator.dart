import 'package:flutter/material.dart';

import '../../constants.dart';

class CustomLoadingIndicator extends StatelessWidget {
  double height;
  double width;
  double strokeWidth;
  Color indicatorColor;

  CustomLoadingIndicator(
      {Key? key,
      this.height = 20,
      this.width = 20,
      this.strokeWidth = 2.5,
      this.indicatorColor = Constants.COLOR_WHITE_MAIN})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
        strokeWidth: strokeWidth,
      ),
    );
  }
}
